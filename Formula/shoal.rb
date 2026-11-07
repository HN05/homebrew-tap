class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: ce6d51b4f2f54387e442f6776827399216526e02
  version "0.15.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.4/shoal-v0.15.4-macos-arm64.tar.gz"
      sha256 "a4259d04396f394cf16d782b6964d1cf5af296856cec46766fc2941365efb65a"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.4/shoal-v0.15.4-macos-x86_64.tar.gz"
      sha256 "fb2f21d27004afc5c2e7fa89b6cd1f61d6bc0301e4394cd6456796eb52dcc4a6"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.4/shoal-v0.15.4-linux-arm64.tar.gz"
      sha256 "83a4db62d6180c9df8220e2262b6fb6710af4507bfc42ddc1a8218b92ac7a890"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.4/shoal-v0.15.4-linux-x86_64.tar.gz"
      sha256 "d2b078b9ff03db3bf9c9e19dcbb2b003a93a7ab9537b4c1296ec8e246392751e"
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
