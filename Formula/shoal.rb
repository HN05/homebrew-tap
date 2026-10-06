class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 371d25a41cde9a8b3d3863625cdd5ad88f3128a8
  version "0.5.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.2/shoal-v0.5.2-macos-arm64.tar.gz"
      sha256 "a99516ac2848fc9f8d96341b27d0d36f45441039992c217b64f5d5700ccbc9fa"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.2/shoal-v0.5.2-macos-x86_64.tar.gz"
      sha256 "3a7acdd7bd082550894b2193aafc0da4b81fc24666367567937e0cc574c20b47"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.5.2/shoal-v0.5.2-linux-arm64.tar.gz"
      sha256 "bf74e146e1c1a9db8dff1270d9756393921170b4266b0fa9b65ed442f852ac80"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.5.2/shoal-v0.5.2-linux-x86_64.tar.gz"
      sha256 "fbb68e0453ab2cb41e8ad559f03cce5db5e37a0ea2ef0a1e9fc2bce0e0179541"
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
