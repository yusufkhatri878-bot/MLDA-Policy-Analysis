# Data setup

Download the two instructor-provided Stata datasets and place them here with these exact filenames:

- `NHIS Data.dta`: https://people.ucsc.edu/~cdobkin/NHIS%20Data.dta
- `Arrest.dta`: https://people.ucsc.edu/~cdobkin/Arrest.dta

These are the course-provided links. The remote links could not be retrieved in the preparation environment. The arrest data were subsequently supplied as a CSV and validated against the original arrest table; the NHIS source file itself has not been inspected. If a link is unavailable, use the course copy. The scripts use Stata files rather than CSVs.

NHIS contains individual survey records from 1997-2007. The arrest file contains California arrest rates per 10,000 by age, not individual arrest records. They are separate samples, not a merged person-level dataset.

Variable names follow the submitted code, including lowercase `hs_diploma`, `age_yrs`, `working_lw`, and `going_school`. If a different course copy uses different names, inspect `describe` and explicitly rename the relevant variables before running. Do not substitute a different drinking measure silently. The course documentation describes `drinks_alcohol` as reporting alcohol consumption; the PDF labels some plots as drinking in the last month. Verify the source label before claiming a specific recall period.

## CSV alternative for arrests

The user-supplied `MLDA Crime CA.csv` contains 2,922 rows and uses `_r` suffixes for arrest-rate columns. A converted `Arrest.dta` was used in the reviewed run. To make the same conversion yourself, place the CSV in `data/`, set Stata's working directory to the project root, and run:

```stata
import delimited using "data/MLDA Crime CA.csv", clear varnames(1)
foreach v in all drunk_risk dui liquor_laws combined_oth robbery ot_assault aggravated_assault {
    rename `v'_r `v'
}
save "data/Arrest.dta", replace
```

This changes eight column names, preserving observations and values. It is an alternative to using an already prepared `Arrest.dta`.

Data are not bundled. No redistribution license is assumed.
