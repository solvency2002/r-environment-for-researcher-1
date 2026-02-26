# ===========================================================================
# 06_figures_tables.R — Generate Figures
# ===========================================================================
# SAP: Section 9.4, Section 10.1–10.3
# Gate: G3-1 ~ G3-5
# Skill: output-and-naming-standards (PNG 300dpi + PDF, ggsave x2)
# ===========================================================================

cat(">>> Generating Figures\n\n")

# --- Theme ---
theme_study <- theme_minimal(base_size = 14) +
    theme(
        plot.title = element_text(face = "bold", size = 16),
        plot.subtitle = element_text(color = "grey40"),
        axis.title = element_text(face = "bold"),
        legend.position = "bottom"
    )

# ===========================================================================
# @plan_id G3-1
# Figure 1: Case Accuracy (Correct vs Incorrect)
# ===========================================================================

fig1_data <- df_cases |>
    count(answer_correct_bool) |>
    mutate(
        label = ifelse(answer_correct_bool, "Correct", "Incorrect"),
        pct = round(n / sum(n) * 100, 1)
    )

p1 <- ggplot(fig1_data, aes(x = label, y = n, fill = label)) +
    geom_col(width = 0.6) +
    geom_text(aes(label = paste0(n, " (", pct, "%)")), vjust = -0.5, size = 5) +
    scale_fill_manual(values = c("Correct" = "#2E86AB", "Incorrect" = "#E8505B")) +
    labs(
        title = "Figure 1: ChatGPT Case Accuracy",
        subtitle = "N = 150 cases",
        x = NULL, y = "Number of Cases"
    ) +
    ylim(0, max(fig1_data$n) * 1.15) +
    theme_study +
    theme(legend.position = "none")

ggsave(file.path(fig_dir, "fig1_case_accuracy.png"), p1,
    width = 8, height = 6, dpi = 300
)
ggsave(file.path(fig_dir, "fig1_case_accuracy.pdf"), p1,
    width = 8, height = 6
)
cat("  Figure 1 saved\n")

# ===========================================================================
# @plan_id G3-2
# Figure 2: Confusion Matrix Heatmap
# ===========================================================================

confusion_data <- df_diag |>
    count(diagnostic_result) |>
    mutate(
        true_class = case_when(
            diagnostic_result %in% c("True Positive", "False Negative") ~ "Positive",
            TRUE ~ "Negative"
        ),
        pred_class = case_when(
            diagnostic_result %in% c("True Positive", "False Positive") ~ "Positive",
            TRUE ~ "Negative"
        )
    )

# Ensure all combinations
cm <- expand.grid(
    true_class = c("Positive", "Negative"),
    pred_class = c("Positive", "Negative"),
    stringsAsFactors = FALSE
) |>
    left_join(confusion_data |> select(true_class, pred_class, n),
        by = c("true_class", "pred_class")
    ) |>
    mutate(n = replace_na(n, 0))

p2 <- ggplot(cm, aes(x = pred_class, y = true_class, fill = n)) +
    geom_tile(color = "white", linewidth = 2) +
    geom_text(aes(label = n), size = 10, fontface = "bold", color = "white") +
    scale_fill_gradient(low = "#5B8FB9", high = "#1A3C5A") +
    labs(
        title = "Figure 2: Confusion Matrix",
        subtitle = "600 responses (150 cases x 4 options)",
        x = "Predicted Class", y = "True Class"
    ) +
    theme_study +
    theme(
        legend.position = "none",
        panel.grid = element_blank()
    )

ggsave(file.path(fig_dir, "fig2_confusion_matrix.png"), p2,
    width = 7, height = 6, dpi = 300
)
ggsave(file.path(fig_dir, "fig2_confusion_matrix.pdf"), p2,
    width = 7, height = 6
)
cat("  Figure 2 saved\n")

# ===========================================================================
# @plan_id G3-3
# Figure 3: ROC Curve
# ===========================================================================

