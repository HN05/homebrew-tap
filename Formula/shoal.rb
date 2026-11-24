class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: cda9a927cf464edb4a131f28babf9275fd0c9a3e
  version "0.21.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.21.0/shoal-v0.21.0-macos-arm64-app.tar.gz"
      sha256 "6d5cbddffad28ee1e33ab742c46caac99ae513e7cc197bbf8c78fe187094107f"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.21.0/shoal-v0.21.0-macos-x86_64-app.tar.gz"
      sha256 "55ad9bc22ac87f36a5f3ac01de533fc423a690473319809f6a62435bda72988f"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.21.0/shoal-v0.21.0-linux-arm64.tar.gz"
      sha256 "dc7f81273222d9b23e27ec703f995ffbaea855c55d23cd85197f4797277a6854"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.21.0/shoal-v0.21.0-linux-x86_64.tar.gz"
      sha256 "425c03529cd70c54cc75639b1b4dbce9f14a71e9392dcbc46fb3775e0022ab4f"
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
