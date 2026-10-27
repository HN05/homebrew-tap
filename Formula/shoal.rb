class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: df5c3ba01fcdbe975e53b676da95bee521b5dd71
  version "0.11.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.11.1/shoal-v0.11.1-macos-arm64.tar.gz"
      sha256 "be6db6e736d4c04258027b158379c6a09b9e6b13c7ea5e05aebb50475c7deebf"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.11.1/shoal-v0.11.1-macos-x86_64.tar.gz"
      sha256 "7651463059bdb1162106f6fcf3aa7e92ed27e4cfdcf17c7e33da1697036d06a9"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.11.1/shoal-v0.11.1-linux-arm64.tar.gz"
      sha256 "036bf5b5568cca0171a42f6e668da34341ba3f14d363a4289b318b0c1a41f19c"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.11.1/shoal-v0.11.1-linux-x86_64.tar.gz"
      sha256 "7dfc7044d013438eb98052b5fe63714806cd0e68d8758e9fdd9c7ccb06eafa79"
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
        shoal daemon install

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
