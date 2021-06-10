#!/bin/sh

src=content
dest=generated

rm -rf "${dest}"
mkdir -p "${dest}"

# Generate bcc.html
if [ ! -f "${dest}/bcc.1.html" ]; then
   [ -f .bcc.1 ] || wget https://raw.githubusercontent.com/Benni3D/bcc/master/bcc.1 -O .bcc.1
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
      -e "\$a<p class=\"unimp\">Generated using groff on $(date -u +"%F %T (UTC)")</p>" \
      > "${src}/bcc.html"
fi

for f in $(ls -1 "${src}" | tr '\n' ' '); do
   file="content/${f}"
   [ ! -d "${file}" ] && continue
   cp -r "${file}" "$dest/$f"
done

for f in "${src}"/*.html; do
   sed -e "/__REPLACE__/r ${f}" -e '/__REPLACE__/d' template.html > "$dest/$(basename "$f")"
done

