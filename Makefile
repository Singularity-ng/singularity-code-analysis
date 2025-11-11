.PHONY: help quality rust-quality elixir-quality security test coverage clean

# Default target
help:
	@echo "Singularity Analysis Engine - Quality Targets"
	@echo ""
	@echo "Available targets:"
	@echo "  make quality         - Run all quality checks (Rust + Elixir + Security)"
	@echo "  make rust-quality    - Run all Rust quality checks"
	@echo "  make elixir-quality  - Run all Elixir quality checks"
	@echo "  make security        - Run security scans"
	@echo "  make test            - Run all tests"
	@echo "  make coverage        - Generate coverage reports"
	@echo "  make clean           - Clean build artifacts"
	@echo ""

# Run all quality checks
quality: rust-quality elixir-quality security
	@echo "✅ All quality checks completed!"

# Rust quality checks
rust-quality:
	@echo "🦀 Running Rust quality checks..."
	@echo "  → Formatting check"
	cargo fmt --check
	@echo "  → Clippy lints"
	cargo clippy --workspace --all-targets --all-features -- -D warnings
	@echo "  → Security audit"
	cargo audit
	@echo "  → Dependency checks"
	cargo deny check
	@echo "  → Outdated dependencies"
	cargo outdated
	@echo "  → Unused dependencies"
	cargo machete
	@echo "✅ Rust quality checks passed!"

# Elixir quality checks
elixir-quality:
	@echo "💜 Running Elixir quality checks..."
	@echo "  → Formatting check"
	mix format --check-formatted
	@echo "  → Credo (strict)"
	mix credo --strict
	@echo "  → Documentation coverage"
	mix doctor
	@echo "  → Security scan (Sobelow)"
	mix sobelow --config
	@echo "  → Dependency audit"
	mix deps.audit
	@echo "✅ Elixir quality checks passed!"

# Security scans
security:
	@echo "🔒 Running security scans..."
	@echo "  → Git secret scanning"
	gitleaks detect --no-git
	@echo "  → Rust security audit"
	cargo audit
	@echo "  → Rust dependency security"
	cargo deny check advisories
	@echo "  → Unsafe code detection"
	cargo geiger --update-readme
	@echo "  → Elixir security (Sobelow)"
	mix sobelow --config
	@echo "  → Elixir dependency audit"
	mix deps.audit
	@echo "✅ Security scans completed!"

# Run all tests
test:
	@echo "🧪 Running tests..."
	@echo "  → Rust tests"
	cargo nextest run --workspace --all-features
	@echo "  → Elixir tests"
	mix test
	@echo "✅ All tests passed!"

# Generate coverage reports
coverage:
	@echo "📊 Generating coverage reports..."
	@echo "  → Rust coverage"
	cargo tarpaulin --out Html --output-dir coverage/rust
	@echo "  → Elixir coverage"
	mix coveralls.html
	@echo "✅ Coverage reports generated!"
	@echo "  • Rust: coverage/rust/index.html"
	@echo "  • Elixir: cover/excoveralls.html"

# Type checking
typecheck:
	@echo "🔍 Running type checks..."
	@echo "  → Dialyzer"
	mix dialyzer
	@echo "✅ Type checking completed!"

# Code statistics
stats:
	@echo "📈 Code statistics..."
	tokei
	@echo ""
	@echo "Duplicate detection (jscpd):"
	@command -v jscpd >/dev/null 2>&1 && jscpd . || echo "⚠️  jscpd not installed. Run: npm install -g jscpd"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cargo clean
	mix clean
	rm -rf _build deps .mix .cargo .sccache
	rm -rf coverage cover reports
	@echo "✅ Clean completed!"

# Quick pre-commit check
pre-commit:
	@echo "🚀 Running pre-commit checks..."
	cargo fmt --check
	cargo clippy --workspace --all-targets --all-features -- -D warnings
	mix format --check-formatted
	mix credo
	gitleaks detect --no-git
	@echo "✅ Pre-commit checks passed!"

# CI/CD pipeline simulation
ci: quality test coverage
	@echo "✅ CI pipeline completed successfully!"
