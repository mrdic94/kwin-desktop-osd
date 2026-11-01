#!/usr/bin/env bash
# Desinstala kwin-desktop-osd del usuario actual.
set -euo pipefail

ID="desktopnameosd"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/kwin/scripts/$ID"

kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" --delete
gdbus call --session --dest org.kde.KWin --object-path /KWin \
  --method org.kde.KWin.reconfigure >/dev/null 2>&1 || true
rm -rf "$DEST"

echo "Desinstalado. Si el popup sigue apareciendo, cierra sesión y vuelve a entrar."
