# Reproduction check

Executed September 9, 2026 with `Rscript --vanilla run.R` in R 4.5.1 on Windows. The run read the original local price workbook and the supplied March 2026 factor ZIP. It completed without an analysis error.

| Check | Result |
| --- | --- |
| Raw factor records versus original normalized CSV | All 15,792 dates and factor records match |
| Final sample | 1,234 rows, May 3, 2021 through March 31, 2026 |
| Entire merged dataset versus saved original | Every numeric cell agrees within 1e-10; dates and columns match |
| CAPM, FF3, and FF5 | Every coefficient, SE, and p-value matches the original printed precision |
| HC1 comparison | Every estimate, SE, and p-value matches the original printed precision |
| Model fit | R-squared, adjusted R-squared, residual standard errors, F statistics, and degrees of freedom match |
| Diagnostics | VIF, studentized BP, fitted-value White, one-sided DW, and AD match |
| Joint tests and ANOVA | Both joint tests and both entries of the original three-model comparison match |
| Descriptive statistics | All variables and summary statistics match the original CSV |
| Graphs | All five generated PNGs visually checked; titles, labels, and legend fit |
| Publication paper | Four empirical tables unchanged from GAR; manuscript edits documented; Markdown retains six tables and five matching figures |

The optional earnings check also completed:

| Announcement date | Price return (%) | FF5 residual (percentage points) | Absolute residual rank |
| --- | ---: | ---: | ---: |
| April 17, 2025 | -22.379666 | -22.462104 | 1 |
| July 29, 2025 | -7.461364 | -7.333068 | 10 |
| January 27, 2026 | -19.605278 | -19.646948 | 2 |

Ranks run from largest absolute residual to smallest across the full sample. This is an alignment check, not an estimate of an earnings announcement's causal effect.

The full run writes `output/verification.txt` and `output/sessionInfo.txt`. The tested package versions are retained in [tested_sessionInfo.txt](tested_sessionInfo.txt). The installed environment emitted locale warnings and build-version notices for two packages; the run and all numerical comparisons completed successfully.

The local source paper and original project outputs remain unchanged. The publication copy includes the author's name, corrects background labels, and clarifies the interpretation of diagnostics and event dates. The [revision record](../paper/README.md) lists the edits. The PDF was exported through Microsoft Word and visually reviewed for table, figure, and caption layout.
