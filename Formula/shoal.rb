class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: be7e3761e30f739f9074e0085be1c73f6a38cd57
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.0/shoal-v0.5.0-macos-arm64.tar.gz"
      sha256 "ed6be93a643e1a19638e39df8bbac92df42331a467cfb1db59879ec0da0d5f4a"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.0/shoal-v0.5.0-macos-x86_64.tar.gz"
      sha256 "595069bd00589166a735cdb3627ef36a7f47d16aa3fd574aebae632fc0facb3d"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.0/shoal-v0.5.0-linux-arm64.tar.gz"
      sha256 "1278883eb91b761854cc39ae196dddc54fdfa7787464bd40597a45b3a80b4f20"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.0/shoal-v0.5.0-linux-x86_64.tar.gz"
      sha256 "49ab18954c6196d5b36c05fb3716d46d2668e12f1b0c2d094eba5a51c7c6324b"
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
