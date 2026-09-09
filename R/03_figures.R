# 11. Base R graphs
# The paper's existing images are in figures/. These are new run outputs.
dir.create("output/figures", showWarnings = FALSE)

png("output/figures/Figure_1_UNH_Daily_Closing_Price.png",
    width = 2400, height = 1500, res = 300, bg = "white")
par(mar = c(5, 5, 4, 2), family = "serif")
plot(data$Date, data$PX_LAST, type = "l", col = "black", lwd = 1.2,
     main = "UNH Daily Closing Price", xlab = "Date",
     ylab = "UNH Closing Price (USD)", cex.main = 1.1)
dev.off()

png("output/figures/Figure_2_UNH_Daily_Stock_Returns.png",
    width = 2400, height = 1500, res = 300, bg = "white")
par(mar = c(5, 5, 4, 2), family = "serif")
plot(data$Date, data$UNH_Return, type = "l", col = "black", lwd = 0.8,
     main = "UNH Daily Stock Returns", xlab = "Date",
     ylab = "Daily Return (%)", cex.main = 1.1)
abline(h = 0, col = "red", lty = 2)
dev.off()

png("output/figures/Figure_3_Actual_vs_Fitted_UNH_Excess_Returns.png",
    width = 2400, height = 1500, res = 300, bg = "white")
par(mar = c(5, 5, 4, 2), family = "serif")
plot(data$Date, data$UNH_Excess_Return, type = "l", col = "black", lwd = 0.8,
     main = "Actual versus Fitted UNH Excess Returns", xlab = "Date",
     ylab = "Excess Return (%)", cex.main = 1.1,
     ylim = range(c(data$UNH_Excess_Return, fitted(FF5))))
lines(data$Date, fitted(FF5), col = "red", lty = 2, lwd = 1.2)
abline(h = 0, col = "gray50", lty = 3)
legend("topright", legend = c("Actual", "Fitted"), col = c("black", "red"),
       lty = c(1, 2), lwd = c(0.8, 1.2), bty = "n", cex = 0.9)
dev.off()

png("output/figures/Figure_4_FF5_Residuals_vs_Fitted.png",
    width = 2400, height = 1500, res = 300, bg = "white")
par(mar = c(5, 5, 4, 2), family = "serif")
plot(fitted(FF5), resid(FF5), pch = 20, col = "black",
     main = "FF5 Residuals versus Fitted Values",
     xlab = "Fitted Values", ylab = "Residuals", cex.main = 1.1)
abline(h = 0, col = "red", lty = 2)
dev.off()

png("output/figures/Figure_5_QQ_Plot_FF5_Residuals.png",
    width = 2400, height = 1500, res = 300, bg = "white")
par(mar = c(5, 5, 4, 2), family = "serif")
qqnorm(resid(FF5), main = "Q-Q Plot of FF5 Residuals", pch = 20,
       col = "black", cex.main = 1.1)
qqline(resid(FF5), col = "red", lwd = 2)
dev.off()
