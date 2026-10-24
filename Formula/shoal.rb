class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 295d956a3fb6327b7c440ebec73bbdb82bc72ed4
  version "0.10.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.5/shoal-v0.10.5-macos-arm64.tar.gz"
      sha256 "b235d3e144249735032aa8afad0f58d5eed92a620ae289dcf17c93d4d33c13ee"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.5/shoal-v0.10.5-macos-x86_64.tar.gz"
      sha256 "4f1fe48320d0608cd6c87df2933dad3aa59efb1f7ca62f4413fd73eb86b6da8c"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.5/shoal-v0.10.5-linux-arm64.tar.gz"
      sha256 "b56c88a4c672fe74cfcea02a9d10113c7a4118e3692ac5f8cc8664d8fbd3f15d"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.5/shoal-v0.10.5-linux-x86_64.tar.gz"
      sha256 "7c79c7dfe5fa9508f51e6d78dfca64fafd68908524ee9468c4f85ccfe3d8651a"
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
