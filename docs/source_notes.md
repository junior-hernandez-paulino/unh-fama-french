# Sources and reproduction notes

This repository follows `UNH_ECO402_Final_PaperGAR.docx`, the paper selected by the author. The course paper is dated May 17, 2026. The publication edition and R implementation were prepared and tested on September 9, 2026 using the saved local data, not a new download. The [publication revision record](../paper/README.md) identifies the manuscript edits.

## Source material

| Material | Role | Date or period |
| --- | --- | --- |
| GAR paper | Narrative, tables, and interpretation to reproduce | May 17, 2026 title-page date |
| `UNH_full_output.txt` | Original numerical authority for estimates and diagnostics | Generated May 17, 2026 |
| `UNH_regression_table.txt` | Original side-by-side table and its star legend | Saved with the original output |
| `UNH_descriptive_statistics.csv` | Original descriptive-statistics values | 1,234-row merged sample |
| Bloomberg `430odayUNHstock.xlsx` | UNH daily `PX_LAST` prices | Requested range April 30, 2021 to May 14, 2026 |
| Kenneth French daily factor ZIP | Five factors and daily RF | Header identifies the 202603 CRSP database; records end March 31, 2026 |
| `hw1-Rcode.R` | Style reference: direct assignments, short comments, base R plots | Date unspecified |
| ECO 402 FF5 Bloomberg/RStudio slides | Classroom workflow and model definitions | Spring 2026; filename dated April 1, 2026 |
| `3. Fama French 5 factors model.pdf` | Classroom daily-price/factor workflow | Uses a 2017 example; document date unspecified |
| Bloomberg `bsunh.pdf` | Balance-sheet context, not a regression input | Report timestamp May 14, 2026; annual columns through 2025 |
| Bloomberg `ern.xlsx` | Earnings dates and fields used in optional event check | Three paper events in 2025 and January 2026 |

The raw exports, handouts, textbook PDFs, and slides remain local. The repository includes the student's paper, code, derived figures, and saved numerical results. No redistribution rights or blanket license for third-party material are asserted here.

## Choices that preserve the UNH analysis

The classroom slides demonstrate IBM with monthly data, a total-return field, and some different diagnostic choices. The shorter handout uses daily data and a 2017 example. Those are reference examples. This repository uses the paper's daily UNH `PX_LAST` calculation, Kenneth French RF, 2021-2026 overlap, Anderson-Darling test, and HC1 covariance estimate.

The original script's price import uses `skip = 5`. In the actual workbook, row 6 is blank and the header is row 7. `readxl` skipped that empty row in the original run. The new script uses the explicit header location, `skip = 6`, and checks that the merged sample is identical.

`bptest(FF5)` is the studentized Breusch-Pagan test from `lmtest`. The White result uses `uhat2 ~ yhat + yhat2` and two degrees of freedom. The Durbin-Watson p-value uses the alternative of positive autocorrelation. Changing packages or test variants is not equivalent to reproducing the same diagnostic.

The comparison table preserves `anova(CAPM, FF3, FF5)`. In that table, the largest model supplies the residual variance estimate. Separate pairwise calls are not substituted for it.

## Clarifications to read alongside the paper

**Balance-sheet label.** The GAR paper called the 2025 figure of $28.121 billion cash and equivalents. Page 1 of the supplied Bloomberg balance sheet labels that row **Cash, Cash Equivalents & STI**. Its components are $24.365 billion of cash and cash equivalents and $3.756 billion of short-term investments. This label is corrected in the publication manuscript. These values do not enter any regression.

**EBITDA measures.** The adjusted income-statement view reports 2025 EBITDA of $27.474 billion and an EBITDA margin of 6.14 percent. The ratio screen reports 5.57 percent using its own basis. The publication manuscript identifies the sources of the two measures so that readers do not treat them as a matching numerator and ratio.

**Segment allocation.** The supplied Bloomberg chart allocates consolidated revenue across UnitedHealthcare, Optum, and an adjustment category. Its $312.730 billion and $130.917 billion values are described as that screen's allocations; they are not labeled as gross segment revenues before eliminations.

**Return definition.** The baseline computes simple changes in the exported `PX_LAST` series. It does not separately add dividends or establish dividend reinvestment. The class slides' total-return example should not be used to relabel these price-derived returns.

**Earnings fields.** The workbook distinguishes `Reported` EPS from `Comp` EPS. The listed `%Surp` aligns with the comparable EPS field, not the raw reported EPS field. The optional table retains the original field names' meanings instead of recalculating the supplied surprise percentage using a different EPS basis. Its daily return is computed from the baseline prices and can differ slightly from a rounded Bloomberg screen value.

**Interpretation.** Event-date alignment is descriptive evidence, not a causal event study. A below-one beta means lower estimated sensitivity to the market; it does not establish lower total volatility. Residuals averaging approximately zero in an OLS regression with an intercept does not verify the zero conditional mean assumption. Failing to reject homoskedasticity does not prove constant variance, and HC1 does not correct serial correlation.

**Timing.** The company screens are May 2026 support context. A filing covering the quarter ended March 31, 2026 may have been published after that date. Such information is not treated as an explanatory variable known on every date of the regression sample.

## References

Bloomberg Terminal. UnitedHealth Group, UNH US Equity. Historical `PX_LAST` export and company description, financial statement, dividend, peer, and earnings materials retained in the local project. May 2026 materials where dated.

Kenneth R. French Data Library. Fama/French 5 Factors (2x3), Daily. Original supplied CSV ZIP, March 2026 CRSP data vintage. Copyright notice in the source file: 2026 Eugene F. Fama and Kenneth R. French.

ECO 402 Econometrics. Fama-French model and Bloomberg/RStudio classroom materials. Spring 2026. The original slides and R examples were used locally as course references.

Fama, Eugene F., and Kenneth R. French. 2015. A five-factor asset pricing model. *Journal of Financial Economics*, 116(1), 1-22. Bibliographic details are reproduced from the local project references.

Heiss, Florian. 2020. *Using R for Introductory Econometrics*. 2nd edition. Local course text cited in the paper.

UnitedHealth Group Incorporated. Form 10-Q for the quarter ended March 31, 2026. Local filing used as company context in the paper.

The paper contains its complete reference list. These entries identify the main sources of the repository without adding outside theory or newly fetched information.
