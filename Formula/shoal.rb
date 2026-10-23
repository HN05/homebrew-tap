class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: e1bc38c5237f3348991980ba435a6f021b9da637
  version "0.10.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.0/shoal-v0.10.0-macos-arm64.tar.gz"
      sha256 "e332d750f59e2b43040798943bd923ba019af6d90a07ecab94af71c48f3787c9"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.0/shoal-v0.10.0-macos-x86_64.tar.gz"
      sha256 "1849e264aad862634fca99037cdd0e30808b805603e52d9262e99a79f085e115"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.0/shoal-v0.10.0-linux-arm64.tar.gz"
      sha256 "9472a40340ca988b989ca30d08174491a02a8ade5c8748b30eb7ce43c0a1674a"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.0/shoal-v0.10.0-linux-x86_64.tar.gz"
      sha256 "a665f8ac0a5630d2b47bd0fc9d58fcc00093a78694ddb07eeef712bffd3362b3"
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
