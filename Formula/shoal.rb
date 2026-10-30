class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 747a84d36564f12deb6929b92bb02088be990d95
  version "0.13.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.13.1/shoal-v0.13.1-macos-arm64.tar.gz"
      sha256 "7e6bdf18f161d377dc8c6f551dc032fd7212b290a9a4b6ec1704fba45093806e"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.13.1/shoal-v0.13.1-macos-x86_64.tar.gz"
      sha256 "e0f29a494e401ce843846daca94078e553abf773ab9bfadc5fd36d10d07700c8"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.13.1/shoal-v0.13.1-linux-arm64.tar.gz"
      sha256 "c71b34e82ff0a2a019b2ae8ede033c944fcc2a4ed220f49386d2b8c154f74fb6"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.13.1/shoal-v0.13.1-linux-x86_64.tar.gz"
      sha256 "757e8042aeba59d34527cb75cb5dcf2bd13cf94c740f96bfef34c5dec785d73a"
    end
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "neurosnap/tap/zmx"
  depends_on "worktrunk"
  uses_from_macos "lsof"

  def install
    libexec.install "shoal"
    (share/"shoal").install "skills"
    (libexec/"shoal-skills").make_symlink opt_share/"shoal/skills"
    bin.install_symlink libexec/"shoal"
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
