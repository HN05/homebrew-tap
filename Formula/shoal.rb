class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: e414f0b706d54f6bde08115c5a953f29b407ef58
  version "0.4.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.5/shoal-v0.4.5-macos-arm64.tar.gz"
      sha256 "4fb7d231b41ba6d925105eccb032cfaf47b624853234b5c27039a295ed9418a2"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.5/shoal-v0.4.5-macos-x86_64.tar.gz"
      sha256 "3890d79213d9177ef323932d6b4957d6f32d1ff6d39d95d0c41ad444dc440a50"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.5/shoal-v0.4.5-linux-arm64.tar.gz"
      sha256 "34f095f1606798660c0f005955c2289b3e8eb6a4f95b33cf82dd53b9ee97da18"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.5/shoal-v0.4.5-linux-x86_64.tar.gz"
      sha256 "eef82bbc026a43a859427244cbd90d2edcc828f812deb999d771908d07922d47"
    end
  end

  head do
    url "https://github.com/HN05/shoal.git", branch: "main"
    depends_on "rust" => :build
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "worktrunk"
  uses_from_macos "lsof"

  def install
    if build.head?
      system "bash", "scripts/install-homebrew.sh", prefix, opt_prefix,
                     "--jobs", ENV.make_jobs.to_s
    else
      libexec.install "shoal"
      (share/"shoal/skill").install "SKILL.md"
      (libexec/"shoal-skill").make_symlink opt_share/"shoal/skill/SKILL.md"
      bin.install_symlink libexec/"shoal"
    end
  end

  def caveats
    <<~EOS
      Install the agent skill once (it follows future Homebrew upgrades):
        #{opt_bin}/shoal skill install

      Register the per-user daemon:
        shoal install

      After upgrading, restart the daemon:
        #{opt_bin}/shoal daemon restart
    EOS
  end

  test do
    assert_match "shoal", shell_output("#{bin}/shoal --version")
    assert_match "name: shoal", shell_output("#{bin}/shoal skill")
    ENV["HOME"] = testpath.to_s
    ENV.delete "SHOAL_SCOPE_TOKEN"
    system bin/"shoal", "skill", "install", "codex"
    installed = testpath/".agents/skills/shoal/SKILL.md"
    assert_predicate installed, :symlink?
    assert_equal (opt_share/"shoal/skill/SKILL.md").to_s, installed.readlink.to_s
    assert_equal (share/"shoal/skill/SKILL.md").read, installed.read
  end
end
