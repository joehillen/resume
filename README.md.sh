#!/bin/bash -e

source include.sh

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

cat <<EOF >README.md
---
date: $(date -I)
---

# Resume - $(get name)

*PDF version available [here]($(get links.Resume)joehillen-resume.pdf)*

$(get email)  
$(get location)

$(get about | sed 's/$/\n/' | fold -w 78 -s | trim | sed 's/$/  /g')
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

## Links

- <$(get links.Resume)>
- <$(get links.GitHub)>
- <$(get links.LinkedIn)>
- <$(get links.Keybase)>
EOF

check README.md
pandoc --standalone --template README.template.html -o README.html README.md
