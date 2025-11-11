{ pkgs, ... }:

{
  # Cachix binary cache configuration
  cachix = {
    pull = [ "mikkihugo" ];
    push = "mikkihugo";
  };

  # Languages and tools (matching our flake.nix setup)
  languages = {
    rust = {
      enable = true;
      channel = "stable";
    };
    elixir = {
      enable = true;
      package = pkgs.beam.packages.erlang_28.elixir_1_19;
    };
  };

  # Pre-commit hooks for code quality
  pre-commit.hooks = {
    # Rust hooks
    rustfmt.enable = true;
    clippy = {
      enable = true;
      args = [
        "--workspace"
        "--all-targets"
        "--all-features"
        "--"
        "-D" "warnings"
        "-D" "clippy::all"
        "-D" "clippy::pedantic"
        "-D" "clippy::nursery"
        "-D" "clippy::cargo"
        "-W" "clippy::restriction"
        "-A" "clippy::missing_docs_in_private_items"
        "-A" "clippy::implicit_return"
        "-A" "clippy::missing_inline_in_public_items"
        "-A" "clippy::question_mark_used"
        "-A" "clippy::mod_module_files"
        "-A" "clippy::self_named_module_files"
      ];
    };

    # Security audit
    cargo-audit = {
      enable = true;
    };

    # Dependency linting
    cargo-deny = {
      enable = true;
      args = [ "check" ];
    };

    # Elixir hooks
    mix-format = {
      enable = true;
      excludes = [ "deps/" "_build/" ];
    };

    # Credo for Elixir linting
    credo = {
      enable = true;
    };
  };

  # Environment variables
  env = {
    RUST_BACKTRACE = "1";
    RUST_LOG = "debug";
  };

  # Shell hook for development
  enterShell = ''
    echo "🚀 Singularity Analysis Engine Development Environment"
    echo "📦 Cachix: Configured for mikkihugo cache"
    echo "🦀 Rust: $(rustc --version)"
    echo "💜 Elixir: $(elixir --version | head -n1)"
    echo ""
    echo "Binary cache will be used for faster builds!"
  '';
}