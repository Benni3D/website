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

rm -f links.html
for e in $(grep -v '^#' content/templates/links.lst); do
   entry "$(echo "${e}" | cut -d',' -f1 | tr '_' ' ')" "$(echo "${e}" | cut -d',' -f2)" >> links.html
done

sed -e '/__LINKS__/rlinks.html' -e '/__LINKS__/d'

rm -f links.html
