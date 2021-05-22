#!/bin/sh

escape() {
   sed 's/\\/\\\\/g;s/\//\\\//g;s/\./\\./g;'"s/\n//g" "$1"
}

dest=generated

rm -rf "$dest"
mkdir -p "$dest"

for f in $(ls -1 content | tr '\n' ' '); do
   file="content/$f"
   [ ! -d "$file" ] && continue
   cp -r "$file" "$dest/$f"
done

for f in content/*.html; do
   #sed "s/__REPLACE__/$(escape "$f")/g" "template.html" > "$dest/$(basename "$f")"
   sed -e "/__REPLACE__/r $f" -e '/__REPLACE__/d' template.html > "$dest/$(basename "$f")"
done

