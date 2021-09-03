#!/bin/sh

if [ "$1" = "-v" ]; then
   verbose=1
   shift
fi

for f in $@; do
   # Get the size
   size=$(identify "${f}" | sed 's/^[^$]*JPEG\s\+\([0-9]\+\)x\([0-9]\+\)[^$]*$/\1 \2/')
   width=$(echo "${size}" | cut -d' ' -f1)
   height=$(echo "${size}" | cut -d' ' -f2)
   ([ -z "${width}" ] || [ -z "${height}" ]) && continue

   # Get the displayed width
   real_width=$(grep -v '^\s*#' content/templates/cats.lst | grep "^$(basename "$f")|" | cut -d'|' -f2)
   if [ -z "${real_width}" ]; then
      if [ "${width}" -gt "${height}" ]; then
         class="hcat"
         real_width=1055
      else
         class="vcat"
         real_width=348
      fi
   fi

   # Determine if the cat is horizontal or vertical
   [ -n "${style}" ] && style="style='${style}'"
   echo "<a href='$(basename "${f}" .jpg).html'>"

   echo "<img width='${real_width}' class='${class}' ${style} src='img/$(basename "${f}")'>"
   [ "${verbose}" = 1 ] && echo "file: $(basename "${f}"), size: ${size}, class: ${class}, width: ${real_width}" >&2
   echo "</a>"
done
