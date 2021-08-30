#!/bin/sh

[ -f .bcc.1 ] || wget https://raw.githubusercontent.com/Benni3D/bcc/master/src/bcc.1 -O .bcc.1

groff -mandoc -Thtml ".bcc.1" | sed \
   -e '/<!DOCTYPE[^$]\+$/d' \
   -e '/"http:[^$]\+$/d' \
   -e '1,19d' \
   -e 's/<h1 align="center">bcc/<h1>Brainlet C Compiler/' \
   -e '/^<\/body>$/d' \
   -e '/^<\/html>$/d' \
   -e 's/<p/<p class="bcc-p"/g' \
   -e 's/<pre/<pre class="bcc-pre"/g' \
   -e 's/<h2/<h2 class="bcc-h2"/g' \
   -e 's/<hr>/<hr class="bcc-hr">/g' \
   -e 's/<a/<a class="bcc-a"/g' | sed \
   -e '3i<table width="100%"><tr><td width="80%">' \
   -e '12i<\/td><td>' \
   -e '12i<img width="100%" src="img/bcc.png"><br>' \
   -e '12i<a align="center" class="bcc-link" target="_blank" href="https://github.com/Benni3D/bcc">GitHub<\/a>' \
   -e '12i<\/td><\/tr><\/table>' \
   -e "\$a<p class=\"unimp\">Generated using groff on $(date -u +"%F %T (UTC)")</p>"
