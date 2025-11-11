# Singularity RCA CLI

Command-line interface for the Singularity Root Cause Analysis Engine.

## Installation

### Using Cargo

```bash
# Install from source
cargo install --path . --features cli

# Or use just
just install-cli
```

### Using Nix

```bash
# Build with Nix
nix build .#singularity-rca

# Run directly
nix run .#singularity-rca -- --help
```

## Quick Start

```bash
# Show help
singularity-rca --help

# Analyze a file
singularity-rca analyze src/lib.rs

# Analyze a directory (recursive)
singularity-rca analyze src/ --recursive

# Get metrics for a specific file
singularity-rca metrics src/lib.rs

# List supported languages
singularity-rca languages

# Check complexity
singularity-rca complexity src/ --threshold 10

# Generate HTML report
singularity-rca report src/ --output report.html --format html

# Compare two versions
singularity-rca compare v1/src v2/src --diff
```

## Commands

### `analyze`

Analyze a file or directory for code quality metrics.

```bash
singularity-rca analyze <PATH> [OPTIONS]

Options:
  -l, --language <LANG>    Language to analyze (auto-detect if not specified)
      --insights           Include advanced insight metrics
  -r, --recursive          Recursive directory analysis
  -f, --format <FORMAT>    Output format: table, json, pretty, csv [default: table]
  -v, --verbose            Enable verbose logging
```

**Examples:**

```bash
# Analyze single file
singularity-rca analyze src/main.rs

# Analyze directory recursively
singularity-rca analyze src/ --recursive

# Output as JSON
singularity-rca analyze src/ -r --format json

# Enable insights and verbose output
singularity-rca analyze src/ -r --insights -v

# Specify language explicitly
singularity-rca analyze script.txt --language python
```

### `metrics`

Get detailed metrics for a specific file.

```bash
singularity-rca metrics <PATH> [OPTIONS]

Options:
  -l, --language <LANG>    Language to analyze
  -m, --metric <METRIC>    Show only specific metric
  -f, --format <FORMAT>    Output format [default: table]
```

**Metrics:**
- `cyclomatic` - Cyclomatic complexity
- `cognitive` - Cognitive complexity
- `halstead` - Halstead metrics
- `loc` - Lines of code
- `maintainability` - Maintainability index
- `all` - All metrics (default)

**Examples:**

```bash
# All metrics
singularity-rca metrics src/lib.rs

# Only cyclomatic complexity
singularity-rca metrics src/lib.rs --metric cyclomatic

# JSON output
singularity-rca metrics src/lib.rs --format json
```

### `languages`

List all supported languages and their status.

```bash
singularity-rca languages [OPTIONS]

Options:
  -f, --format <FORMAT>    Output format [default: table]
```

**Example:**

```bash
singularity-rca languages
singularity-rca languages --format json
```

### `complexity`

Analyze code complexity and highlight high-complexity functions.

```bash
singularity-rca complexity <PATH> [OPTIONS]

Options:
  -t, --threshold <NUM>    Threshold for warning [default: 10]
      --only-high          Show only functions above threshold
  -f, --format <FORMAT>    Output format [default: table]
```

**Examples:**

```bash
# Check with default threshold (10)
singularity-rca complexity src/

# Custom threshold
singularity-rca complexity src/ --threshold 15

# Show only high complexity functions
singularity-rca complexity src/ --only-high
```

### `report`

Generate a comprehensive quality report.

```bash
singularity-rca report <PATH> [OPTIONS]

Options:
  -o, --output <FILE>      Output file for report
  -f, --format <FORMAT>    Report format: html, markdown, json, pdf [default: html]
```

**Examples:**

```bash
# Generate HTML report to stdout
singularity-rca report src/

# Save to file
singularity-rca report src/ --output quality-report.html

# Markdown format
singularity-rca report src/ --output REPORT.md --format markdown

# JSON format for CI integration
singularity-rca report src/ --output report.json --format json
```

### `compare`

Compare metrics between two versions of code.

```bash
singularity-rca compare <PATH1> <PATH2> [OPTIONS]

Options:
      --diff               Show improvement/regression details
  -f, --format <FORMAT>    Output format [default: table]
```

**Examples:**

```bash
# Compare two directories
singularity-rca compare old-version/ new-version/

# Show detailed diff
singularity-rca compare v1.0/ v2.0/ --diff

# JSON output for automation
singularity-rca compare v1/ v2/ --format json
```

## Output Formats

All commands support multiple output formats:

### `table` (default)
Pretty-printed table format for terminal viewing.

