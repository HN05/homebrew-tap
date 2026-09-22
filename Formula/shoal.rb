class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: b5fa94f21dc32b240737d8c1ee0a886353a22c70
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.3.0/shoal-v0.3.0-macos-arm64.tar.gz"
      sha256 "d2c9dd7ebfa219be75ff6c34a0b0d534a1e07f57f5bbdfcb8ca31e1c9b0a93be"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.3.0/shoal-v0.3.0-macos-x86_64.tar.gz"
      sha256 "a0e361c1fc4008c558f42466b95f618fb7e8c54da98cb2ebfbc47e79722d2be6"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.3.0/shoal-v0.3.0-linux-arm64.tar.gz"
      sha256 "3a40b3b3b16a1aacaf145a1dbfe6af184fe2abfc69faacf336809b1819a03886"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.3.0/shoal-v0.3.0-linux-x86_64.tar.gz"
      sha256 "01820f675ba2c32ea9110353873880bad02e168013af030098858360f36d6480"
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
      (bin/"shoal").write_env_script opt_libexec/"shoal",
                                    SHOAL_SKILL_PATH: opt_share/"shoal/skill/SKILL.md"
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
