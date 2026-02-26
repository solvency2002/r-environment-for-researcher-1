# ===========================================================================
# 04_diagnostic_accuracy.R — Diagnostic Accuracy Metrics
# ===========================================================================
# SAP: Section 10.1 (Diagnostic accuracy)
# Gate: G2B-1, G2B-2, G2C-2
# Skill: analysis-guardrails
# ===========================================================================

# @plan_id G2B-1
# --- Confusion matrix counts ---
cat(">>> Diagnostic Accuracy Analysis\n\n")

diag_counts <- df_diag |>
    count(diagnostic_result) |>
    mutate(pct = round(n / sum(n) * 100, 2))

print(diag_counts)
cat("\n")

tp <- diag_counts |>
    filter(diagnostic_result == "True Positive") |>
    pull(n)
fp <- diag_counts |>
    filter(diagnostic_result == "False Positive") |>
    pull(n)
tn <- diag_counts |>
    filter(diagnostic_result == "True Negative") |>
    pull(n)
fn <- diag_counts |>
    filter(diagnostic_result == "False Negative") |>
    pull(n)

cat("  TP:", tp, "(expected: 73)\n")
cat("  FP:", fp, "(expected: 77)\n")
cat("  TN:", tn, "(expected: 373)\n")
cat("  FN:", fn, "(expected: 77)\n\n")

# @plan_id G2B-2
# --- Diagnostic accuracy metrics ---
overall_accuracy <- round((tp + tn) / (tp + fp + tn + fn) * 100, 2)
precision_val <- round(tp / (tp + fp) * 100, 2)
sensitivity_val <- round(tp / (tp + fn) * 100, 2)
specificity_val <- round(tn / (tn + fp) * 100, 2)

cat("  Overall Accuracy:", overall_accuracy, "%\n")
cat("  Precision:", precision_val, "%\n")
cat("  Sensitivity:", sensitivity_val, "%\n")
cat("  Specificity:", specificity_val, "%\n")

# --- AUC ---
# Create binary labels: 1 = Positive (TP or FP), 0 = Negative (TN or FN)
# True label: 1 = actually positive (TP or FN), 0 = actually negative (TN or FP)
df_roc <- df_diag |>
    mutate(
        true_label = case_when(
            diagnostic_result == "True Positive" ~ 1L,
            diagnostic_result == "False Negative" ~ 1L,
            diagnostic_result == "True Negative" ~ 0L,
            diagnostic_result == "False Positive" ~ 0L
        ),
        pred_label = case_when(
            diagnostic_result == "True Positive" ~ 1L,
            diagnostic_result == "False Positive" ~ 1L,
            diagnostic_result == "True Negative" ~ 0L,
            diagnostic_result == "False Negative" ~ 0L
        )
    )

auc_val <- NA_real_
if (pROC_available) {
    roc_obj <- pROC::roc(df_roc$true_label, df_roc$pred_label, quiet = TRUE)
    auc_val <- round(as.numeric(pROC::auc(roc_obj)), 2)
    cat("  AUC:", auc_val, "\n")
} else {
    cat("  AUC: skipped (pROC not available)\n")
}

# @plan_id G2C-2
# --- Sensitivity analysis: manual AUC calculation ---
# AUC for binary predictor = (sensitivity + specificity) / 2
auc_manual <- round((sensitivity_val / 100 + specificity_val / 100) / 2, 2)
cat("  AUC (manual):", auc_manual, "\n")
if (!is.na(auc_val)) {
    cat("  AUC difference (pROC vs manual):", abs(auc_val - auc_manual), "\n")
}

# --- Comparison table ---
diag_metrics <- tibble(
    metric = c(
        "Overall Accuracy (%)", "Precision (%)", "Sensitivity (%)",
        "Specificity (%)", "AUC"
    ),
    paper = c(74, 48.67, 48.67, 82.89, 0.66),
    computed = c(
        overall_accuracy, precision_val, sensitivity_val,
        specificity_val, ifelse(is.na(auc_val), auc_manual, auc_val)
    )
)

print(diag_metrics)
write_csv(diag_metrics, file.path(tbl_dir, "table3_diagnostic_metrics.csv"))
cat("\n  Saved: table3_diagnostic_metrics.csv\n")

# --- Store results for qa_inputs ---
qa_results$G2B_1_tp_count <- tp
qa_results$G2B_1_fp_count <- fp
qa_results$G2B_1_tn_count <- tn
qa_results$G2B_1_fn_count <- fn
qa_results$G2B_2_overall_accuracy_pct <- overall_accuracy
qa_results$G2B_2_precision_pct <- precision_val
qa_results$G2B_2_sensitivity_pct <- sensitivity_val
qa_results$G2B_2_specificity_pct <- specificity_val
qa_results$G2B_2_auc <- ifelse(is.na(auc_val), auc_manual, auc_val)

cat("\n>>> 04_diagnostic_accuracy.R completed\n")
