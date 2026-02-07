# CCO - Claude Code Orchestrator
# Homebrew formula for binary distribution
#
# Installation:
#   brew tap visiquate/cco
#   brew install cco
#
# This formula installs CCO to ~/.local/bin/cco (not Homebrew's bin)
# to ensure auto-updates work correctly with a single installation location.

class Cco < Formula
  desc "Claude Code Orchestrator - Multi-agent development system"
  homepage "https://github.com/visiquate/cco"
  version "2026.2.22"
  license :cannot_represent  # Proprietary
 
  # Platform-specific binary URLs
  # SHA256 values will be updated by CI after each release
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/visiquate/cco/releases/download/v2026.2.22/cco-aarch64-apple-darwin.tar.gz"
    sha256 "43fa6e4cab55f16e33ab817ea66a76c0664fdf55d7bf4a793bf641a0aec67f47"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/visiquate/cco/releases/download/v2025.12.58/cco-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "84736d3bdab7c589ada2752b9eb2364ed5efcaf05970a9d2ad47becdbcd6ece1"
  end


  def install
    # Initially install to Homebrew's bin directory
    # The post_install hook will move it to ~/.local/bin
    bin.install "cco"
  end

  def post_install
    begin
      # Target location for the binary
      local_bin = File.expand_path("~/.local/bin")
      target_path = File.join(local_bin, "cco")
      source_path = File.join(bin, "cco")

      # Create ~/.local/bin if it doesn't exist
      FileUtils.mkdir_p(local_bin) unless Dir.exist?(local_bin)

      # Move the binary from Homebrew's bin to ~/.local/bin
      if File.exist?(source_path)
        FileUtils.mv(source_path, target_path, force: true)
        FileUtils.chmod(0755, target_path)
        ohai "Binary moved to #{target_path}"
      else
        opoo "Warning: Source binary not found at #{source_path}"
      end

      # Update shell PATH configuration
      update_shell_path(local_bin)

      ohai ""
      ohai "CCO installed successfully to ~/.local/bin/cco"
      ohai ""
      ohai "IMPORTANT: Restart your terminal or run:"

      shell = ENV["SHELL"]
      if shell&.include?("zsh")
        ohai "  source ~/.zshrc"
      elsif shell&.include?("bash")
        ohai "  source ~/.bashrc"
      elsif shell&.include?("fish")
        ohai "  source ~/.config/fish/config.fish"
      else
        ohai "  source <your shell config file>"
      end

      ohai ""
      ohai "Then start the daemon: cco daemon start"

    rescue => e
      opoo "Error during post-installation: #{e.message}"
      opoo "You may need to manually move the binary to ~/.local/bin/cco"
    end
  end

  # Helper method to update shell PATH configuration
  def update_shell_path(local_bin)
    begin
      shell = ENV["SHELL"]

      # Determine the appropriate RC file based on shell
      rc_file = if shell&.include?("zsh")
                  File.expand_path("~/.zshrc")
                elsif shell&.include?("bash")
                  bashrc = File.expand_path("~/.bashrc")
                  bash_profile = File.expand_path("~/.bash_profile")
                  File.exist?(bashrc) ? bashrc : bash_profile
                elsif shell&.include?("fish")
                  File.expand_path("~/.config/fish/config.fish")
                else
                  nil
                end

      return unless rc_file

      # Path export line to add
      path_export = 'export PATH="$HOME/.local/bin:$PATH"'
      fish_path_export = "set -gx PATH $HOME/.local/bin $PATH"

      export_line = shell&.include?("fish") ? fish_path_export : path_export

      # Check if PATH is already configured
      if File.exist?(rc_file)
        content = File.read(rc_file)
        if content.include?(".local/bin") && content.include?("PATH")
          ohai "Shell PATH already configured in #{rc_file}"
          return
        end
      end

      # Create config directory for fish if needed
      if shell&.include?("fish")
        config_dir = File.dirname(rc_file)
        FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      end

      # Append PATH configuration
      File.open(rc_file, "a") do |f|
        f.puts ""
        f.puts "# Added by CCO Homebrew installer"
        f.puts export_line
      end

      ohai "Updated PATH in #{rc_file}"

    rescue => e
      opoo "Could not update shell PATH: #{e.message}"
      opoo "Please manually add ~/.local/bin to your PATH"
    end
  end

  def caveats
    <<~EOS
      CCO has been installed to ~/.local/bin/cco

      RESTART YOUR TERMINAL or source your shell config:
        source ~/.zshrc      # zsh (macOS default)
        source ~/.bashrc     # bash (Linux)
        source ~/.config/fish/config.fish  # fish

      If PATH isn't configured, manually add:
        export PATH="$HOME/.local/bin:$PATH"

      Start the daemon:
        cco daemon start

      Auto-updates will keep ~/.local/bin/cco up to date automatically.
      You can also run: brew upgrade cco

      For more information:
        https://github.com/visiquate/cco
    EOS
  end

  test do
    # Test that the binary exists in ~/.local/bin after installation
    local_cco = File.expand_path("~/.local/bin/cco")
    if File.exist?(local_cco)
      assert_match version.to_s, shell_output("#{local_cco} --version")
    else
      # Fallback to Homebrew's bin if post_install didn't run (e.g., during formula audit)
      assert_match version.to_s, shell_output("#{bin}/cco --version")
    end
  end
end
