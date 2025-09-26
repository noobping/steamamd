FROM archlinux:latest

# Enable multilib (Steam needs 32-bit)
RUN sed -i 's/^#Color/Color/' /etc/pacman.conf \
 && sed -i '/\[multilib\]/{N;s/#\[multilib\]\n#Include/\[multilib\]\nInclude/}' /etc/pacman.conf \
 && pacman -Syu --noconfirm

# Minimal runtime: Steam, AMD Vulkan/VA-API, gamescope, Xwayland, PulseAudio (null sink)
RUN pacman -S --noconfirm \
    steam \
    mesa lib32-mesa \
    vulkan-radeon lib32-vulkan-radeon vulkan-tools \
    libva-mesa-driver lib32-libva-mesa-driver \
    gamescope xorg-xwayland \
    pulseaudio \
 && pacman -Scc --noconfirm

# Non-root user; we’ll map host UID with --userns=keep-id
RUN useradd -m -s /bin/bash steamuser || true
ENV HOME=/home/steamuser
WORKDIR /home/steamuser

# Good defaults for AMD on Linux
ENV LIBVA_DRIVER_NAME=radeonsi \
    VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json \
    __GL_SHADER_DISK_CACHE=1

# Headless start script: Pulse null-sink + gamescope (virtual display) + Steam Big Picture
RUN printf '%s\n' '#!/bin/bash
set -euo pipefail

# Ensure runtime dir exists
export XDG_RUNTIME_DIR=/run/user/$(id -u)
mkdir -p "$XDG_RUNTIME_DIR"

# Start PulseAudio (no real sound card needed)
pulseaudio -D --exit-idle-time=-1 || true
# Wait for PA, then create a null sink so Steam has an audio device
for i in $(seq 1 30); do pactl info >/dev/null 2>&1 && break; sleep 0.2; done
pactl load-module module-null-sink sink_name=GameSink sink_properties=device.description=GameSink >/dev/null 2>&1 || true
export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native

# Virtual display via gamescope; override size via env if you want
W=${GAMESCOPE_WIDTH:-1920}
H=${GAMESCOPE_HEIGHT:-1080}
FPS=${GAMESCOPE_FPS:-60}

# Prefer headless backend; fall back if not available
if gamescope --help 2>/dev/null | grep -q "backend.*headless"; then
  BACKEND=(--backend headless)
else
  BACKEND=()
fi

exec gamescope "${BACKEND[@]}" -w "$W" -h "$H" -r "$FPS" --xwayland -- \
  steam -tenfoot -fulldesktopres -silent
' > /usr/local/bin/start-headless.sh \
 && chmod +x /usr/local/bin/start-headless.sh

# Small entrypoint that fixes $HOME perms when running rootless
RUN printf '#!/bin/bash\nchown -R $(id -u):$(id -g) "$HOME" 2>/dev/null || true\nexec "$@"\n' \
  > /usr/local/bin/entry.sh && chmod +x /usr/local/bin/entry.sh

ENTRYPOINT ["/usr/local/bin/entry.sh"]
CMD ["/usr/local/bin/start-headless.sh"]
