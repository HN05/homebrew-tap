class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: a56f91ccd660811f512b094e9fa96eb92ad58177
  version "0.9.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.0/shoal-v0.9.0-macos-arm64.tar.gz"
      sha256 "96028b4b29048970d7a86c21faf7727b3156db3439b30522b02df02670782645"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.0/shoal-v0.9.0-macos-x86_64.tar.gz"
      sha256 "5e7ce39a7e5e15a1fb94db88e4272c81dac5f177dd597410b963923b63123a01"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.0/shoal-v0.9.0-linux-arm64.tar.gz"
      sha256 "7174db6dc40dbbcd8ccafbfd44f26bb804e97a94b92c36a0fe532a42a866b5e6"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.0/shoal-v0.9.0-linux-x86_64.tar.gz"
      sha256 "f2ae2d1d553561be86866a09d8994bcc2e5f81f9fb35091cab3f56a9dd540e03"
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