if (pROC_available) {
    # roc_obj was created in 04_diagnostic_accuracy.R
    roc_plot_data <- tibble(
        specificity = roc_obj$specificities,
        sensitivity = roc_obj$sensitivities
    )

    p3 <- ggplot(roc_plot_data, aes(x = 1 - specificity, y = sensitivity)) +
        geom_line(color = "#2E86AB", linewidth = 1.5) +
        geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
        geom_point(color = "#E8505B", size = 4) +
        annotate("text",
            x = 0.6, y = 0.3,
            label = paste0("AUC = ", round(as.numeric(pROC::auc(roc_obj)), 2)),
            size = 6, fontface = "bold", color = "#1A3C5A"
        ) +
        labs(
            title = "Figure 3: ROC Curve",
            subtitle = "ChatGPT diagnostic performance",
            x = "1 - Specificity (False Positive Rate)",
            y = "Sensitivity (True Positive Rate)"
        ) +
        coord_equal() +
        theme_study

    ggsave(file.path(fig_dir, "fig3_roc_curve.png"), p3,
        width = 7, height = 7, dpi = 300
    )
    ggsave(file.path(fig_dir, "fig3_roc_curve.pdf"), p3,
        width = 7, height = 7
    )
    cat("  Figure 3 saved\n")
} else {
    cat("  Figure 3 skipped (pROC not available)\n")
}

# ===========================================================================
# @plan_id G3-4
# Figure 4: Cognitive Load Distribution
# ===========================================================================

cog_plot_data <- df_cases |>
    count(cognitive_load_std) |>
    mutate(pct = round(n / sum(n) * 100, 1))

p4 <- ggplot(cog_plot_data, aes(
    x = cognitive_load_std, y = n,
    fill = cognitive_load_std
)) +
    geom_col(width = 0.6) +
    geom_text(aes(label = paste0(n, " (", pct, "%)")), vjust = -0.5, size = 5) +
    scale_fill_manual(values = c(
        "Low" = "#48BF84", "Moderate" = "#F5A623",
        "High" = "#E8505B"
    )) +
    labs(
        title = "Figure 4: Cognitive Load Distribution",
        subtitle = "N = 150 cases",
        x = "Cognitive Load Level", y = "Number of Cases"
    ) +
    ylim(0, max(cog_plot_data$n) * 1.15) +
    theme_study +
    theme(legend.position = "none")

ggsave(file.path(fig_dir, "fig4_cognitive_load.png"), p4,
    width = 8, height = 6, dpi = 300
)
ggsave(file.path(fig_dir, "fig4_cognitive_load.pdf"), p4,
    width = 8, height = 6
)
cat("  Figure 4 saved\n")

# ===========================================================================
# @plan_id G3-5
# Figure 5: Quality of Medical Information
# ===========================================================================

qual_plot_data <- df_cases |>
    count(quality_answer_std) |>
    mutate(pct = round(n / sum(n) * 100, 1))

p5 <- ggplot(qual_plot_data, aes(
    x = quality_answer_std, y = n,
    fill = quality_answer_std
)) +
    geom_col(width = 0.6) +
    geom_text(aes(label = paste0(n, " (", pct, "%)")), vjust = -0.5, size = 5) +
    scale_fill_manual(values = c(
        "Complete Relevant" = "#2E86AB",
        "Incomplete Relevant" = "#F5A623",
        "Incomplete Irrelevant" = "#E8505B"
    )) +
    labs(
        title = "Figure 5: Quality of Medical Information",
        subtitle = "N = 150 cases",
        x = "Quality Category", y = "Number of Cases"
    ) +
    ylim(0, max(qual_plot_data$n) * 1.15) +
    theme_study +
    theme(
        legend.position = "none",
        axis.text.x = element_text(size = 11)
    )

ggsave(file.path(fig_dir, "fig5_quality.png"), p5,
    width = 9, height = 6, dpi = 300
)
ggsave(file.path(fig_dir, "fig5_quality.pdf"), p5,
    width = 9, height = 6
)
cat("  Figure 5 saved\n")

cat("\n>>> 06_figures_tables.R completed\n")
