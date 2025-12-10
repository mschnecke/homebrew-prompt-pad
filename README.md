# Homebrew Tap for PromptPad

This is the official Homebrew tap for [PromptPad](https://github.com/mschnecke/prompt-pad), a Spotlight-style prompt launcher for macOS.

## Installation

```bash
brew tap mschnecke/prompt-pad
brew install --cask prompt-pad
```

## Update

```bash
brew upgrade --cask prompt-pad
```

## Uninstall

```bash
# Keep user data
brew uninstall --cask prompt-pad

# Remove everything including user data
brew uninstall --cask --zap prompt-pad

# Remove tap
brew untap mschnecke/prompt-pad
```

## Post-Installation

PromptPad requires Accessibility permissions to register global hotkeys.

1. Open **System Settings** > **Privacy & Security** > **Accessibility**
2. Enable **PromptPad** in the list

Default hotkey: `Cmd+Shift+P`

## Data Locations

- Prompts: `~/.prompt-pad/prompts/`
- Settings: `~/.prompt-pad.json`

## Links

- [PromptPad Repository](https://github.com/mschnecke/prompt-pad)
- [Releases](https://github.com/mschnecke/prompt-pad/releases)
- [Issues](https://github.com/mschnecke/prompt-pad/issues)
