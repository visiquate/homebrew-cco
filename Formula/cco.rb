# CCO - Claude Code Orchestrator
# Homebrew formula for binary distribution
#
# Installation:
#   brew tap visiquate/cco
#   brew install cco

class Cco < Formula
  desc "Claude Code Orchestrator - Multi-agent development system"
  homepage "https://github.com/visiquate/cco"
  version "2025.12.23"
  license :cannot_represent  # Proprietary

  # Platform-specific binary URLs
  # SHA256 values will be updated by CI after each release
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.23/cco-aarch64-apple-darwin.tar.gz"
    sha256 "287b55d39cfb7279aec46fa4bb3b5c0acb99ebdfa8a9fdb7e9ac95fa5773c761"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.23/cco-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "8bbbc13bd056fc860600dd09e67e1833af631e42275570515ae0bff63c0a2677"
  end

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

      Upgrade with:
        brew upgrade cco

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
