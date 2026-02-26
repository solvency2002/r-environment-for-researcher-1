# ===========================================================================
# 99_verify_data.R — Stage B Verification
# ===========================================================================
# Skill: code-review-companion (Stage B)
# Reads qa_inputs.json and verification_config.yml, performs comparison,
# generates qa_report.md and sample_verification_report.md
# ===========================================================================

# --- Path setup only (no side effects) ---
source(file.path(
    here::here("projects", "chatgpt_diagnostic_study", "scripts"),
    "_project_config.R"
))

if (!dir.exists(verify_dir)) dir.create(verify_dir, recursive = TRUE)

cat(">>> Running Stage B Verification\n\n")

# --- Read qa_inputs ---
qa_json_path <- file.path(verify_dir, "qa_inputs.json")
if (!file.exists(qa_json_path)) {
    stop("qa_inputs.json not found. Run run_all.R first.")
}
qa_inputs <- jsonlite::fromJSON(qa_json_path)

# --- Read verification config ---
config_path <- file.path(project_root, "verification_config.yml")
if (!file.exists(config_path)) {
    stop("verification_config.yml not found.")
}
config <- yaml::read_yaml(config_path)
on_failure <- config$on_failure %||% "warn"

# ===========================================================================
# QA Report: key_results comparison
# ===========================================================================

qa_lines <- c(
    "# QA Report",
    "",
    paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    "",
    "## Key Results Comparison",
    "",
    "| ID | Metric | Expected | Actual | Tolerance | Status |",
    "|-----|--------|----------|--------|-----------|--------|"
)

all_pass <- TRUE
n_pass <- 0
n_fail <- 0
n_warn <- 0

for (kr in config$key_results) {
    # Find matching entry in qa_inputs
    match_idx <- which(qa_inputs$key_results$id == kr$id &
        qa_inputs$key_results$metric == kr$metric)

    if (length(match_idx) == 0) {
        status <- "FAIL"
        actual <- "MISSING"
        all_pass <- FALSE
        n_fail <- n_fail + 1
    } else {
        actual <- qa_inputs$key_results$value[match_idx[1]]
        diff <- abs(actual - kr$expected)
        if (diff <= kr$tolerance) {
            status <- "PASS"
            n_pass <- n_pass + 1
        } else {
            status <- "FAIL"
            all_pass <- FALSE
            n_fail <- n_fail + 1
        }
    }

    status_icon <- ifelse(status == "PASS", "\\u2705", "\\u274C")
    qa_lines <- c(
        qa_lines,
        sprintf(
            "| %s | %s | %s | %s | %s | %s %s |",
            kr$id, kr$metric, kr$expected, actual,
            kr$tolerance, status_icon, status
        )
    )
}

# Check for extra entries in qa_inputs not in config
config_keys <- paste(sapply(config$key_results, `[[`, "id"),
    sapply(config$key_results, `[[`, "metric"),
    sep = "|"
)
qa_keys <- paste(qa_inputs$key_results$id,
    qa_inputs$key_results$metric,
    sep = "|"
)
extra <- setdiff(qa_keys, config_keys)

if (length(extra) > 0) {
    qa_lines <- c(qa_lines, "", "## Extra Results (not in config)", "")
    for (e in extra) {
        n_warn <- n_warn + 1
        qa_lines <- c(qa_lines, sprintf("- WARNING: %s found in qa_inputs but not in config", e))
    }
}

qa_lines <- c(
    qa_lines, "",
    "## Summary", "",
    sprintf("- Total checks: %d", n_pass + n_fail),
    sprintf("- Passed: %d", n_pass),
    sprintf("- Failed: %d", n_fail),
    sprintf("- Warnings: %d", n_warn),
    sprintf("- Overall: %s", ifelse(all_pass, "ALL PASS", "FAILURES DETECTED"))
)

writeLines(qa_lines, file.path(verify_dir, "qa_report.md"))
cat("  qa_report.md generated\n")

# ===========================================================================
# Sample Verification Report
# ===========================================================================

verify_lines <- c(
    "# Sample Verification Report",
    "",
    paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    "",
    "## File Integrity",
    "",
    "| File | Expected Rows | Status |",
    "|------|---------------|--------|"
)

# Check data files
files_check <- list(
    list(file = "chatgpt_cases_cleaned.csv", expected = 150),
    list(file = "diagnostic_accuracy_600.csv", expected = 600),
    list(file = "all_reviews.csv", expected = 300)
)

for (fc in files_check) {
    fpath <- file.path(data_dir, fc$file)
    if (file.exists(fpath)) {
        actual_n <- nrow(readr::read_csv(fpath, show_col_types = FALSE))
        status <- ifelse(actual_n == fc$expected, "PASS", "FAIL")
        verify_lines <- c(
            verify_lines,
            sprintf("| %s | %d | %s (n=%d) |", fc$file, fc$expected, status, actual_n)
        )
    } else {
        verify_lines <- c(
            verify_lines,
            sprintf("| %s | %d | FAIL (file not found) |", fc$file, fc$expected)
        )
    }
}

# Check output files
verify_lines <- c(
    verify_lines, "",
    "## Output Files", "",
    "| File | Exists |",
    "|------|--------|"
)

expected_outputs <- c(
    file.path(fig_dir, "fig1_case_accuracy.png"),
    file.path(fig_dir, "fig1_case_accuracy.pdf"),
    file.path(fig_dir, "fig2_confusion_matrix.png"),
    file.path(fig_dir, "fig3_roc_curve.png"),
    file.path(fig_dir, "fig4_cognitive_load.png"),
    file.path(fig_dir, "fig5_quality.png"),
    file.path(tbl_dir, "table1_descriptives.csv"),
    file.path(tbl_dir, "table2_primary_outcome.csv"),
    file.path(tbl_dir, "table3_diagnostic_metrics.csv")
)

for (f in expected_outputs) {
    exists_flag <- file.exists(f)
    verify_lines <- c(
        verify_lines,
        sprintf("| %s | %s |", basename(f), ifelse(exists_flag, "YES", "NO"))
    )
}

# Assumption checks (none for this study)
verify_lines <- c(
    verify_lines, "",
    "## Assumption Checks", "",
    "No model-specific assumption checks required (descriptive study)."
)

writeLines(verify_lines, file.path(verify_dir, "sample_verification_report.md"))
cat("  sample_verification_report.md generated\n")

# --- Handle on_failure ---
if (!all_pass && on_failure == "error") {
    stop("Verification FAILED. See qa_report.md for details.")
} else if (!all_pass) {
    warning("Verification has failures. See qa_report.md for details.")
}

cat("\n>>> 99_verify_data.R completed\n")
