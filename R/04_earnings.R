# Optional: connect the paper's three earnings dates to fitted returns.
# Run after 02_models.R. This table does not change the regression sample.
library(readxl)

earnings <- read_excel("data/raw/ern.xlsx")
earnings$Date <- as.Date(earnings$`Ann Date`, format = "%m/%d/%Y")
event_dates <- as.Date(c("2025-04-17", "2025-07-29", "2026-01-27"))
earnings <- earnings[!is.na(earnings$Date) & earnings$Date %in% event_dates,
                     c("Date", "Per", "Reported", "Comp", "Estimate", "%Surp")]
names(earnings) <- c("Date", "Period", "Reported_EPS", "Comparable_EPS",
                    "Estimate_EPS", "Bloomberg_Surprise")
stopifnot(nrow(earnings) == 3, !anyDuplicated(earnings$Date))

event_returns <- data[c("Date", "UNH_Return", "UNH_Excess_Return")]
event_returns$Fitted <- fitted(FF5)
event_returns$Residual <- resid(FF5)
event_returns$Absolute_Residual_Rank <- rank(-abs(resid(FF5)), ties.method = "min")
event_table <- merge(earnings, event_returns, by = "Date", sort = TRUE)
stopifnot(nrow(event_table) == 3)
print(event_table)
write.csv(event_table, "output/earnings_event_check.csv", row.names = FALSE)

# Bloomberg has separate Reported and Comp EPS columns. Its %Surp field
# should not be relabeled as (Reported - Estimate) / Estimate.
