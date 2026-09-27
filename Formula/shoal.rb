class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 5836042af5e313fd78181b33d27feeae27cfc663
  version "0.4.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.1/shoal-v0.4.1-macos-arm64.tar.gz"
      sha256 "c41e838ee9d362cb035516f1adae0793a133cec32468dbe3cba8728eb739c617"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.1/shoal-v0.4.1-macos-x86_64.tar.gz"
      sha256 "7bfdbee400e168319fb57328879579027cdf0b7848d876e085211fc6873a1da8"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.1/shoal-v0.4.1-linux-arm64.tar.gz"
      sha256 "3bd56ead487dd75f87a233e86385be3022d27a0b6a84186aaf0606d6818ac736"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.1/shoal-v0.4.1-linux-x86_64.tar.gz"
      sha256 "708c375a2a8e5bf252c2b840e0ec0e64249a8d7af0fb72192ee2d293e0e4be40"
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
