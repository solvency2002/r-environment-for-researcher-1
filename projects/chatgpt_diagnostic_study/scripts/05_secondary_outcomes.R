# ===========================================================================
# 05_secondary_outcomes.R — Secondary Outcomes
# ===========================================================================
# SAP: Section 10.2–10.4, Section 12.1 (Sensitivity)
# Gate: G2B-3, G2B-4, G2B-5, G2C-1
# Skill: analysis-guardrails
# ===========================================================================

cat(">>> Secondary Outcomes Analysis\n\n")

# @plan_id G2B-3
# --- Cognitive Load Distribution ---
cat("  --- Cognitive Load Distribution ---\n")
cog_dist <- df_cases |>
    count(cognitive_load_std) |>
    mutate(pct = round(n / sum(n) * 100, 1))

paper_cog <- tibble(
    cognitive_load_std = factor(c("Low", "Moderate", "High"),
        levels = c("Low", "Moderate", "High"),
        ordered = TRUE
    ),
    paper_n = c(77, 61, 12),
    paper_pct = c(51.3, 40.7, 8.0)
)

cog_comparison <- cog_dist |>
    left_join(paper_cog, by = "cognitive_load_std") |>
    mutate(match_n = (n == paper_n))

print(cog_comparison)
cat("\n")

# Store for qa_inputs
qa_results$G2B_3_cognitive_load_low <- cog_dist |>
    filter(cognitive_load_std == "Low") |>
    pull(n)
qa_results$G2B_3_cognitive_load_moderate <- cog_dist |>
    filter(cognitive_load_std == "Moderate") |>
    pull(n)
qa_results$G2B_3_cognitive_load_high <- cog_dist |>
    filter(cognitive_load_std == "High") |>
    pull(n)

# @plan_id G2C-1
# --- Sensitivity: High count = 11 vs 12 ---
cat("  --- Sensitivity Analysis: Cognitive Load High Count ---\n")
high_count <- cog_dist |>
    filter(cognitive_load_std == "High") |>
    pull(n)
cat("  Current High count:", high_count, "\n")
cat("  Paper High count: 11 (sums to 149; adjusted to 12 for total=150)\n")
cat("  Impact on High percentage: ",
    round(11 / 150 * 100, 1), "% (if 11) vs ",
    round(12 / 150 * 100, 1), "% (if 12)\n\n",
    sep = ""
)

# @plan_id G2B-4
# --- Quality of Medical Information Distribution ---
cat("  --- Quality of Medical Information Distribution ---\n")
qual_dist <- df_cases |>
    count(quality_answer_std) |>
    mutate(pct = round(n / sum(n) * 100, 1))

paper_qual <- tibble(
    quality_answer_std = factor(
        c("Complete Relevant", "Incomplete Relevant", "Incomplete Irrelevant"),
        levels = c("Complete Relevant", "Incomplete Relevant", "Incomplete Irrelevant")
    ),
    paper_n = c(78, 64, 8),
    paper_pct = c(52.0, 42.7, 5.3)
)

qual_comparison <- qual_dist |>
    left_join(paper_qual, by = "quality_answer_std") |>
    mutate(match_n = (n == paper_n))

print(qual_comparison)
cat("\n")

# Store for qa_inputs
qa_results$G2B_4_quality_complete_relevant <- qual_dist |>
    filter(quality_answer_std == "Complete Relevant") |>
    pull(n)
qa_results$G2B_4_quality_incomplete_relevant <- qual_dist |>
    filter(quality_answer_std == "Incomplete Relevant") |>
    pull(n)
qa_results$G2B_4_quality_incomplete_irrelevant <- qual_dist |>
    filter(quality_answer_std == "Incomplete Irrelevant") |>
    pull(n)

# @plan_id G2B-5
# --- Inter-rater Reliability (Cohen's Kappa) ---
cat("  --- Inter-rater Reliability (Cohen's Kappa) ---\n")

if (irr_available) {
    # Pivot reviews to wide format for kappa calculation
    reviews_wide <- df_reviews |>
        select(case_name, reviewer, diagnostic_accuracy) |>
        pivot_wider(names_from = reviewer, values_from = diagnostic_accuracy)

    kappa_diag <- irr::kappa2(reviews_wide[, c("R1", "R2")])
    cat("  Diagnostic accuracy kappa:", round(kappa_diag$value, 2), "\n")
    cat("    Paper value: 0.78\n")

    # Cognitive load
    reviews_cog <- df_reviews |>
        select(case_name, reviewer, cognitive_load) |>
        pivot_wider(names_from = reviewer, values_from = cognitive_load)

    kappa_cog <- irr::kappa2(reviews_cog[, c("R1", "R2")])
    cat("  Cognitive load kappa:", round(kappa_cog$value, 2), "\n")
    cat("    Paper value: 0.64\n")

    # Quality
    reviews_qual <- df_reviews |>
        select(case_name, reviewer, quality_answer) |>
        pivot_wider(names_from = reviewer, values_from = quality_answer)

    kappa_qual <- irr::kappa2(reviews_qual[, c("R1", "R2")])
    cat("  Quality kappa:", round(kappa_qual$value, 2), "\n")
    cat("    Paper value: 1.0\n")

    cat("\n  Note: Synthetic data has R1==R2 by design, so kappa values\n")
    cat("  are expected to be 1.0 (perfect agreement).\n")
    cat("  This is documented in Decision log #2.\n\n")
} else {
    cat("  Skipped: irr package not available\n\n")
}

cat(">>> 05_secondary_outcomes.R completed\n")
