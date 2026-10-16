class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 8891d59bed5b2e802d75328c36ac9dd786f37f95
  version "0.9.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.2/shoal-v0.9.2-macos-arm64.tar.gz"
      sha256 "4b0c2d41177c2195435787abc79cdf328d09370e352f142ec91be51ae2d18a31"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.2/shoal-v0.9.2-macos-x86_64.tar.gz"
      sha256 "8dd183e2a3a0034f5ec279852caec446df179cc46140d9bec979e116e3ef70ea"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.2/shoal-v0.9.2-linux-arm64.tar.gz"
      sha256 "733dfd9761a5e8f81faeac466c889cefa92a47d0cec8b46a79591cc013b55002"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.2/shoal-v0.9.2-linux-x86_64.tar.gz"
      sha256 "4a961be952a433683613ef22d4b0397cfffbecf0d7374ee0f291c1815838a7eb"
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
      Install the agent skills once (later shoal commands update them after upgrades).
      This fills existing skill directories; name a tool to create its directory:
        #{opt_bin}/shoal skill install
        #{opt_bin}/shoal skill install claude

      Register the per-user daemon:
        shoal install

      The managed daemon applies upgrades when its clients and operations are idle.
      To apply an upgrade immediately, restart the daemon:
        #{opt_bin}/shoal daemon restart
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
