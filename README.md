# UNH Stock Returns and the Fama-French Model

Undergraduate research by **Junior Hernandez Paulino** for ECO 402 Econometrics at Lehman College, Spring 2026. Publication edition: September 2026.

**Question:** How much of UnitedHealth Group's daily excess stock return can the Fama-French factors explain?

The analysis starts with Bloomberg closing prices, calculates daily returns, and joins them to Kenneth French's daily factors. It compares CAPM, FF3, and FF5 using ordinary least squares in R. The sample is **May 3, 2021 to March 31, 2026**, with **1,234 observations**.

The market factor is positive and significant in every model. FF5 explains about **6.6%** of daily excess-return variation. The stock has below-one estimated market sensitivity, but it still has large daily movements that the factors do not explain.

![Actual and fitted UNH excess returns](figures/Figure_3_Actual_vs_Fitted_UNH_Excess_Returns.png)

*Actual excess returns and fitted FF5 values over the same 1,234 trading days. The fitted line is red and dashed.*

## Start here

- [Paper PDF](paper/UNH_ECO402_Paper.pdf): the publication manuscript.
- [Read the paper on GitHub](paper/UNH_ECO402_Paper.md): the same manuscript in Markdown.
- [Word paper](paper/UNH_ECO402_Paper.docx): the editable publication copy.
- [Walkthrough](docs/walkthrough.md): what each step does and how to read the output.
- [Data notes](data/README.md): source files, units, dates, and the frozen data vintage.
- [Source notes](docs/source_notes.md): references and distinctions between the paper and classroom examples.
- [Version and data availability](docs/publishing.md): what is included in the release.

## Run the analysis

The code was tested with R 4.5.1. Open `unh-fama-french.Rproj` in RStudio so paths start in this folder.

1. Put the original files in `data/raw/`, following [these instructions](data/raw/README.md). They are present in the local working copy but are excluded from Git.
2. If needed, run `source("setup.R")` once to install packages. Package installation requires internet access.
3. Run `source("run.R")`.

From a terminal in this folder, the equivalent analysis command is:

```sh
Rscript --vanilla run.R
```

The analysis reads local files and does not download data. A public clone needs the original inputs to reproduce the estimates. Without those inputs, readers can still inspect the code, paper, figures, and [saved regression output](results/reference/UNH_full_output.txt).

For line-by-line work, open these scripts in order:

| Script | What it does |
| --- | --- |
| [01_data.R](R/01_data.R) | Reads prices and factors, calculates returns, merges dates, and summarizes the sample |
| [02_models.R](R/02_models.R) | Estimates CAPM, FF3, FF5, joint tests, and diagnostics |
| [03_figures.R](R/03_figures.R) | Draws the five figures using base R |
| [04_earnings.R](R/04_earnings.R) | Optionally matches three earnings dates to model residuals |
| [check_results.R](checks/check_results.R) | Compares the run with the paper's saved results |

`run.R` runs the first three scripts, the earnings script if its workbook is available, and the result checks. The R scripts use ordinary assignments, data-frame columns, `lm()`, `summary()`, and base R plots so the analysis can be followed in the console.

## Return construction

```r
UNH$UNH_Return <- ((UNH$PX_LAST / UNH$Previous_Price) - 1) * 100
data$UNH_Excess_Return <- data$UNH_Return - data$RF
```

Prices are sorted from oldest to newest before computing returns. The first price has no earlier observation, so it cannot produce a return. Returns are calculated before the date merge to preserve the previous trading day's price.

All return and factor variables are in percent. `RF` comes from the same Kenneth French file as the factors. The baseline uses changes in `PX_LAST`; it does not separately add cash dividends. It should not be described as a dividend-reinvested total-return model.

## Models

```r
CAPM <- lm(UNH_Excess_Return ~ Mkt_RF, data = data)
FF3 <- lm(UNH_Excess_Return ~ Mkt_RF + SMB + HML, data = data)
FF5 <- lm(UNH_Excess_Return ~ Mkt_RF + SMB + HML + RMW + CMA, data = data)
```

`Mkt_RF` is market excess return. `SMB` is Small Minus Big, `HML` is High Minus Low, `RMW` is Robust Minus Weak, and `CMA` is Conservative Minus Aggressive. The intercept is alpha. A slope describes the change in UNH excess return, in percentage points, associated with a one-percentage-point change in that factor, holding the others constant.

## Results

These values are from the output saved on May 17, 2026.

| Result | CAPM | FF3 | FF5 |
| --- | ---: | ---: | ---: |
| Market coefficient | 0.40607 | 0.48799 | 0.51161 |
| Alpha | -0.03725 | -0.04786 | -0.04781 |
| Alpha p-value | 0.498 | 0.382740 | 0.3825 |
| R-squared | 0.05227 | 0.06157 | 0.0659 |
| Observations | 1,234 | 1,234 | 1,234 |

The market factor is significant at 1% in all three models. Alpha is not significant. HML is significant in FF3 but not in FF5. In FF5, CMA has a conventional p-value of **0.0249**; with HC1 standard errors it rises to **0.05454**. That is evidence at 10%, but not 5%, under HC1. SMB and RMW are not significant in FF5.

The Breusch-Pagan p-value is **0.7956**, and the fitted-value White test p-value is **0.9833245**. Neither test rejects homoskedasticity at 5%. Anderson-Darling rejects residual normality, with **p < 2.2e-16**. Durbin-Watson gives **p = 0.06759** against positive autocorrelation, which is above 5% but below 10%.

These results describe in-sample relationships. Low beta refers to market sensitivity, not low total volatility. A low R-squared leaves considerable variation unexplained, but does not identify the cause of every residual.

## Files produced

Each run writes to `output/`: the merged sample, descriptive statistics, regression table, coefficient CSV, diagnostic CSVs, HC1 comparison, models, five PNG figures, R session information, and a verification report. If `ern.xlsx` is present, it also writes an earnings-event table.

The `results/reference/` files and `figures/` images are the saved paper results. Running the code does not overwrite them. Checks compare estimates and tests at the precision printed in the original output, and compare descriptive statistics with the original CSV.

## Scope and limitations

This is a daily single-stock study. It uses no trimming or winsorization, does not add company-event variables to the baseline regression, and does not evaluate forecasting performance. HC1 changes standard errors, not coefficients, and does not correct serial correlation. The company screens are May 2026 background context, after the regression sample ends.

The publication manuscript is based on the author's GAR paper. Its empirical results are unchanged. The [revision record](paper/README.md) identifies source-label corrections and interpretation clarifications made for publication. The original course manuscript remains in the local archive.

## Cite this project

Hernandez Paulino, Junior. (2026). *UNH Stock Returns and the Fama-French Model* (Version 1.0.0). Undergraduate research, ECO 402 Econometrics, Lehman College. https://github.com/junior-hernandez-paulino/unh-fama-french

Citation metadata are provided in [CITATION.cff](CITATION.cff). The [reproduction report](results/REPRODUCTION.md) records the numerical checks. GitHub's repository check validates the packaged files and links; the numerical reproduction requires the original local data.

## Sources

The project uses Bloomberg's UNH `PX_LAST` export, Kenneth French's March 2026 daily factor vintage, the ECO 402 classroom materials, and the local sources cited in the paper. Source dates and file provenance are listed in [source notes](docs/source_notes.md). No additional data were fetched for this repository.
