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
# BLOQUE 4: Gaming
# ══════════════════════════════════════════════════════════════════

RUN dnf copr enable -y wehagy/protonplus && \
    dnf install -y \
    steam \
    gamemode \
    mangohud \
    protonplus \
    blender && \
    dnf clean all && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 5: Remover bloat
# ══════════════════════════════════════════════════════════════════

RUN dnf remove -y \
    gnome-tour \
    gnome-software \
    gnome-software-rpm-ostree || true && \
    dnf clean all && \
    ostree container commit