class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 620fb6d18be331fa4efdf724c56f1c5abdc539ad
  version "0.20.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.3/shoal-v0.20.3-macos-arm64-app.tar.gz"
      sha256 "950805b3e320f0d939642dc8b3ab5eca7671f98fafb408ca139b36147365bf92"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.3/shoal-v0.20.3-macos-x86_64-app.tar.gz"
      sha256 "4baa1ac6d06fb0d6ee05d9badda2905cf5b78785e01a4a49214f2a834b4bc615"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.3/shoal-v0.20.3-linux-arm64.tar.gz"
      sha256 "df098cdce0d08c1e20a9fedf4882f44f1d61d53832ea45c7c19cab1f99444619"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.3/shoal-v0.20.3-linux-x86_64.tar.gz"
      sha256 "2fdd9d22ab5e4ab0ffc88e3bd2de71830f5037c663472c6e97dd76822e58ccd4"
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
