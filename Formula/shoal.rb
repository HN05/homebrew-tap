class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: f542bc8036a2f643bac77912ea367518011ab7ea
  version "0.17.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.17.1/shoal-v0.17.1-macos-arm64.tar.gz"
      sha256 "62ca74143d18142c1c8035402ee88be59044857cc3565b03178af212b6812b67"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.17.1/shoal-v0.17.1-macos-x86_64.tar.gz"
      sha256 "dee1aeeb8b1ed6b90cfce76afd29db20ff12fe980441984928fcd35c4cf3d7a5"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.17.1/shoal-v0.17.1-linux-arm64.tar.gz"
      sha256 "b26fdfd14faf84cc6d85c44021190cdc900d97e64587ce7d2b247f7518ef1cef"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.17.1/shoal-v0.17.1-linux-x86_64.tar.gz"
      sha256 "31d342ade817a03fa0ed9d37f476bbbfe30da8220c101784a9cd5dec9cb4af49"
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
