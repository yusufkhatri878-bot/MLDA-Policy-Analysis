# Development notes

## Origin and preparation

This project originated in ECON 104 at UC Santa Cruz. Two course submissions covered alcohol-consumption discontinuities and the relationship between legal drinking eligibility and arrests. The research questions and datasets were provided by the course.

The alcohol-consumption and balance/arrest scripts were transcribed from code included in the submitted PDFs. The original submissions reported IV estimates and standard errors but did not include executable code for those calculations. The IV script was therefore reconstructed separately from the stated method, with AI assistance. It is not presented as recovered original code.

## Repairs and additions

- Split commands that had run together, restore Stata `///` continuations, normalize smart quotation marks, and change `Restore` to `restore`.
- Generate `age` once at alcohol-consumption analysis startup instead of repeating the command. Add an explicit data-loading command where the alcohol-consumption analysis submission assumed the dataset was already open.
- Remove references to `bin30`, `band20_22`, and `yrange_narrow` from graph-combine commands. The supplied code never creates those graphs. No missing specifications were invented.
- Preserve the y-axis tick specifications. In Stata, `ylabel()` does not force a hard plotting range or clip observations. Change panel titles to describe tick choices rather than promise exact limits.
- Add `sort` to fitted-line plots and remove redundant `yscale(axis())` calls in the dual-axis figure. Retain the original dual-axis structure.
- Use neutral alcohol-consumption labels instead of asserting a last-month recall period that could not be checked in the underlying dataset.
- Add relative input/output paths, output directories, a dependency check for `outreg2`, a master runner, and a log. No automatic data download or package installation occurs.
- Add saved first-stage estimates and full-precision first-stage scalars for IV reconstruction. Add a second model table with standard errors to the log.
- Preserve ordinary OLS standard errors, bin-level first-stage estimation, the unused cubic age variable, and the source's different demographic and arrest age filters. These were not silently replaced with a different analytical method.

## Material gaps in the source

The original plotting task requests plots for every arrest category. The submission supplies plotting code only for all arrests and the DUI/liquor-laws pair. The extracted script reproduces those figures; it does not claim to contain the missing category plots. All eight requested arrest regressions are present.

At initial extraction, no raw data, original `.do` files, Excel workbook, or calculation formula from the class was supplied. The arrest CSV and completed run outputs were supplied later. The new IV code implements the conventional independent-sample delta method; it is not an extraction of an unseen spreadsheet or class formula.

## IV discrepancy

The alcohol-consumption analysis screenshot reports a separate-slope linear first stage of 0.085, rounded to three decimals, with 30 bins. The arrest analysis arrest table reports the following reduced-form coefficients. Its written IV answers imply different first-stage denominators:

| Outcome | Reported arrest jump | Reported IV answer | Implied first-stage denominator |
| --- | ---: | ---: | ---: |
| All arrests | 76.762 | 764.29 | 0.10044 |
| DUI | 51.295 | 566.28 | 0.09058 |
| Drunkenness/risk | 31.619 | 321.90 | 0.09823 |
| Liquor laws | −71.337 | −833.12 | 0.08563 |

A common first stage should give a common denominator. These differences cannot all be explained by rounding a coefficient reported as 0.085. For example, 76.762 / 0.085 is about 903.08, not 764.29. Without the original calculation workbook, the cause cannot be established. The PDF's IV standard errors cannot be reproduced from the supplied screenshots alone because the first-stage standard error is not shown.

The reconstructed script uses the full-precision coefficient and standard error from the alcohol-consumption analysis separate-slope linear model and the same arrest specifications as the arrest regression analysis:

`IV = reduced_form / first_stage`

`SE(IV) = sqrt(SE(reduced_form)^2 / first_stage^2 + reduced_form^2 * SE(first_stage)^2 / first_stage^4)`

This formula sets the cross-sample covariance to zero. Outputs are per unit change in drinking proportion; dividing the estimate and standard error by 100 gives the values per percentage point. The calculation does not establish the identifying assumptions or fix potential sample-comparability and exclusion problems.

## Interpretation corrections

- The balance table's marriage discontinuity is **−0.031**, not an increase; the positive age slope is a separate coefficient. A smooth age trend does not explain away a discontinuity at the cutoff.
- Ages 19–23 span roughly two years on either side of 21. This is not a regression window of only a few days.
- Balance on measured characteristics does not prove independence or the exclusion restriction. Direct changes in liquor-law enforcement are a specific exclusion concern.
- The `drinks_alcohol` outcome is a participation measure as described in the assignment. It should not be casually described as drinking frequency or intensity.
- Arrest rates count arrests per 10,000, not necessarily unique people arrested.
- The displayed arrest categories need not exhaust the total. Their coefficients should not be presented as a complete decomposition without checking dataset documentation.

## Validation performed

The initial PDF extraction was reviewed against the source tables. A subsequent user-supplied Stata run completed all three scripts and produced the reviewed results included here. The first-stage, balance, and arrest estimates reproduce the original reported values to displayed precision. IV arithmetic was checked independently using the run's CSV. See [validation.md](validation.md) for the completed review and the distinction between execution checks and causal validity.

## Portfolio presentation

Filenames, export paths, script comments, and documentation are organized by research topic rather than assignment number. The same model commands, data transformations, and numerical outputs are retained. The category chart supplied after the legend correction is included. No original datasets or full local session logs are published in this package.
