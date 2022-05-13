#!/bin/bash -e

# This repo uses Bash as a template language to fill in the data index.html and README.md.
# index.html is then used to generate the PDF version.

if [[ $1 = install ]]; then
    INSTALL=true
fi

function loop() {
  while read -r line; do
    "$@" "$line"
  done
}

function trim() {
  local s
  local arg
  local left
  local right

  # TODO getopt
  while [[ $1 ]]; do
    case "$1" in
    -l | --left)
      left=true
      ;;
    -r | --right)
      right=true
      ;;
    --)
      shift
      arg="$*"
      break
      ;;
    *)
      arg="$*"
      break
      ;;
    esac
    shift
  done

  if [[ $left != true && $right != true ]]; then
    left=true
    right=true
  fi

  # if no arguments, read from STDIN
  while [[ $arg ]] || IFS=$'\n' read -r s; do
    # XXX: $arg is to avoid defining a function for this block
    [[ $arg ]] && s="$arg"

    # remove leading whitespace characters
    if [[ $left = true ]]; then
      s="${s#"${s%%[![:space:]]*}"}"
    fi

    # remove trailing whitespace characters
    if [[ $right = true ]]; then
      s="${s%"${s##*[![:space:]]}"}"
    fi

    printf '%s\n' "$s"

    [[ $arg ]] && break
  done
}

function get() {
  yq -r ".$1 // empty" data.yaml
}

function job_html() {
  local path="$1"

  function job() {
    get "$path.$*"
  }

  cat <<JOB
    <div class="job nobreak">
      <div class="jobtitle">
        <span class="jobtitle-text">
          <b>$(job title)</b> @ $(
    if [[ $(job company.url) != null ]]; then
      echo "<a href=\"$(job company.url)\">$(job company.name)</a>"
    else
      job company.name
    fi
  )</span>
        <span class="dates"><i>$(job start) - $(job end)</i></span>
      </div>
      <div class="description">
        $([[ $(job description) ]] && echo "<p>$(job description)</p>")
JOB

  n_acc=$(job 'accomplishments | length')
  [[ $n_acc -gt 0 ]] && echo '<ul>'
  job 'accomplishments[]' | while read -r line; do
    echo "<li>${line}</li>"
  done
  [[ $n_acc -gt 0 ]] && echo '</ul>'
  echo "</div>" # description
  echo "</div>" # job
}

function edu() {
  get "education.$*"
}

function check() {
  local path="$1"
  ! grep -q null "$path" || {
    echo "$path contains null values"
    exit 1
  }
}

# HTML

echo "++ rendering index.html"
eval 'cat <<EOF >index.html
'"$(<index.tmpl.html)"'
EOF'

check index.html

prettier --write index.html

# Markdown

function job_md() {
  local path="$1"

  function job() {
    get "$path.$*"
  }

  cat <<EOL
### $(job title) @ $(job company.name)

$(job start) - $(job end)$(
    [[ $(job 'description') ]] && {
      echo
      echo
      job description
    }
    [[ $(job 'accomplishments | length') -gt 0 ]] && {
      [[ $(job 'description') ]] || echo
      echo
    }
    job 'accomplishments[]' | while read -r line; do
      echo "- $line" | fold -w 78 -s | trim | sed 's/$/  /;2,$s/^/  /'
    done
  )

EOL
}

echo "++ rendering README.md"
eval 'cat <<EOF >README.md
'"$(<README.tmpl.md)"'
EOF'

check README.md

# PDF

echo "++ rendering joehillen-resume.pdf"

MARGIN=50px
QT_QPA_PLATFORM=offscreen wkhtmltopdf --allow . --title "Resume - Joe Hillenbrand" -T $MARGIN -R $MARGIN -B $MARGIN -L $MARGIN index.html joehillen-resume.pdf

if [[ $INSTALL ]]; then
    cp -r css/ index.html joehillen-resume.pdf /var/www/resume/
fi

