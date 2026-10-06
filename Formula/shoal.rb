class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 6a6f84f291c627899e269286a70de801c9728e39
  version "0.5.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.1/shoal-v0.5.1-macos-arm64.tar.gz"
      sha256 "03005a631141409a020c15684f5de3f225ac63604d4a68fd46a7b4d4ec4ea26e"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.1/shoal-v0.5.1-macos-x86_64.tar.gz"
      sha256 "b94f0c2b6be0428c948eac23b85140b5a42697758c0851d41ce2bf31204e8d00"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.1/shoal-v0.5.1-linux-arm64.tar.gz"
      sha256 "a777bf26247bfb7b2ff97b3f33acbf7fd436dbbefb6adafe5f45c3fef4ed8c00"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.1/shoal-v0.5.1-linux-x86_64.tar.gz"
      sha256 "78e91011dd702c9f770debd82342e64b1903a117233ea713d0d885ad7d728940"
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
