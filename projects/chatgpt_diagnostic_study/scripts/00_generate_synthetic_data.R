# ============================================================================
# ChatGPT Diagnostic Accuracy Study - Generate Synthetic Data
# ============================================================================
# Purpose: Create synthetic data matching the paper's reported results
#          for hands-on tutorial purposes
# Paper: Evaluation of ChatGPT as a diagnostic tool (PLOS ONE)
# ============================================================================

set.seed(123)

# Load packages
suppressPackageStartupMessages({
  library(here)
})

# ============================================================================
# 1. Generate case data
# ============================================================================

# Paper reported values - use literals to avoid any confusion
# 150 total cases, 74 correct, 76 incorrect

# Generate answer_correct: 74 TRUE, 76 FALSE
answer_correct <- c(rep(TRUE, 74), rep(FALSE, 76))
set.seed(123)
answer_correct <- sample(answer_correct)  # Shuffle

# Cognitive Load: Low 77, Moderate 61, High 11
cognitive_load <- c(rep("Low", 77), rep("Moderate", 61), rep("High", 12))
# Note: 77+61+12 = 150 (paper says High=11 but that only sums to 149, using 12)
set.seed(456)
cognitive_load <- sample(cognitive_load)

# Quality: Complete/Relevant 78, Incomplete/Relevant 64, Incomplete/Irrelevant 8
quality_answer <- c(
  rep("Complete Relevant", 78),
  rep("Incomplete Relevant", 64),
  rep("Incomplete Irrelevant", 8)
)
set.seed(789)
quality_answer <- sample(quality_answer)

# Create main dataset with simple case names
chatgpt_cases <- data.frame(
  case_id = 1:150,
  case_name = paste0("Case_", sprintf("%03d", 1:150)),
  answer_correct = ifelse(answer_correct, "yes", "no"),
  answer_correct_bool = answer_correct,
  cognitive_load = cognitive_load,
  cognitive_load_std = cognitive_load,
  quality_answer = quality_answer,
  quality_answer_std = quality_answer,
  n_reviewers = rep(2, 150),
  stringsAsFactors = FALSE
)

# ============================================================================
# 2. Generate diagnostic accuracy data (600 responses = 150 cases × 4 options)
# ============================================================================

# Build the data
diagnostic_results <- character(600)
idx <- 1

for (i in 1:150) {
  if (answer_correct[i]) {
    # ChatGPT was correct: 1 TP + 3 TN
    diagnostic_results[idx:(idx+3)] <- c("True Positive", "True Negative", "True Negative", "True Negative")
  } else {
    # ChatGPT was incorrect: 1 FN + 1 FP + 2 TN
    diagnostic_results[idx:(idx+3)] <- c("False Negative", "False Positive", "True Negative", "True Negative")
  }
  idx <- idx + 4
}

# Current counts
# TP = 74, FP = 76, TN = 74*3 + 76*2 = 222 + 152 = 374, FN = 76
# Paper: TP=73, FP=77, TN=373, FN=77
# Adjust: TP-1, FP+1, TN-1, FN+1

tp_indices <- which(diagnostic_results == "True Positive")
tn_indices <- which(diagnostic_results == "True Negative")

diagnostic_results[tp_indices[1]] <- "False Negative"
diagnostic_results[tn_indices[1]] <- "False Positive"

diagnostic_accuracy_data <- data.frame(
  response_id = 1:600,
  case_id = rep(1:150, each = 4),
  option = rep(1:4, times = 150),
  diagnostic_result = diagnostic_results,
  stringsAsFactors = FALSE
)

# ============================================================================
# 3. Generate all_reviews.csv for inter-rater scripts
# ============================================================================

all_reviews <- data.frame(
  case_name = rep(chatgpt_cases$case_name, 2),
  answer_correct = rep(chatgpt_cases$answer_correct, 2),
  cognitive_load = rep(chatgpt_cases$cognitive_load, 2),
  quality_answer = rep(chatgpt_cases$quality_answer, 2),
  reviewer = c(rep("R1", 150), rep("R2", 150)),
  diagnostic_accuracy = rep(ifelse(answer_correct, "True Positive", "False Negative"), 2),
  stringsAsFactors = FALSE
)

# ============================================================================
# 4. Save datasets
# ============================================================================

project_root <- here::here("projects", "chatgpt_diagnostic_study")
data_processed <- file.path(project_root, "data", "processed")

if (!dir.exists(data_processed)) {
  dir.create(data_processed, recursive = TRUE)
}

write.csv(chatgpt_cases, file.path(data_processed, "chatgpt_cases_cleaned.csv"), row.names = FALSE)
write.csv(diagnostic_accuracy_data, file.path(data_processed, "diagnostic_accuracy_600.csv"), row.names = FALSE)
write.csv(all_reviews, file.path(data_processed, "all_reviews.csv"), row.names = FALSE)

# ============================================================================
# 5. Verify
# ============================================================================

cat("\n=== Synthetic Data Generated ===\n\n")

cat("Cases dataset:\n")
cat("  Total cases:", nrow(chatgpt_cases), "(expected: 150)\n")
cat("  Correct:", sum(chatgpt_cases$answer_correct_bool), "(expected: 74)\n")
cat("  Accuracy:", round(mean(chatgpt_cases$answer_correct_bool) * 100, 1), "% (expected: 49.3%)\n\n")

cat("Cognitive Load:\n")
print(table(chatgpt_cases$cognitive_load))
cat("  Expected: Low=77, Moderate=61, High=11-12\n\n")

cat("Quality:\n")
print(table(chatgpt_cases$quality_answer))
cat("  Expected: Complete Relevant=78, Incomplete Relevant=64, Incomplete Irrelevant=8\n\n")

cat("Diagnostic Accuracy (600 responses):\n")
print(table(diagnostic_accuracy_data$diagnostic_result))
cat("  Expected: TP=73, FP=77, TN=373, FN=77\n\n")

cat("Files saved to:\n")
cat("  ", file.path(data_processed, "chatgpt_cases_cleaned.csv"), "\n")
cat("  ", file.path(data_processed, "diagnostic_accuracy_600.csv"), "\n")
cat("  ", file.path(data_processed, "all_reviews.csv"), "\n")
