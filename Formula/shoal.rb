class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 2e2bc300c0716dde95da778bce014b6cd0a86509
  version "0.12.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.12.0/shoal-v0.12.0-macos-arm64.tar.gz"
      sha256 "de1cd9193db6345745b342d9f3376f25f6ad8abb9fe816ca4ea70d6c1f1c5f2a"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.12.0/shoal-v0.12.0-macos-x86_64.tar.gz"
      sha256 "d928ebce9b85fb8ae017bbac225f6be3d60e2c4cdea7b045933074e0afc0513f"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.12.0/shoal-v0.12.0-linux-arm64.tar.gz"
      sha256 "e80286524e36667e05e0facd497fc32bfe30a45af0bc48f14b3d1003a6a4ed74"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.12.0/shoal-v0.12.0-linux-x86_64.tar.gz"
      sha256 "a47d3ea01a512844e7c8fc47082dd8734efc5441c3c4830929c883b1dbd7a644"
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
      Start the per-user daemon:
        shoal daemon install

      Install the agent skills into each tool's existing skill directory:
        shoal skill install

      Install them for one tool, creating its skill directory:
        shoal skill install claude

      Later shoal commands keep installed skills current.
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
