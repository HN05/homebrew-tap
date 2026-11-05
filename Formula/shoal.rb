class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: f373eabd28dab1e168e0e5f46ac8a42ab3a33d16
  version "0.15.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.1/shoal-v0.15.1-macos-arm64.tar.gz"
      sha256 "8c582f688b003d302683a01f479cfbcdd3f27174e110c2c91975f3fec95397a6"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.1/shoal-v0.15.1-macos-x86_64.tar.gz"
      sha256 "1b21e73beb8836866106e3c399a72e9295b5b167a8ddc93787f91a5a117f528b"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.1/shoal-v0.15.1-linux-arm64.tar.gz"
      sha256 "a4d1eee9046a87c094e627b97dba2ab37d4804274efe40232c7aa0c9531e51c4"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.1/shoal-v0.15.1-linux-x86_64.tar.gz"
      sha256 "c9ddfee5b6413525281567ba44a30043c95adf6b048e99db36c073f7af3e623a"
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
