class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 6d37adef17da9c5c32ab4222e6357524fbfe0661
  version "0.9.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.5/shoal-v0.9.5-macos-arm64.tar.gz"
      sha256 "3a79b76a8c94803d0ec70b4388b46bde724aca341a42bf46017b381c64d1c2b2"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.5/shoal-v0.9.5-macos-x86_64.tar.gz"
      sha256 "0adfbfa6cb58c12208e5dbb45361cc41f801baca237fb2d4b6b4d2a4432fb43a"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.5/shoal-v0.9.5-linux-arm64.tar.gz"
      sha256 "486fd9cfb1fb3b5f11165f87933675ec177445b0f6fa69ec94293bb73486303c"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.5/shoal-v0.9.5-linux-x86_64.tar.gz"
      sha256 "8a2e080d3e814a47f121d8cfe9e3626352a09ff6fb673ce42bf15f0e68f72729"
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
