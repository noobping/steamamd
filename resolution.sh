#!/usr/bin/env bash
set -euo pipefail
OUT="HEADLESS-1"
choice="$(printf '%s\n' \
  '1280x720' \
  '1280x800' \
  '1600x900' \
  '1920x1080' \
  '1920x1200' \
  '2560x1440' \
  '3840x2160' \
  '—' \
  'scale 1.0' \
  'scale 1.25' \
  'scale 1.5' \
  'scale 1.75' \
  'scale 2.0' \
  | wofi --dmenu --prompt='Resolution')"

case "$choice" in
  *x*) swaymsg "output $OUT mode $choice" ;;
  "scale 1.0")  swaymsg "output $OUT scale 1.0" ;;
  "scale 1.25") swaymsg "output $OUT scale 1.25" ;;
  "scale 1.5")  swaymsg "output $OUT scale 1.5" ;;
  "scale 2.0")  swaymsg "output $OUT scale 2.0" ;;
  *) exit 0 ;;
esac
