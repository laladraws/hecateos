# ╔══════════════════════════════════════════════════════════════╗
# ║                        HecateOS                             ║
# ║        Custom immutable distro based on Bazzite/uBlue       ║
# ║        AMD gaming + ROCm compute + Nordic aesthetic         ║
# ╚══════════════════════════════════════════════════════════════╝

ARG BASE_IMAGE="ghcr.io/ublue-os/bazzite"
ARG FEDORA_VERSION="43"

FROM ${BASE_IMAGE}:${FEDORA_VERSION}

# ── Labels de la imagen ───────────────────────────────────────────
LABEL org.opencontainers.image.title="HecateOS"
LABEL org.opencontainers.image.description="Custom immutable distro for AMD gaming and ROCm compute"
LABEL org.opencontainers.image.url="https://github.com/tu-usuario/hecate-os"
LABEL org.opencontainers.image.version="1.0"

# ── Identidad del sistema operativo ──────────────────────────────
COPY config/files/usr/lib/os-release /usr/lib/os-release

# ══════════════════════════════════════════════════════════════════
# BLOQUE 1: Repositorios adicionales
# ══════════════════════════════════════════════════════════════════

RUN rpm-ostree install \
    # Copr para Nordic theme y extensiones extras
    'dnf-command(copr)' \
    --idempotent && \
    # Nordic GTK theme desde Copr
    rpm-ostree copr enable yanboyang013/Nordic && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 2: Tema visual — Nordic + iconos
# ══════════════════════════════════════════════════════════════════


RUN rpm-ostree install \
    papirus-icon-theme \
    jetbrains-mono-fonts \
    google-roboto-fonts \
    --idempotent && \
    ostree container commit

# Nordic theme desde GitHub directamente (sin Copr)
RUN mkdir -p /usr/share/themes && \
    curl -Lo /tmp/nordic.tar.xz \
      "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz" && \
    tar -xf /tmp/nordic.tar.xz -C /usr/share/themes/ && \
    rm /tmp/nordic.tar.xz && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 3: Extensiones de GNOME Shell
# ══════════════════════════════════════════════════════════════════

RUN rpm-ostree install \
    # Tray icons en el panel (necesario para Steam, Discord, etc.)
    gnome-shell-extension-appindicator \
    # Blur en el panel y overview
    gnome-shell-extension-blur-my-shell \
    # User themes (necesario para aplicar temas Shell)
    gnome-shell-extension-user-theme \
    # Dash to Dock o Dash to Panel (elegí uno)
    gnome-shell-extension-dash-to-dock \
    # GSConnect (integración con Android)
    gnome-shell-extension-gsconnect \
    # Logo Menu (para el logo de HecateOS en el panel)
    gnome-shell-extension-Logo-menu \
    # Caffeine (evitar suspensión)
    gnome-shell-extension-caffeine \
    --idempotent && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 4: Bazaar como store por defecto — remover GNOME Software
# ══════════════════════════════════════════════════════════════════
# Bazaar ya viene incluido en Bazzite — solo hay que sacar GNOME Software
# para que no compita como handler de software/flatpaks

RUN rpm-ostree override remove \
    gnome-software \
    gnome-software-rpm-ostree \
    --idempotent 2>/dev/null || true && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 5: ROCm para AMD RX 9070 XT (RDNA 4 / gfx1201)
# ══════════════════════════════════════════════════════════════════

RUN rpm-ostree install \
    rocm-opencl \
    rocm-hip \
    rocm-clinfo \
    rocm-smi \
    # Blender vía RPM para acceso directo a ROCm/HIP
    blender \
    --idempotent && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 6: Herramientas adicionales del sistema
# ══════════════════════════════════════════════════════════════════

RUN rpm-ostree install \
    # Monitor de GPU AMD
    amdgpu_top \
    # Información del sistema (con logo de HecateOS)
    fastfetch \
    # Herramientas de red
    tailscale \
    --idempotent && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 7: Archivos de configuración
# ══════════════════════════════════════════════════════════════════

# Logo e identidad visual
COPY config/files/usr/share/pixmaps/hecate-os.svg \
     /usr/share/pixmaps/hecate-os.svg

# Wallpaper por defecto
COPY config/files/usr/share/backgrounds/hecate-os/ \
     /usr/share/backgrounds/hecate-os/

COPY config/files/usr/share/gnome-background-properties/hecate-os.xml \
     /usr/share/gnome-background-properties/hecate-os.xml

# Schemas de GNOME (tema, iconos, extensiones, wallpaper)
COPY config/files/usr/share/glib-2.0/schemas/99-hecate-os.gschema.override \
     /usr/share/glib-2.0/schemas/99-hecate-os.gschema.override

# Configuración dconf del sistema (settings globales)
COPY config/files/etc/dconf/db/distro.d/00-hecate-os \
     /etc/dconf/db/distro.d/00-hecate-os

# Variables de entorno ROCm para RDNA 4
COPY config/files/etc/environment.d/50-rocm.conf \
     /etc/environment.d/50-rocm.conf

# Fastfetch config con logo HecateOS
COPY config/files/etc/profile.d/hecate-os-fastfetch.sh \
     /etc/profile.d/hecate-os-fastfetch.sh

# ══════════════════════════════════════════════════════════════════
# BLOQUE 8: Compilar schemas y dconf — siempre al final
# ══════════════════════════════════════════════════════════════════

RUN glib-compile-schemas /usr/share/glib-2.0/schemas && \
    dconf update && \
    ostree container commit

# ══════════════════════════════════════════════════════════════════
# BLOQUE 9: Flatpaks declarativos (se instalan en primer boot)
# ══════════════════════════════════════════════════════════════════

COPY config/flatpaks.txt /usr/share/ublue-os/firstboot/flatpaks

RUN ostree container commit
