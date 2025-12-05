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
  version "2025.12.4"
  license :cannot_represent  # Proprietary

  # Platform-specific binary URLs
  # SHA256 values will be updated by CI after each release
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.4/cco-aarch64-apple-darwin.tar.gz",
        using: GitHubCliDownloadStrategy
    sha256 "PLACEHOLDER_SHA256_ARM64_DARWIN"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.4/cco-x86_64-apple-darwin.tar.gz",
        using: GitHubCliDownloadStrategy
    sha256 "PLACEHOLDER_SHA256_X86_64_DARWIN"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.4/cco-x86_64-unknown-linux-gnu.tar.gz",
        using: GitHubCliDownloadStrategy
    sha256 "PLACEHOLDER_SHA256_X86_64_LINUX"
  end

  # Dependencies
  depends_on "gh" => :build  # GitHub CLI for downloading from private releases

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

      For more information, see:
        https://github.com/visiquate/cco
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cco --version")
  end
end
