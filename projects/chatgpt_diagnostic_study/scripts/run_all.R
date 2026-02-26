# ===========================================================================
# run_all.R — Orchestration Script
# ===========================================================================
# Runs all analysis scripts in order, generates qa_inputs.json,
# then calls 99_verify_data.R for Stage B verification.
# Skill: code-review-companion (Stage B orchestration)
# ===========================================================================

cat("============================================================\n")
cat("  ChatGPT Diagnostic Accuracy Study - Full Analysis Run\n")
cat("  Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("============================================================\n\n")

# --- Shared result accumulator for qa_inputs ---
qa_results <- list()

# --- Phase 0: Setup ---
cat("=== Phase 0: Environment Setup ===\n")
source(file.path(
    here::here("projects", "chatgpt_diagnostic_study", "scripts"),
    "00_setup.R"
))

# --- Phase 0: Data Loading ---
cat("\n=== Phase 0: Data Loading & Cleaning ===\n")
source(file.path(scripts_dir, "01_data_load_clean.R"))

# Store data integrity results
qa_results$G0B_3_n_cases <- nrow(df_cases)
qa_results$G0B_3_n_responses <- nrow(df_diag)
qa_results$G0B_3_n_reviews <- nrow(df_reviews)

# --- Phase 1: Descriptive Statistics ---
cat("\n=== Phase 1: Descriptive Statistics ===\n")
source(file.path(scripts_dir, "02_descriptives.R"))

# --- Phase 2A: Primary Analysis ---
cat("\n=== Phase 2A: Primary Analysis ===\n")
source(file.path(scripts_dir, "03_primary_analysis.R"))

# --- Phase 2B: Diagnostic Accuracy ---
cat("\n=== Phase 2B: Diagnostic Accuracy ===\n")
source(file.path(scripts_dir, "04_diagnostic_accuracy.R"))

# --- Phase 2B: Secondary Outcomes ---
cat("\n=== Phase 2B-2C: Secondary Outcomes ===\n")
source(file.path(scripts_dir, "05_secondary_outcomes.R"))

# --- Phase 3: Figures ---
cat("\n=== Phase 3: Figures ===\n")
source(file.path(scripts_dir, "06_figures_tables.R"))

# ===========================================================================
# Stage B: Generate qa_inputs.json
# ===========================================================================
cat("\n=== Stage B: Verification ===\n")
cat(">>> Generating qa_inputs.json\n")

# Build key_results array from qa_results
key_results_list <- list()
qa_map <- list(
    list(id = "G2A-1", metric = "n_correct", key = "G2A_1_n_correct"),
    list(id = "G2A-1", metric = "case_accuracy_pct", key = "G2A_1_case_accuracy_pct"),
    list(id = "G2B-1", metric = "tp_count", key = "G2B_1_tp_count"),
    list(id = "G2B-1", metric = "fp_count", key = "G2B_1_fp_count"),
    list(id = "G2B-1", metric = "tn_count", key = "G2B_1_tn_count"),
    list(id = "G2B-1", metric = "fn_count", key = "G2B_1_fn_count"),
    list(id = "G2B-2", metric = "overall_accuracy_pct", key = "G2B_2_overall_accuracy_pct"),
    list(id = "G2B-2", metric = "precision_pct", key = "G2B_2_precision_pct"),
    list(id = "G2B-2", metric = "sensitivity_pct", key = "G2B_2_sensitivity_pct"),
    list(id = "G2B-2", metric = "specificity_pct", key = "G2B_2_specificity_pct"),
    list(id = "G2B-2", metric = "auc", key = "G2B_2_auc"),
    list(id = "G2B-3", metric = "cognitive_load_low", key = "G2B_3_cognitive_load_low"),
    list(id = "G2B-3", metric = "cognitive_load_moderate", key = "G2B_3_cognitive_load_moderate"),
    list(id = "G2B-3", metric = "cognitive_load_high", key = "G2B_3_cognitive_load_high"),
    list(id = "G2B-4", metric = "quality_complete_relevant", key = "G2B_4_quality_complete_relevant"),
    list(id = "G2B-4", metric = "quality_incomplete_relevant", key = "G2B_4_quality_incomplete_relevant"),
    list(id = "G2B-4", metric = "quality_incomplete_irrelevant", key = "G2B_4_quality_incomplete_irrelevant"),
    list(id = "G0B-3", metric = "n_cases", key = "G0B_3_n_cases"),
    list(id = "G0B-3", metric = "n_responses", key = "G0B_3_n_responses"),
    list(id = "G0B-3", metric = "n_reviews", key = "G0B_3_n_reviews")
)

for (item in qa_map) {
    val <- qa_results[[item$key]]
    if (!is.null(val)) {
        key_results_list <- c(key_results_list, list(list(
            id     = item$id,
            metric = item$metric,
            value  = val
        )))
    }
}

qa_json <- list(
    key_results       = key_results_list,
    assumption_checks = list()
)

jsonlite::write_json(qa_json, file.path(verify_dir, "qa_inputs.json"),
    pretty = TRUE, auto_unbox = TRUE
)
cat("  qa_inputs.json saved\n")

# --- Run verification ---
source(file.path(scripts_dir, "99_verify_data.R"))

cat("\n============================================================\n")
cat("  All analysis scripts completed successfully!\n")
cat("============================================================\n")
