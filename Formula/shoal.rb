class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 09be038fbdbc44a547a87077ba72cb6cd307e97f
  version "0.18.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.3/shoal-v0.18.3-macos-arm64-app.tar.gz"
      sha256 "d8337754eb09b74b166d1cfa66b1ee5411ba77c49f940d73bd773047e7e08bd0"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.3/shoal-v0.18.3-macos-x86_64-app.tar.gz"
      sha256 "aaeb5c1844064b3746ad0126b3001536f1e39f176f967775cdf756775f1278c1"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.18.3/shoal-v0.18.3-linux-arm64.tar.gz"
      sha256 "ea3781f7d842196e0dc292c51dd11d23a16a47fd95a2c6b741cc59fedfd07a31"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.18.3/shoal-v0.18.3-linux-x86_64.tar.gz"
      sha256 "4125086120c1509314bae7fa3aacd29abf2e5dd153dbc58a5dcfbfbafa5717f0"
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
