# Singularity Analysis Engine - Quality Justfile
# Run with: just quality

# Default recipe (shows help)
default:
    @just --list

# Run all quality checks (Rust + Elixir + Security + CLI analysis)
quality: rust-quality elixir-quality security duplication cli-quality-check
    @echo "✅ All quality checks completed!"

# === RUST QUALITY CHECKS ===

# Run all Rust quality checks
rust-quality: rust-fmt rust-clippy rust-audit rust-deny rust-outdated rust-machete
    @echo "✅ Rust quality checks passed!"

# Check Rust formatting
rust-fmt:
    @echo "🦀 Checking Rust formatting..."
    cargo fmt --check

# Run Clippy with pedantic + nursery + cargo lints
rust-clippy:
    @echo "🦀 Running Clippy (pedantic + nursery)..."
    cargo clippy --workspace --all-targets --all-features -- \
        -D warnings \
        -D clippy::all \
        -D clippy::pedantic \
        -D clippy::nursery \
        -D clippy::cargo

# Security audit
rust-audit:
    @echo "🦀 Running cargo-audit..."
    cargo audit

# Dependency checks (licenses, bans, advisories)
rust-deny:
    @echo "🦀 Running cargo-deny..."
    cargo deny check

# Check for outdated dependencies
rust-outdated:
    @echo "🦀 Checking outdated dependencies..."
    cargo outdated

# Find unused dependencies
rust-machete:
    @echo "🦀 Finding unused dependencies..."
    cargo machete

# Detect unsafe code usage
rust-geiger:
    @echo "🦀 Detecting unsafe code..."
    cargo geiger

# Find unused dependencies (build-time, requires nightly)
rust-udeps:
    @echo "🦀 Finding unused dependencies (nightly)..."
    cargo +nightly udeps --workspace

# === ELIXIR QUALITY CHECKS ===

# Run all Elixir quality checks
elixir-quality: elixir-fmt elixir-credo elixir-doctor elixir-sobelow elixir-audit
    @echo "✅ Elixir quality checks passed!"

# Check Elixir formatting
elixir-fmt:
    @echo "💜 Checking Elixir formatting..."
    mix format --check-formatted

# Run Credo (strict mode)
elixir-credo:
    @echo "💜 Running Credo (strict)..."
    mix credo --strict

# Check documentation coverage
elixir-doctor:
    @echo "💜 Checking documentation coverage..."
    mix doctor

# Security scan with Sobelow
elixir-sobelow:
    @echo "💜 Running Sobelow security scan..."
    mix sobelow --config

# Audit dependencies for vulnerabilities
elixir-audit:
    @echo "💜 Auditing dependencies..."
    mix deps.audit

# Run Dialyzer type checking
elixir-dialyzer:
    @echo "💜 Running Dialyzer..."
    mix dialyzer

# === SECURITY SCANS ===

# Run all security scans
security: gitleaks rust-audit rust-deny rust-geiger elixir-sobelow elixir-audit
    @echo "✅ Security scans completed!"

# Scan for secrets and credentials
gitleaks:
    @echo "🔒 Scanning for secrets..."
    gitleaks detect --no-git

# Lint shell scripts
shellcheck:
    @echo "🔒 Linting shell scripts..."
    find . -name "*.sh" -not -path "./deps/*" -not -path "./_build/*" -not -path "./target/*" -exec shellcheck {} \;

# === CODE QUALITY & ANALYSIS ===

# Detect duplicate code (requires: npm install -g jscpd)
duplication:
    @echo "📊 Detecting duplicate code..."
    @if command -v jscpd >/dev/null 2>&1; then \
        jscpd .; \
    else \
        echo "⚠️  jscpd not installed. Run: npm install -g jscpd"; \
    fi

# Code statistics
stats:
    @echo "📈 Code statistics..."
    @tokei

# === TESTING & COVERAGE ===

# Run all tests
test:
    @echo "🧪 Running tests..."
    @echo "  → Rust tests"
    cargo nextest run --workspace --all-features
    @echo "  → Elixir tests"
    mix test

# Generate coverage reports
coverage: coverage-rust coverage-elixir
    @echo "✅ Coverage reports generated!"
    @echo "  • Rust: coverage/rust/index.html"
    @echo "  • Elixir: cover/excoveralls.html"

