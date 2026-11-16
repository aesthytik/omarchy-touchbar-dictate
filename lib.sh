# Shared helpers for setup.sh and remove.sh. Sourced, not executed.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ETC_DIR=/etc/tiny-dfr
ETC_CONFIG=$ETC_DIR/config.toml
ETC_BACKUP=$ETC_CONFIG.touchbar-dictate.bak
ETC_ICON=$ETC_DIR/dictate.svg
BINDINGS="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"
MARK_BEGIN="-- >>> io.github.aesthytik.touchbar-dictate >>>"
MARK_END="-- <<< io.github.aesthytik.touchbar-dictate <<<"
DICTATE_KEY="F19"

say() { printf '\033[1m==>\033[0m %s\n' "$*"; }
die() { printf '\033[31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# sudo in a terminal, pkexec when there's no terminal to type a password into.
as_root() {
  if [[ $EUID -eq 0 ]]; then "$@"
  elif [[ -t 0 ]]; then sudo "$@"
  else pkexec "$@"
  fi
}

has_touchbar() {
  [[ -d /sys/module/hid_appletb_kbd ]] || modinfo appletbdrm >/dev/null 2>&1
}

remove_binding() {
  [[ -f $BINDINGS ]] || return 0
  sed -i "/^$(printf '%s' "$MARK_BEGIN" | sed 's/[]\/$*.^[]/\\&/g')\$/,/^$(printf '%s' "$MARK_END" | sed 's/[]\/$*.^[]/\\&/g')\$/d" "$BINDINGS"
}

reload_hyprland() {
  command -v hyprctl >/dev/null || return 0
  hyprctl reload >/dev/null
  local errs; errs="$(hyprctl configerrors 2>/dev/null || true)"
  [[ -z ${errs//[[:space:]]/} ]] || printf 'Hyprland config errors:\n%s\n' "$errs" >&2
}
