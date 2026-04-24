
# ╔══════════════════════════════════════════════════════════════╗
# ║                        HecateOS                             ║
# ║        Custom immutable distro based on uBlue Silverblue    ║
# ║        AMD gaming + ROCm compute + Nordic aesthetic         ║
# ╚══════════════════════════════════════════════════════════════╝
ARG BASE_IMAGE="ghcr.io/ublue-os/silverblue-main"
ARG FEDORA_VERSION="43"

FROM ${BASE_IMAGE}:${FEDORA_VERSION}

LABEL org.opencontainers.image.title="HecateOS"
LABEL org.opencontainers.image.description="Custom immutable distro for AMD gaming and ROCm compute"
LABEL org.opencontainers.image.url="https://github.com/laladraws/hecateos"
LABEL org.opencontainers.image.version="1.0"

# ── Identidad ─────────────────────────────────────────────────────
COPY config/files/usr/lib/os-release /usr/lib/os-release

# ══════════════════════════════════════════════════════════════════
# BLOQUE 1: Tema visual — Nordic + iconos + fuentes
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    papirus-icon-theme \
    jetbrains-mono-fonts \
    google-roboto-fonts \
    unzip && \
    dnf clean all && \
    ostree container commit

RUN mkdir -p /usr/share/themes && \
    curl -Lo /tmp/nordic.tar.xz \
      "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz" && \
    tar -xf /tmp/nordic.tar.xz -C /usr/share/themes/ && \
    rm /tmp/nordic.tar.xz && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 2: Extensiones de GNOME Shell
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-gsconnect \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-just-perfection \
    gnome-weather \
    git \
    unzip && \
    dnf clean all && \
    ostree container commit

# Weather O'Clock desde GitHub
RUN git clone https://github.com/CleoMenezesJr/weather-oclock.git /tmp/weatheroclock && \
    cp -r /tmp/weatheroclock/weatheroclock@CleoMenezesJr.github.io \
      /usr/share/gnome-shell/extensions/ && \
    rm -rf /tmp/weatheroclock && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 3: Gaming — Steam + ProtonPlus
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    steam \
    gamemode \
    mangohud && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 4: ROCm para AMD RX 9070 XT (RDNA 4 / gfx1201)
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    rocm-opencl \
    rocm-hip \
    rocm-clinfo \
    rocm-smi \
    blender && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 5: Flatpaks esenciales y remover GNOME Software
# ══════════════════════════════════════════════════════════════════


COPY config/files/usr/lib/systemd/system/hecate-os-firstboot.service \
     /usr/lib/systemd/system/hecate-os-firstboot.service

COPY config/files/usr/bin/hecate-os-install-flatpaks.sh \
     /usr/bin/hecate-os-install-flatpaks.sh

RUN chmod +x /usr/bin/hecate-os-install-flatpaks.sh && \
    systemctl enable hecate-os-firstboot.service && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 6: Archivos de configuración
# ══════════════════════════════════════════════════════════════════

COPY config/files/usr/share/pixmaps/hecate-os.svg \
     /usr/share/pixmaps/hecate-os.svg

COPY config/files/usr/share/glib-2.0/schemas/99-hecate-os.gschema.override \
     /usr/share/glib-2.0/schemas/99-hecate-os.gschema.override

COPY config/files/etc/dconf/db/distro.d/00-hecate-os \
     /etc/dconf/db/distro.d/00-hecate-os

COPY config/files/etc/environment.d/50-rocm.conf \
     /etc/environment.d/50-rocm.conf

COPY config/files/etc/profile.d/hecate-os-fastfetch.sh \
     /etc/profile.d/hecate-os-fastfetch.sh

COPY config/files/usr/share/backgrounds/hecate-os/ \
     /usr/share/backgrounds/hecate-os/

# ══════════════════════════════════════════════════════════════════
# BLOQUE 7: Compilar schemas y dconf
# ══════════════════════════════════════════════════════════════════

RUN glib-compile-schemas /usr/share/glib-2.0/schemas && \
    dconf update && \
    ostree container commit 

RUN ln -sf /usr/share/pixmaps/hecate-os.svg \
    /usr/share/icons/hicolor/scalable/apps/org.gnome.Software.svg && \
    ln -sf /usr/share/pixmaps/hecate-os.svg \
    /usr/share/pixmaps/fedora-logo.svg && \
    ostree container commit



# ══════════════════════════════════════════════════════════════════
# BLOQUE 8: Flatpaks (se instalan en primer boot)
# ══════════════════════════════════════════════════════════════════

COPY config/flatpaks.txt /usr/share/ublue-os/firstboot/flatpaks

RUN ostree container commit