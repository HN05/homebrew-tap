class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: bfe1b7f258369d809392984ce3f9c68a46c6648c
  version "0.15.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.2/shoal-v0.15.2-macos-arm64.tar.gz"
      sha256 "4c7008849391de49aa0712b2c8b6ab77f55eb422885ff3656336ea9550b4aa43"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.2/shoal-v0.15.2-macos-x86_64.tar.gz"
      sha256 "9894af7d4c7cad7435b9ffb1bfa0118487dc5d68351fcacd631630557e80096c"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.2/shoal-v0.15.2-linux-arm64.tar.gz"
      sha256 "d6224842c85959349993d447017dc5a0909017eee1eb523e7ba1c8f4c3cd81f7"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.2/shoal-v0.15.2-linux-x86_64.tar.gz"
      sha256 "4ab3e73aafa98bcdeaff573a4f8a20cddce0ba170b6cc6694f0da27b230fadba"
    end
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "worktrunk"
  uses_from_macos "lsof"

  def install
    # macOS keeps privacy grants for an app bundle across upgrades, but for a
    # bare executable only at its versioned Cellar path.
    if OS.mac?
      libexec.install "Shoal.app"
      bin.install_symlink libexec/"Shoal.app/Contents/MacOS/shoal"
    else
      libexec.install "shoal"
      bin.install_symlink libexec/"shoal"
    end
    (share/"shoal").install "skills"
    (libexec/"shoal-skills").make_symlink opt_share/"shoal/skills"
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

      Agents started from a terminal run in zmx sessions by default:
        brew install neurosnap/tap/zmx
    EOS
  end

  test do
    system "codesign", "--verify", "--strict", libexec/"Shoal.app" if OS.mac?
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
