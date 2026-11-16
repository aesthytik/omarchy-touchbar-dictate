#!/usr/bin/env bash
# Undoes setup.sh. Pass --uninstall-tiny-dfr to also remove the tiny-dfr package.
source "$(dirname "$(readlink -f "$0")")/lib.sh"

say "Removing the Hyprland binding"
remove_binding
reload_hyprland

if [[ -f $ETC_ICON ]] || { [[ -f $ETC_CONFIG ]] && grep -q "io.github.aesthytik.touchbar-dictate" "$ETC_CONFIG"; }; then
  say "Restoring the Touch Bar config"
  as_root sh -c '
    set -e
    if [ -f "$2" ]; then mv -f "$2" "$1"
    elif grep -q "io.github.aesthytik.touchbar-dictate" "$1" 2>/dev/null; then rm -f "$1"; fi
    rm -f "$3"
    systemctl try-restart tiny-dfr.service || true
  ' _ "$ETC_CONFIG" "$ETC_BACKUP" "$ETC_ICON"
fi

if [[ ${1:-} == --uninstall-tiny-dfr ]] && pacman -Q tiny-dfr >/dev/null 2>&1; then
  say "Uninstalling tiny-dfr"
  as_root pacman -Rns --noconfirm tiny-dfr
fi

say "Removed."
