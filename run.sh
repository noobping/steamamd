#!/bin/bash
set -euo pipefail

# Use a private runtime dir in HOME
export XDG_RUNTIME_DIR="$HOME/.xdg-runtime"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# start PipeWire stack in the container
(pipewire --verbose=0 >/dev/null 2>&1 &) || true
(wireplumber >/dev/null 2>&1 &) || true

# wait for sockets to appear
for i in {1..20}; do pactl info >/dev/null 2>&1 && break; sleep 0.2; done

# create the null sink for Remote Play
pactl load-module module-null-sink sink_name=GameSink \
  sink_properties=device.description=GameSink >/dev/null 2>&1 || true

# Virtual display parameters
W=${GAMESCOPE_WIDTH:-1920}
H=${GAMESCOPE_HEIGHT:-1080}
FPS=${GAMESCOPE_FPS:-60}

# Run gamescope -> Steam Big Picture
exec gamescope --expose-wayland --steam --backend headless -w "$W" -h "$H" -r "$FPS" -- \
  steam -tenfoot -fulldesktopres -silent
