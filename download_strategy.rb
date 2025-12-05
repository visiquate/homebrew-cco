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

    # Check if gh is installed
    unless which("gh")
      raise "GitHub CLI (gh) is required but not installed. Install with: brew install gh"
    end

    # Check if gh is authenticated
    unless system("gh", "auth", "status", out: File::NULL, err: File::NULL)
      raise "GitHub CLI is not authenticated. Run: gh auth login"
    end

    # Create temporary directory for download
    FileUtils.mkdir_p(temporary_path.dirname)

    # Download using gh release download
    args = [
      "release", "download", @tag,
      "-R", "#{@owner}/#{@repo}",
      "--pattern", @filename,
      "-D", temporary_path.dirname.to_s,
      "--clobber"
    ]

    ohai "Running: gh #{args.join(' ')}"

    unless system("gh", *args)
      raise "Failed to download #{@filename} from #{@owner}/#{@repo}"
    end

    # Move downloaded file to expected location
    downloaded_file = temporary_path.dirname.join(@filename)
    unless downloaded_file.exist?
      raise "Downloaded file not found at #{downloaded_file}"
    end

    FileUtils.mv(downloaded_file, temporary_path)
  end

  def clear_cache
    super
  end
end
