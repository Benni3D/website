#!/bin/sh

link="https://github.com/riscygeek/bcc"

groff -mandoc -Thtml ".cache/bcc.1" | sed \
   -e '/<!DOCTYPE[^$]\+$/d' \
   -e '/"http:[^$]\+$/d' \
   -e '1,19d' \
   -e 's/<h1 align="center">bcc/<h1>Brainlet C Compiler/' \
   -e '/<h1/a<hr class="bcc-hr"><!--insert-->'  \
   -e '/^<\/body>$/d' \
   -e '/^<\/html>$/d' \
   -e 's/<p/<p class="bcc-p"/g' \
   -e 's/<pre/<pre class="bcc-pre"/g' \
   -e 's/<h2/<h2 class="bcc-h2"/g' \
   -e 's/<hr>/<hr class="bcc-hr">/g' \
   -e 's/<a/<a class="bcc-a"/g' | sed \
   -e '/<!--insert-->/i<table width="100%"><tr><td width="80%">' \
   -e '/#COPYRIGHT/a<\/td><td>' \
   -e '/#COPYRIGHT/a<img width="100%" src="img/bcc.png"><br>' \
   -e "/#COPYRIGHT/a<a align='center' class='bcc-link' target='_blank' href='${link}'>GitHub<\/a>" \
   -e '/#COPYRIGHT/a<\/td><\/tr><\/table>' \
   -e "\$a<p class=\"unimp\">Generated using groff on $(date -u +"%F %T (UTC)")</p>"
