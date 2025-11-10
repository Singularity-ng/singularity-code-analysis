#!/bin/bash

# Clean old grammars builds
cargo clean --manifest-path ./enums/Cargo.toml

# Recreate all grammars
cargo run --manifest-path ./enums/Cargo.toml -- languages --out ./src/languages

# Recreate C macros
cargo run --manifest-path ./enums/Cargo.toml -- macros --out ./src/c_langs_macros

# Format the code of the recreated grammars
cargo fmt
