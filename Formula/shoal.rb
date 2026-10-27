class Shoal < Formula
  desc "Local workspaces and resource allocation for coding agents"
  homepage "https://github.com/HN05/shoal"
  # Release commit: 6d9870efdc726f53ad384dd96c72fdaac67f363d
  version "0.11.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.11.2/shoal-v0.11.2-macos-arm64.tar.gz"
      sha256 "58394a66a7b2ef6ed3a719fc51ceeb24160c788c599d126bb5ffb681a5ff0d30"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.11.2/shoal-v0.11.2-macos-x86_64.tar.gz"
      sha256 "0f000fb60def567ae683fce98dc436f6c696452085384b2bc5680f93c9719377"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/HN05/shoal/releases/download/v0.11.2/shoal-v0.11.2-linux-arm64.tar.gz"
      sha256 "b71b0ca33b0e5a3cc2654405981cf23b4b936816d938f7927e861d505f820483"
    end
    on_intel do
      url "https://github.com/HN05/shoal/releases/download/v0.11.2/shoal-v0.11.2-linux-x86_64.tar.gz"
      sha256 "7a6abac0b5a119a380299f423b259b7797cfe64d6b53e40f8f0a9470cddeae9c"
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
