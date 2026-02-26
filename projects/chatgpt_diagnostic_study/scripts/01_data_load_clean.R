# ===========================================================================
# 01_data_load_clean.R — Data Loading and Cleaning
# ===========================================================================
# SAP: Section 6 (Data processing plan)
# Gate: G0B-1 ~ G0B-4
# Skill: data-wrangling, analysis-guardrails
# ===========================================================================

# @plan_id G0B-1
# --- Read CSV files ---
cat(">>> Loading data...\n")

df_cases <- readr::read_csv(
    file.path(data_dir, "chatgpt_cases_cleaned.csv"),
    show_col_types = FALSE
)

df_diag <- readr::read_csv(
    file.path(data_dir, "diagnostic_accuracy_600.csv"),
    show_col_types = FALSE
)

df_reviews <- readr::read_csv(
    file.path(data_dir, "all_reviews.csv"),
    show_col_types = FALSE
)

# @plan_id G0B-4
# --- Guardrails: row count and variable type validation ---
stopifnot(
    "df_cases must have 150 rows" = nrow(df_cases) == 150,
    "df_diag must have 600 rows" = nrow(df_diag) == 600,
    "df_reviews must have 300 rows" = nrow(df_reviews) == 300
)

cat("  chatgpt_cases_cleaned.csv:", nrow(df_cases), "rows\n")
cat("  diagnostic_accuracy_600.csv:", nrow(df_diag), "rows\n")
cat("  all_reviews.csv:", nrow(df_reviews), "rows\n")

# --- Variable type check ---
stopifnot(
    is.logical(df_cases$answer_correct_bool),
    is.character(df_cases$cognitive_load_std),
    is.character(df_cases$quality_answer_std),
    is.character(df_diag$diagnostic_result)
)

# @plan_id G0B-2
# --- Type conversions ---
# cognitive_load_std: ordered factor
df_cases <- df_cases |>
    mutate(
        cognitive_load_std = factor(
            cognitive_load_std,
            levels = c("Low", "Moderate", "High"),
            ordered = TRUE
        ),
        # quality_answer_std: unordered factor
        quality_answer_std = factor(
            quality_answer_std,
            levels = c("Complete Relevant", "Incomplete Relevant", "Incomplete Irrelevant")
        )
    )

# diagnostic_result: factor
df_diag <- df_diag |>
    mutate(
        diagnostic_result = factor(
            diagnostic_result,
            levels = c("True Positive", "False Positive", "True Negative", "False Negative")
        )
    )

# @plan_id G0B-3
# --- Missing data check ---
na_cases <- colSums(is.na(df_cases))
na_diag <- colSums(is.na(df_diag))
na_reviews <- colSums(is.na(df_reviews))

cat("\n  Missing values in df_cases:\n")
print(na_cases[na_cases > 0])
if (all(na_cases == 0)) cat("    None\n")

cat("  Missing values in df_diag:\n")
print(na_diag[na_diag > 0])
if (all(na_diag == 0)) cat("    None\n")

cat("  Missing values in df_reviews:\n")
print(na_reviews[na_reviews > 0])
if (all(na_reviews == 0)) cat("    None\n")

# --- Data structure summary ---
cat("\n  Structure of df_cases:\n")
str(df_cases, give.attr = FALSE)

cat("\n>>> 01_data_load_clean.R completed\n")
