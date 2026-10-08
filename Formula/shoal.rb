class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 3fae7e951baf3aaa8b47895d33ad7f2848fc81cb
  version "0.6.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.6.2/shoal-v0.6.2-macos-arm64.tar.gz"
      sha256 "e5a86fb6a1c491cedd038c687e8962367ac0e376c18d72286179b7f39d786514"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.6.2/shoal-v0.6.2-macos-x86_64.tar.gz"
      sha256 "26816dbacee47afee93caab303f080dadfbb321afe0a284e06e25c873aef67af"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.6.2/shoal-v0.6.2-linux-arm64.tar.gz"
      sha256 "be4e3ebdfb54027a1fdd5225bde38aea72b629f7fb0847d1de03d20767dee0da"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.6.2/shoal-v0.6.2-linux-x86_64.tar.gz"
      sha256 "87cc19f8bb8dfd5b5c009aac9da1db59a0c323f60ec50f007c51fec67b01630b"
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
