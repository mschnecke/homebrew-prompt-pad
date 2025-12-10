cask "prompt-pad" do
  version "1.1.2"
  sha256 arm:   "7f5bda347414962cf52b3864f977597898635c7cd063bc229c1c8c7fc094cb23",
         intel: "426a82815a4eea8b3d9f0c7054823452d41946a6e43e9ae9505dba857c38ae44"

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
