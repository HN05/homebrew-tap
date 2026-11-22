class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 1f5c59b4492b3b39aefce89fdbedacba60f920a9
  version "0.20.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.5/shoal-v0.20.5-macos-arm64-app.tar.gz"
      sha256 "2181ee45566b3db4b1b5bfcc868abde9f3e1e7e189e417c7e87c0f6f33275bd7"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.5/shoal-v0.20.5-macos-x86_64-app.tar.gz"
      sha256 "6c16aa888757bee28986b56b2d46edbb0d38c7ee9a0daa0ea1e2609d5bbb8015"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.5/shoal-v0.20.5-linux-arm64.tar.gz"
      sha256 "900c4be383d28245caff297c2dd27e88dac7656e3085519c698af38768056f4b"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.5/shoal-v0.20.5-linux-x86_64.tar.gz"
      sha256 "15cd4f3f797f479b85e63d18a8c3c7591735a7bc36b3bbbbad2e3a7c2c586853"
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
