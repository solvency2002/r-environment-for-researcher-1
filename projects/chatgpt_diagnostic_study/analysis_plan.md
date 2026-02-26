# Analysis Plan — ChatGPT Diagnostic Accuracy Study

Gate-based analysis plan following `analysis-hitl-plan` skill.
All items have `G<gate>-<seq>` IDs for traceability via `@plan_id` tags.

---

## Phase 0: Data Preparation

### Gate 0A: Environment Setup ✅

- **G0A-1**: R version ≥ 4.1, packages: `tidyverse`, `pROC`, `irr`, `here`
- **G0A-2**: Session info saved to `output/session_info.txt`
- **G0A-3**: `set.seed(42)` for reproducibility

### Gate 0B: Data Cleaning Plan ✅

- **G0B-1**: Read 3 CSVs from `data/processed/` via `readr::read_csv()`
  - `chatgpt_cases_cleaned.csv` (N=150)
  - `diagnostic_accuracy_600.csv` (N=600)
  - `all_reviews.csv` (N=300)
- **G0B-2**: Type conversions
  - `cognitive_load_std` → ordered factor (Low < Moderate < High)
  - `quality_answer_std` → factor
  - `diagnostic_result` → factor
- **G0B-3**: Missing data check (`is.na()` → expect 0 missing)
- **G0B-4**: Row count / variable type validation (guardrails)

---

## Phase 1: Data Exploration

### Gate 1: Exploration (承認不要)

- **G1-1**: Frequency tables for `answer_correct`, `cognitive_load`, `quality_answer`
- **G1-2**: Distribution barplots for key variables (visual check)

---

## Phase 2: Data Analyses

### Gate 2A: Descriptive Statistics Plan ✅

- **G2A-1**: Primary outcome — Case Accuracy
  - `sum(answer_correct_bool) / 150 * 100`
  - Target: 49.3% (74/150)
  - Output: comparison table (computed vs paper)

### Gate 2B: Main Analysis Plan ✅

- **G2B-1**: Diagnostic accuracy counts from 600-response data
  - TP=73, FP=77, TN=373, FN=77
- **G2B-2**: Diagnostic accuracy metrics
  - Overall Accuracy = (TP+TN)/600 → 74%
  - Precision = TP/(TP+FP) → 48.67%
  - Sensitivity = TP/(TP+FN) → 48.67%
  - Specificity = TN/(TN+FP) → 82.89%
  - AUC via `pROC::roc()` → 0.66
- **G2B-3**: Cognitive load distribution
  - Low=77 (51%), Moderate=61 (41%), High=12 (8%)
- **G2B-4**: Quality of medical information distribution
  - Complete Relevant=78 (52%), Incomplete Relevant=64 (43%), Incomplete Irrelevant=8 (5%)
- **G2B-5**: Inter-rater reliability (Cohen's Kappa)
  - `irr::kappa2()` on `all_reviews.csv`
  - Variables: `diagnostic_accuracy`, `cognitive_load`, `quality_answer`
  - Note: Synthetic data has R1≡R2; expect κ≈1.0

> [!NOTE]
> No model-specific assumption checks required (no regression models used).

### Gate 2C: Sensitivity Analysis Plan ✅

- **G2C-1**: Cognitive load High count sensitivity (High=11 vs High=12)
- **G2C-2**: AUC calculation method comparison (`pROC::roc()` vs manual)

### Gate 2D: Exploratory Analysis Plan ✅

- Not applicable (no subgroup/interaction analyses per paper).

---

## Phase 3: Outputs

### Gate 3: Figures and Tables

- **G3-1**: Figure 1 — Correct/Incorrect barplot (SAP §9.4)
- **G3-2**: Figure 2 — Confusion matrix heatmap (SAP §10.1)
- **G3-3**: Figure 3 — ROC curve (SAP §10.1)
- **G3-4**: Figure 4 — Cognitive load barplot (SAP §10.2)
- **G3-5**: Figure 5 — Quality barplot (SAP §10.3)
- **G3-6**: Table — Primary outcome comparison
- **G3-7**: Table — Diagnostic accuracy metrics comparison

All figures: PNG (300 dpi) + PDF, saved to `output/figures/`.
All tables: CSV, saved to `output/tables/`.
