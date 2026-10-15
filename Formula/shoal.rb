class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 4b35a61b394923a86403ce17ec60a5084adf5d88
  version "0.9.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.1/shoal-v0.9.1-macos-arm64.tar.gz"
      sha256 "bf248c952b4a388ebbc4a9d52e90fa1211fe42daa9c8008b89af305f1f5c3d67"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.1/shoal-v0.9.1-macos-x86_64.tar.gz"
      sha256 "a050470db1547f4c8adcc9a469f7c5595ce2ecd82dba21a2424c6ea48807480a"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.1/shoal-v0.9.1-linux-arm64.tar.gz"
      sha256 "ff85855824d06f47f7063558aebaca881cbd1d9dc45ffdac50f22b82665d8339"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.1/shoal-v0.9.1-linux-x86_64.tar.gz"
      sha256 "dbd6f0747522bb70ba34f21b3a14e70f8d6b926b465fc9071bfe31f812937c19"
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
