class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 1f439ecddf622a6478481918f843924af4ab2bb1
  version "0.18.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.4/shoal-v0.18.4-macos-arm64-app.tar.gz"
      sha256 "7128602a305fe14fd76fc4c5c0b28b8d26d1bd20e59dc3aebb96d5b27d6aa099"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.4/shoal-v0.18.4-macos-x86_64-app.tar.gz"
      sha256 "4e7ac5802e362502cf87216b31b3ebe74c77eda384d92ad2eb8594ecc3e51bac"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.4/shoal-v0.18.4-linux-arm64.tar.gz"
      sha256 "ac981cfbe34b45bec45a11c7ecd2386f33db95e3e38d81a345e89a44a192d954"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.4/shoal-v0.18.4-linux-x86_64.tar.gz"
      sha256 "5e5e0b90a89f6cb7bf7783ab5a10e67c1c740f5066f250498bac488548409231"
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
