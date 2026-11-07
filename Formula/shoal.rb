class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: b03b2924643a923a9a5fb742cdf749d65c26017a
  version "0.15.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.3/shoal-v0.15.3-macos-arm64.tar.gz"
      sha256 "98211cfbab9e21bdf284e73adb5ff530af4eaef020a6101ec0bfe8603d5b1c93"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.3/shoal-v0.15.3-macos-x86_64.tar.gz"
      sha256 "27cb6ad9f546063e65ad3a4d889bf10eb346c6f13a02dd2a36c1ab3579b39b93"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.3/shoal-v0.15.3-linux-arm64.tar.gz"
      sha256 "3950ab0ea6cf7b0c2d400b7ecbdf2b6df489191de1b1a2e9dc5074f77ab70dce"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.3/shoal-v0.15.3-linux-x86_64.tar.gz"
      sha256 "beb823edc2475d0c5baf1792fdd6455f48f6f32ab9153b02901d6cd7510143e5"
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
    assert_match "name: shoal", shell_output("#{bin}/shoal skill")
    ENV["HOME"] = testpath.to_s
    ENV.delete "SHOAL_SCOPE_TOKEN"
    system bin/"shoal", "skill", "install", "codex"
    installed = testpath/".agents/skills/shoal/SKILL.md"
    refute_predicate installed, :symlink?
    assert_equal (share/"shoal/skills/shoal/SKILL.md").read, installed.read
  end
end
