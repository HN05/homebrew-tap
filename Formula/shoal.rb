class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 988a647f7e8f8573ff203ca7b0903c623d696b97
  version "0.16.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.16.0/shoal-v0.16.0-macos-arm64.tar.gz"
      sha256 "83b07b86ee06e0ac433567c6eb1c56d99103356d343d827e33c5c0689a02788b"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.16.0/shoal-v0.16.0-macos-x86_64.tar.gz"
      sha256 "2e0afc420ad83114dceb74072b6f0205e016b03b200f7c9ede112388ea07b9d4"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.16.0/shoal-v0.16.0-linux-arm64.tar.gz"
      sha256 "f8fb76112abe250452f980b0734eb7e1bbd936d33f6b9e845e626755d68b5b59"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.16.0/shoal-v0.16.0-linux-x86_64.tar.gz"
      sha256 "8638f10afc51c149c3bb4cb3208f4d1d7ce7caac20e55367ead715b48a35642a"
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
