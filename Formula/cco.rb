# CCO - Claude Code Orchestrator
# Homebrew formula for private binary distribution
#
# Installation:
#   brew tap visiquate/cco https://github.com/visiquate/homebrew-cco
#   brew install visiquate/cco/cco
#
# Prerequisites:
#   - GitHub CLI (gh) must be installed and authenticated
#   - User must have read access to visiquate/cco repository

require_relative "../download_strategy"

class Cco < Formula
  desc "Claude Code Orchestrator - Multi-agent development system"
  homepage "https://github.com/visiquate/cco"
  version "2025.12.20"
  license :cannot_represent  # Proprietary

  # Platform-specific binary URLs
  # SHA256 values will be updated by CI after each release
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.20/cco-aarch64-apple-darwin.tar.gz",
        using: GitHubCliDownloadStrategy
    sha256 "a32923b0509bb40e679ceda2c6d1b42203c3bb521658c11dd52c3a0193df063c"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.20/cco-x86_64-unknown-linux-gnu.tar.gz",
        using: GitHubCliDownloadStrategy
    sha256 "a10e65d3a84627c967afc13f59b46c84a891233c8bb8bfc751bd71c01c7751e0"
  end

  # Dependencies
  depends_on "gh" => :build  # GitHub CLI for downloading from private releases
  # Note: Claude Code CLI is recommended but installed separately via:
  #   brew install --cask claude-code

  def install
    bin.install "cco"
  end

  def post_install
    ohai "CCO installed successfully!"
    ohai ""
    ohai "To start using CCO:"
    ohai "  1. Start the daemon: cco daemon start"
    ohai "  2. Check status:     cco daemon status"
    ohai "  3. View help:        cco --help"
    ohai ""
    ohai "Auto-updates are enabled by default. The daemon will check for"
    ohai "updates hourly and install them automatically."
    ohai ""
    ohai "To disable auto-updates: cco config set auto_update false"
  end

  def caveats
    <<~EOS
      CCO daemon should be started to enable:
        - Multi-agent orchestration
        - Automatic updates (hourly)
        - LLM gateway features

      Start the daemon with:
        cco daemon start

      For full functionality, install Claude Code CLI:
        brew install --cask claude-code

      For more information, see:
        https://github.com/visiquate/cco
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cco --version")
  end
end
