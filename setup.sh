#!/usr/bin/env bash
# Adds a mic button to the Touch Bar that starts/stops Superwhisper dictation.
# Safe to run again: it only changes what isn't set up yet.
source "$(dirname "$(readlink -f "$0")")/lib.sh"

has_touchbar || die "No Apple Touch Bar found (needs a T2 MacBook running linux-t2)."
command -v superwhisper >/dev/null || die "Superwhisper isn't installed."

if [[ ${1:-} != --yes ]]; then
  cat <<MSG
This will:
  - install tiny-dfr if it isn't installed (needs your password)
  - replace $ETC_CONFIG with a layout that adds a mic button
    (the current file is backed up to $ETC_BACKUP)
  - add one binding for $DICTATE_KEY to $BINDINGS, between marker comments
Run remove.sh at any time to undo all of it.
MSG
  if [[ -t 0 ]]; then
    read -rp "Continue? [y/N] " answer
    [[ $answer == [yY]* ]] || { echo "Nothing changed."; exit 0; }
  else
    die "Run this in a terminal to confirm, or pass --yes."
  fi
fi

if ! pacman -Q tiny-dfr >/dev/null 2>&1; then
  say "Installing tiny-dfr"
  as_root pacman -S --needed --noconfirm tiny-dfr
fi

say "Adding the mic button to the Touch Bar"
as_root sh -c '
  set -e
  if [ -f "$1" ] && [ ! -f "$2" ] && ! grep -q "io.github.aesthytik.touchbar-dictate" "$1"; then cp -p "$1" "$2"; fi
  install -Dm644 "$3" "$1"
  install -Dm644 "$4" "$5"
  modprobe appletbdrm 2>/dev/null || true
  udevadm trigger --subsystem-match=usb --attr-match=idVendor=05ac --attr-match=idProduct=8302 --action=add || true
  udevadm settle || true
  systemctl restart tiny-dfr.service
' _ "$ETC_CONFIG" "$ETC_BACKUP" "$PLUGIN_DIR/touchbar/config.toml" "$PLUGIN_DIR/touchbar/dictate.svg" "$ETC_ICON"

say "Binding the button ($DICTATE_KEY) to Superwhisper"
remove_binding
cat >>"$BINDINGS" <<LUA
$MARK_BEGIN
-- Touch Bar mic button sends $DICTATE_KEY. Managed by the touchbar-dictate plugin; run its remove.sh to undo.
o.bind("$DICTATE_KEY", "Dictation (Touch Bar)", "superwhisper record")
$MARK_END
LUA
reload_hyprland

if systemctl is-active --quiet tiny-dfr.service; then
  say "Done. Tap the mic on the Touch Bar to start dictating, tap again to stop."
else
  say "Set up. The Touch Bar will switch over after a reboot."
fi
