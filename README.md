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
