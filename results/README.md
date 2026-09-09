# Saved and reproduced results

`reference/UNH_full_output.txt`, `reference/UNH_regression_table.txt`, and `reference/UNH_descriptive_statistics.csv` are the saved numerical results used in the GAR paper. The full-output copy replaces one computer-specific source-path line with a portable source description. No coefficient, standard error, p-value, test statistic, or observation is changed.

The reproduction writes new results to the ignored `output/` directory. `checks/check_results.R` compares them with the original printed values and descriptive-statistics CSV. The check script retains printed precision; it does not require a rounded display value to equal a full-precision machine value exactly.

`REPRODUCTION.md` records the execution and checks performed when this repository was prepared. For another computer, the R version and installed package versions are useful context; different source-data vintages will not necessarily reproduce the same results.
