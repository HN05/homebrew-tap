class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 52f22a648556ec7e227a3f02022a6cc29f977275
  version "0.4.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.4/shoal-v0.4.4-macos-arm64.tar.gz"
      sha256 "18e84cba4a62d2cfc34b9caed483b9a40089247465ddbf3cb0a567cdd02aca6f"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.4/shoal-v0.4.4-macos-x86_64.tar.gz"
      sha256 "d407f209c01849dacde62d48c3180540f7f97772b9657ea5aba303e9c35ef7d2"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.4/shoal-v0.4.4-linux-arm64.tar.gz"
      sha256 "3a5c3a32e25bc122da43a5bd8fe0fcdb74533c56b9e4d519f1c107927621617c"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.4/shoal-v0.4.4-linux-x86_64.tar.gz"
      sha256 "d17ee2cb863f0b04b5fe040471a21d3cbe9402ca541a334dc24114c549017b28"
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
