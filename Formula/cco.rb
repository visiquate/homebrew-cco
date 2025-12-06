# CCO - Claude Code Orchestrator
# Homebrew formula for binary distribution
#
# Installation:
#   brew tap visiquate/cco
#   brew install visiquate/cco/cco

class Cco < Formula
  desc "Claude Code Orchestrator - Multi-agent development system"
  homepage "https://github.com/visiquate/cco"
  version "2025.12.21"
  license :cannot_represent  # Proprietary

  # Platform-specific binary URLs
  # SHA256 values will be updated by CI after each release
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.21/cco-aarch64-apple-darwin.tar.gz"
    sha256 "14c24fb2788cf2310275854c3d43a5b194079973a15da2e5157870b08effda8b"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.21/cco-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "ba2537a74f878cfa3e60e10dc4362150c066523b6b82ad78495c958366ab2baa"
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
