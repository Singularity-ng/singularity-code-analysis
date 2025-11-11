# Development Environment Setup

## Prerequisites

- **Nix** (with flakes enabled)
- **direnv** (optional, recommended)
- **Git**

## Quick Start

### 1. Enter Development Environment

```bash
# Using Nix directly
nix develop

# Or with direnv (recommended)
direnv allow
```

### 2. Install jscpd for Duplicate Detection

```bash
npm install -g jscpd
```

### 3. Run Quality Checks

```bash
# See all available commands
just --list

# Run all quality checks
just quality

# Run specific checks
just rust-quality
just elixir-quality
just security
```

## Available Tools

All tools are pre-installed via Nix (flake.nix):

### Rust Tools
- `cargo-audit` - Security vulnerability scanning
- `cargo-deny` - License and advisory checking
- `cargo-geiger` - Unsafe code detection
- `cargo-udeps` - Unused dependency detection (requires nightly)
- `cargo-machete` - Unused dependency detection
- `cargo-outdated` - Outdated dependency checker
- `cargo-nextest` - Fast test runner
- `cargo-tarpaulin` - Code coverage
- `cargo-bloat` - Binary size analysis
- `cargo-llvm-lines` - LLVM IR line counting
- `cargo-expand` - Macro expansion
- `cargo-fuzz` - Fuzz testing

### Elixir Tools
Installed via mix.exs dependencies:
- `credo` - Code linting and consistency
- `dialyxir` - Static type analysis
- `doctor` - Documentation coverage
- `sobelow` - Security scanner
- `mix_audit` - Dependency vulnerability scanner
- `excoveralls` - Code coverage

### Security & General
- `gitleaks` - Secret scanning
- `shellcheck` - Shell script linting
- `tokei` - Code statistics
- `just` - Command runner
- `nodejs` - For jscpd

## Configuration Files

| File | Purpose |
|------|---------|
| `flake.nix` | Nix development environment |
| `devenv.nix` | Pre-commit hooks configuration |
| `justfile` | Command runner recipes |
| `clippy.toml` | Rust Clippy linter settings |
| `deny.toml` | Cargo-deny policies |
| `.credo.exs` | Elixir Credo settings |
| `.jscpd.json` | Duplicate code detection config |
| `mix.exs` | Elixir project & dependencies |

## Quality Standards

### Rust
- **Clippy**: Pedantic + Nursery + Cargo lints
- **Cognitive Complexity**: ≤ 15
- **Function Lines**: ≤ 100
- **Function Parameters (bools)**: ≤ 3
- **Max Trait Bounds**: 3
- **Max Struct Bools**: 3
- **Enum Variant Size Diff**: ≤ 200 bytes

### Elixir
- **Cyclomatic Complexity**: ≤ 12
- **Function Arity**: ≤ 6
- **Nesting Depth**: ≤ 3
- **Line Length**: ≤ 120 characters
- **Module Documentation**: Required

### Security
- **Vulnerabilities**: Zero tolerance
- **Secrets**: No hardcoded secrets/keys
- **Licenses**: Only approved licenses (see deny.toml)

## Common Commands

### Format Code
```bash
just fmt                    # Format all code
just rust-fmt-fix          # Rust only
just elixir-fmt-fix        # Elixir only
```

### Run Tests
```bash
just test                  # All tests
just coverage              # Generate coverage reports
```

### Security Scans
```bash
just security              # All security checks
just gitleaks              # Scan for secrets
just rust-audit            # Rust vulnerabilities
just elixir-sobelow        # Elixir security
```

### Code Analysis
```bash
just stats                 # Code statistics
just duplication           # Find duplicate code
just rust-geiger           # Unsafe code detection
just bloat                 # Binary size analysis
```

### CLI Commands
```bash
just build-cli             # Build singularity-rca CLI
just install-cli           # Install CLI globally
just cli-languages         # List supported languages
just cli-analyze src/      # Analyze with CLI
just cli-metrics FILE      # Show metrics
just cli-complexity src/   # Check complexity
```

### Pre-commit
```bash
just pre-commit            # Quick essential checks
```

### CI Pipeline
```bash
just ci                    # Full CI simulation (all checks + tests + coverage)
just quality               # All quality checks (includes CLI analysis)
```

## Pre-commit Hooks

Configured in `devenv.nix`, automatically run on git commit:

**Rust:**
- `rustfmt --check`
- `clippy --workspace --all-targets --all-features`
- `cargo audit`
- `cargo deny check`

**Elixir:**
- `mix format --check-formatted`
- `mix credo`

## Troubleshooting

### Nix Issues
```bash
# Rebuild environment
nix flake update
nix develop --rebuild

# Clear cache
rm -rf .direnv .sccache
direnv allow
```

### Dialyzer Issues
```bash
# Clean and rebuild PLT
mix dialyzer --clean
mix dialyzer --plt
```

### Coverage Issues
```bash
# Clean coverage data
rm -rf coverage/ cover/
mix clean
cargo clean
```

### Pre-commit Hook Issues
```bash
# Skip hooks temporarily (use sparingly)
git commit --no-verify
```

## IDE Integration

### VS Code
Recommended extensions:
- `rust-analyzer` (Rust)
- `ElixirLS` (Elixir)
- `shellcheck` (Shell)
- `EditorConfig` (formatting)

### Neovim/Vim
- Use built-in LSP with `rust-analyzer` and `elixir-ls`
- Both are available in the Nix environment

## CI/CD

The `justfile` provides a `ci` target that runs:
1. All quality checks (Rust + Elixir + Security)
2. All tests
3. Coverage report generation

Use in CI pipeline:
```yaml
script:
  - nix develop -c just ci
```

## CLI Binary

The project includes a command-line interface `singularity-rca`:

**Build & Install:**
```bash
# Build CLI
just build-cli

# Install globally
just install-cli

# Or with cargo
cargo install --path . --features cli
```

**Usage:**
```bash
singularity-rca --help
singularity-rca languages
singularity-rca analyze src/ --recursive
```

See `CLI.md` for complete documentation.

## Language Registry

This project uses the Singularity Language Registry from GitHub:
```toml
singularity-language-registry = {
  git = "https://github.com/Singularity-ng/singularity-language-registry",
  tag = "v0.1.0"
}
```

See `Cargo.toml:50` for configuration.

## Additional Resources

- **Quality Documentation**: `QUALITY.md`
- **Contributing Guide**: `CONTRIBUTING.md`
- **Main README**: `README.md`
- **Just Documentation**: https://just.systems
- **Nix Flakes**: https://nixos.wiki/wiki/Flakes
