class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 3867f8e73d6f5c8f0d2d09db3b5ebb4f92bec368
  version "0.8.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.8.1/shoal-v0.8.1-macos-arm64.tar.gz"
      sha256 "817d35a776ab03e8ecefc3ee6901c4463cfa4d6f16c833eec4671f469b95ebfd"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.8.1/shoal-v0.8.1-macos-x86_64.tar.gz"
      sha256 "1d0e66cbfcf41e2655d814a32bc1158a9507372ebd83899329190c8a00789025"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.8.1/shoal-v0.8.1-linux-arm64.tar.gz"
      sha256 "7bfe832e2246cf0684f6df7363a45ec09230919899a3ffb2a930c96a80845c0b"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.8.1/shoal-v0.8.1-linux-x86_64.tar.gz"
      sha256 "d6d577fb9e633c0638c4b19c720e950bdf502a890e89562f3879188356d6d7f3"
    end
  end

  head do
    url "https://github.com/HN05/shoal.git", branch: "main"
    depends_on "rust" => :build
  end

  depends_on "fzf"
  depends_on "git"
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
      Install the agent skills once (they follow future Homebrew upgrades).
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
      assert_predicate installed, :symlink?
      assert_equal (opt_share/"shoal/skills/#{skill}/SKILL.md").to_s, installed.readlink.to_s
      assert_equal (share/"shoal/skills/#{skill}/SKILL.md").read, installed.read
    end
  end
end
