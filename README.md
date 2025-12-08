# Homebrew Tap for CCO

This is the Homebrew tap for CCO (Claude Code Orchestrator).

## Installation

### Prerequisites

1. Install Homebrew: https://brew.sh
2. Install GitHub CLI and authenticate:
   ```bash
   brew install gh
   gh auth login
   ```
3. You must have read access to the `visiquate/cco` repository

### Installing CCO

```bash
# Add the tap
brew tap visiquate/cco https://github.com/visiquate/homebrew-cco

# Install CCO
brew install visiquate/cco/cco

# Verify installation
cco --version
```

### Canonical Installation Path

The formula pipes through the official installer, so the binary ends up in `~/.local/bin/cco` (macOS/Linux). `cco update` only replaces binaries stored in the canonical paths documented in [visiquate/cco#canonical-installation-paths](https://github.com/visiquate/cco#canonical-installation-paths). If `which cco` still reports `/usr/local/bin/cco`, remove that legacy copy and reinstall so Homebrew's shim points at `~/.local/bin/cco`:

```bash
sudo rm -f /usr/local/bin/cco
brew reinstall visiquate/cco/cco
hash -r
echo $PATH  # ensure $HOME/.local/bin precedes /usr/local/bin
```

### Starting the Daemon

After installation, start the CCO daemon:

```bash
cco daemon start
```

The daemon enables:
- Multi-agent orchestration
- Automatic updates (checks hourly)
- LLM gateway features

## Updating

CCO has built-in auto-updates that run hourly when the daemon is running.

You can also update manually:
```bash
cco update          # Using built-in updater
brew upgrade cco    # Using Homebrew
```
> Both commands update the binary under `~/.local/bin/cco`; stale copies in `/usr/local/bin` will never change and should be removed.

## Uninstalling

```bash
cco daemon stop
brew uninstall cco
brew untap visiquate/cco
```

## Troubleshooting

### Authentication Errors

If you see authentication errors during installation:

1. Ensure GitHub CLI is authenticated:
   ```bash
   gh auth status
   ```

2. Re-authenticate if needed:
   ```bash
   gh auth login
   ```

3. Verify you have access to the CCO repository:
   ```bash
   gh repo view visiquate/cco
   ```

### Formula Updates

The formula is automatically updated when new releases are published.
SHA256 checksums are updated by CI after each release.

## Documentation

Full documentation is available at:
https://github.com/visiquate/cco

## Support

For issues, contact your administrator.
