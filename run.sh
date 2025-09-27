#!/bin/bash
set -euo pipefail

# Use a private runtime dir in HOME
export XDG_RUNTIME_DIR="$HOME/.xdg-runtime"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# ----- Audio: Pulse null-sink -----
# Clean any stale sockets
rm -rf "$XDG_RUNTIME_DIR/pulse"
mkdir -p "$XDG_RUNTIME_DIR/pulse"

# Start PulseAudio (quietly). If it’s already running, continue.
pulseaudio --start --daemonize=true --log-level=error || true

# Wait until pactl is ready (Pulse socket created)
for i in $(seq 1 50); do
  if pactl info >/dev/null 2>&1; then break; fi
  sleep 0.1
done

# Ensure a null sink exists so Remote Play gets audio
pactl load-module module-null-sink sink_name=GameSink \
  sink_properties=device.description=GameSink >/dev/null 2>&1 || true

# Virtual display parameters
W=${GAMESCOPE_WIDTH:-1920}
H=${GAMESCOPE_HEIGHT:-1080}
FPS=${GAMESCOPE_FPS:-60}

# Run gamescope -> Steam Big Picture
exec gamescope --expose-wayland --steam --backend headless -w "$W" -h "$H" -r "$FPS" -- \
  steam -tenfoot -fulldesktopres -silent
