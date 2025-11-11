# Code Quality Tools

This project uses enterprise-grade quality tools for both Rust and Elixir code.

## Elixir Quality Tools

### Code Quality & Linting
- **Credo** (`mix credo --strict`): Strict static code analysis
  - Configured in `.credo.exs`
  - Max cyclomatic complexity: 12
  - Max function arity: 6
  - Max nesting: 3
  - Enabled in pre-commit hooks

- **Dialyzer** (`mix dialyzer`): Static type checking and analysis
  - Configured in `mix.exs`
  - PLT file cached in `priv/plts/`
  - Flags: error_handling, underspecs, unmatched_returns

- **Doctor** (`mix doctor`): Documentation coverage analysis
  - Ensures module documentation
  - Tracks documentation completeness

### Security Scanning
- **Sobelow** (`mix sobelow --config`): Security-focused static analysis
  - Detects common security issues
  - Checks for OWASP top 10 vulnerabilities

- **mix_audit** (`mix deps.audit`): Dependency vulnerability scanner
  - Checks dependencies against security advisories
  - Integrates with hex.pm security database

### Code Coverage
- **ExCoveralls** (`mix coveralls` / `mix coveralls.html`):
  - Line and branch coverage
  - HTML reports: `cover/excoveralls.html`
  - Configured in `mix.exs`

### Formatting
- **mix format** (`mix format`): Official Elixir formatter
  - Enabled in pre-commit hooks
  - Excludes: `deps/`, `_build/`

## Rust Quality Tools

### Code Quality & Linting
- **Clippy** (`cargo clippy`): Comprehensive linter
  - Pedantic lints enabled
  - Nursery lints enabled
  - Cargo lints enabled
  - Restriction lints as warnings
  - Configured in `clippy.toml` and `devenv.nix`
  - Cognitive complexity threshold: 15
  - Max function lines: 100
  - Enabled in pre-commit hooks

- **rustfmt** (`cargo fmt`): Official Rust formatter
  - Enabled in pre-commit hooks

### Security & Dependencies
- **cargo-audit** (`cargo audit`): Security vulnerability scanner
  - Checks RustSec Advisory Database
  - Enabled in pre-commit hooks

- **cargo-deny** (`cargo deny check`): Comprehensive dependency checker
  - License compliance checking
  - Security advisory checking
  - Duplicate dependency detection
  - Configured in `deny.toml`
  - Enabled in pre-commit hooks

- **cargo-geiger** (`cargo geiger`): Unsafe code detector
  - Counts unsafe usage in dependencies
  - Highlights security-sensitive code

### Dependency Management
- **cargo-outdated** (`cargo outdated`): Find outdated dependencies
- **cargo-udeps** (`cargo +nightly udeps`): Find unused dependencies at build time
- **cargo-machete** (`cargo machete`): Find unused dependencies in Cargo.toml

### Performance & Analysis
- **cargo-bloat** (`cargo bloat --release`): Analyze binary size
- **cargo-expand** (`cargo expand`): Macro expansion
- **cargo-llvm-lines** (`cargo llvm-lines`): Count LLVM IR lines
- **cargo-fuzz** (`cargo fuzz`): Fuzz testing framework

### Testing & Coverage
- **cargo-nextest** (`cargo nextest run`): Next-generation test runner
  - Faster than `cargo test`
  - Better output formatting
  - Parallel execution

- **cargo-tarpaulin** (`cargo tarpaulin`): Code coverage
  - Line and branch coverage
  - HTML and XML reports
  - Works without instrumentation

## General Quality Tools

### Code Statistics
- **tokei**: Lines of code counter
  - Supports multiple languages
  - Fast and accurate

### Duplicate Detection
- **jscpd**: Multi-language duplicate code detector
  - Configured in `.jscpd.json`
  - Supports Rust, Elixir, and more
  - HTML reports in `reports/jscpd/`
  - Min lines: 5, Min tokens: 50
  - Install: `npm install -g jscpd`
  - Run: `jscpd .`

### Security Scanning
- **gitleaks** (`gitleaks detect`): Secret scanning
  - Finds hardcoded secrets, API keys, tokens
  - Pre-commit and historical scanning

- **shellcheck**: Shell script linter
  - Catches common shell scripting errors
  - Best practices enforcement

## Running Quality Checks

### Quick Check (Pre-commit)
Pre-commit hooks automatically run:
- `rustfmt`
- `clippy` (all workspaces)
- `cargo-audit`
- `cargo-deny check`
- `mix format`
- `mix credo`

### Full Quality Suite

**Rust:**
```bash
# Format check
cargo fmt --check

# Lint
cargo clippy --workspace --all-targets --all-features

# Security
cargo audit
cargo deny check
cargo geiger

# Tests with coverage
cargo tarpaulin --out Html --output-dir coverage

# Dependency checks
cargo outdated
cargo machete
cargo +nightly udeps
```

**Elixir:**
```bash
# Format check
mix format --check-formatted

# Lint
mix credo --strict

# Type checking
mix dialyzer

# Security
mix sobelow --config
mix deps.audit

# Documentation
mix doctor

# Tests with coverage
mix coveralls.html
```

**General:**
```bash
# Code statistics
tokei

# Duplicate detection
jscpd .

# Secret scanning
gitleaks detect

# Shell scripts
find . -name "*.sh" -exec shellcheck {} \;
```

## CI/CD Integration

All pre-commit hooks run automatically on commit. For CI/CD pipelines:

1. Run all formatters in check mode
2. Run all linters with strict settings
3. Run security scanners
4. Run tests with coverage
5. Generate coverage reports
6. Check for secrets with gitleaks

## Configuration Files

- `.credo.exs` - Credo configuration
- `clippy.toml` - Clippy configuration (root and enums/)
- `deny.toml` - cargo-deny configuration
- `.jscpd.json` - jscpd duplicate detection
- `mix.exs` - Test coverage and dialyzer settings
- `devenv.nix` - Pre-commit hook configuration

## Thresholds & Standards

**Rust:**
- Cognitive complexity: ≤ 15
- Function lines: ≤ 100
- Function parameters (bools): ≤ 3
- Max trait bounds: 3
- Max struct bools: 3
- Enum variant size difference: ≤ 200 bytes

**Elixir:**
- Cyclomatic complexity: ≤ 12
- Function arity: ≤ 6
- Nesting depth: ≤ 3
- Line length: ≤ 120 characters
- Module documentation required

**General:**
- Code duplication: ≥ 5 lines or ≥ 50 tokens triggers warning
- Security vulnerabilities: Zero tolerance (deny on commit)
- License compliance: Only approved licenses allowed
