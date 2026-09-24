class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: e297447ba659302e4b09726d2379db3d64bbfa08
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.0/shoal-v0.4.0-macos-arm64.tar.gz"
      sha256 "4648da4ba7085a9f34576103f30d57fec38ebe94d5484b95633f01338a080e6e"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.0/shoal-v0.4.0-macos-x86_64.tar.gz"
      sha256 "eac12adcf39cb1b17bcad545a7aa1a3f3f4a861e2e3c1c57fad65b2a94e88b9f"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.4.0/shoal-v0.4.0-linux-arm64.tar.gz"
      sha256 "8ecdadad05003f3a07dfcd2b85b9cfca371a4621399b45e6fdda7b69aef540c8"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.4.0/shoal-v0.4.0-linux-x86_64.tar.gz"
      sha256 "536c563740cdcf78a4f64c9c03c6fb19096221e9e3264429e81da80c336fa3fe"
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
