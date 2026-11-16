class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 7c1660606846d0c6409ed132eed9961c4db5586e
  version "0.18.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.0/shoal-v0.18.0-macos-arm64.tar.gz"
      sha256 "8b81031c56f42e7588730424cbb13d537ab547f9c6b683ff01d354feb02367d4"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.0/shoal-v0.18.0-macos-x86_64.tar.gz"
      sha256 "74a33256b2d6ee23db8e60e0f2471c8c810887016992a2d753702128a5a61481"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.0/shoal-v0.18.0-linux-arm64.tar.gz"
      sha256 "4d6c08e16e14c017ed09547c88715868677e7f1cda892b93a7dfd48327de3108"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.0/shoal-v0.18.0-linux-x86_64.tar.gz"
      sha256 "ccffe0b1675052d115019cd9195a896713d693fdb4de9d27c79203839ced9426"
    end
  end

  depends_on "fzf"
  depends_on "git"

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

      Agents started from a terminal run in zmx 1.0.1 or later by default:
        brew install neurosnap/tap/zmx
      Sessions an older zmx started are unreachable after an upgrade, so
      stop their agents with `shoal stop` before upgrading zmx and resume
      them after with `shoal restore`.
    EOS
  end

  test do
    system "codesign", "--verify", "--strict", libexec/"Shoal.app" if OS.mac?
    assert_match "shoal", shell_output("#{bin}/shoal --version")
    assert_match "name: shoal", shell_output("#{bin}/shoal skill")
    ENV["HOME"] = testpath.to_s
    ENV.delete "SHOAL_SCOPE_TOKEN"
    system bin/"shoal", "skill", "install", "codex"
    installed = testpath/".agents/skills/shoal/SKILL.md"
    refute_predicate installed, :symlink?
    assert_equal (share/"shoal/skills/shoal/SKILL.md").read, installed.read
  end
end
