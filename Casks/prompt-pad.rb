cask "prompt-pad" do
  version "1.1.1"
  sha256 arm:   "3e923910cb0b7e2cc47a2b1d0c16178eab76587958d8b56d78e49128ce7c0508",
         intel: "5dc6ad166e2ecf6cd2d53caa70dd42d2e827858114148a56c1ffe4ff747c3ec9"

  on_arm do
    url "https://github.com/mschnecke/prompt-pad/releases/download/v#{version}/PromptPad_#{version}_aarch64.pkg"
  end
  on_intel do
    url "https://github.com/mschnecke/prompt-pad/releases/download/v#{version}/PromptPad_#{version}_x64.pkg"
  end

  name "PromptPad"
  desc "Spotlight-style prompt launcher"
  homepage "https://github.com/mschnecke/prompt-pad"

  pkg "PromptPad_#{version}_#{arch == :arm64 ? 'aarch64' : 'x64'}.pkg"

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
