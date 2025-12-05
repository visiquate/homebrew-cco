# Custom download strategy for private GitHub releases
# Uses the GitHub CLI (gh) for authenticated downloads
#
# This strategy is required because standard curl cannot download from
# private GitHub release assets. The gh CLI handles authentication
# using the user's GitHub credentials.

class GitHubCliDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    parse_url
  end

  def parse_url
    match_data = %r{^https?://github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/releases/download/(?<tag>[^/]+)/(?<filename>.+)$}.match(@url)
    if match_data
      @owner = match_data[:owner]
      @repo = match_data[:repo]
      @tag = match_data[:tag]
      @filename = match_data[:filename]
    else
      raise "Invalid GitHub release URL: #{@url}"
    end
  end

  def fetch(timeout: nil)
    ohai "Downloading #{@filename} from #{@owner}/#{@repo} using GitHub CLI"

    # Check if gh is installed (search common paths)
    gh_paths = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh", "/usr/bin/gh"]
    gh_path = gh_paths.find { |p| File.exist?(p) } || `which gh 2>/dev/null`.strip
    gh_path = nil if gh_path.empty?

    unless gh_path && File.executable?(gh_path)
      raise "GitHub CLI (gh) is required but not installed. Install with: brew install gh"
    end

    # Check if gh is authenticated
    unless system(gh_path, "auth", "status", out: File::NULL, err: File::NULL)
      raise "GitHub CLI is not authenticated. Run: gh auth login"
    end

    # Create temporary directory for download
    FileUtils.mkdir_p(temporary_path.dirname)

    # Create a unique temp directory for the download
    temp_download_dir = Dir.mktmpdir("homebrew-gh-download")

    # Download using gh release download to temp dir
    args = [
      "release", "download", @tag,
      "-R", "#{@owner}/#{@repo}",
      "--pattern", @filename,
      "-D", temp_download_dir,
      "--clobber"
    ]

    ohai "Running: #{gh_path} #{args.join(' ')}"

    unless system(gh_path, *args)
      FileUtils.rm_rf(temp_download_dir)
      raise "Failed to download #{@filename} from #{@owner}/#{@repo}"
    end

    # Find the downloaded file and move it to the expected location
    downloaded_file = File.join(temp_download_dir, @filename)
    unless File.exist?(downloaded_file)
      FileUtils.rm_rf(temp_download_dir)
      raise "Downloaded file not found at #{downloaded_file}"
    end

    # Move to the location Homebrew expects (temporary_path is where it goes during download)
    FileUtils.mv(downloaded_file, temporary_path)
    FileUtils.rm_rf(temp_download_dir)
  end

  def clear_cache
    super
  end
end
