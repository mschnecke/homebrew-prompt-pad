# Implementation Plan: Homebrew Tap for PromptPad

**Status:** Completed
**Implemented:** 2025-12-10

---

## Overview

This plan details the implementation of a Homebrew tap for PromptPad, enabling macOS users to install via:

```bash
brew tap mschnecke/prompt-pad
brew install --cask prompt-pad
```

### Target Repository Structure

```
homebrew-prompt-pad/
├── .github/
│   └── workflows/
│       └── update-cask.yml
├── Casks/
│   └── prompt-pad.rb
├── docs/
│   ├── homebrew-prompt-pad-PRD.md
│   └── implementation-plan.md
├── CLAUDE.md
└── README.md
```

---

## File 1: Casks/prompt-pad.rb

Create the Homebrew cask definition:

```ruby
cask "prompt-pad" do
  version "1.0.0"
  sha256 arm:   "PLACEHOLDER_ARM64_SHA256",
         intel: "PLACEHOLDER_X64_SHA256"

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
```

---

## File 2: .github/workflows/update-cask.yml

Create the automated update workflow:

```yaml
name: Update Cask

on:
  repository_dispatch:
    types: [update-cask]
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to update to'
        required: true

jobs:
  update:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set version
        id: version
        run: |
          if [ "${{ github.event_name }}" == "repository_dispatch" ]; then
            echo "version=${{ github.event.client_payload.version }}" >> $GITHUB_OUTPUT
          else
            echo "version=${{ github.event.inputs.version }}" >> $GITHUB_OUTPUT
          fi

      - name: Download and calculate checksums
        id: checksums
        run: |
          VERSION="${{ steps.version.outputs.version }}"

          # Download ARM64 pkg
          curl -L -o arm64.pkg "https://github.com/mschnecke/prompt-pad/releases/download/v${VERSION}/PromptPad_${VERSION}_aarch64.pkg"
          ARM64_SHA=$(shasum -a 256 arm64.pkg | cut -d ' ' -f 1)
          echo "arm64_sha256=$ARM64_SHA" >> $GITHUB_OUTPUT

          # Download x64 pkg
          curl -L -o x64.pkg "https://github.com/mschnecke/prompt-pad/releases/download/v${VERSION}/PromptPad_${VERSION}_x64.pkg"
          X64_SHA=$(shasum -a 256 x64.pkg | cut -d ' ' -f 1)
          echo "x64_sha256=$X64_SHA" >> $GITHUB_OUTPUT

      - name: Update cask
        run: |
          VERSION="${{ steps.version.outputs.version }}"
          ARM64_SHA="${{ steps.checksums.outputs.arm64_sha256 }}"
          X64_SHA="${{ steps.checksums.outputs.x64_sha256 }}"

          sed -i '' "s/version \".*\"/version \"$VERSION\"/" Casks/prompt-pad.rb
          sed -i '' "s/arm:   \".*\"/arm:   \"$ARM64_SHA\"/" Casks/prompt-pad.rb
          sed -i '' "s/intel: \".*\"/intel: \"$X64_SHA\"/" Casks/prompt-pad.rb

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v5
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: "Update PromptPad cask to v${{ steps.version.outputs.version }}"
          title: "Update PromptPad to v${{ steps.version.outputs.version }}"
          body: |
            Automated cask update for PromptPad v${{ steps.version.outputs.version }}

            **Package checksums:**
            - ARM64 (.pkg): `${{ steps.checksums.outputs.arm64_sha256 }}`
            - x64 (.pkg): `${{ steps.checksums.outputs.x64_sha256 }}`
          branch: update-v${{ steps.version.outputs.version }}
          labels: automerge
```

---

## Implementation Order

1. Create `Casks/` directory
2. Create `Casks/prompt-pad.rb` with placeholder SHA256 values
3. Create `.github/workflows/` directory
4. Create `.github/workflows/update-cask.yml`
5. Test cask locally (once real packages exist)
6. Configure main repo to trigger updates

---

## Testing Instructions

```bash
# Install from local cask file
brew install --cask ./Casks/prompt-pad.rb

# Audit cask for issues
brew audit --cask prompt-pad

# Style check
brew style Casks/prompt-pad.rb

# Auto-fix style issues
brew style --fix Casks/prompt-pad.rb

# Manual checksum calculation
VERSION="1.0.0"
curl -L -o arm64.pkg "https://github.com/mschnecke/prompt-pad/releases/download/v${VERSION}/PromptPad_${VERSION}_aarch64.pkg"
shasum -a 256 arm64.pkg
```

---

## Integration Notes

### Main Repository Setup

The main `prompt-pad` repository needs to trigger this workflow on release. Add to `.github/workflows/release.yml`:

```yaml
update-homebrew:
  needs: [create-release, publish-release]
  runs-on: ubuntu-latest
  steps:
    - name: Trigger Homebrew cask update
      uses: peter-evans/repository-dispatch@v2
      with:
        token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
        repository: mschnecke/homebrew-prompt-pad
        event-type: update-cask
        client-payload: '{"version": "${{ needs.create-release.outputs.version }}"}'
```

### Required Secrets

| Secret | Location | Description |
|--------|----------|-------------|
| `HOMEBREW_TAP_TOKEN` | prompt-pad repo | GitHub PAT with `repo` scope for homebrew-prompt-pad |
| `GITHUB_TOKEN` | homebrew-prompt-pad | Auto-provided for PR creation |
