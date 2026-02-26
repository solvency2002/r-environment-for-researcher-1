# ===========================================================================
# 03_primary_analysis.R — Primary Analysis (Case Accuracy)
# ===========================================================================
# SAP: Section 9 (Primary analysis)
# Gate: G2A-1
# Skill: analysis-guardrails (do not fabricate; compute from data)
# ===========================================================================

# @plan_id G2A-1
# --- Case Accuracy ---
cat(">>> Primary Analysis: Case Accuracy\n\n")

n_total <- nrow(df_cases)
n_correct <- sum(df_cases$answer_correct_bool)
n_wrong <- n_total - n_correct
accuracy <- round(n_correct / n_total * 100, 1)

cat("  Total cases:", n_total, "\n")
cat("  Correct:", n_correct, "\n")
cat("  Incorrect:", n_wrong, "\n")
cat("  Case Accuracy:", accuracy, "%\n\n")

# --- Comparison with paper ---
paper_values <- tibble(
    metric = c("N total", "N correct", "N incorrect", "Case Accuracy (%)"),
    paper = c(150, 74, 76, 49.3),
    computed = c(n_total, n_correct, n_wrong, accuracy),
    match = c(
        n_total == 150, n_correct == 74, n_wrong == 76,
        abs(accuracy - 49.3) < 0.1
    )
)

print(paper_values)
cat("\n")

write_csv(paper_values, file.path(tbl_dir, "table2_primary_outcome.csv"))
cat("  Saved: table2_primary_outcome.csv\n")

# --- Store results for qa_inputs ---
qa_results$G2A_1_n_correct <- n_correct
qa_results$G2A_1_case_accuracy_pct <- accuracy

cat("\n>>> 03_primary_analysis.R completed\n")
