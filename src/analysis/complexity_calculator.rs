//! Language-aware complexity calculator.
//! Pure calculation functions for comprehensive code complexity analysis.
//! Elixir handles orchestration, state management, and database operations.

use crate::langs::LANG;

/// Calculate comprehensive complexity score for a given language.
///
/// This replaces simple string-based calculations with heuristics that consider
/// multiple complexity dimensions.
#[inline]
pub fn calculate_language_complexity_score(code: &str, language: LANG) -> f64 {
    let features = extract_complexity_features(code, language);

    // Weighted complexity calculation
    let structural_complexity = calculate_structural_complexity(&features);
    let cognitive_complexity = calculate_cognitive_complexity(&features);
    let maintainability_complexity = calculate_maintainability_complexity(&features);

    // AI-optimized weighting for learning
    (structural_complexity * 0.4 + cognitive_complexity * 0.4 + maintainability_complexity * 0.2)
        .min(10.0) // Cap at 10.0 for consistency
}

/// Extract complexity features from code
#[inline]
pub fn extract_complexity_features(code: &str, language: LANG) -> ComplexityFeatures {
    let lines: Vec<&str> = code.lines().collect();
    let non_empty_lines: Vec<&str> = lines
        .iter()
        .filter(|line| !line.trim().is_empty())
        .map(|s| *s)
        .collect();

    ComplexityFeatures {
        total_lines: lines.len(),
        non_empty_lines: non_empty_lines.len(),
        function_count: count_patterns(code, &get_function_patterns(language)),
        control_flow_count: count_patterns(code, &get_control_flow_patterns(language)),
        nesting_depth: calculate_max_nesting_depth(code, language),
        operator_count: count_patterns(code, &get_operator_patterns(language)),
        comment_ratio: calculate_comment_ratio(code, language),
        identifier_length_avg: calculate_avg_identifier_length(code, language),
        cyclomatic_complexity: calculate_cyclomatic_complexity_estimate(code, language),
    }
}

/// Extract complexity features from code with custom patterns.
#[inline]
pub fn extract_complexity_features_with_patterns(
    code: &str,
    language: LANG,
    function_patterns: &[String],
    control_flow_patterns: &[String],
    operator_patterns: &[String],
    opening_delimiters: &[String],
    closing_delimiters: &[String],
    comment_patterns: &[String],
) -> ComplexityFeatures {
    let lines: Vec<&str> = code.lines().collect();
    let non_empty_lines: Vec<&str> = lines
        .iter()
        .filter(|line| !line.trim().is_empty())
        .map(|s| *s)
        .collect();

    // Convert Vec<String> to Vec<&str> for compatibility
    let function_patterns_str: Vec<&str> = function_patterns.iter().map(|s| s.as_str()).collect();
    let control_flow_patterns_str: Vec<&str> =
        control_flow_patterns.iter().map(|s| s.as_str()).collect();
    let operator_patterns_str: Vec<&str> = operator_patterns.iter().map(|s| s.as_str()).collect();
    let opening_delimiters_str: Vec<&str> = opening_delimiters.iter().map(|s| s.as_str()).collect();
    let closing_delimiters_str: Vec<&str> = closing_delimiters.iter().map(|s| s.as_str()).collect();
    let comment_patterns_str: Vec<&str> = comment_patterns.iter().map(|s| s.as_str()).collect();

    ComplexityFeatures {
        total_lines: lines.len(),
        non_empty_lines: non_empty_lines.len(),
        function_count: count_patterns(code, &function_patterns_str),
        control_flow_count: count_patterns(code, &control_flow_patterns_str),
        nesting_depth: calculate_max_nesting_depth_with_patterns(
            code,
            &opening_delimiters_str,
            &closing_delimiters_str,
        ),
        operator_count: count_patterns(code, &operator_patterns_str),
        comment_ratio: calculate_comment_ratio_with_patterns(code, &comment_patterns_str),
        identifier_length_avg: calculate_avg_identifier_length(code, language), // This doesn't need patterns
        cyclomatic_complexity: calculate_cyclomatic_complexity_estimate(code, language), // This doesn't need patterns
    }
}

/// Calculate structural complexity based on code organization
#[inline]
pub fn calculate_structural_complexity(features: &ComplexityFeatures) -> f64 {
    let function_density = features.function_count as f64 / features.non_empty_lines.max(1) as f64;
    let nesting_factor = (features.nesting_depth as f64).powi(2) / 10.0;
    let operator_density = features.operator_count as f64 / features.non_empty_lines.max(1) as f64;

    (function_density * 2.0 + nesting_factor + operator_density * 1.5).min(5.0)
}

