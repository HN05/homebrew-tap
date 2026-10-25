class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 12779a4af0d555af07d7ea22e951600970fa0d7e
  version "0.10.7"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.7/shoal-v0.10.7-macos-arm64.tar.gz"
      sha256 "a7b105957928a637a6a5b930c553a22d37167fc4c617d3d917c1afb8b1cb06d4"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.7/shoal-v0.10.7-macos-x86_64.tar.gz"
      sha256 "3d187b8d030af819b690fab61240f1357caaf1fb2af12de1bffda60c6b51a5b4"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.7/shoal-v0.10.7-linux-arm64.tar.gz"
      sha256 "92993dfda731da99b547d0e488ee23a5424db4b7d978e0edd91646aa524a17f1"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.7/shoal-v0.10.7-linux-x86_64.tar.gz"
      sha256 "131d825e77c3e1fa144d2f0affac050340046c5f2d0b6854301b256b05a366be"
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
        shoal daemon install

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
