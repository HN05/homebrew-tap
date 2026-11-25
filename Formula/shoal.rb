class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: fe034d77aebbe8fac47ffb3ba112fc21b221a979
  version "0.21.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.21.1/shoal-v0.21.1-macos-arm64-app.tar.gz"
      sha256 "dc7ddb3840ed8f1c6aaef49e4dc36ffe2efdfecb86abdc12aad9755a10c73e5b"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.21.1/shoal-v0.21.1-macos-x86_64-app.tar.gz"
      sha256 "f49490ee71483799d5c5cfd1c0b1f590cf4ab9fdb1e44cb034999ed70f38bcc0"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.21.1/shoal-v0.21.1-linux-arm64.tar.gz"
      sha256 "9720d8909b132e0da0dd2a65262ac24340d9708820eea8c45e2b5f95f56d9044"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.21.1/shoal-v0.21.1-linux-x86_64.tar.gz"
      sha256 "704f7c0b7eb46cb80b4d89841d413f4b0d94b33f3203a19732c07692ad6e139c"
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
