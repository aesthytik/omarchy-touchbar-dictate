# Touch Bar Dictation

An Omarchy plugin that puts a 🎤 button on the MacBook Touch Bar. Tap it to start
[Superwhisper](https://superwhisper.com) dictation, tap it again to stop. The text is
typed wherever your cursor is.

## Requirements

- An Intel MacBook Pro with a Touch Bar (T2), running Omarchy with the `linux-t2` kernel
- Superwhisper for Linux
- `tiny-dfr` from the `arch-mact2` repo (setup installs it if it's missing)

## Install

```bash
omarchy plugin add https://github.com/aesthytik/omarchy-touchbar-dictate --enable
~/.config/omarchy/plugins/io.github.aesthytik.touchbar-dictate/setup.sh
```

Setup lists what it will change and asks before doing anything (pass `--yes` to skip
the question). It needs your password once. It:

1. installs `tiny-dfr`, which draws the Touch Bar, if it isn't installed;
2. writes `/etc/tiny-dfr/config.toml` with the media keys shown by default and a mic
   button at the end of both rows, backing up the existing file first;
3. adds one Hyprland binding to `~/.config/hypr/bindings.lua`, between marker comments,
   so the button's key (F19) runs `superwhisper record`.

Your normal Superwhisper shortcut keeps working.

## Remove

```bash
~/.config/omarchy/plugins/io.github.aesthytik.touchbar-dictate/remove.sh                       # undo the setup
~/.config/omarchy/plugins/io.github.aesthytik.touchbar-dictate/remove.sh --uninstall-tiny-dfr  # also remove tiny-dfr
omarchy plugin remove io.github.aesthytik.touchbar-dictate
```

Remove restores the backed-up Touch Bar config, deletes the mic icon and removes the
binding.

## Notes

- The Touch Bar can't show whether Superwhisper is recording, because tiny-dfr only draws
  fixed icons. Superwhisper's own recording indicator shows that.
- If the Touch Bar stays blank right after setup, reboot once.
