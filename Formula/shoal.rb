class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: f5e0143144b9833cdda860ebcad3e8dc19fc836c
  version "0.19.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.19.0/shoal-v0.19.0-macos-arm64-app.tar.gz"
      sha256 "b496eb7e1928f6dd915abe3bd4042861533f35334ef99afb3f431477f6d5c519"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.19.0/shoal-v0.19.0-macos-x86_64-app.tar.gz"
      sha256 "1fa777189b7cf2a25b682690a2c72a2da77eadbd70f2bd9cd5a49dad909e4886"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.19.0/shoal-v0.19.0-linux-arm64.tar.gz"
      sha256 "44846b178c8a1f119e3ca0bab27398c30a95eb347480627da91a1583c04da191"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.19.0/shoal-v0.19.0-linux-x86_64.tar.gz"
      sha256 "fee5cafd408b46267a8200c77664272ce2afcdf48c1bc0b9864dc5cfb769fe10"
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
