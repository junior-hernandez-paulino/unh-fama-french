# Local inputs

Place these original files in this folder:

| File | Required | Layout |
| --- | --- | --- |
| `430odayUNHstock.xlsx` | Yes | Bloomberg UNH prices. Header at Excel row 7; columns `Date` and `PX_LAST` |
| `F-F_Research_Data_5_Factors_2x3_daily_CSV.zip` | Yes | Original daily factor ZIP created from the 202603 CRSP database |
| `ern.xlsx` | No | Bloomberg earnings workbook used for the three event dates discussed in the paper |

The local working copy already contains these files. They are ignored by Git and excluded from the upload ZIP. Bloomberg screenshots, spreadsheets, course slides, and textbook PDFs are not part of the public package.

The price history includes April 30, 2021, which is needed to calculate the first sample return on May 3. The saved factor file ends March 31, 2026. Using a newer factor download or a different price export is a different data version and may change the estimates.

The script checks the two required files against `data/source_manifest.csv`. If they differ, it stops rather than presenting a new run as a reproduction of the paper.
