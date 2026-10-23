class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 0eb0f6e0f7e520d1877b78ebc66dd51ca6d0af36
  version "0.10.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.1/shoal-v0.10.1-macos-arm64.tar.gz"
      sha256 "d0fcdc26d78462f6787d4689dd2aee522aae7e44e5084b8cb84a9736e3332d6b"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.1/shoal-v0.10.1-macos-x86_64.tar.gz"
      sha256 "fd0cf09f3681bfd94a7d88a58e075e9947ca2baa4c12af76f8a3ade314a1dca5"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.1/shoal-v0.10.1-linux-arm64.tar.gz"
      sha256 "ec211ec59e25ab0f7338243737b0e975adebeb386554e0b9fb1557fb0f41625e"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.1/shoal-v0.10.1-linux-x86_64.tar.gz"
      sha256 "15322d92f61fd35b1fe689dfa3b186f22e27fd25f5ac7738b652699d82e4f415"
    end
  end

  head do
    url "https://github.com/HN05/shoal.git", branch: "main"
    depends_on "rust" => :build
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "neurosnap/tap/zmx"
  depends_on "worktrunk"
  uses_from_macos "lsof"

  def install
    if build.head?
      system "bash", "scripts/install-homebrew.sh", prefix, opt_prefix,
                     "--jobs", ENV.make_jobs.to_s
    else
      libexec.install "shoal"
      (share/"shoal").install "skills"
      (libexec/"shoal-skills").make_symlink opt_share/"shoal/skills"
      bin.install_symlink libexec/"shoal"
    end
  end

  def caveats
    <<~EOS
      Start the per-user daemon:
        shoal install

      Install the agent skills into each tool's existing skill directory:
        shoal skill install

      Install them for one tool, creating its skill directory:
        shoal skill install claude

      Later shoal commands keep installed skills current.
    EOS
  end

  test do
    assert_match "shoal", shell_output("#{bin}/shoal --version")
    assert_match "name: shoal-worker", shell_output("#{bin}/shoal skill")
    assert_match "name: shoal-orchestrator", shell_output("#{bin}/shoal skill orchestrator")
    ENV["HOME"] = testpath.to_s
    ENV.delete "SHOAL_SCOPE_TOKEN"
    system bin/"shoal", "skill", "install", "codex"
    %w[shoal-worker shoal-orchestrator].each do |skill|
      installed = testpath/".agents/skills/#{skill}/SKILL.md"
      refute_predicate installed, :symlink?
      assert_equal (share/"shoal/skills/#{skill}/SKILL.md").read, installed.read
    end
  end
end