/// Calculate cognitive complexity based on mental effort required
#[inline]
pub fn calculate_cognitive_complexity(features: &ComplexityFeatures) -> f64 {
    let control_flow_factor = features.control_flow_count as f64 * 0.5;
    let nesting_factor = features.nesting_depth as f64 * 0.8;
    let cyclomatic_factor = features.cyclomatic_complexity * 0.3;

    (control_flow_factor + nesting_factor + cyclomatic_factor).min(5.0)
}

/// Calculate maintainability complexity based on code quality indicators
#[inline]
pub fn calculate_maintainability_complexity(features: &ComplexityFeatures) -> f64 {
    let comment_factor: f64 = if features.comment_ratio > 0.2 {
        0.5
    } else {
        2.0
    };
    let identifier_factor: f64 = if features.identifier_length_avg > 8.0 {
        0.5
    } else {
        1.5
    };
    let length_factor: f64 = if features.non_empty_lines > 100 {
        1.5
    } else {
        0.5
    };

    (comment_factor + identifier_factor + length_factor).min(5.0)
}

/// Count patterns in code using language-specific patterns
#[inline]
pub fn count_patterns(code: &str, patterns: &[&str]) -> usize {
    patterns
        .iter()
        .map(|pattern| code.matches(pattern).count())
        .sum()
}

/// Get function definition patterns for a language
#[inline]
pub fn get_function_patterns(language: LANG) -> Vec<&'static str> {
    match language {
        LANG::Elixir => vec!["def ", "defp ", "defmacro "],
        LANG::Rust => vec!["fn ", "async fn "],
        LANG::Python => vec!["def ", "async def "],
        LANG::Javascript => vec!["function ", "=> ", "async function "],
        LANG::Typescript => vec!["function ", "=> ", "async function "],
        LANG::Java => vec!["public ", "private ", "protected "],
        LANG::Cpp => vec!["void ", "int ", "bool ", "string ", "char ", "float "],
        LANG::Go => vec!["func "],
        LANG::Kotlin => vec!["fun ", "class ", "object "],
        LANG::Csharp => vec!["void ", "public ", "private ", "async "],
        LANG::Erlang => vec!["-spec ", "when "],
        LANG::Gleam => vec!["pub fn ", "fn "],
        LANG::Lua => vec!["function "],
        _ => vec!["def ", "function ", "fn "],
    }
}

/// Get control flow patterns for a language
#[inline]
pub fn get_control_flow_patterns(language: LANG) -> Vec<&'static str> {
    match language {
        LANG::Elixir => vec![
            "if ", "unless ", "case ", "cond ", "with ", "for ", "while ",
        ],
        LANG::Rust => vec!["if ", "match ", "while ", "for ", "loop "],
        LANG::Python => vec!["if ", "elif ", "else ", "for ", "while ", "try "],
        LANG::Javascript => vec!["if ", "else ", "for ", "while ", "switch ", "try "],
        LANG::Typescript => vec!["if ", "else ", "for ", "while ", "switch ", "try "],
        LANG::Java => vec!["if ", "else ", "for ", "while ", "switch ", "try "],
        LANG::Cpp => vec!["if ", "else ", "for ", "while ", "switch ", "try "],
        LANG::Go => vec!["if ", "else ", "for ", "switch "],
        LANG::Kotlin => vec!["if ", "else ", "for ", "while ", "when ", "try "],
        LANG::Csharp => vec!["if ", "else ", "for ", "while ", "switch ", "try "],
        LANG::Erlang => vec!["case ", "if ", "receive "],
        LANG::Gleam => vec!["case ", "if ", "try "],
        LANG::Lua => vec!["if ", "elseif ", "for ", "while "],
        _ => vec!["if ", "else ", "for ", "while ", "case "],
    }
}

/// Get operator patterns for a language
#[inline]
pub fn get_operator_patterns(language: LANG) -> Vec<&'static str> {
    match language {
        LANG::Elixir => vec!["&&", "||", "and", "or", "|>", "->", "=>"],
        LANG::Rust => vec!["&&", "||", "&", "|", "->", "=>"],
        LANG::Python => vec!["and", "or", "not", "in", "is"],
        LANG::Javascript => vec!["&&", "||", "!", "===", "!=="],
        LANG::Typescript => vec!["&&", "||", "!", "===", "!=="],
        LANG::Java => vec!["&&", "||", "!", "==", "!="],
        LANG::Cpp => vec!["&&", "||", "!", "==", "!="],
        LANG::Go => vec!["&&", "||", "!", "==", "!="],
        LANG::Kotlin => vec!["&&", "||", "!", "==", "!=", "===", "!=="],
        LANG::Csharp => vec!["&&", "||", "!", "==", "!=", "??"],
        LANG::Erlang => vec!["and", "or", "not", "andalso", "orelse"],
        LANG::Gleam => vec!["&&", "||", "!", "==", "!="],
        LANG::Lua => vec!["and", "or", "not"],
        _ => vec!["&&", "||", "!", "==", "!="],
    }
}

