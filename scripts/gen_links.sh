#!/bin/sh

offset=$((6 * 3))

do_print() {
   printf "%*s%s\n" "${offset}" "" "$1"
}

entry() {
   do_print "<tr>"
   do_print "   <td class='link-td'>"
   do_print "      <a href='$2'>"
   do_print "         <button class='link-button'>"
   do_print "            $1"
   do_print "         </button>"
   do_print "      </a>"
   do_print "   </td>"
   do_print "</tr>"
}

while read -r line; do
   echo "${line}" | grep -q '^\s*#' && continue
   entry "$(echo "${line}" | cut -d',' -f1)" "$(echo "${line}" | cut -d',' -f2)"
done
