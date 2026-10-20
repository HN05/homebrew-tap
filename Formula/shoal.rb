class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 659c9c8539479ba9911b48c3bdb891aef0f35a46
  version "0.9.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.6/shoal-v0.9.6-macos-arm64.tar.gz"
      sha256 "c6c35c6c3139b4077c5368df823e6214db16e92830dd73744a084fd78d7426bf"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.6/shoal-v0.9.6-macos-x86_64.tar.gz"
      sha256 "62c80b3996bff58e8a7169a6f489e04a2564cc8219b538349afcf0926d304f13"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.6/shoal-v0.9.6-linux-arm64.tar.gz"
      sha256 "fcb573f8774ada221f8096c119e0156a7bf18c848db41f607c374ceec9191c5d"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.6/shoal-v0.9.6-linux-x86_64.tar.gz"
      sha256 "850281d90978bd6f05d2d33bd35e0f6a1951e4c35d4413fc4e6c66adfaca7990"
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
