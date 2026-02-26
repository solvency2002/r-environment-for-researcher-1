# ===========================================================================
# 00_setup.R — Environment Setup
# ===========================================================================
# SAP: Section 7 (Statistical principles)
# Gate: G0A-1, G0A-2, G0A-3
# Skill: output-and-naming-standards, analysis-guardrails
# ===========================================================================

# --- Source project paths ---
source(file.path(
    here::here("projects", "chatgpt_diagnostic_study", "scripts"),
    "_project_config.R"
))

# @plan_id G0A-1
# --- Load packages ---
suppressPackageStartupMessages({
    library(tidyverse) # includes ggplot2, dplyr, readr, etc.
    library(here)
})

# Optional packages with graceful fallback
pROC_available <- requireNamespace("pROC", quietly = TRUE)
irr_available <- requireNamespace("irr", quietly = TRUE)

if (pROC_available) library(pROC) else message("pROC not available; AUC/ROC will be skipped")
if (irr_available) library(irr) else message("irr not available; Kappa will be skipped")

# @plan_id G0A-3
# --- Set seed for reproducibility ---
set.seed(42)

# --- Create output directories ---
dirs_needed <- c(output_dir, fig_dir, tbl_dir, verify_dir)
for (d in dirs_needed) {
    if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# @plan_id G0A-2
# --- Record session info ---
sink(file.path(output_dir, "session_info.txt"))
cat("Analysis Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")
cat("R Version:", R.version.string, "\n")
cat("Platform:", R.version$platform, "\n\n")

if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    cat("RStudio Version:", as.character(rstudioapi::versionInfo()$version), "\n\n")
}

cat("Loaded Packages:\n")
pkgs <- sort(loadedNamespaces())
for (pkg in pkgs) {
    cat(sprintf("  %s %s\n", pkg, as.character(packageVersion(pkg))))
}
sink()

cat(">>> 00_setup.R completed\n")
