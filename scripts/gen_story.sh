#!/bin/sh

# Format:
# Title
# Author
# Text...

die() {
   echo "$1" >&2
   exit 1
}

read title     || die "missing title"
read author    || die "missing author"
read text      || die "missing text"
while read -r line; do
   if echo "${line}" | grep -q '^\s*$'; then
      text="${text}\n</p><p class='storytext'>\n"
   else
      text="${text} ${line}"
   fi
done

echo "<h1>${title}</h1>"
echo '<table>'
echo '   <tr>'
echo '      <td width="92%">'
echo '         <p class="storytext">'
echo "         ${text}"
echo '         <br>'
echo '         <br>'
echo "         ${author}"
echo '          </p>'
echo '      </td>'
echo '      <td>&nbsp;</td>'
echo '   </tr>'

