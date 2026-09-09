# 6. Estimate the three models
library(lmtest)
library(sandwich)
library(car)
library(nortest)
library(stargazer)

CAPM <- lm(UNH_Excess_Return ~ Mkt_RF, data = data, na.action = na.fail)
FF3 <- lm(UNH_Excess_Return ~ Mkt_RF + SMB + HML,
          data = data, na.action = na.fail)
FF5 <- lm(UNH_Excess_Return ~ Mkt_RF + SMB + HML + RMW + CMA,
          data = data, na.action = na.fail)

print(summary(CAPM))
print(summary(FF3))
print(summary(FF5))

stargazer(CAPM, FF3, FF5, type = "text",
          title = "UNH Fama-French Regression Results",
          column.labels = c("CAPM", "FF3", "FF5"),
          out = "output/regression_table.txt")

# 7. Test whether the additional factors matter together
joint_nonmarket <- linearHypothesis(FF5, c("SMB = 0", "HML = 0", "RMW = 0", "CMA = 0"))
joint_rmw_cma <- linearHypothesis(FF5, c("RMW = 0", "CMA = 0"))
model_comparison <- anova(CAPM, FF3, FF5)
print(joint_nonmarket)
print(joint_rmw_cma)
print(model_comparison)

# 8. Residual diagnostics
vif_ff5 <- vif(FF5)
bp_test <- bptest(FF5)

uhat <- resid(FF5)
uhat2 <- uhat^2
yhat <- fitted(FF5)
yhat2 <- yhat^2

# This is the fitted-value version of the White test used in the paper.
white_aux <- lm(uhat2 ~ yhat + yhat2)
White_LM <- nrow(data) * summary(white_aux)$r.squared
White_pvalue <- pchisq(White_LM, df = 2, lower.tail = FALSE)

dw_test <- dwtest(FF5, alternative = "greater")
ad_test <- ad.test(uhat)

print(vif_ff5)
print(bp_test)
print(White_LM)
print(White_pvalue)
print(dw_test)
print(ad_test)

# 9. Compare usual standard errors with HC1 standard errors
robust_ff5 <- coeftest(FF5, vcov. = vcovHC(FF5, type = "HC1"))
print(robust_ff5)

ols <- coef(summary(FF5))
robust_comparison <- data.frame(
  Variable = rownames(ols), Estimate = ols[, 1],
  OLS_SE = ols[, 2], OLS_p = ols[, 4],
  HC1_SE = robust_ff5[, 2], HC1_p = robust_ff5[, 4], row.names = NULL)
write.csv(robust_comparison, "output/robust_comparison.csv", row.names = FALSE)

# 10. Save the output without changing the paper's saved results
capture.output({
  cat("UNH daily excess returns: 2021-05-03 to 2026-03-31; N = 1234\n\n")
  cat("CAPM\n"); print(summary(CAPM))
  cat("\nFF3\n"); print(summary(FF3))
  cat("\nFF5\n"); print(summary(FF5))
  cat("\nNon-market factors jointly zero\n"); print(joint_nonmarket)
  cat("\nRMW and CMA jointly zero\n"); print(joint_rmw_cma)
  cat("\nThree-model ANOVA\n"); print(model_comparison)
  cat("\nVIF\n"); print(vif_ff5)
  cat("\nStudentized Breusch-Pagan\n"); print(bp_test)
  cat("\nWhite auxiliary regression\n"); print(summary(white_aux))
  cat("\nWhite LM\n"); print(White_LM)
  cat("\nWhite p-value\n"); print(White_pvalue)
  cat("\nHC1 standard errors\n"); print(robust_ff5)
  cat("\nDurbin-Watson (positive autocorrelation alternative)\n"); print(dw_test)
  cat("\nAnderson-Darling\n"); print(ad_test)
}, file = "output/full_output.txt")

diagnostics <- data.frame(
  Test = c("Studentized Breusch-Pagan", "White (fitted-value auxiliary)",
           "Durbin-Watson (greater)", "Anderson-Darling",
           "Non-market factors jointly zero", "RMW and CMA jointly zero",
           "CAPM to FF3 (three-model ANOVA)", "FF3 to FF5 (three-model ANOVA)"),
  Statistic = c(unname(bp_test$statistic), White_LM, unname(dw_test$statistic),
                unname(ad_test$statistic), joint_nonmarket$F[2], joint_rmw_cma$F[2],
                model_comparison$F[2:3]),
  p_value = c(bp_test$p.value, White_pvalue, dw_test$p.value, ad_test$p.value,
              joint_nonmarket$`Pr(>F)`[2], joint_rmw_cma$`Pr(>F)`[2],
              model_comparison$`Pr(>F)`[2:3]))
write.csv(diagnostics, "output/diagnostics.csv", row.names = FALSE)
write.csv(data.frame(Variable = names(vif_ff5), VIF = unname(vif_ff5)),
          "output/vif.csv", row.names = FALSE)

models <- list(CAPM = CAPM, FF3 = FF3, FF5 = FF5)
coefficient_table <- do.call(rbind, lapply(names(models), function(name) {
  tab <- coef(summary(models[[name]]))
  data.frame(Model = name, Variable = rownames(tab), Estimate = tab[, 1],
             SE = tab[, 2], t = tab[, 3], p_value = tab[, 4], row.names = NULL)
}))
write.csv(coefficient_table, "output/coefficients.csv", row.names = FALSE)
saveRDS(models, "output/models.rds")
