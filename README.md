# HecateOS

> Custom immutable Linux distro based on [Universal Blue](https://universal-blue.org/) / Bazzite.  
> AMD gaming + ROCm compute + Nordic aesthetic.

## Stack

| Componente | Detalle |
|---|---|
| Base | Bazzite (Fedora 43 / Silverblue) |
| Desktop | GNOME 49 → 50 (en Fedora 44) |
| Kernel | OGC gaming kernel (incluido en Bazzite) |
| GPU | AMD RX 9070 XT (RDNA 4 / gfx1201) |
| Compute | ROCm 6.4+ para Blender/HIP |
| Tema | Nordic GTK + Papirus-Dark icons |
| Updates | Atómicos vía rpm-ostree, rollback disponible |

## Instalar desde ISO

Descargá la última ISO desde [Releases](../../releases).

## Instalar via rebase (si ya tenés Silverblue/Bazzite)

```bash
# Sin verificación (testing)
rpm-ostree rebase \
  ostree-unverified-registry:ghcr.io/TU_USUARIO/hecate-os:latest

# Con verificación de firma (recomendado)
rpm-ostree rebase \
  ostree-image-signed:docker://ghcr.io/TU_USUARIO/hecate-os:latest

systemctl reboot
```

## Personalización post-instalación

El usuario puede cambiar cualquier default visual desde:
- **GNOME Tweaks** → tema, fuentes, iconos
- **Extension Manager** → activar/desactivar extensiones
- **Configuración del sistema** → apariencia, pantalla

## Verificar ROCm (RX 9070 XT)

```bash
# Ver GPU detectada
rocminfo | grep "Agent Type" -A 5

# Verificar OpenCL
clinfo | grep "Device Name"

# En Blender:
# Preferences → System → Cycles Render Devices → HIP → RX 9070 XT
```

## Estructura del repositorio

```
hecate-os/
├── Containerfile                          # Definición de la imagen
├── config/
│   ├── flatpaks.txt                       # Flatpaks del primer boot
│   └── files/                             # Overlay del filesystem
│       ├── usr/lib/os-release             # Identidad de la distro
│       ├── usr/share/
│       │   ├── pixmaps/hecate-os.svg      # Logo
│       │   ├── backgrounds/hecate-os/     # Wallpapers (agregar .jpg)
│       │   ├── gnome-background-properties/
│       │   └── glib-2.0/schemas/
│       │       └── 99-hecate-os.gschema.override  # Tema, iconos, extensiones
│       └── etc/
│           ├── dconf/db/distro.d/
│           │   └── 00-hecate-os           # dconf defaults del sistema
│           └── environment.d/
│               └── 50-rocm.conf          # Variables ROCm para RDNA 4
└── .github/workflows/
    └── build.yml                          # CI/CD: build, push, ISO
```

## Actualizar a Fedora 44

Cuando salga Fedora 44, cambiar en el `Containerfile`:

```dockerfile
ARG FEDORA_VERSION="44"   # era "43"
```

Pushear a main → el CI rebuilda HecateOS sobre la nueva base automáticamente.

## Migrar usuarios existentes a F44

```bash
rpm-ostree rebase \
  ostree-image-signed:docker://ghcr.io/TU_USUARIO/hecate-os:44
systemctl reboot
```

## Pendientes antes de hacer build

- [ ] Reemplazar `config/files/usr/share/pixmaps/hecate-os.svg` con el logo definitivo
- [ ] Agregar wallpapers en `config/files/usr/share/backgrounds/hecate-os/` (default.jpg y default-dark.jpg)
- [ ] Verificar que el Copr de Nordic esté disponible para Fedora 43
- [ ] Cambiar `tu-usuario` en el README y en el workflow por tu usuario de GitHub
- [ ] Generar y agregar `cosign.pub` al repo (ver documentación de uBlue)
