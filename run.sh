#!/bin/bash
set -euo pipefail

# Runtime dir inside HOME
export XDG_RUNTIME_DIR=$HOME/.xdg-runtime
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Start PulseAudio
pulseaudio -D --exit-idle-time=-1 || true
for i in $(seq 1 30); do
  pactl info >/dev/null 2>&1 && break
  sleep 0.2
done
pactl load-module module-null-sink sink_name=GameSink \
    sink_properties=device.description=GameSink >/dev/null 2>&1 || true
export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native

# gamescope virtual display
W=${GAMESCOPE_WIDTH:-1920}
H=${GAMESCOPE_HEIGHT:-1080}
FPS=${GAMESCOPE_FPS:-60}

if gamescope --help 2>/dev/null | grep -q "backend.*headless"; then
  BACKEND=(--backend headless)
else
  BACKEND=()
fi

exec gamescope "${BACKEND[@]}" -w "$W" -h "$H" -r "$FPS" --xwayland -- \
  steam -tenfoot -fulldesktopres -silent
