import QtQuick
import Quickshell.Io

// Checks whether the Touch Bar mic button is set up. The button itself lives in
// tiny-dfr's config and a Hyprland binding, both written by setup.sh, because a
// shell plugin runs as the user and can't change system files on its own.
Item {
  id: root

  // Injected by omarchy-shell.
  property var shell: null

  property bool checked: false
  property bool tinyDfrRunning: false
  property bool buttonInstalled: false
  property bool bindingInstalled: false
  readonly property bool ready: tinyDfrRunning && buttonInstalled && bindingInstalled

  function refresh() {
    if (!probe.running) probe.running = true
  }

  Component.onCompleted: refresh()

  Process {
    id: probe
    command: ["bash", "-c",
      "systemctl is-active --quiet tiny-dfr.service && echo dfr; " +
      "grep -q 'Icon = \"dictate\"' /etc/tiny-dfr/config.toml 2>/dev/null && echo button; " +
      "grep -q 'io.github.aesthytik.touchbar-dictate' \"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua\" 2>/dev/null && echo binding; true"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        const lines = text.split("\n")
        root.tinyDfrRunning = lines.indexOf("dfr") !== -1
        root.buttonInstalled = lines.indexOf("button") !== -1
        root.bindingInstalled = lines.indexOf("binding") !== -1
        root.checked = true
        if (!root.ready)
          console.warn("[touchbar-dictate] not fully set up; run setup.sh in the plugin folder")
      }
    }
  }
}
