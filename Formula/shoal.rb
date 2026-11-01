class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: feb97a9980b220123fb4a59a2ba01a6a6ba6d430
  version "0.14.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.14.0/shoal-v0.14.0-macos-arm64.tar.gz"
      sha256 "5dc40fd8662439869127a775f6b9b82c5e6c21314bc8920c0dc89502649ad1b4"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.14.0/shoal-v0.14.0-macos-x86_64.tar.gz"
      sha256 "64fabf20fe073722b7791ae1aa4d83f1efb9ee27203ab9df9bcb8be5528fe26e"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.14.0/shoal-v0.14.0-linux-arm64.tar.gz"
      sha256 "7ec94bdb8be2399e821f830e677eaabeeb5877bad9da73aea923306198b300f9"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.14.0/shoal-v0.14.0-linux-x86_64.tar.gz"
      sha256 "b058cd44fc70d629b94ca25a1752bb4576e2d140071aae29c5ac188750a1c7f7"
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
