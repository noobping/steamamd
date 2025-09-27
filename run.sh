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
export PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native"

# ----- wlroots headless: disable seat/logind; no input devices -----
export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export WLR_SESSION=0

# Virtual display parameters
W=${GAMESCOPE_WIDTH:-1920}
H=${GAMESCOPE_HEIGHT:-1080}
FPS=${GAMESCOPE_FPS:-60}

# Prefer gamescope headless backend if available
if gamescope --help 2>/dev/null | grep -q "backend.*headless"; then
  BACKEND=(--backend headless)
else
  BACKEND=()
fi

# Run gamescope -> Steam Big Picture (no --xwayland flag to avoid count parsing)
exec gamescope "${BACKEND[@]}" -w "$W" -h "$H" -r "$FPS" -- \
  steam -tenfoot -fulldesktopres -silent
