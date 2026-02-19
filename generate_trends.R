library(tidyverse)
library(ggplot2)

# Load consolidated data
combined_data <- read_csv("data/admission_data.csv", show_col_types = FALSE)

# Calculate success rate per 1000 students
combined_data <- combined_data %>%
    mutate(success_rate = (count / enrollment) * 1000)

# Set Japanese font for PDF (Windows)
# Using 'Yu Gothic' which is standard on Windows.
# If it fails, 'MS Gothic' is an alternative.
japanese_font <- "Yu Gothic"

# 1. Analysis 1: Raw Success Trends
p1 <- ggplot(combined_data, aes(x = year, y = count, color = jukun, group = jukun)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 3) +
    facet_wrap(~school, scales = "free_y", ncol = 1) +
    theme_minimal(base_family = japanese_font) +
    labs(
        title = "塾別合格者数の推移 (2016-2026)",
        subtitle = "東海中学・滝中学",
        x = "年度",
        y = "合格者数",
        color = "塾名"
    ) +
    scale_x_continuous(breaks = 2016:2026) +
    theme(
        legend.position = "bottom",
        text = element_text(size = 12),
        plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)
    )

# Save Raw Plot
# Use device = grDevices::cairo_pdf for proper Japanese rendering in PDFs
ggsave("raw_success_trends.png", plot = p1, width = 10, height = 8, dpi = 300)
ggsave("C:/Users/solve/Downloads/raw_success_trends.pdf", plot = p1, width = 10, height = 8, device = grDevices::cairo_pdf)
print("Graph saved as raw_success_trends.png and C:/Users/solve/Downloads/raw_success_trends.pdf")

# 2. Analysis 2: Adjusted Success Trends (Success Rate per 1000 students)
p2 <- ggplot(combined_data, aes(x = year, y = success_rate, color = jukun, group = jukun)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 3) +
    facet_wrap(~school, scales = "free_y", ncol = 1) +
    theme_minimal(base_family = japanese_font) +
    labs(
        title = "通塾生数を考慮した合格実績の推移 (2016-2026)",
        subtitle = "1000人あたりの合格者数（補正後の傾向）",
        x = "年度",
        y = "補正後合格者数 (per 1000 students)",
        color = "塾名"
    ) +
    scale_x_continuous(breaks = 2016:2026) +
    theme(
        legend.position = "bottom",
        text = element_text(size = 12),
        plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)
    )

# Save Adjusted Plot
ggsave("adjusted_success_trends.png", plot = p2, width = 10, height = 8, dpi = 300)
ggsave("C:/Users/solve/Downloads/adjusted_success_trends.pdf", plot = p2, width = 10, height = 8, device = grDevices::cairo_pdf)
print("Graph saved as adjusted_success_trends.png and C:/Users/solve/Downloads/adjusted_success_trends.pdf")
