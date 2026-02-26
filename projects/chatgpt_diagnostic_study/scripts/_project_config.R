# ===========================================================================
# _project_config.R — Path definitions only (no side effects)
# ===========================================================================
# This file defines project paths. It must NOT load packages or cause
# any side effects. Source this file at the top of every analysis script.
# Skill: code-review-companion, output-and-naming-standards
# ===========================================================================

project_root <- here::here("projects", "chatgpt_diagnostic_study")
data_dir <- file.path(project_root, "data", "processed")
output_dir <- file.path(project_root, "output")
fig_dir <- file.path(output_dir, "figures")
tbl_dir <- file.path(output_dir, "tables")
verify_dir <- file.path(output_dir, "verification")
scripts_dir <- file.path(project_root, "scripts")
