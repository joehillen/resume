#!/bin/bash -e

source include.sh

function wrap() {
  sed 's/$/\n/' | fold -w 78 -s | trim | sed '${/^$/d}'

}

function job_md() {
  local path="$1"

  function job() {
    get "$path.$*"
  }

  cat <<EOL
### $(job title) @ $(job company.name) ($(job start) - $(job end))$(
    [[ $(job 'description') ]] && {
      echo
      echo
      job description | wrap | sed 's/^/  /'
    }
    [[ $(job 'accomplishments | length') -gt 0 ]] && {
      [[ $(job 'description') ]] || echo
      echo
    }
    job 'accomplishments[]' | while read -r line; do
      echo -n "- $line" | wrap
    done
  )

EOL
}

cat <<EOF >README.md
---
title: Resume - $(get name)
date: $(date -I)
---

*PDF version available [here]($PDF)*

$(get email)  
$(get location)

$(get about | wrap)

## Links

$(
  yq -crM '.links | .[] | .url' data.yaml | while read -r url; do
    echo "- <$url>"
  done
)

## History

$(for job in $(get 'history | keys | .[]'); do
  job_md "history[$job]"
  for client in $(get "history[$job].clients | keys[]"); do
    echo -n '#'
    job_md "history[$job].clients[$client]"
  done
done)

## Education

$(edu degree) ($(edu focus))  
$(edu school)  
Graduated: $(edu graduated)  
EOF

check README.md
pandoc --standalone --template README.template.html -o README.html README.md
