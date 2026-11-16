class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: ebcbbc63cbc077e079ba2940c910b792c58d03ac
  version "0.17.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.17.2/shoal-v0.17.2-macos-arm64.tar.gz"
      sha256 "13f8fcc62f7196bd5c3d81cd28c862f6646bfaa0963fe6345dcb331ac55ceecb"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.17.2/shoal-v0.17.2-macos-x86_64.tar.gz"
      sha256 "6b2426acc308d0491b24d9cf01b8aef754c3532fb7be9572b6d6e22ed04cbb96"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.17.2/shoal-v0.17.2-linux-arm64.tar.gz"
      sha256 "e7d81526f4125ef49d10a6d5cea6ff1940d8e228fcbd6c69e7b7b6d782aa3964"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.17.2/shoal-v0.17.2-linux-x86_64.tar.gz"
      sha256 "f47c740126bf16541003215b40086b58d3981a30b053ecaae44adf4deb1844e4"
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
