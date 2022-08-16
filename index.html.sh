#!/bin/bash -e

source include.sh

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

cat <<EOF >index.html
<!DOCTYPE html>
<html lang="en">

  <head>
    <title>Resume - $(get name)</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/normalize.css" type="text/css" />
    <link rel="stylesheet" href="css/index.css" type="text/css" />
  </head>

  <body>
    <header>
      <h1>$(get name)</h1>
      <a id="pdf" class="noprint" href="joehillen-resume.pdf">PDF</a>
    </header>
    <main>
      <section id="info">
          <div id="contact">
            <div>
              <p>
              <a href="mailto:$(get email)">$(get email)</a><br>
              $(get location)
              </p>
              <ul>
              $(
  yq -crM ".links | .[]" data.yaml | while read -r link; do
    url=$(echo "$link" | jq -r .url)
    echo "<li><span class=\"noprint\"><a href=\"$url\">$(echo "$link" | jq -r .name)</a></span><span class=\"print\">$url</span></li>"
  done
)
              </ul>
            </div>
          </div>
      </section>
      <section id="about">
          $(get about | sed 's/^/<p>/; s/$/<\/p>/')
      </section>
      <section id="history">
        $(for job in $(get 'history | keys[]'); do
  job_html "history[$job]"

  n_clients=$(get "history[$job].clients | length")
  [[ n_clients -gt 0 ]] && echo '<div class="clients">'
  for client in $(get "history[$job].clients | keys[]"); do
    job_html "history[$job].clients[$client]"
  done
  [[ n_clients -gt 0 ]] && echo '</div>'
done)
      </section>
      <section id="education">
        <b>$(get education.degree)</b>
        <br>
        <i>$(edu focus)</i>
        <br>
        $(get education.school)
        <br>
        $(get education.graduated)
      </section>
    </main>
    <footer>
      <p id="date">Updated: $(date -I)</p>
    </footer>

  </body>

</html>
EOF
