# ===========================================================================
# 02_descriptives.R — Descriptive Statistics and Exploration
# ===========================================================================
# SAP: Section 8 (Descriptive and exploratory analyses)
# Gate: G1-1, G1-2
# Skill: analysis-guardrails (confirm counts before analysis)
# ===========================================================================

# @plan_id G1-1
# --- Frequency tables ---
cat(">>> Descriptive Statistics\n\n")

# Answer correctness
cat("  Answer Correct:\n")
tbl_answer <- df_cases |>
    count(answer_correct_bool) |>
    mutate(pct = round(n / sum(n) * 100, 1))
print(tbl_answer)
cat("\n")

# Cognitive load
cat("  Cognitive Load:\n")
tbl_cog <- df_cases |>
    count(cognitive_load_std) |>
    mutate(pct = round(n / sum(n) * 100, 1))
print(tbl_cog)
cat("\n")

# Quality of medical information
cat("  Quality of Medical Information:\n")
tbl_qual <- df_cases |>
    count(quality_answer_std) |>
    mutate(pct = round(n / sum(n) * 100, 1))
print(tbl_qual)
cat("\n")

# --- Save Table 1 equivalent ---
table1 <- bind_rows(
    tbl_answer |> mutate(
        variable = "Answer Correct",
        category = as.character(answer_correct_bool)
    ) |>
        select(variable, category, n, pct),
    tbl_cog |> mutate(
        variable = "Cognitive Load",
        category = as.character(cognitive_load_std)
    ) |>
        select(variable, category, n, pct),
    tbl_qual |> mutate(
        variable = "Quality",
        category = as.character(quality_answer_std)
    ) |>
        select(variable, category, n, pct)
)

write_csv(table1, file.path(tbl_dir, "table1_descriptives.csv"))
cat("  Saved: table1_descriptives.csv\n")

cat("\n>>> 02_descriptives.R completed\n")
