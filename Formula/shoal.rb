class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 549ccb034682d79f71bca7e6511498568c4fa832
  version "0.10.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.4/shoal-v0.10.4-macos-arm64.tar.gz"
      sha256 "79cebae627a86341a75c03dc6d48735075d37ae8e24c6827111c68d9c8db85ea"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.4/shoal-v0.10.4-macos-x86_64.tar.gz"
      sha256 "098289898e8e1c7b63781c394748a00550c99b03cd3ef4e6e3804e9ea95d341f"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.4/shoal-v0.10.4-linux-arm64.tar.gz"
      sha256 "aba4c807a942f378697410c1c9778bfb6d83a0ab7a4809f61f135a8f0352889b"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.4/shoal-v0.10.4-linux-x86_64.tar.gz"
      sha256 "96f2c72cfaf9ed966d11bf049e3eaab8f4b2a378d3d6cb0e5e3894627f2ee029"
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
