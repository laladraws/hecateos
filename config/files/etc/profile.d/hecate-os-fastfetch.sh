#!/bin/bash
# HecateOS — mostrar fastfetch solo en terminales interactivas
# y solo una vez por sesión

if [[ $- == *i* ]] && [[ -z "$HECATE_FASTFETCH_SHOWN" ]]; then
    export HECATE_FASTFETCH_SHOWN=1
    fastfetch --config /etc/hecate-os/fastfetch.jsonc 2>/dev/null || true
fi
