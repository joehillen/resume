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
      <a id="pdf" href="$(get links.Resume)joehillen-resume.pdf">PDF</a>
    </header>
    <main>
      <section id="info">
          <img src="https://joe.h9d.org/me.jpg" alt="$(get name)" />
          <div id="contact">
            <a href="mailto:$(get email)">$(get email)</a><br>
            $(get location)<br>
            <ul class="noprint">
              $(
  link() {
    cat <<LINK
                    <li>
                      <a class="noprint link" href="$(get links.$1)">$1</a>
                    </li>
LINK
  }

  link Homepage
  link GitHub
  link LinkedIn
  link Keybase
)
            </ul>
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
      <section id="links" class="print">
        <ul>
          <li>$(get "links.Resume")joehillen-resume.pdf</li>
          $(get 'links | keys[]' | while read -r link; do
  echo "<li>$(get "links.$link")</li>"
done)
        </ul>
      </section>
    </main>
  </body>

</html>
EOF
