# From closing prices to a regression

The scripts follow the same sequence as the paper: prepare the data, estimate the models, check the residuals, and explain what the results mean. Run them in the RStudio project so paths such as `data/raw/` work on another computer.

## 1. Read and inspect the prices

```r
library(readxl)
UNH <- read_excel("data/raw/430odayUNHstock.xlsx", skip = 6)
head(UNH)
```

The workbook starts with six rows of export information. Row 7 contains the column names. Only `Date` and `PX_LAST` enter this analysis; `PX_BID` is not needed. Sorting the dates matters because the export is newest first, while a return needs the preceding trading day's price.

## 2. Calculate a daily return

```r
UNH$Previous_Price <- c(NA, head(UNH$PX_LAST, -1))
UNH$UNH_Return <- ((UNH$PX_LAST / UNH$Previous_Price) - 1) * 100
```

The lagged-price column moves each closing price down one row. Dividing today's price by that price gives the growth factor. Subtracting one gives the rate of change, and multiplying by 100 expresses it in percent.

The first row has no earlier price. It is removed after the return calculation. The April 30, 2021 price remains available for calculating the May 3 return before that initial row is removed. No large return is deleted because of its size.

## 3. Read the factor file

The attached ZIP contains one daily CSV. It has explanatory text above the data and copyright text below it. `01_data.R` reads the ZIP locally and selects records that start with an eight-digit date followed by a comma.

```r
factor_lines <- factor_lines[grepl("^[0-9]{8},", factor_lines)]
factors$Date <- as.Date(factors$Date, format = "%Y%m%d")
```

`20260331` becomes March 31, 2026. The script calls the market column `Mkt_RF` so it can be used directly in an R formula. The other columns keep the familiar factor names. They are already in percent, so they are not divided by 100.

## 4. Match trading dates

```r
data <- merge(UNH, factors, by = "Date", all = FALSE, sort = TRUE)
data$UNH_Excess_Return <- data$UNH_Return - data$RF
```

`all = FALSE` keeps dates found in both sources. Returns must be calculated before this merge: otherwise, dropping a date could make a price change span more than one observed trading interval. The saved sample has 1,234 rows, starts May 3, 2021, and ends March 31, 2026.

The dependent variable is excess return. A daily return and a daily risk-free return can be subtracted because both use the same percent units. `RF` is not an extra sixth regressor; it has already been subtracted.

## 5. Look at the distribution

The descriptive table reports the observation count, mean, median, standard deviation, minimum, and maximum for excess returns and the factors.

UNH's mean daily excess return is -0.024925136%, compared with a standard deviation of 1.980748818%. The minimum is -22.39967%, and the maximum is 11.95834%. The small mean does not imply quiet daily trading; positive and negative movements can offset each other in the average.

![UNH daily returns](../figures/Figure_2_UNH_Daily_Stock_Returns.png)

*The return chart shows individual movements that a mean alone would hide.*

## 6. Estimate CAPM, FF3, and FF5

```r
CAPM <- lm(UNH_Excess_Return ~ Mkt_RF, data = data)
FF3 <- lm(UNH_Excess_Return ~ Mkt_RF + SMB + HML, data = data)
FF5 <- lm(UNH_Excess_Return ~ Mkt_RF + SMB + HML + RMW + CMA, data = data)
summary(FF5)
```

In a formula, the response is on the left of `~` and the regressors are on the right. `lm()` includes an intercept unless told otherwise. CAPM includes market excess return, FF3 adds size and value, and FF5 adds profitability and investment. All three are estimated on the same rows.

Read the FF5 output in this order:

1. `Estimate` gives the coefficient. For `Mkt_RF`, 0.51161 means a one-percentage-point increase in market excess return is associated with a 0.51161-percentage-point increase in UNH excess return, holding the other factors constant.
2. `Std. Error` measures uncertainty in the coefficient estimate. It is not the standard deviation of the stock's returns.
3. `Pr(>|t|)` is the two-sided p-value for a zero coefficient. A small value supports rejecting that null under the test's assumptions.
4. `Multiple R-squared` describes the fraction of in-sample variation explained jointly by the regressors. FF5's 0.0659 is 6.59%, not 65.9%.

