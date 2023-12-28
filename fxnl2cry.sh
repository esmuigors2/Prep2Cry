#!/bin/bash

fxfile="$HOME/crydarba/tmpl/fxnls/${1}.fxl"
[ ! -f "$fxfile" ] && echo "Sorry, no such functional defined!" && exit 1
#if [ "$$" -eq "$(exec sh -c 'echo "$PPID"')" ]; then
#    echo -n '"'; cat "$fxfile" | while read un; do echo -n "${un}#"; done; echo '"'
#else
    cat "$fxfile" | while read un; do echo -n "${un}#"; done
#fi

