class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 8f88f68bb801081c6a309c7b73470fe4a37a6021
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.7.0/shoal-v0.7.0-macos-arm64.tar.gz"
      sha256 "74a8c759e1f55bc41d1999fc188d6619a1f4358750c77344f710777cbe98e5de"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.7.0/shoal-v0.7.0-macos-x86_64.tar.gz"
      sha256 "e8a53164a0374334f6770501c12f324783008b05d051e52db14303072ddb65e5"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.7.0/shoal-v0.7.0-linux-arm64.tar.gz"
      sha256 "eb4c5db445a67ea1ee17c23b38e2669c84d828c462653883a1a8e876ffb1f791"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.7.0/shoal-v0.7.0-linux-x86_64.tar.gz"
      sha256 "4d4dc33ce350c1e87c4251b27b9a321c4527acc0bbe7a258a1add53e95ba1ed1"
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
      Install the agent skills once (they follow future Homebrew upgrades):
        #{opt_bin}/shoal skill install

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
