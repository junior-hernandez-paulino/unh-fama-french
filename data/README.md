# Data used in the paper

The baseline combines Bloomberg daily UNH prices with Kenneth French daily five factors and RF. The price export's requested range is April 30, 2021 through May 14, 2026. The factor vintage is March 2026, as stated inside the attached ZIP. The overlapping return sample is May 3, 2021 through March 31, 2026, with 1,234 rows.

| Variable | Meaning | Unit |
| --- | --- | --- |
| `Date` | Trading date | Date |
| `PX_LAST` | Bloomberg closing-price field | USD |
| `UNH_Return` | 100 times the simple change in consecutive closing prices | Percent per trading day |
| `Mkt_RF` | Market excess return | Percent per trading day |
| `SMB` | Small Minus Big | Percent per trading day |
| `HML` | High Minus Low | Percent per trading day |
| `RMW` | Robust Minus Weak | Percent per trading day |
| `CMA` | Conservative Minus Aggressive | Percent per trading day |
| `RF` | Risk-free return supplied in the French file | Percent per trading day |
| `UNH_Excess_Return` | `UNH_Return - RF` | Percent per trading day |

The script sorts prices before constructing lagged returns. It removes only the initial undefined return, merges on shared dates, and retains every valid merged observation. It rejects missing values and duplicate dates instead of silently dropping them during estimation. Weekends and holidays are not filled in.

`data/source_manifest.csv` records file sizes, MD5, and SHA-256 for the original inputs. The MD5 check in R is a reproducibility check, not a security mechanism. The attached ZIP's factor records were also checked against the original normalized `FF5_factors_daily.csv`.

Raw data and the original merged CSV remain in ignored local folders. A public clone therefore is not self-contained: reproducing the numerical results requires the same original inputs. The reference statistics and numerical checks remain available without redistributing the row-level data.

The baseline follows the paper's `PX_LAST` price-change formula. The export does not establish a separate dividend-reinvestment calculation. Dividend screens and balance-sheet data are company context; they are not columns in the regression.