The market slope being below one describes sensitivity to market movements. It does not show that UNH's total volatility is below the market's. Alpha is not statistically different from zero; this is not proof that alpha is exactly zero.

Blank cells in the side-by-side table mean a factor is not included in that specification. CAPM has no estimated SMB, HML, RMW, or CMA coefficient. Those cells are not missing observations or estimated zeros. Also read the legend: `summary()` and `stargazer()` use different star cutoffs by default.

## 7. Compare the models

```r
linearHypothesis(FF5, c("SMB = 0", "HML = 0", "RMW = 0", "CMA = 0"))
linearHypothesis(FF5, c("RMW = 0", "CMA = 0"))
anova(CAPM, FF3, FF5)
```

The first joint test asks whether the four non-market coefficients are all zero. Its p-value is 0.001348. The second asks whether the two FF5 additions are jointly zero; its p-value is 0.05831. Those are different questions from testing one coefficient at a time.

The paper's comparison uses the three-model `anova()` call. R uses the largest model's residual variance for this multi-model table. Replacing it with separate two-model calls can slightly change the CAPM-to-FF3 statistic. The reproduction retains the original call and its 0.002287 and 0.058308 p-values.

## 8. Check the residuals

```r
uhat <- resid(FF5)
yhat <- fitted(FF5)
```

A residual is actual excess return minus fitted excess return for the same date. The residual plots help identify shape and extreme observations, while the formal tests ask more specific questions.

| Check | Code | What is being checked |
| --- | --- | --- |
| Multicollinearity | `vif(FF5)` | Linear dependence among regressors |
| Heteroskedasticity | `bptest(FF5)` | Whether the test detects nonconstant conditional variance |
| Positive serial correlation | `dwtest(FF5, alternative = "greater")` | Positive dependence between successive errors |
| Normality | `ad.test(resid(FF5))` | Whether residuals follow a normal distribution |

Breusch-Pagan is the studentized version returned by `lmtest::bptest()` here. Its p-value is 0.7956, so it does not reject homoskedasticity at 5%. Failing to reject is not proof that variance is constant under every alternative.

For the paper's White calculation, squared residuals are regressed on fitted values and their square. The LM statistic is the sample size multiplied by that auxiliary regression's R-squared. The chi-squared reference uses two degrees of freedom. This is the fitted-value version, not the full expansion of every regressor, square, and interaction.

Anderson-Darling rejects normality. The Q-Q plot shows large tail departures. Non-normality and heteroskedasticity are separate issues; one does not establish the other. A large sample does not by itself establish zero conditional mean or eliminate time dependence.

## 9. Compare standard errors

```r
coeftest(FF5, vcov. = vcovHC(FF5, type = "HC1"))
```

The coefficients stay the same. The estimated covariance matrix changes, so standard errors, t statistics, and p-values can change. CMA's p-value moves from 0.0249 under conventional standard errors to 0.05454 under HC1. Market significance and the lack of significant alpha remain.

HC1 is a sensitivity check for heteroskedasticity. It does not repair omitted-variable bias or serial correlation, and it does not reduce extreme observations' influence on the fitted OLS coefficients.

## 10. Read the earnings check

With `ern.xlsx` available, the last script joins April 17, 2025, July 29, 2025, and January 27, 2026 to their returns and FF5 residuals. It reports the rank of each absolute residual within the full sample. This makes the paper's event discussion traceable to actual dates.

The Bloomberg file has separate `Reported`, `Comp`, `Estimate`, and `%Surp` columns. These should not be treated as interchangeable. A return occurring on an earnings date does not establish that the EPS figure alone caused it. January 2026 is particularly useful for this distinction: reported EPS exceeds the listed estimate, yet the stock falls sharply.

## 11. Reproduce the saved results

`checks/check_results.R` compares coefficients, standard errors, p-values, fit measures, diagnostics, and joint tests against the saved output. It allows only the rounding implicit in the printed numbers. It also checks dates, units through the return identity, factor alignment, and descriptive statistics. In the local working copy it compares every merged observation with the original merged CSV.

The checks provide evidence that the code reproduces this paper. They do not establish that all OLS assumptions hold. An event-dummy extension would be a separate specification and should be reported alongside this baseline, with its own results.
