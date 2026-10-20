class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 1fbd69754452c2df8d537c333faaa356afcc2f01
  version "0.9.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.4/shoal-v0.9.4-macos-arm64.tar.gz"
      sha256 "bdfea932e53df78076326838dd082e2bdf862e8d9f0181feda60ca759cded6b7"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.4/shoal-v0.9.4-macos-x86_64.tar.gz"
      sha256 "aa6d6777c2b90041ac53940dfcc13d1f9d975c3c8790447f7556b9a255c02d0b"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.4/shoal-v0.9.4-linux-arm64.tar.gz"
      sha256 "d298993785bcb58777524be92c669d21ed6533d18abe2763785c18852962e344"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.4/shoal-v0.9.4-linux-x86_64.tar.gz"
      sha256 "f7c4f45f8a7e127ede96fdcab43db779b88b617f6c53ac0942302c4b4aa06fe1"
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
