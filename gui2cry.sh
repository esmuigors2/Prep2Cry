#!/bin/bash

[ "$#" -lt 1 ] && echo "Usage: gui2cry.sh guifile [NUMBER_OF_WYKOFF_POSITIONS]" && exit 5
guifile="$1"
howmanylines=22
[ -n "$2" ] && howmanylines="$2" && howmanylines=$((howmanylines+2))
myprocn=$$

tail -$howmanylines "$guifile" > /tmp/gui2cry.${myprocn}
group=$(tail -1 /tmp/gui2cry.${myprocn} | gawk '{print $1}')
nnumel=$(grep -n '^\s*[0-9]\+\s*$' /tmp/gui2cry.${myprocn} | cut -d : -f 1)
[ "$nnumel" -gt 1 ] && sed -i '1,'"$((nnumel-1))"'d' /tmp/gui2cry.${myprocn}
numel=$(head -1 /tmp/gui2cry.${myprocn} | xargs)
wykoffs="$(sed 's@$@#@;s@^\s*@@' /tmp/gui2cry.${myprocn} | sed 's@\s\+@ @g' | sed -n '2{:a;N;'"$((numel+1))"'!ba;s@\n@@g;p}')"
rm /tmp/gui2cry.${myprocn}

echo pre2crys -g $group -n $numel -w '"'"$wykoffs"'"'
