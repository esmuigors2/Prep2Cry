#!/bin/bash

cifile="$1"

tmpfille="/tmp/prep2cry.$$"
verytmpfille="/tmp/dpos.$$."
dcnt=0
rm "${tmpfille}.wypos" "${tmpfille}.wyel" 2>/dev/null
if [ "$(sed -n '/_atom_site_/,/^_geom/p' "$cifile" | wc -l)" -gt 2 ]; then
    #sed -n '/^_atom_site/,/^_geom/p' "$cifile" | sed '/^_atom_site_aniso/,/^loop_|^_atom_type/d' | grep -e '\([0-9\t ]\.[ \t0-9]\)\{3,6\}' -e '\([0-9\t ]\.[ \t0-9]\)\{6\}' | sed 's@0/s\+@0.0@g;s@\s0$@ 0.0@g;s@0.\s@0.0 @g;s@\s0.$@ 0.0@g;s@\s.\([0-9]\)@ 0.\1@g' | while read un; do
    sed -n '/^_atom_site_/,/^_geom/p' "$cifile" | while read un; do
        #echo "$un"; echo "=============="
        dcnt=$((dcnt+1))
        [ -n "$(echo "$un" | grep '^_atom_site_label')" ] && echo "$dcnt" > "${verytmpfille}0"
        [ -n "$(echo "$un" | grep '^_atom_site_fract_x')" ] && echo "$dcnt" > "${verytmpfille}1"
        [ -n "$(echo "$un" | grep '^_atom_site_fract_y')" ] && echo "$dcnt" > "${verytmpfille}2"
        [ -n "$(echo "$un" | grep '^_atom_site_fract_z')" ] && echo "$dcnt" > "${verytmpfille}3"

        if [ -z "$(echo "$un" | grep '^_\|^loop_')" ] && [ -f "${verytmpfille}3" ]; then
            unn="$(echo "$un" | sed 's@([0-9]\+)@@g;s@\s\+0\s\+@ 0.0 @g;s@\s0$@ 0.0@g;s@0\.\s@0.0 @g;s@\s0\.$@ 0.0@g;s@\s\.\([0-9]\)@ 0.\1@g')"
            #echo "%%%%%%%%%%%%%%%%%%%"; echo "$unn"; echo '$$$$$$$$$$$$$$$$$$'
            echo "$unn" | gawk '{printf "%8.5f  %8.5f  %8.5f\n", $'"$(cat "${verytmpfille}1")"', $'"$(cat "${verytmpfille}2")"', $'"$(cat "${verytmpfille}3")"'}' >> "${tmpfille}.wypos"
            grep -nm 1 $(echo "$unn" | gawk '{print $'"$(cat "${verytmpfille}0")"'}' | sed 's@[0-9+-]@@g') $HOME/.pertanu | cut -d : -f 1  | gawk '{printf "%-2s\n", $1}' >> "${tmpfille}.wyel"
        fi
        [ -n "$(echo "$un" | grep '^loop_')" ] && dcnt=0
        [ -n "$(echo "$un" | grep '^loop_')" ] && [ -f "${verytmpfille}3" ] && rm ${verytmpfille}[0-3] && break
    done # 2>&1 >/dev/null
else
    echo "sorry pal, cannot find coordinates"
    exit 1
fi
#echo "===DEBUG: WUEL"
#cat "${tmpfille}.wyel"
#echo "===DEBUG: WUPOS"
#cat "${tmpfille}.wypos"
wypos="$(echo -n '"'; paste -d ' ' "${tmpfille}.wyel" "${tmpfille}.wypos" | while read un; do echo -n "${un}#"; done; echo '"')"
spgrp="$(grep '_space_group_IT_number' "$cifile" | gawk '{print $2}')"
numel="$(echo "$wypos" | grep -o '#' | wc -l)"
latcon="$(grep '_cell_length_a'  "$cifile" | gawk '{print $2}' | cut -d '(' -f 1)"

echo "pre2crys -g $spgrp -l $latcon -n $numel -w $wypos"

