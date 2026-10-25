class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: eb8189b8373af05acb7dbd6e710a7cabcfec35ed
  version "0.10.8"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.8/shoal-v0.10.8-macos-arm64.tar.gz"
      sha256 "c7de79c3f5f251efd04838b631d2f134d8c6108b76911ccebbee0531b2b9787e"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.8/shoal-v0.10.8-macos-x86_64.tar.gz"
      sha256 "2dd2cc0d173fbf7b8ca98801925781c10715359e8deb137446b09657e9f8ab50"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.8/shoal-v0.10.8-linux-arm64.tar.gz"
      sha256 "650583dd9ff004a91da9a6a0c2ec241f17f0196cbeca223790229a612ae00503"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.8/shoal-v0.10.8-linux-x86_64.tar.gz"
      sha256 "3b23ce87624785e185e291d9498ecbb8422e865f1cd40eb6ef83d99be6c50744"
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
