#!/bin/sh

if [ $# -ne 3 ]; then
   echo "Usage: $(basename "$0") name title link" >&2
   exit 1
fi

name="$1"
title="$2"
link="$3"

groff -mandoc -Thtml | sed \
   -e '/<!DOCTYPE[^$]\+$/d' \
   -e '/"http:[^$]\+$/d' \
   -e '1,19d' \
   -e "s/<h1 align=\"center\">${name}/<h1>${title}/" \
   -e '/<h1/a<hr class="bcc-hr">'  \
   -e '/^<\/body>$/d' \
   -e '/^<\/html>$/d' \
   -e 's/<p/<p class="bcc-p"/g' \
   -e 's/<pre/<pre class="bcc-pre"/g' \
   -e 's/<h2/<h2 class="bcc-h2"/g' \
   -e 's/<hr>/<hr class="bcc-hr">/g' \
   -e 's/<a/<a class="bcc-a"/g' | sed \
   -e "/#COPYRIGHT/a<a align='center' class='bcc-link' target='_blank' href='${link}'>Source Code<\/a>" \
   -e "\$a<p class=\"unimp\">Generated using groff on $(date -u +"%F %T (UTC)")</p>"
