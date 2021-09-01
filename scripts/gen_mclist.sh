#!/bin/sh

[ $# -ne 1 ] && echo "Usage: $(basename "$0") list" >&2 && exit 1
file="$1"

while read mc; do
   echo "${mc}" | grep -q '^\s*#' && continue
   name=$(echo "${mc}" | cut -d'.' -f1)
   section=$(echo "${mc}" | cut -d'.' -f2)
   echo "<a class='mc-summary-link' href='mc-${mc}.html'>${name} (${section})</a><br>"
done <"${file}"
