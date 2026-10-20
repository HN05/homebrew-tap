class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 9f848f01bdf7e798a64a874a96408f575f6dd3ef
  version "0.9.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.3/shoal-v0.9.3-macos-arm64.tar.gz"
      sha256 "e9e13c9281408d4bb4bb5f5efc51cf4690bb2fb08f7dd11495fa69ea958ba514"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.3/shoal-v0.9.3-macos-x86_64.tar.gz"
      sha256 "19130fa973ccf303b3e07706d596534920ebdcdd4e10a5cd4d8bce75e0104a48"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.3/shoal-v0.9.3-linux-arm64.tar.gz"
      sha256 "64aa368ec2ca3258f46f9e84eaec0d8dc6d4fcd903b4d942c525d03683039aa7"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.3/shoal-v0.9.3-linux-x86_64.tar.gz"
      sha256 "023695694860ac9dd94ba1be2497e102fff919309db20aca1fd42434a65c5710"
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
