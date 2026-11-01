#!/usr/bin/env bash
# Instala kwin-desktop-osd para el usuario actual (sin sudo).
#
#   ./install.sh          instala como ENLACE SIMBÓLICO a este repositorio
#                         (para actualizar basta con «git pull» y reiniciar sesión)
#   ./install.sh --copy   copia los archivos (puedes borrar el repositorio después)
set -euo pipefail

ID="desktopnameosd"
REPO="$(cd "$(dirname "$0")" && pwd -P)"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/kwin/scripts/$ID"
MODE=link
[ "${1:-}" = "--copy" ] && MODE=copy

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }

echo "Comprobando requisitos…"
command -v kwriteconfig6 >/dev/null || fail "no encuentro kwriteconfig6: hace falta KDE Plasma 6"
if pgrep -x kwin_wayland >/dev/null || pgrep -x kwin_x11 >/dev/null; then
  ok "KWin en ejecución"
else
  warn "KWin no está en ejecución: se instalará, pero no se cargará hasta que entres en Plasma"
fi

echo "Instalando en $DEST…"
UPDATE=0
if [ -e "$DEST" ] || [ -L "$DEST" ]; then UPDATE=1; fi
mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
if [ "$MODE" = link ]; then
  ln -s "$REPO/package" "$DEST"
  ok "enlace simbólico → $REPO/package"
else
  cp -r "$REPO/package" "$DEST"
  ok "archivos copiados"
fi

kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" true
ok "script activado en kwinrc"

if gdbus call --session --dest org.kde.KWin --object-path /KWin \
     --method org.kde.KWin.reconfigure >/dev/null 2>&1; then
  ok "KWin recargado"
fi

echo
if [ "$UPDATE" = 1 ]; then
  echo "Actualizado. KWin guarda en caché el script anterior:"
  echo "cierra sesión y vuelve a entrar para ver los cambios."
else
  echo "Listo. Cambia de escritorio virtual para ver el popup."
  echo "Si no aparece, cierra sesión y vuelve a entrar."
fi
