class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 4fc64bb0fe6c3e8b448805572b1f05fdf2a0573a
  version "0.15.8"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.8/shoal-v0.15.8-macos-arm64.tar.gz"
      sha256 "248a4c0c23092d303bde2d42102511886373c31ffcc0e44cac0cc820f6aefc8c"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.8/shoal-v0.15.8-macos-x86_64.tar.gz"
      sha256 "15c8ac3cc65d79cce19d25d4b8f3398a907d2a5abdc589ded3b71eb8dafe0a1a"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.8/shoal-v0.15.8-linux-arm64.tar.gz"
      sha256 "8a499ca8d038d8152e1f792231162b4a0ea6d530addf976d28bbea931afe775d"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.8/shoal-v0.15.8-linux-x86_64.tar.gz"
      sha256 "5e4f6c2304c3918000a4ab9700c972a7a4e45207a32fdbbb56a0bb4a25c8866d"
    end
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "worktrunk"

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
    assert_match "name: shoal", shell_output("#{bin}/shoal skill")
    ENV["HOME"] = testpath.to_s
    ENV.delete "SHOAL_SCOPE_TOKEN"
    system bin/"shoal", "skill", "install", "codex"
    installed = testpath/".agents/skills/shoal/SKILL.md"
    refute_predicate installed, :symlink?
    assert_equal (share/"shoal/skills/shoal/SKILL.md").read, installed.read
  end
end
