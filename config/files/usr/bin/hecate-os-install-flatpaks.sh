#!/bin/bash

MARKER="/var/lib/hecate-os-firstboot-done"
if [ -f "$MARKER" ]; then
    exit 0
fi

flatpak remote-add --system --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# Instalar cada Flatpak individualmente — si uno falla no detiene el resto
flatpak install --system -y flathub io.github.kolunmi.Bazaar || true
flatpak install --system -y flathub com.mattjakeman.ExtensionManager || true
flatpak install --system -y flathub com.github.tchx84.Flatseal || true
flatpak install --system -y flathub io.github.flattool.Warehouse || true
flatpak install --system -y flathub com.spotify.Client || true
flatpak install --system -y flathub com.discordapp.Discord || true
flatpak install --system -y flathub com.rtosta.zapzap || true
flatpak install --system -y flathub org.freecad.FreeCAD || true
flatpak install --system -y flathub com.orcaslicer.OrcaSlicer || true
flatpak install --system -y flathub io.mango3d.LycheeSlicer || true
flatpak install --system -y flathub org.mozilla.firefox || true
flatpak install --system -y flathub org.kde.krita || true
flatpak install --system -y flathub org.inkscape.Inkscape || true
flatpak install --system -y flathub com.obsproject.Studio || true
flatpak install --system -y flathub net.davidotek.pupgui2 || true
flatpak install --system -y flathub com.heroicgameslauncher.hgl || true
flatpak install --system -y flathub net.lutris.Lutris || true

touch "$MARKER"