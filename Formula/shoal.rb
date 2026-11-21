class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 91e371d71fceb4f81424c5757cec1b7adca13010
  version "0.20.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.2/shoal-v0.20.2-macos-arm64-app.tar.gz"
      sha256 "01223a5d7efdf129677dc2ee88fcaa030dcac1d98a8d8bde85d0fca2471d28a6"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.2/shoal-v0.20.2-macos-x86_64-app.tar.gz"
      sha256 "fb8222a5436b6f3dace6ad32fae245833e0d031667de720a732057e178567aa9"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.2/shoal-v0.20.2-linux-arm64.tar.gz"
      sha256 "897ecf417819f4aec4f4b3b132edb2c6608a477ffd190531d155cb16d105e430"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.2/shoal-v0.20.2-linux-x86_64.tar.gz"
      sha256 "c500d1fd3dd8a852644146875270de9bb261f976bfedcce6576cc845b8df7d2a"
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