```
╔═══════════════════════╦═══════╦════════════╦═══════════╗
║ File                  ║ Lines ║ Complexity ║ Functions ║
╠═══════════════════════╬═══════╬════════════╬═══════════╣
║ src/lib.rs            ║  450  ║     12     ║    8      ║
║ src/analyzer.rs       ║  320  ║     8      ║    5      ║
╚═══════════════════════╩═══════╩════════════╩═══════════╝
```

### `json`
Structured JSON output for programmatic processing.

```json
{
  "files": [
    {
      "file": "src/lib.rs",
      "lines": 450,
      "complexity": 12,
      "functions": 8
    }
  ]
}
```

### `pretty`
Human-readable emoji-enhanced output.

```
📄 src/lib.rs
  Lines: 450
  Complexity: 12
  Functions: 8
```

### `csv`
CSV format for spreadsheet import.

```csv
File,Lines,Complexity,Functions
src/lib.rs,450,12,8
src/analyzer.rs,320,8,5
```

## Features & Feature Gates

The CLI is built with feature gates to minimize dependencies:

### Building Different Configurations

```bash
# Library only (no CLI dependencies)
cargo build --release

# CLI binary (includes CLI dependencies)
cargo build --release --features cli

# All features (including insight metrics)
cargo build --release --all-features

# Using just
just build-lib        # Library only
just build-cli        # CLI binary
just build-all        # Everything
```

### Available Features

| Feature | Description | Dependencies |
|---------|-------------|--------------|
| `default` | Base library | Core dependencies only |
| `cli` | Command-line interface | clap, anyhow, comfy-table, indicatif |
| `insight-metrics` | Advanced AI-powered metrics | Additional analysis libraries |
| `nif` | Elixir NIF support | rustler |

## Integration Examples

### CI/CD Pipeline

```yaml
# GitHub Actions example
- name: Install Singularity RCA CLI
  run: cargo install --path . --features cli

- name: Analyze code quality
  run: |
    singularity-rca analyze src/ --recursive --format json > metrics.json

- name: Check complexity threshold
  run: |
    singularity-rca complexity src/ --threshold 15 --format json
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Checking code complexity..."
if ! singularity-rca complexity src/ --threshold 10 --only-high; then
    echo "Error: Code complexity exceeds threshold"
    exit 1
fi
```

### Makefile Integration

```makefile
analyze:
    singularity-rca analyze src/ --recursive

quality-report:
    singularity-rca report src/ --output report.html

complexity-check:
    singularity-rca complexity src/ --threshold 12
```

## Environment Variables

```bash
# Enable debug logging
RUST_LOG=debug singularity-rca analyze src/

# Disable colored output
NO_COLOR=1 singularity-rca languages

# Custom log level
RUST_LOG=singularity=trace singularity-rca analyze src/ --verbose
```

## Using with Just

The project includes a `justfile` with convenient CLI commands:

```bash
# Build CLI
just build-cli

# Run CLI help
just cli-help

# Analyze current directory
just run-cli

# Analyze specific path
just cli-analyze src/

# Show metrics
just cli-metrics src/lib.rs

# List languages
just cli-languages

# Check complexity
just cli-complexity src/ --threshold 15

# Generate report
just cli-report src/ --output report.html

# Compare versions
just cli-compare v1/ v2/
```

## Performance Tips

1. **Use `--format json` for large outputs** - Faster than table formatting
2. **Specify language explicitly** - Skips auto-detection
3. **Use `--only-high` with complexity** - Reduces output size
4. **Enable parallel processing** - Set `RAYON_NUM_THREADS` environment variable

```bash
# Optimize for speed
RAYON_NUM_THREADS=8 singularity-rca analyze large-project/ --recursive --format json
```

## Troubleshooting

### "language not supported"
Check supported languages: `singularity-rca languages`

### "failed to parse file"
- Verify file is valid source code
- Try specifying language explicitly: `--language rust`
- Enable verbose mode: `--verbose`

### Slow analysis on large directories
- Use `--format json` instead of table
- Reduce parallelism if memory-constrained: `RAYON_NUM_THREADS=2`

## Development

```bash
# Run in development mode
cargo run --features cli -- analyze src/

# With hot reload (using cargo-watch)
cargo watch -x 'run --features cli -- analyze src/'

# Build optimized binary
cargo build --release --features cli

# Profile binary size
just bloat
```

## Contributing

See the main [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

For CLI-specific contributions:
1. All CLI code lives in `src/bin/cli.rs`
2. Follow the clap derive API patterns
3. Add tests in `tests/cli_tests.rs`
4. Update this documentation

## License

MIT OR Apache-2.0
