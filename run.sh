#!/bin/bash
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
