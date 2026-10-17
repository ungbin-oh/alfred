#!/usr/bin/env bash
# written by Ungbin_Oh
# project : [AWP] AI-Assistant-Workflow-Publishing
# created : 2026-10-17
# updated : 2026-10-17
#
# Renders the README images from the html sources in this folder with headless Chrome (no install needed on macOS).
# usage: bash render.sh            → writes ../<name>.png at 2x
set -eu
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cd "$(dirname "$0")"
shot() { # name width height
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 --virtual-time-budget=4000 \
    --window-size="$2,$3" --screenshot="../$1.png" "file://$PWD/$1.html" >/dev/null 2>&1
  echo "../$1.png"
}
shot banner 1600 400
shot banner-ko 1600 400
shot before-after 1600 720
[ -f flow.html ] && shot flow 1600 560 || true
[ -f decision-window.html ] && shot decision-window 1400 790
true