/// Calculate maximum nesting depth in code
#[inline]
pub fn calculate_max_nesting_depth(code: &str, language: LANG) -> usize {
    let mut max_depth = 0;
    let mut current_depth = 0;

    for line in code.lines() {
        let trimmed = line.trim();

        // Count opening braces/brackets
        current_depth += trimmed.matches(get_opening_patterns(language)).count();

        // Count closing braces/brackets
        current_depth =
            current_depth.saturating_sub(trimmed.matches(get_closing_patterns(language)).count());

        max_depth = max_depth.max(current_depth);
    }

    max_depth
}

/// Get opening patterns for nesting calculation
#[inline]
pub fn get_opening_patterns(language: LANG) -> &'static str {
    match language {
        LANG::Elixir => "{",
        LANG::Rust => "{",
        LANG::Python => ":",
        LANG::Javascript => "{",
        LANG::Typescript => "{",
        LANG::Java => "{",
        LANG::Cpp => "{",
        LANG::Go => "{",
        LANG::Kotlin => "{",
        LANG::Csharp => "{",
        LANG::Erlang => "(",
        LANG::Gleam => "{",
        LANG::Lua => "do",
        _ => "{",
    }
}

/// Get closing patterns for nesting calculation
#[inline]
pub fn get_closing_patterns(language: LANG) -> &'static str {
    match language {
        LANG::Elixir => "}",
        LANG::Rust => "}",
        LANG::Python => "",
        LANG::Javascript => "}",
        LANG::Typescript => "}",
        LANG::Java => "}",
        LANG::Cpp => "}",
        LANG::Go => "}",
        LANG::Kotlin => "}",
        LANG::Csharp => "}",
        LANG::Erlang => ")",
        LANG::Gleam => "}",
        LANG::Lua => "end",
        _ => "}",
    }
}

/// Calculate comment ratio in code
#[inline]
pub fn calculate_comment_ratio(code: &str, language: LANG) -> f64 {
    let lines: Vec<&str> = code.lines().collect();
    let comment_patterns = get_comment_patterns(language);

    let comment_lines = lines
        .iter()
        .filter(|line| {
            let trimmed = line.trim();
            comment_patterns
                .iter()
                .any(|pattern| trimmed.starts_with(pattern))
        })
        .count();

    if lines.is_empty() {
        0.0
    } else {
        comment_lines as f64 / lines.len() as f64
    }
}

/// Get comment patterns for a language
#[inline]
pub fn get_comment_patterns(language: LANG) -> Vec<&'static str> {
    match language {
        LANG::Elixir => vec!["#"],
        LANG::Rust => vec!["//", "/*"],
        LANG::Python => vec!["#"],
        LANG::Javascript => vec!["//", "/*"],
        LANG::Typescript => vec!["//", "/*"],
        LANG::Java => vec!["//", "/*"],
        LANG::Cpp => vec!["//", "/*"],
        LANG::Go => vec!["//", "/*"],
        LANG::Kotlin => vec!["//", "/*"],
        LANG::Csharp => vec!["//", "/*"],
        LANG::Erlang => vec!["%"],
        LANG::Gleam => vec!["//"],
        LANG::Lua => vec!["--"],
        _ => vec!["//", "#"],
    }
}

/// Calculate maximum nesting depth with custom patterns
#[inline]
pub fn calculate_max_nesting_depth_with_patterns(
    code: &str,
    opening_patterns: &[&str],
    closing_patterns: &[&str],
) -> usize {
    let mut max_depth = 0;
    let mut current_depth = 0;

    for line in code.lines() {
        let trimmed = line.trim();

        // Count opening delimiters
        for pattern in opening_patterns {
            current_depth += trimmed.matches(pattern).count();
        }

        // Count closing delimiters
        for pattern in closing_patterns {
            current_depth = current_depth.saturating_sub(trimmed.matches(pattern).count());
        }

        max_depth = max_depth.max(current_depth);
    }

    max_depth
}

/// Calculate comment ratio with custom patterns
#[inline]
pub fn calculate_comment_ratio_with_patterns(code: &str, comment_patterns: &[&str]) -> f64 {
    let lines: Vec<&str> = code.lines().collect();

    let comment_lines = lines
        .iter()
        .filter(|line| {
            let trimmed = line.trim();
            comment_patterns
                .iter()
                .any(|pattern| trimmed.starts_with(pattern))
        })
        .count();

    if lines.is_empty() {
        0.0
    } else {
        comment_lines as f64 / lines.len() as f64
    }
}

