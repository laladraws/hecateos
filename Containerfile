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
# BLOQUE 4: Extensiones de GNOME Shell
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
# BLOQUE 5: Configuración GNOME — extensiones por defecto
# ══════════════════════════════════════════════════════════════════

COPY config/files/usr/share/glib-2.0/schemas/99-hecate-os.gschema.override \
     /usr/share/glib-2.0/schemas/99-hecate-os.gschema.override

COPY config/files/usr/share/backgrounds/hecate-os/ \
     /usr/share/backgrounds/hecate-os/

COPY config/files/usr/share/gnome-background-properties/hecate-os.xml \
     /usr/share/gnome-background-properties/hecate-os.xml     

RUN glib-compile-schemas /usr/share/glib-2.0/schemas && \
    ostree container commit

COPY config/files/usr/bin/hecate-os-install-flatpaks.sh \
     /usr/bin/hecate-os-install-flatpaks.sh

COPY config/files/etc/profile.d/hecate-os-flatpaks.sh \
     /etc/profile.d/hecate-os-flatpaks.sh

RUN chmod +x /usr/bin/hecate-os-install-flatpaks.sh && \
    chmod +x /etc/profile.d/hecate-os-flatpaks.sh && \
    ostree container commit


# ══════════════════════════════════════════════════════════════════
# BLOQUE 6: Gaming
# ══════════════════════════════════════════════════════════════════

RUN dnf install -y \
    steam \
    mangohud \
    blender && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 7: Remover bloat
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