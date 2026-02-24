# Hypertension Simulation and Logistic Regression Analysis
# Author: Antigravity
# Date: 2026-02-24

set.seed(20260224)

# 1. Data Simulation
N <- 100
age <- rnorm(N, mean = 55, sd = 10)
bmi <- rnorm(N, mean = 24, sd = 4)
smoking <- rbinom(N, 1, 0.3) # 30% are smokers

# Define logistic probability
# Logit(p) = intercept + b1*age + b2*bmi + b3*smoking
# We want some association:
# Age and BMI should increase risk.
intercept <- -8
b_age <- 0.08
b_bmi <- 0.15
b_smoking <- 0.5

logit_p <- intercept + b_age * age + b_bmi * bmi + b_smoking * smoking
p <- 1 / (1 + exp(-logit_p))
hypertension <- rbinom(N, 1, p)

df <- data.frame(
    id = 1:N,
    age = round(age, 1),
    bmi = round(bmi, 1),
    smoking = factor(smoking, levels = c(0, 1), labels = c("No", "Yes")),
    hypertension = factor(hypertension, levels = c(0, 1), labels = c("No", "Yes"))
)

# 2. Save Data
if (!dir.exists("data")) dir.create("data")
write.csv(df, "data/hypertension_sim.csv", row.names = FALSE)

# 3. Descriptive Statistics
summary_stats <- list(
    total_hypertension = table(df$hypertension),
    mean_age_by_ht = tapply(df$age, df$hypertension, mean),
    mean_bmi_by_ht = tapply(df$bmi, df$hypertension, mean),
    smoking_by_ht = table(df$smoking, df$hypertension)
)

print("--- Descriptive Statistics ---")
print(summary_stats)

# 4. Logistic Regression
model <- glm(hypertension ~ age + bmi + smoking, data = df, family = binomial)
summary_model <- summary(model)

# Extract OR and 95% CI
or_table <- exp(cbind(OR = coef(model), confint(model)))
p_values <- summary_model$coefficients[, 4]
results <- cbind(or_table, p_value = p_values)

print("--- Logistic Regression Results ---")
print(results)

# 5. Output for report
results_file <- "data/analysis_results.rds"
saveRDS(list(summary = summary_stats, model_results = results), results_file)
