class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 198ce0c4279c25330fda9776e3b77ae59b303cb3
  version "0.8.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.8.2/shoal-v0.8.2-macos-arm64.tar.gz"
      sha256 "7c2b1bfefd9132ab3ded9cf66ec7fafdee32627f0b5d3a132f229db88b2859c0"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.8.2/shoal-v0.8.2-macos-x86_64.tar.gz"
      sha256 "ad314ec86327fa136093f165188b3166ae8fd4963435971cb896070e6b61963f"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.8.2/shoal-v0.8.2-linux-arm64.tar.gz"
      sha256 "3dc131c416825e1d63e1ad6b99a55d6185526d59c85efa994a926d13f9995163"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.8.2/shoal-v0.8.2-linux-x86_64.tar.gz"
      sha256 "bbdbe2e646ff50eb91923bd93b6600ca5f08a9252d938925880f91644a1d4272"
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
