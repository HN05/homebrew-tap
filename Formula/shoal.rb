class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: be094890579f1984467cbc48b38d71946966d043
  version "0.15.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.6/shoal-v0.15.6-macos-arm64.tar.gz"
      sha256 "96e621b5a2280b06ce7311577cd7596feed526bb9b291450bcc4c0e781a3ff19"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.6/shoal-v0.15.6-macos-x86_64.tar.gz"
      sha256 "c0df40d172cfda501ddc0a725ef73f6b32b95a564cea5c10456b6b91adc4145e"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.15.6/shoal-v0.15.6-linux-arm64.tar.gz"
      sha256 "eb0487c9cb8b8fa9db45e6a0cc9f48024cb6135085b27777d9614b25a2f91d63"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.15.6/shoal-v0.15.6-linux-x86_64.tar.gz"
      sha256 "17e490eb38dcc30a5e5ad0b71076dcb7dc769176c77afae79a3fa9b0e34157c1"
    end
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "worktrunk"

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

  def caveats
    <<~EOS
      Start the per-user daemon:
        shoal daemon install

      Install the agent skills into each tool's existing skill directory:
        shoal skill install

      Install them for one tool, creating its skill directory:
        shoal skill install claude

      Later shoal commands keep installed skills current.

      Agents started from a terminal run in zmx sessions by default:
        brew install neurosnap/tap/zmx
    EOS
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
