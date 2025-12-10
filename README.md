# Homebrew Tap for PromptPad

Official Homebrew cask for [PromptPad](https://github.com/mschnecke/prompt-pad), a Spotlight-style prompt launcher for macOS.

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

| Location | Purpose |
|----------|---------|
| `~/.prompt-pad/prompts/` | User prompts |
| `~/.prompt-pad.json` | Settings |

## Architecture Support

The cask automatically installs the correct version for your Mac:
- Apple Silicon (M1/M2/M3): `aarch64.pkg`
- Intel: `x64.pkg`

## Automatic Updates

This tap automatically stays in sync with PromptPad releases. When a new version is published to the [main repository](https://github.com/mschnecke/prompt-pad), a GitHub Actions workflow updates this cask with new version numbers and checksums.

## Links

- [PromptPad Repository](https://github.com/mschnecke/prompt-pad)
- [Releases](https://github.com/mschnecke/prompt-pad/releases)
- [Issues](https://github.com/mschnecke/prompt-pad/issues)
