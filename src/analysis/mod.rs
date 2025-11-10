//! Advanced analysis utilities that power higher-level insights such as
//! semantic understanding, predictive quality scoring, and historical
//! evolution tracking.

pub mod code_evolution_tracker;
pub mod complexity_calculator;
pub mod quality_predictor;
pub mod semantic_analyzer;

pub use code_evolution_tracker::*;
pub use complexity_calculator::*;
pub use quality_predictor::*;
pub use semantic_analyzer::*;
