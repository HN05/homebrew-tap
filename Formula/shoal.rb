class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: af3df67af9f232b3934b77dfd7a3f23c20b36e56
  version "0.20.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.6/shoal-v0.20.6-macos-arm64-app.tar.gz"
      sha256 "9951dc3132de43f69073fabc963949cbba7ea63a259fec1efa0d399ab14a6683"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.6/shoal-v0.20.6-macos-x86_64-app.tar.gz"
      sha256 "61959297b0c5b50996f737bdaad26699fa2198cbf897edf04c0021e7377a6375"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.6/shoal-v0.20.6-linux-arm64.tar.gz"
      sha256 "7efc91cfbe440a7c604df3003cfbe5bbbdbc70cc1b3d839b5cca27d370a6876f"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.6/shoal-v0.20.6-linux-x86_64.tar.gz"
      sha256 "0497ea52cf9e6d7caf00ae6239d675a6ea37be29dc544510052db6380d9e4f57"
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
