class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: db4ac4b5c93d22786c068a9ca1c296f025502e1e
  version "0.20.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.4/shoal-v0.20.4-macos-arm64-app.tar.gz"
      sha256 "c338badaf897a700a7fc3b3faeb644bcba3f771694016aaf6025eceb9e56ab3a"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.4/shoal-v0.20.4-macos-x86_64-app.tar.gz"
      sha256 "1619862cb587b8b2345cf52fe3b7763be2e28c59b912a2a685649aa585b05d36"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.20.4/shoal-v0.20.4-linux-arm64.tar.gz"
      sha256 "873af8391dd902c9a7bb5ed5898d882e406c33d2825929f0957013df9923628c"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.20.4/shoal-v0.20.4-linux-x86_64.tar.gz"
      sha256 "27dfbc3f39ea454908b12c838dfaa0977623d2c7bcc2c8a1fd7da7d39156de90"
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
