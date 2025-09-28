#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en_US:en}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export WLR_RENDERER="${WLR_RENDERER:-vulkan}"
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-0}"

exec sway
