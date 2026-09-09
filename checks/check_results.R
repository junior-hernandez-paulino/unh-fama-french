# Compare a fresh run with the paper's saved output, at its printed precision.
# Run after 01_data.R and 02_models.R, or use source("run.R").

expected <- read.csv("checks/expected_coefficients.csv", colClasses = "character")
checks <- character()

# A printed p-value such as 0.3825 is rounded, not an exact machine value.
check_printed <- function(actual, printed, label) {
  if (startsWith(printed, "<")) {
    ok <- is.finite(actual) && actual < as.numeric(substring(printed, 2))
  } else {
    parts <- strsplit(tolower(printed), "e", fixed = TRUE)[[1]]
    exponent <- if (length(parts) == 2) as.numeric(parts[2]) else 0
    decimals <- if (grepl(".", parts[1], fixed = TRUE)) {
      nchar(sub(".*\\.", "", parts[1]))
    } else 0
    tolerance <- 0.50001 * 10^(exponent - decimals)
    ok <- is.finite(actual) && abs(actual - as.numeric(printed)) <= tolerance
  }
  if (!ok) stop(paste("Result differs from saved output:", label, "expected", printed))
}

for (i in seq_len(nrow(expected))) {
  model_name <- expected$Model[i]
  tab <- if (model_name == "HC1") robust_ff5 else coef(summary(models[[model_name]]))
  row <- expected$Variable[i]
  check_printed(tab[row, 1], expected$Estimate[i], paste(model_name, row, "estimate"))
  check_printed(tab[row, 2], expected$SE[i], paste(model_name, row, "SE"))
  check_printed(tab[row, 4], expected$p_value[i], paste(model_name, row, "p-value"))
}
checks <- c(checks, "PASS: all conventional and HC1 coefficients, SEs, and p-values match printed output.")

fit_expected <- data.frame(
  Model = c("CAPM", "FF3", "FF5"),
  R2 = c("0.05227", "0.06157", "0.0659"),
  Adjusted_R2 = c("0.0515", "0.05928", "0.0621"),
  RSE = c("1.929", "1.921", "1.918"),
  F = c("67.95", "26.9", "17.33"),
  Residual_df = c(1232, 1230, 1228))
for (i in 1:3) {
  m <- models[[fit_expected$Model[i]]]
  s <- summary(m)
  stopifnot(nobs(m) == 1234, df.residual(m) == fit_expected$Residual_df[i])
  check_printed(s$r.squared, fit_expected$R2[i], "R-squared")
  check_printed(s$adj.r.squared, fit_expected$Adjusted_R2[i], "adjusted R-squared")
  check_printed(s$sigma, fit_expected$RSE[i], "residual standard error")
  check_printed(s$fstatistic[1], fit_expected$F[i], "model F statistic")
}
checks <- c(checks, "PASS: model fit, observation counts, and residual degrees of freedom match.")

check_printed(bp_test$statistic, "2.3722", "BP statistic")
check_printed(bp_test$p.value, "0.7956", "BP p-value")
check_printed(White_LM, "0.03363219", "White LM")
check_printed(White_pvalue, "0.9833245", "White p-value")
check_printed(dw_test$statistic, "1.915", "DW statistic")
check_printed(dw_test$p.value, "0.06759", "DW p-value")
check_printed(ad_test$statistic, "38.353", "AD statistic")
check_printed(ad_test$p.value, "<2.2e-16", "AD p-value")
check_printed(joint_nonmarket$F[2], "4.4797", "non-market joint F")
check_printed(joint_nonmarket$`Pr(>F)`[2], "0.001348", "non-market joint p")
check_printed(joint_rmw_cma$F[2], "2.8486", "RMW/CMA joint F")
check_printed(joint_rmw_cma$`Pr(>F)`[2], "0.05831", "RMW/CMA joint p")
check_printed(model_comparison$F[2], "6.1108", "CAPM to FF3 F")
check_printed(model_comparison$`Pr(>F)`[2], "0.002287", "CAPM to FF3 p")
check_printed(model_comparison$F[3], "2.8486", "FF3 to FF5 F")
check_printed(model_comparison$`Pr(>F)`[3], "0.058308", "FF3 to FF5 p")
vif_expected <- c("1.302836", "1.439641", "2.018858", "1.579036", "1.670055")
for (i in 1:5) check_printed(vif_ff5[i], vif_expected[i], names(vif_ff5)[i])
checks <- c(checks, "PASS: VIF, BP, White, DW, AD, joint tests, and three-model ANOVA match.")

stopifnot(!anyDuplicated(data$Date), all(diff(data$Date) > 0),
          all(abs(data$UNH_Excess_Return - (data$UNH_Return - data$RF)) < 1e-12),
          all(abs(fitted(FF5) + resid(FF5) - data$UNH_Excess_Return) < 1e-12))
factor_rows <- match(data$Date, factors$Date)
stopifnot(!anyNA(factor_rows),
          isTRUE(all.equal(as.matrix(data[names(factors)[-1]]),
                           as.matrix(factors[factor_rows, -1]), check.attributes = FALSE)))
checks <- c(checks, "PASS: dates are unique and ordered; RF subtraction and fitted/residual alignment hold.")

reference_stats <- read.csv("results/reference/UNH_descriptive_statistics.csv", check.names = FALSE)
stopifnot(identical(descriptive_statistics$Variable, reference_stats$Variable),
          isTRUE(all.equal(as.matrix(descriptive_statistics[-1]),
                           as.matrix(reference_stats[-1]),
                           tolerance = 1e-10, check.attributes = FALSE)))
checks <- c(checks, "PASS: all descriptive statistics match the original CSV.")

# The local source-data comparison is optional for readers with only raw files.
reference_path <- "data/reference/UNH_FF5_merged_data.csv"
if (file.exists(reference_path)) {
  reference_data <- read.csv(reference_path)
  reference_data$Date <- as.Date(reference_data$Date)
  stopifnot(identical(data$Date, reference_data$Date),
            identical(names(data), names(reference_data)),
            max(abs(as.matrix(data[-1]) - as.matrix(reference_data[-1]))) < 1e-10)
  checks <- c(checks, "PASS: every merged observation matches the local original CSV within 1e-10.")
} else {
  checks <- c(checks, "NOT RUN: optional local original merged CSV is not included in the public repository.")
}

writeLines(checks, "output/verification.txt")
cat(paste(checks, collapse = "\n"), "\n")
