{
  description = "Singularity Analysis Engine development environment";

  # Configure binary caches for faster builds
  nixConfig = {
    extra-substituters = [
      "https://mikkihugo.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "mikkihugo.cachix.org-1:TJ+vwFP1XImrAATJbqWLaEvtzuWpui9hw5stDdeOTAE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # Rust toolchain - latest stable
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        # Build inputs for the project
        buildInputs = with pkgs; [
          # Rust and cargo tools
          rustToolchain
          cargo-edit      # cargo add/rm/upgrade
          cargo-watch     # cargo watch for auto-recompilation
          cargo-audit     # security audit
          cargo-outdated  # check for outdated dependencies
          cargo-tarpaulin # code coverage
          cargo-nextest   # better test runner
          cargo-machete   # find unused dependencies
          cargo-deny      # lint dependencies
          cargo-release   # release automation
          cargo-udeps     # find unused dependencies (build-time)
          cargo-expand    # expand macros
          cargo-bloat     # find what takes space in binary
          cargo-geiger    # detect unsafe usage
          cargo-fuzz      # fuzz testing
          cargo-llvm-lines # count LLVM IR lines
          sccache         # compilation cache

          # Node.js for additional tooling (jscpd can be installed via npm)
          nodejs

          # Elixir and Erlang
          beam.packages.erlang_28.elixir_1_19  # Elixir 1.19 with Erlang/OTP 28
          beam.packages.erlang_28.erlang
          beam.packages.erlang_28.rebar3
          beam.packages.erlang_28.hex

          # Elixir tools from Nix (pre-built, no compilation needed)
          beam.packages.erlang_28.elixir-ls  # Language server

          # Build dependencies for NIFs
          pkg-config
          openssl

          # Development tools
          git
          gnumake
          just           # command runner (modern make alternative)
          gcc
          libiconv

          # Security and quality scanning
          gitleaks       # secret scanning
          shellcheck     # shell script linting

          # Optional: useful for development
          jq
          ripgrep
          fd
          bat
          eza
          tokei          # code statistics
        ];

        # Set up environment variables
        shellHook = ''
          echo "🚀 Singularity Analysis Engine Development Environment"
          echo ""
          echo "📦 Versions:"
          echo "  • Rust: $(rustc --version | cut -d' ' -f2)"
          echo "  • Cargo: $(cargo --version | cut -d' ' -f2)"
          echo "  • Elixir: $(elixir --version | grep Elixir | cut -d' ' -f2)"
          echo "  • Erlang/OTP: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell | tr -d '\"')"
          echo ""
          echo "🛠️  Rust Quality Tools:"
          echo "  • cargo-audit, cargo-deny, cargo-geiger (security)"
          echo "  • cargo-nextest, cargo-tarpaulin (testing & coverage)"
          echo "  • cargo-outdated, cargo-udeps, cargo-machete (dependencies)"
          echo "  • cargo-bloat, cargo-llvm-lines (performance analysis)"
          echo "  • cargo-expand, cargo-fuzz (advanced)"
          echo ""
          echo "💜 Elixir Quality Tools:"
          echo "  • credo, dialyzer, doctor (code quality)"
          echo "  • sobelow, mix_audit (security)"
          echo "  • excoveralls (coverage)"
          echo ""
          echo "🔒 Security & General:"
          echo "  • gitleaks (secret scanning)"
          echo "  • shellcheck (shell script linting)"
          echo "  • tokei (code statistics)"
          echo "  • jscpd (install: npm install -g jscpd)"
          echo ""
          echo "🚀 Quick Commands:"
          echo "  • make help          - Show all available targets"
          echo "  • make quality       - Run all quality checks"
          echo "  • make security      - Security scans"
          echo "  • make test          - Run all tests"
          echo "  • make coverage      - Generate coverage reports"
          echo "  • See QUALITY.md for detailed documentation"
          echo ""

          # Set up Rust environment
          export RUST_SRC_PATH="${rustToolchain}/lib/rustlib/src/rust/library"
          export RUST_BACKTRACE=1

          # Set up build cache
          export SCCACHE_DIR="$PWD/.sccache"
          export RUSTC_WRAPPER="${pkgs.sccache}/bin/sccache"

          # Elixir/Erlang environment
          export ERL_AFLAGS="-kernel shell_history enabled"
          export HEX_HOME="$PWD/.hex"
          export MIX_HOME="$PWD/.mix"

          # Create local directories if they don't exist
          mkdir -p .sccache .hex .mix

          # Install local hex and rebar if not present
          if [ ! -f "$MIX_HOME/escripts/hex" ]; then
            echo "📥 Installing local hex..."
            mix local.hex --force --if-missing
          fi

          if [ ! -f "$MIX_HOME/escripts/rebar" ] && [ ! -f "$MIX_HOME/escripts/rebar3" ]; then
            echo "📥 Installing local rebar..."
            mix local.rebar --force --if-missing
          fi
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          inherit shellHook;

          # Additional environment variables
          RUST_LOG = "debug";
          CARGO_HOME = "$PWD/.cargo";
        };

        # Also provide a minimal shell without the startup message
        devShells.minimal = pkgs.mkShell {
          inherit buildInputs;
          shellHook = ''
            export RUST_SRC_PATH="${rustToolchain}/lib/rustlib/src/rust/library"
            export RUST_BACKTRACE=1
            export SCCACHE_DIR="$PWD/.sccache"
            export RUSTC_WRAPPER="${pkgs.sccache}/bin/sccache"
            export ERL_AFLAGS="-kernel shell_history enabled"
            export HEX_HOME="$PWD/.hex"
            export MIX_HOME="$PWD/.mix"
            export RUST_LOG="debug"
            export CARGO_HOME="$PWD/.cargo"
            mkdir -p .sccache .hex .mix .cargo
          '';
        };
      });
}