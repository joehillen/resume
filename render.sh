#!/bin/bash -e

# This repo uses Bash as a template language to fill in the data index.html and README.md.
# index.html is then used to generate the PDF version.

if [[ $1 = install ]]; then
  INSTALL=true
fi

if [[ $1 = force ]]; then
  FORCE=true
fi

# HTML

if [[ $FORCE || include.sh -nt index.html || index.html.sh -nt index.html || data.yaml -nt index.html ]]; then
  echo "Generating index.html..."
  ./index.html.sh
fi

# Markdown

if [[ $FORCE || README.template.html -nt README.html || include.sh -nt README.md || README.md.sh -nt README.md || data.yaml -nt README.md ]]; then
  echo "Generating README.md..."
  ./README.md.sh
fi

# PDF

if [[ $FORCE || index.html -nt joehillen-resume.pdf ]]; then
  echo "++ rendering joehillen-resume.pdf"
  MARGIN=50px
  QT_QPA_PLATFORM=offscreen wkhtmltopdf --allow . --title "Resume - Joe Hillenbrand" -T $MARGIN -R $MARGIN -B $MARGIN -L $MARGIN index.html joehillen-resume.pdf
fi

if [[ $INSTALL ]]; then
  cp -r css/ index.html joehillen-resume.pdf README.html README.md /var/www/resume/
fi
