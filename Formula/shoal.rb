class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 44b638f3003d2c7de6dd1d007843c29543ded829
  version "0.9.7"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.7/shoal-v0.9.7-macos-arm64.tar.gz"
      sha256 "e4f6409dabcc268c36336638689b17604a981c92fcdcb0a12dcb817089a5a277"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.7/shoal-v0.9.7-macos-x86_64.tar.gz"
      sha256 "74f2d6610dd81d723b2ac21ac51a271e216f94d71258eda579c27c631f8faf19"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.9.7/shoal-v0.9.7-linux-arm64.tar.gz"
      sha256 "df16622bb41e6e6c200c8f98b4726a5dd4ab9bbb2d7bf901bf11cface0b51388"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.9.7/shoal-v0.9.7-linux-x86_64.tar.gz"
      sha256 "fd6d4130c45dd296b1ce2881a75dd40f2d62706cf8faa1c2ed607267ac97c085"
    end
  end

  head do
    url "https://github.com/HN05/shoal.git", branch: "main"
    depends_on "rust" => :build
  end

  depends_on "fzf"
  depends_on "git"
  depends_on "neurosnap/tap/zmx"
  depends_on "worktrunk"
  uses_from_macos "lsof"

  def install
    if build.head?
      system "bash", "scripts/install-homebrew.sh", prefix, opt_prefix,
                     "--jobs", ENV.make_jobs.to_s
    else
      libexec.install "shoal"
      (share/"shoal").install "skills"
      (libexec/"shoal-skills").make_symlink opt_share/"shoal/skills"
      bin.install_symlink libexec/"shoal"
    end
  end

  def caveats
    <<~EOS
      Install the agent skills once (later shoal commands update them after upgrades).
      This fills existing skill directories; name a tool to create its directory:
        #{opt_bin}/shoal skill install
        #{opt_bin}/shoal skill install claude

      Register the per-user daemon:
        shoal install

      The managed daemon applies upgrades when its clients and operations are idle.
      To apply an upgrade immediately, restart the daemon:
        #{opt_bin}/shoal daemon restart
    EOS
  end

  test do
    assert_match "shoal", shell_output("#{bin}/shoal --version")
    assert_match "name: shoal-worker", shell_output("#{bin}/shoal skill")
    assert_match "name: shoal-orchestrator", shell_output("#{bin}/shoal skill orchestrator")
    ENV["HOME"] = testpath.to_s
    ENV.delete "SHOAL_SCOPE_TOKEN"
    system bin/"shoal", "skill", "install", "codex"
    %w[shoal-worker shoal-orchestrator].each do |skill|
      installed = testpath/".agents/skills/#{skill}/SKILL.md"
      refute_predicate installed, :symlink?
      assert_equal (share/"shoal/skills/#{skill}/SKILL.md").read, installed.read
    end
  end
end
