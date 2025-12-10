# Homebrew Tap PRD: homebrew-prompt-pad

**Repository:** github.com/mschnecke/homebrew-prompt-pad  
**Main App Repository:** github.com/mschnecke/prompt-pad  
**License:** Proprietary - Pisum Projects  
**Document Version:** 1.0.0  
**Last Updated:** 2025-01-XX

---

## 1. Overview

This repository hosts the Homebrew Cask for PromptPad, enabling macOS users to install the application via Homebrew:

```bash
brew tap mschnecke/prompt-pad
brew install --cask prompt-pad
```

The cask installs PromptPad from `.pkg` installers hosted on GitHub Releases in the main prompt-pad repository.

---

## 2. Repository Structure

```
homebrew-prompt-pad/
├── .github/
│   └── workflows/
│       └── update-cask.yml      # Automated cask updates
├── Casks/
│   └── prompt-pad.rb            # Homebrew cask definition
├── CLAUDE.md                    # Claude Code guidance
└── README.md                    # Repository documentation
```

---

## 3. Cask Definition

### 3.1 Cask File (Casks/prompt-pad.rb)

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

  # Install the .pkg
  pkg "PromptPad_#{version}_#{arch == :arm64 ? 'aarch64' : 'x64'}.pkg"

  # Uninstall: remove pkg receipt and app
  uninstall pkgutil: "com.promptpad.app",
            delete: "/Applications/PromptPad.app"

  # Zap: remove all user data on full uninstall
  zap trash: [
    "~/Library/Application Support/com.promptpad.app",
    "~/Library/Caches/com.promptpad.app",
    "~/Library/Preferences/com.promptpad.app.plist",
    "~/Library/Saved Application State/com.promptpad.app.savedState",
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

### 3.2 Cask Properties Explained

| Property | Description |
|----------|-------------|
| `version` | Current version of PromptPad |
| `sha256` | SHA256 checksums for ARM64 and Intel packages |
| `url` | Download URL from GitHub Releases (architecture-specific) |
| `pkg` | Specifies this is a .pkg installer |
| `uninstall` | Removes package receipt and app on uninstall |
| `zap` | Removes all user data when `--zap` flag is used |
| `caveats` | Post-install instructions shown to user |

---

## 4. Automated Update Workflow

### 4.1 Workflow File (.github/workflows/update-cask.yml)

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
          
          # Update Cask file
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

### 4.2 Workflow Triggers

| Trigger | Description | Usage |
|---------|-------------|-------|
| `repository_dispatch` | Triggered by main prompt-pad repo after release | Automatic |
| `workflow_dispatch` | Manual trigger via GitHub Actions UI | Manual updates |

### 4.3 How Updates Work

1. Main prompt-pad repo publishes a new release
2. Release workflow triggers `update-cask` event via `repository_dispatch`
3. This workflow downloads the new .pkg files
4. Calculates SHA256 checksums
5. Updates `Casks/prompt-pad.rb` with new version and checksums
6. Creates a Pull Request for review
7. PR can be auto-merged if `automerge` label is configured

---

## 5. User Installation Commands

```bash
# Add tap (one-time setup)
brew tap mschnecke/prompt-pad

# Install PromptPad
brew install --cask prompt-pad

# Update to latest version
brew upgrade --cask prompt-pad

# Uninstall (keeps user data)
brew uninstall --cask prompt-pad

# Full uninstall (removes all user data)
brew uninstall --cask --zap prompt-pad

# Remove tap
brew untap mschnecke/prompt-pad
```

---

## 6. Integration with Main Repository

### 6.1 Main Repo Release Workflow Integration

The main prompt-pad repository triggers cask updates via:

```yaml
# In prompt-pad repo: .github/workflows/release.yml
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

### 6.2 Required Secrets

| Secret | Location | Description |
|--------|----------|-------------|
| `HOMEBREW_TAP_TOKEN` | prompt-pad repo | GitHub PAT with `repo` scope for homebrew-prompt-pad |
| `GITHUB_TOKEN` | homebrew-prompt-pad repo | Auto-provided, used for creating PRs |

---

## 7. README.md Template

```markdown
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
```

---

## 8. CLAUDE.md Template

```markdown
# CLAUDE.md - Homebrew Tap for PromptPad

## Repository Purpose

This repository hosts the Homebrew Cask for PromptPad, enabling installation via:
```bash
brew tap mschnecke/prompt-pad
brew install --cask prompt-pad
```

## Key Files

- `Casks/prompt-pad.rb` - Homebrew cask definition
- `.github/workflows/update-cask.yml` - Automated update workflow

## Update Process

The cask is automatically updated when a new release is published in the main prompt-pad repository:

1. Main repo releases new version
2. Release workflow triggers `update-cask` event
3. Workflow downloads .pkg files and calculates checksums
4. Creates PR with updated version and checksums

## Manual Update

To manually update the cask:

1. Go to Actions > Update Cask
2. Click "Run workflow"
3. Enter the version number (e.g., "1.2.0")
4. Review and merge the created PR

## Cask Structure

The cask downloads architecture-specific .pkg installers:
- ARM64: `PromptPad_X.Y.Z_aarch64.pkg`
- Intel: `PromptPad_X.Y.Z_x64.pkg`

## Testing Changes

```bash
# Test cask locally
brew install --cask ./Casks/prompt-pad.rb

# Audit cask
brew audit --cask prompt-pad

# Style check
brew style --fix Casks/prompt-pad.rb
```
```

---

## 9. Local Development & Testing

### 9.1 Test Cask Locally

```bash
# Clone the tap repository
git clone https://github.com/mschnecke/homebrew-prompt-pad.git
cd homebrew-prompt-pad

# Install from local cask file
brew install --cask ./Casks/prompt-pad.rb

# Uninstall
brew uninstall --cask prompt-pad
```

### 9.2 Audit Cask

```bash
# Check for common issues
brew audit --cask prompt-pad

# Check style
brew style Casks/prompt-pad.rb

# Auto-fix style issues
brew style --fix Casks/prompt-pad.rb
```

### 9.3 Manual Checksum Calculation

```bash
# Download and calculate checksums manually
VERSION="1.0.0"

curl -L -o arm64.pkg "https://github.com/mschnecke/prompt-pad/releases/download/v${VERSION}/PromptPad_${VERSION}_aarch64.pkg"
shasum -a 256 arm64.pkg

curl -L -o x64.pkg "https://github.com/mschnecke/prompt-pad/releases/download/v${VERSION}/PromptPad_${VERSION}_x64.pkg"
shasum -a 256 x64.pkg
```

---

## 10. Troubleshooting

### 10.1 Common Issues

| Issue | Solution |
|-------|----------|
| Checksum mismatch | Re-download .pkg and recalculate checksum |
| Cask not found | Ensure tap is added: `brew tap mschnecke/prompt-pad` |
| Permission denied | Grant Accessibility permissions in System Settings |
| Update not available | Run `brew update` first |

### 10.2 Debug Commands

```bash
# Update Homebrew
brew update

# Clear cask cache
brew cleanup --prune=all

# Reinstall cask
brew reinstall --cask prompt-pad

# Show cask info
brew info --cask prompt-pad
```

---

## 11. Release Checklist

When updating the cask manually:

- [ ] Download both .pkg files (ARM64 and x64)
- [ ] Calculate SHA256 checksums
- [ ] Update `version` in `Casks/prompt-pad.rb`
- [ ] Update `sha256 arm:` and `intel:` values
- [ ] Test locally: `brew install --cask ./Casks/prompt-pad.rb`
- [ ] Run audit: `brew audit --cask prompt-pad`
- [ ] Commit and push changes
- [ ] Verify installation: `brew install --cask prompt-pad`
