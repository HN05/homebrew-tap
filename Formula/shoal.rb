class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: a33a450cc9524321b57a91268a2c7e06806d0ba0
  version "0.22.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.22.0/shoal-v0.22.0-macos-arm64-app.tar.gz"
      sha256 "010fc441b4cffe7fd4daf449d54fd88b0d9635f50f471c56ad5632e386460342"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.22.0/shoal-v0.22.0-macos-x86_64-app.tar.gz"
      sha256 "428891ce84d2f38208fae826de3589f11e9fb81c4023c351dc2c1c3b6a51fb8a"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.22.0/shoal-v0.22.0-linux-arm64"
      sha256 "f9f813917993a489b5f8bcbc406bbd1bfb1aba0cfed941817151956f4c16145a"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.22.0/shoal-v0.22.0-linux-x86_64"
      sha256 "6692dbd32e0f07090079565843b6dbad0c0972eff28689f4c4988ffa5290b14f"
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
      # Linux downloads the bare binary, staged under its release name.
      libexec.install Dir["shoal-v*"].fetch(0) => "shoal"
      (libexec/"shoal").chmod 0755
      bin.install_symlink libexec/"shoal"
    end
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
    assert_equal shell_output("#{bin}/shoal skill"), installed.read
  end
end
