# ╔══════════════════════════════════════════════════════════════╗
# ║                        HecateOS                             ║
# ║                       Fase 1 — Base                         ║
# ╚══════════════════════════════════════════════════════════════╝
ARG BASE_IMAGE="ghcr.io/ublue-os/silverblue-main"
ARG FEDORA_VERSION="43"

FROM ${BASE_IMAGE}:${FEDORA_VERSION}

LABEL org.opencontainers.image.title="HecateOS"
LABEL org.opencontainers.image.description="Custom immutable distro for AMD gaming and ROCm compute"
LABEL org.opencontainers.image.url="https://github.com/laladraws/hecateos"
LABEL org.opencontainers.image.version="1.0"

COPY config/files/usr/lib/os-release /usr/lib/os-release

# ══════════════════════════════════════════════════════════════════
# BLOQUE 1: RPM Fusion
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 2: Media, drivers y ROCm
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    mesa-dri-drivers \
    mesa-vulkan-drivers \
    mesa-va-drivers \
    ffmpeg \
    gstreamer1-vaapi \
    rocm-opencl \
    rocm-hip \
    rocminfo \
    rocm-clinfo \
    rocm-smi && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 3: Aplicaciones GNOME y sistema
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    ptyxis \
    gnome-calculator \
    gnome-disk-utility \
    gnome-system-monitor \
    gnome-weather \
    gnome-tweaks \
    gnome-text-editor \
    gnome-calendar \
    baobab \
    evince \
    htop \
    fastfetch \
    fuse-libs \
    cifs-utils \
    unzip && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 4: Remover bloat
# ══════════════════════════════════════════════════════════════════
RUN dnf remove -y \
    gnome-tour \
    gnome-software \
    gnome-software-rpm-ostree || true && \
    rm -rf /usr/share/backgrounds/f43 \
           /usr/share/backgrounds/fedora-workstation \
           /usr/share/backgrounds/gnome && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 5: Extensiones de GNOME Shell
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-just-perfection && \
    dnf clean all && \
    ostree container commit

# Weather O'Clock desde GitHub
RUN git clone https://github.com/CleoMenezesJr/weather-oclock.git /tmp/weatheroclock && \
    cp -r /tmp/weatheroclock/weatheroclock@CleoMenezesJr.github.io \
      /usr/share/gnome-shell/extensions/ && \
    glib-compile-schemas \
      /usr/share/gnome-shell/extensions/weatheroclock@CleoMenezesJr.github.io/schemas/ && \
    rm -rf /tmp/weatheroclock && \
    ostree container commit



# ══════════════════════════════════════════════════════════════════
# BLOQUE 6: Tema visual — Nordic + Tela icons
# ══════════════════════════════════════════════════════════════════

# Nordic GTK theme
RUN mkdir -p /usr/share/themes && \
    curl -Lo /tmp/nordic.tar.xz \
      "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz" && \
    tar -xf /tmp/nordic.tar.xz -C /usr/share/themes/ && \
    rm /tmp/nordic.tar.xz && \
    ostree container commit

# Tela icon theme
RUN git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela && \
    bash /tmp/tela/install.sh -a && \
    rm -rf /tmp/tela && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 7: Gaming
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    steam \
    mangohud \
    blender && \
    dnf clean all && \
    ostree container commit    

# ══════════════════════════════════════════════════════════════════
# BLOQUE 8: Configuración GNOME — extensiones por defecto
# ══════════════════════════════════════════════════════════════════

COPY config/files/usr/share/glib-2.0/schemas/99-hecate-os.gschema.override \
     /usr/share/glib-2.0/schemas/99-hecate-os.gschema.override

COPY config/files/usr/share/backgrounds/hecate-os/ \
     /usr/share/backgrounds/hecate-os/

COPY config/files/usr/share/gnome-background-properties/hecate-os.xml \
     /usr/share/gnome-background-properties/hecate-os.xml

COPY config/files/usr/share/pixmaps/hecate-os.svg \
     /usr/share/pixmaps/hecate-os.svg

COPY config/files/usr/share/pixmaps/hecate-os.png \
     /usr/share/pixmaps/hecate-os.png

RUN glib-compile-schemas /usr/share/glib-2.0/schemas && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/icons/hicolor/scalable/apps/fedora-logo.svg && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/icons/hicolor/scalable/apps/hecate-os.svg && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/icons/hicolor/scalable/apps/start-here.svg && \
    cp /usr/share/pixmaps/hecate-os.png \
       /usr/share/pixmaps/fedora-logo-sprite.png && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/fedora-logos/fedora_logo.svg && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/fedora-logos/fedora_darkbackground.svg && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/fedora-logos/fedora_lightbackground.svg && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/fedora-logos/fedora_logo_darkbackground.svg && \
    cp /usr/share/pixmaps/hecate-os.svg \
       /usr/share/pixmaps/fedora-logo-sprite.svg && \
    ostree container commit


# ══════════════════════════════════════════════════════════════════
# BLOQUE 9: Servicio de instalación de Flatpaks
# ══════════════════════════════════════════════════════════════════

COPY config/files/usr/libexec/hecate-os-install-flatpaks \
     /usr/libexec/hecate-os-install-flatpaks

COPY config/files/usr/lib/systemd/system/hecate-os-flatpaks.service \
     /usr/lib/systemd/system/hecate-os-flatpaks.service

RUN chmod +x /usr/libexec/hecate-os-install-flatpaks && \
    systemctl enable hecate-os-flatpaks.service && \
    ostree container commit



