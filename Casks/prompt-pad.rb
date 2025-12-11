cask "prompt-pad" do
  version "1.1.6"
  sha256 arm:   "d5b0b9dd05167ff1955fc4fad506db7e79e3940e30e517bc4753bc44886096bc"
  url "https://github.com/mschnecke/prompt-pad/releases/download/v#{version}/PromptPad_#{version}_aarch64.pkg"

  name "PromptPad"
  desc "Spotlight-style prompt launcher"
  homepage "https://github.com/mschnecke/prompt-pad"

  pkg "PromptPad_#{version}_aarch64.pkg"

  uninstall pkgutil: "net.pisum.promptpad.app",
            delete: "/Applications/PromptPad.app"

  zap trash: [
    "~/Library/Application Support/net.pisum.promptpad.app",
    "~/Library/Caches/net.pisum.promptpad.app",
    "~/Library/Preferences/net.pisum.promptpad.app.plist",
    "~/Library/Saved Application State/net.pisum.promptpad.app.savedState",
    "~/.prompt-pad",
    "~/.prompt-pad.json",
  ]

  caveats <<~EOS
    PromptPad requires Accessibility permissions to register global hotkeys.

    To grant permissions:
    1. Open System Settings > Privacy & Security > Accessibility
    2. Enable PromptPad in the list

    Default hotkey: Cmd+Shift+P

    Prompts are stored in: ~/.prompt-pad/prompts/
    Settings are stored in: ~/.prompt-pad.json
  EOS
end
