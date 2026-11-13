class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 3a6448793c2e606e6f76f7222832a56be4712ee8
  version "0.16.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.16.1/shoal-v0.16.1-macos-arm64.tar.gz"
      sha256 "394627b3b319be41b2854a524fa469caaab29d636248fa959f9963e16624c0b4"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.16.1/shoal-v0.16.1-macos-x86_64.tar.gz"
      sha256 "b7bf17f185b6334c4cf20222b73aa2a1a227c90d312d92f04482548b1ffa652d"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.16.1/shoal-v0.16.1-linux-arm64.tar.gz"
      sha256 "4a4d738fabe6cb7f535e2dece164ad62b8e76132161a27f3a0dc87e251c7422f"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.16.1/shoal-v0.16.1-linux-x86_64.tar.gz"
      sha256 "f66c90a416840b1d85e7a5f5309bcef37da0e0984302435e5a225b33aab5c6ba"
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
      them after with `shoal resume`.
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
