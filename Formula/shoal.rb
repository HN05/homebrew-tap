class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: c7c6f70107662df5e98b5fa28db6f6fec24cb934
  version "0.22.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.22.1/shoal-v0.22.1-macos-arm64-app.tar.gz"
      sha256 "87e06037909c66bff104f166c1ce9d0d6ace3e75d5def9a4443e8076749e1b41"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.22.1/shoal-v0.22.1-macos-x86_64-app.tar.gz"
      sha256 "db21d8f8508717b847b9289d9ff3bf87db5c2a4d5a53f30f098f84bf740c55fb"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.22.1/shoal-v0.22.1-linux-arm64"
      sha256 "2e57a6d076c65c384f2cf3a60194788bb5cbe68b19786e7aa26d62c487fc6951"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.22.1/shoal-v0.22.1-linux-x86_64"
      sha256 "0df3f214a92fd8f6dd205f37d9f79391774e543da812f1c52a816ab06b53556f"
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
