class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 8c06645add4e4818e100269e25f01804d0e07562
  version "0.18.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.1/shoal-v0.18.1-macos-arm64.tar.gz"
      sha256 "576f6bb6365a2660f0f0693f759827e13b1bdc96a4ed0c473565552425186c70"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.1/shoal-v0.18.1-macos-x86_64.tar.gz"
      sha256 "27228d0ae81dc70e6fdbb663d409704b3059bc5dc5240e4c84ce907884562fba"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.1/shoal-v0.18.1-linux-arm64.tar.gz"
      sha256 "e5067559e8e31ca93f81befd8b43c0b61595e4e03ca631fc7ac43dab0ac64760"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.1/shoal-v0.18.1-linux-x86_64.tar.gz"
      sha256 "b1b29ec6b128feee34c99525a5ebcf0f34bbb3317ccc86eda7fbc064b83eca5e"
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
