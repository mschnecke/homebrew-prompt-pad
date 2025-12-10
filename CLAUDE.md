# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Homebrew Cask tap for PromptPad, enabling macOS users to install via:
```bash
brew tap mschnecke/prompt-pad
brew install --cask prompt-pad
```

## Key Files

- `Casks/prompt-pad.rb` - Homebrew cask definition (Ruby)
- `.github/workflows/update-cask.yml` - Automated cask update workflow

## Testing Commands

```bash
# Install from local cask file
brew install --cask ./Casks/prompt-pad.rb

# Audit cask for issues
brew audit --cask prompt-pad

# Style check and auto-fix
brew style --fix Casks/prompt-pad.rb

# Manual checksum calculation
shasum -a 256 <pkg-file>
```

## Update Process

The cask auto-updates when the main prompt-pad repo publishes a release:
1. Main repo triggers `repository_dispatch` event to this repo
2. Workflow downloads ARM64 and Intel .pkg files
3. Calculates SHA256 checksums
4. Updates cask file with new version and checksums
5. Creates PR and auto-merges it

Manual updates: Actions > Update Cask > Run workflow > Enter version

**Note:** Auto-merge requires "Allow auto-merge" enabled in repository settings.

## Cask Architecture

Downloads architecture-specific `.pkg` installers from GitHub Releases:
- ARM64: `PromptPad_X.Y.Z_aarch64.pkg`
- Intel: `PromptPad_X.Y.Z_x64.pkg`

Related repository: github.com/mschnecke/prompt-pad