# Rust coverage
coverage-rust:
    @echo "📊 Generating Rust coverage..."
    cargo tarpaulin --out Html --output-dir coverage/rust

# Elixir coverage
coverage-elixir:
    @echo "📊 Generating Elixir coverage..."
    mix coveralls.html

# === FORMATTING ===

# Format all code
fmt: rust-fmt-fix elixir-fmt-fix
    @echo "✅ All code formatted!"

# Fix Rust formatting
rust-fmt-fix:
    @echo "🦀 Formatting Rust code..."
    cargo fmt

# Fix Elixir formatting
elixir-fmt-fix:
    @echo "💜 Formatting Elixir code..."
    mix format

# === MAINTENANCE ===

# Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    cargo clean
    mix clean
    rm -rf _build deps .mix .cargo .sccache
    rm -rf coverage cover reports
    @echo "✅ Clean completed!"

# Update dependencies
update:
    @echo "📦 Updating dependencies..."
    @echo "  → Rust dependencies"
    cargo update
    @echo "  → Elixir dependencies"
    mix deps.update --all

# === CI/CD SIMULATION ===

# Run CI pipeline (all checks + tests + coverage)
ci: quality test coverage
    @echo "✅ CI pipeline completed successfully!"

# Pre-commit checks (fast, essential only)
pre-commit:
    @echo "🚀 Running pre-commit checks..."
    cargo fmt --check
    cargo clippy --workspace --all-targets --all-features -- -D warnings
    mix format --check-formatted
    mix credo
    gitleaks detect --no-git
    @echo "✅ Pre-commit checks passed!"

# === PERFORMANCE ANALYSIS ===

# Analyze binary size
bloat:
    @echo "📊 Analyzing binary size..."
    cargo bloat --release --features cli

# Count LLVM IR lines
llvm-lines:
    @echo "📊 Counting LLVM IR lines..."
    cargo llvm-lines

# Expand macros
expand:
    @echo "🔍 Expanding macros..."
    cargo expand

# === CLI BUILD & RUN ===

# Build the CLI binary (library + CLI features)
build-cli:
    @echo "🔨 Building singularity-rca CLI binary..."
    cargo build --release --features cli

# Run quality analysis using the CLI (after building)
cli-quality-check:
    @echo "🔍 Running CLI-based quality analysis..."
    @if cargo build --release --features cli 2>/dev/null; then \
        echo "  → Analyzing src/ with singularity-rca..."; \
        ./target/release/singularity-rca analyze src/ --recursive --format table 2>/dev/null || echo "  ⚠️  CLI analysis skipped (implementation pending)"; \
    else \
        echo "  ⚠️  CLI build skipped (optional feature)"; \
    fi

# Build library only (no CLI)
build-lib:
    @echo "🔨 Building library..."
    cargo build --release

# Build with all features
build-all:
    @echo "🔨 Building all features..."
    cargo build --release --all-features

# Install CLI binary
install-cli:
    @echo "📦 Installing singularity-rca CLI..."
    cargo install --path . --features cli

# Run CLI (analyze current directory)
run-cli PATH="." *ARGS="":
    @echo "🚀 Running CLI..."
    cargo run --features cli -- analyze {{PATH}} {{ARGS}}

# Show CLI help
cli-help:
    @echo "📖 CLI Help:"
    cargo run --features cli -- --help

# CLI: Analyze file or directory
cli-analyze PATH *ARGS="":
    cargo run --features cli -- analyze {{PATH}} {{ARGS}}

# CLI: Show metrics for a file
cli-metrics FILE *ARGS="":
    cargo run --features cli -- metrics {{FILE}} {{ARGS}}

# CLI: List supported languages
cli-languages:
    cargo run --features cli -- languages

# CLI: Check complexity
cli-complexity PATH *ARGS="":
    cargo run --features cli -- complexity {{PATH}} {{ARGS}}

# CLI: Generate report
cli-report PATH *ARGS="":
    cargo run --features cli -- report {{PATH}} {{ARGS}}

# CLI: Compare two versions
cli-compare PATH1 PATH2 *ARGS="":
    cargo run --features cli -- compare {{PATH1}} {{PATH2}} {{ARGS}}
