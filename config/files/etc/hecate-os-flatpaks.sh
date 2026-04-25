#!/bin/bash
# Solo corre en sesiones gráficas interactivas
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    if [ ! -f "$HOME/.local/share/hecate-os-flatpaks-done" ]; then
        /usr/bin/hecate-os-install-flatpaks.sh &
    fi
fi