class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 1d043d9de20f405678cf1aaafb4d5296438bc9f3
  version "0.18.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.2/shoal-v0.18.2-macos-arm64-app.tar.gz"
      sha256 "db5eb460180c8146193ecd186b92ba5431e5510bf399ac7d08285b4023c03c1d"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.2/shoal-v0.18.2-macos-x86_64-app.tar.gz"
      sha256 "4a5ab299f683d9810558e2980758d69c9221caee477669d1d1a5d37fdffe0ed0"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.2/shoal-v0.18.2-linux-arm64.tar.gz"
      sha256 "ca7b5705c6c5b1b74226a301bab5eff1b88c675bc63b3874244cacf97d16ba93"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.2/shoal-v0.18.2-linux-x86_64.tar.gz"
      sha256 "02d0fd3b6733985a8163f3db86bae535fa23427a0cb910a348e4db68c30e3b6a"
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
