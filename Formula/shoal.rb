class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 662a99be353a166b9a512d3773207cbfd9a11d6f
  version "0.15.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.5/shoal-v0.15.5-macos-arm64.tar.gz"
      sha256 "38206e0e9f8e0db0b5a86e2f8161cae91f8049a95be7a0bfa76ac8d2f4aee45d"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.5/shoal-v0.15.5-macos-x86_64.tar.gz"
      sha256 "a1f3fc94a126e9ef3de1853ef163d79831f687603ea54c87af462b0b6aaf1ee1"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.5/shoal-v0.15.5-linux-arm64.tar.gz"
      sha256 "3f1f246340e6c430a1866c4dd8b0b90111db692f5e63429ccf4a417c2d0db24c"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.5/shoal-v0.15.5-linux-x86_64.tar.gz"
      sha256 "df9e68234efa75f89a33de95d2c805e66f92f28bd990aa886d8414537e940ec5"
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
