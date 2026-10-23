class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: e0de6f374f28fdff6c0ebf39854972b1d405e66c
  version "0.10.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.3/shoal-v0.10.3-macos-arm64.tar.gz"
      sha256 "2ee19bfaf56584e8f1c25a5a04e284f27ffb6368a606930267b88ca25895385f"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.3/shoal-v0.10.3-macos-x86_64.tar.gz"
      sha256 "5db3f00c91edbffc7052e55299cab9bdac02337bee54da8a59e316200798cc58"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.10.3/shoal-v0.10.3-linux-arm64.tar.gz"
      sha256 "6bf87f6153ef49537430b9c8811194009c63ff07f40151f7b02e3342e92fb12d"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.10.3/shoal-v0.10.3-linux-x86_64.tar.gz"
      sha256 "4dbac4dd8482e2dde479bde55a877e37121c618b1c1b745c0eb3adda1e8b35f4"
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
      Start the per-user daemon:
        shoal install

      Install the agent skills into each tool's existing skill directory:
        shoal skill install

      Install them for one tool, creating its skill directory:
        shoal skill install claude

      Later shoal commands keep installed skills current.
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