/// Calculate comprehensive complexity score with custom patterns
#[inline]
pub fn calculate_language_complexity_score_with_patterns(
    code: &str,
    language: LANG,
    function_patterns: &[String],
    control_flow_patterns: &[String],
    operator_patterns: &[String],
    opening_delimiters: &[String],
    closing_delimiters: &[String],
    comment_patterns: &[String],
) -> f64 {
    let features = extract_complexity_features_with_patterns(
        code,
        language,
        function_patterns,
        control_flow_patterns,
        operator_patterns,
        opening_delimiters,
        closing_delimiters,
        comment_patterns,
    );

    // Weighted complexity calculation
    let structural_complexity = calculate_structural_complexity(&features);
    let cognitive_complexity = calculate_cognitive_complexity(&features);
    let maintainability_complexity = calculate_maintainability_complexity(&features);

    // AI-optimized weighting for learning
    (structural_complexity * 0.4 + cognitive_complexity * 0.4 + maintainability_complexity * 0.2)
        .min(10.0) // Cap at 10.0 for consistency
}

/// Calculate average identifier length
#[inline]
pub fn calculate_avg_identifier_length(code: &str, _language: LANG) -> f64 {
    let words: Vec<&str> = code.split_whitespace().collect();
    let identifiers: Vec<&str> = words
        .iter()
        .filter(|word| word.chars().all(|c| c.is_alphanumeric() || c == '_'))
        .map(|s| *s)
        .collect();

    if identifiers.is_empty() {
        0.0
    } else {
        let total_length: usize = identifiers.iter().map(|id| id.len()).sum();
        total_length as f64 / identifiers.len() as f64
    }
}

/// Calculate cyclomatic complexity estimate
#[inline]
pub fn calculate_cyclomatic_complexity_estimate(code: &str, language: LANG) -> f64 {
    let control_flow_patterns = get_control_flow_patterns(language);
    let operator_patterns = get_operator_patterns(language);

    let control_flow_count = count_patterns(code, &control_flow_patterns);
    let operator_count = count_patterns(code, &operator_patterns);

    // Basic cyclomatic complexity: 1 + control flow + logical operators
    1.0 + control_flow_count as f64 + (operator_count as f64 * 0.5)
}

/// Complexity features extracted from code
#[derive(Debug, Clone)]
pub struct ComplexityFeatures {
    pub total_lines: usize,
    pub non_empty_lines: usize,
    pub function_count: usize,
    pub control_flow_count: usize,
    pub nesting_depth: usize,
    pub operator_count: usize,
    pub comment_ratio: f64,
    pub identifier_length_avg: f64,
    pub cyclomatic_complexity: f64,
}

/// Calculate pattern effectiveness for AI learning
#[inline]
pub fn calculate_pattern_effectiveness(_pattern: &str, metrics: &ComplexityFeatures) -> f64 {
    // Pattern effectiveness based on complexity reduction
    let complexity_reduction = if metrics.cyclomatic_complexity > 5.0 {
        0.8
    } else {
        0.3
    };
    let maintainability_boost = if metrics.comment_ratio > 0.2 {
        0.9
    } else {
        0.4
    };
    let readability_score = if metrics.identifier_length_avg > 6.0 {
        0.7
    } else {
        0.5
    };

    (complexity_reduction + maintainability_boost + readability_score) / 3.0
}

/// Calculate supervision complexity for BEAM languages
#[inline]
pub fn calculate_supervision_complexity(modules: &[String]) -> f64 {
    if modules.is_empty() {
        return 0.0;
    }

    let supervisor_count = modules
        .iter()
        .filter(|module| module.contains("Supervisor") || module.contains("supervisor"))
        .count();

    let genserver_count = modules
        .iter()
        .filter(|module| module.contains("GenServer") || module.contains("gen_server"))
        .count();

    (supervisor_count as f64 * 0.5 + genserver_count as f64 * 0.3).min(10.0)
}

/// Calculate actor complexity for BEAM languages
#[inline]
pub fn calculate_actor_complexity(functions: &[String]) -> f64 {
    if functions.is_empty() {
        return 0.0;
    }

    let spawn_count = functions
        .iter()
        .filter(|func| func.contains("spawn") || func.contains("Task.async"))
        .count();

    let send_count = functions
        .iter()
        .filter(|func| func.contains("send") || func.contains("cast"))
        .count();

    let receive_count = functions
        .iter()
        .filter(|func| func.contains("receive") || func.contains("call"))
        .count();

    (spawn_count as f64 * 0.4 + send_count as f64 * 0.3 + receive_count as f64 * 0.3).min(10.0)
}
