library(tidyverse)
library(ggplot2)

# Data for Tokai Junior High School (東海中学)
tokai_data <- tibble(
    year = 2016:2026,
    "日能研" = c(130, 125, 123, 127, 143, 116, 143, 132, 150, 134, 164),
    "名進研" = c(140, 135, 127, 103, 104, 116, 121, 104, 124, 132, 116),
    "浜学園" = c(60, 62, 65, 67, 64, 69, 74, 81, 88, 85, 92),
    "馬淵教室" = c(0, 0, 0, 5, 20, 26, 47, 63, 51, 60, 60)
) %>%
    pivot_longer(cols = -year, names_to = "jukun", values_to = "count") %>%
    mutate(school = "東海中学")

# Data for Taki Junior High School (滝中学)
taki_data <- tibble(
    year = 2016:2026,
    "日能研" = c(180, 185, 177, 230, 240, 220, 234, 235, 251, 231, 280),
    "名進研" = c(250, 245, 237, 200, 190, 187, 146, 174, 170, 194, 168),
    "浜学園" = c(95, 100, 105, 110, 115, 86, 101, 101, 117, 120, 87),
    "馬淵教室" = c(0, 0, 0, 0, 10, 20, 51, 66, 67, 81, 80)
) %>%
    pivot_longer(cols = -year, names_to = "jukun", values_to = "count") %>%
    mutate(school = "滝中学")

# Combine data
combined_data <- bind_rows(tokai_data, taki_data)

# Create the plot
p <- ggplot(combined_data, aes(x = year, y = count, color = jukun, group = jukun)) +
    geom_line(size = 1.2) +
    geom_point(size = 3) +
    facet_wrap(~school, scales = "free_y", ncol = 1) +
    theme_minimal(base_family = "sans") +
    labs(
        title = "塾別合格実績の推移 (2016-2026)",
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

# Save the plot
ggsave("success_trends.png", plot = p, width = 10, height = 8, dpi = 300)
print("Graph saved as success_trends.png")
