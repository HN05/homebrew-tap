class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: af4a1e642e510ac0e814d66c003e48ab30d3f008
  version "0.5.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.3/shoal-v0.5.3-macos-arm64.tar.gz"
      sha256 "835cf464bb542fa9bca94484c9815f0a25ca067b51733cdd38f77f4d9f990040"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.3/shoal-v0.5.3-macos-x86_64.tar.gz"
      sha256 "ddd7c76739dd3661b049c0f085ff8ae8689f3103e45795247dc7c9da7f318513"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.3/shoal-v0.5.3-linux-arm64.tar.gz"
      sha256 "7b738a2bcf3e9d209c2eec63f53bf5f2d6cc76e5c61aa0346e283a38870b7486"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.3/shoal-v0.5.3-linux-x86_64.tar.gz"
      sha256 "c3729a84ed61f23217137ed81431f74a7bc7e621cc86ec546c1d98b75aa83482"
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
