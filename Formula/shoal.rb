class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: a02f92fbd87b381a86fc673e0305888143283ad9
  version "0.10.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.6/shoal-v0.10.6-macos-arm64.tar.gz"
      sha256 "cac14ebdb545b64f60046090b21153c41bb5de8cd00192901f0979c0906ef341"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.6/shoal-v0.10.6-macos-x86_64.tar.gz"
      sha256 "4f220c365cf6d67c77d0fcfb29c023225ebabf5e27f41f106484d2220171d4fa"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.6/shoal-v0.10.6-linux-arm64.tar.gz"
      sha256 "1551c1276e790d0220f4ec0cb5b1558d197a9470f0b0704271626a671cce4e39"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.6/shoal-v0.10.6-linux-x86_64.tar.gz"
      sha256 "b0b599308ee9904bac28511e4749e0c4fd194fb0c9871edf62f9f8c1abcb7d96"
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
