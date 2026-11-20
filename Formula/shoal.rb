class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 5ec6b6c809b1ddc333773cd6799f3d7bd5b6ae91
  version "0.20.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.1/shoal-v0.20.1-macos-arm64-app.tar.gz"
      sha256 "b0744ea21d43b4096161c4ea111b67242e2072e790e1204681eaccbbeeef1864"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.1/shoal-v0.20.1-macos-x86_64-app.tar.gz"
      sha256 "cea880502a0337878507eed481dc2b3daf8daa683d883d916bfcff9eb174aacc"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.1/shoal-v0.20.1-linux-arm64.tar.gz"
      sha256 "3a382eaff6bf588dc5c792d70f9976e18f91176bc6dcaeda10a5faf4c0671854"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.1/shoal-v0.20.1-linux-x86_64.tar.gz"
      sha256 "6cce56031c86e4822481aed3c37538ee0ff773a9b33df2408fe8fc773b17e196"
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
