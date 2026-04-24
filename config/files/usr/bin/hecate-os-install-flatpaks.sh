#!/bin/bash
set -euo pipefail

# Solo correr una vez
MARKER="/var/lib/hecate-os-firstboot-done"
if [ -f "$MARKER" ]; then
    exit 0
fi

# Asegurar que Flathub está configurado
flatpak remote-add --system --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# Instalar Flatpaks esenciales
flatpak install --system -y flathub \
    io.github.kolunmi.Bazaar \
    com.mattjakeman.ExtensionManager \
    com.github.tchx84.Flatseal \
    io.github.flattool.Warehouse \
    com.spotify.Client \
    com.discordapp.Discord \
    com.rtosta.zapzap \
    org.freecad.FreeCAD \
    com.orcaslicer.OrcaSlicer \
    io.mango3d.LycheeSlicer \
    org.mozilla.firefox \
    org.kde.krita \
    org.inkscape.Inkscape \
    com.obsproject.Studio \
    net.davidotek.pupgui2 \
    com.heroicgameslauncher.HeroicGamesLauncher \
    net.lutris.Lutris

# Marcar como completado
touch "$MARKER"