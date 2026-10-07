class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: e46e4ced042b7dcd931c55f28dd3ddab51e1321a
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.6.0/shoal-v0.6.0-macos-arm64.tar.gz"
      sha256 "00055dbb8eb33a58e65a68c05a4238a9c4232c03c2be5d781ed9b58b8c10b319"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.6.0/shoal-v0.6.0-macos-x86_64.tar.gz"
      sha256 "b31cb5a4f7361ae640c6928038375ee79ddea7fc650060b697d55c2c36f06e69"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.6.0/shoal-v0.6.0-linux-arm64.tar.gz"
      sha256 "c58f558c4d5cccc18756f6bbe69a0f88883793f316a9e0269315497489530499"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.6.0/shoal-v0.6.0-linux-x86_64.tar.gz"
      sha256 "6db5c4488c02b3fe5d44ab4abea5ec8facd9754f8dd8194601a999be2f6a5ec2"
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
