# Open unh-fama-french.Rproj, then run source("run.R").
# From a terminal in this folder: Rscript --vanilla run.R

if (!file.exists("unh-fama-french.Rproj")) {
  stop("Open the RStudio project or run Rscript from the repository folder.")
}

source("R/01_data.R")
source("R/02_models.R")
source("R/03_figures.R")

if (file.exists("data/raw/ern.xlsx")) {
  source("R/04_earnings.R")
} else {
  message("Optional earnings table skipped: data/raw/ern.xlsx is not present.")
}

source("checks/check_results.R")
writeLines(capture.output(sessionInfo()), "output/sessionInfo.txt")
cat("Analysis finished. Tables, figures, and checks are in output/.\n")
