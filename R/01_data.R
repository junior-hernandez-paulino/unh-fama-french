# 1. Read the UNH prices
library(readxl)
library(readr)

required_files <- c("430odayUNHstock.xlsx",
                    "F-F_Research_Data_5_Factors_2x3_daily_CSV.zip")
if (!all(file.exists(file.path("data/raw", required_files)))) {
  stop("The original price workbook and factor ZIP are needed. See data/raw/README.md.")
}

# Check the saved data vintage before doing any calculations.
manifest <- read.csv("data/source_manifest.csv")
expected_md5 <- manifest$MD5[match(required_files, manifest$File)]
actual_md5 <- unname(tools::md5sum(file.path("data/raw", required_files)))
if (!identical(actual_md5, expected_md5)) {
  stop("An input differs from the paper's saved source. See data/README.md.")
}

# The first six Excel rows contain Bloomberg export information.
UNH <- read_excel("data/raw/430odayUNHstock.xlsx", skip = 6)
UNH <- as.data.frame(UNH[c("Date", "PX_LAST")])
UNH$Date <- as.Date(UNH$Date)
UNH <- UNH[order(UNH$Date), ]
rownames(UNH) <- NULL

stopifnot(!anyNA(UNH), !anyDuplicated(UNH$Date),
          all(is.finite(UNH$PX_LAST)), all(UNH$PX_LAST > 0))
print(head(UNH))

# 2. Calculate daily returns before merging the dates
# Multiplying by 100 puts returns in the same percent units as the factors.
UNH$Previous_Price <- c(NA, head(UNH$PX_LAST, -1))
UNH$UNH_Return <- ((UNH$PX_LAST / UNH$Previous_Price) - 1) * 100
UNH <- UNH[-1, c("Date", "PX_LAST", "UNH_Return")]

# 3. Read the original Kenneth French daily file
factor_zip <- "data/raw/F-F_Research_Data_5_Factors_2x3_daily_CSV.zip"
zip_members <- unzip(factor_zip, list = TRUE)$Name
factor_csv <- zip_members[basename(zip_members) ==
                            "F-F_Research_Data_5_Factors_2x3_daily.csv"]
stopifnot(length(factor_csv) == 1)
factor_connection <- unz(factor_zip, factor_csv)
factor_lines <- readLines(factor_connection, warn = FALSE)
close(factor_connection)

# The ZIP's CSV has notes above the header and copyright text at the end.
# Only dated CSV records belong in the data frame.
factor_lines <- factor_lines[grepl("^[0-9]{8},", factor_lines)]
factors <- read_csv(I(paste(factor_lines, collapse = "\n")),
                    col_names = c("Date", "Mkt_RF", "SMB", "HML",
                                  "RMW", "CMA", "RF"),
                    col_types = "cdddddd", show_col_types = FALSE)
stopifnot(nrow(problems(factors)) == 0)
factors$Date <- as.Date(factors$Date, format = "%Y%m%d")
stopifnot(!anyNA(factors), !anyDuplicated(factors$Date),
          all(is.finite(as.matrix(factors[-1]))),
          !any(as.matrix(factors[-1]) %in% c(-99.99, -999)))

# 4. Keep overlapping dates and subtract the daily RF
data <- merge(UNH, factors, by = "Date", all = FALSE, sort = TRUE)
data$UNH_Excess_Return <- data$UNH_Return - data$RF
stopifnot(nrow(data) == 1234, !anyNA(data),
          min(data$Date) == as.Date("2021-05-03"),
          max(data$Date) == as.Date("2026-03-31"))

print(range(data$Date))
print(nrow(data))
print(head(data))

dir.create("output", showWarnings = FALSE)
write.csv(data, "output/UNH_FF5_merged_data.csv", row.names = FALSE)
sample_check <- data.frame(
  Item = c("Price rows", "Return rows", "Merged rows", "Sample start", "Sample end"),
  Value = c(nrow(UNH) + 1, nrow(UNH), nrow(data),
            as.character(min(data$Date)), as.character(max(data$Date))))
write.csv(sample_check, "output/sample_check.csv", row.names = FALSE)

# 5. Descriptive statistics
variables <- c("UNH_Excess_Return", "Mkt_RF", "SMB", "HML", "RMW", "CMA", "RF")
descriptive_statistics <- data.frame(
  Variable = variables,
  Observations = sapply(data[variables], length),
  Mean = sapply(data[variables], mean),
  Median = sapply(data[variables], median),
  SD = sapply(data[variables], sd),
  Minimum = sapply(data[variables], min),
  Maximum = sapply(data[variables], max), row.names = NULL)
print(descriptive_statistics)
write.csv(descriptive_statistics, "output/descriptive_statistics.csv", row.names = FALSE)
