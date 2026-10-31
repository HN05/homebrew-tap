class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 784a6b1df403e182ed35d9be26000003cd809c84
  version "0.13.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.13.2/shoal-v0.13.2-macos-arm64.tar.gz"
      sha256 "45089fdc89e590654110cb9db22556f2f8c6a12fa8daef7a96e58ebbd9a18b57"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.13.2/shoal-v0.13.2-macos-x86_64.tar.gz"
      sha256 "377b809c985cef66fcc3e32b3170a774df9e1791f26c7f8e79ea17549ac168ad"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.13.2/shoal-v0.13.2-linux-arm64.tar.gz"
      sha256 "303d9ec34715e0528c8b8bba05e0bb21fd1a8dabbf2f7d82a003089f77f4b755"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.13.2/shoal-v0.13.2-linux-x86_64.tar.gz"
      sha256 "25b7384ed77501ea1de522343cfec29f0049482e0b55489a608064c5d0840961"
    end
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "neurosnap/tap/zmx"
  depends_on "worktrunk"
  uses_from_macos "lsof"

  def install
    libexec.install "shoal"
    (share/"shoal").install "skills"
    (libexec/"shoal-skills").make_symlink opt_share/"shoal/skills"
    bin.install_symlink libexec/"shoal"
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
    EOS
  end

  test do
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
