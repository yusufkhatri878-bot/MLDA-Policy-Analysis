* Two-sample IV estimates of the drinking-arrest relationship.
* Uses the separate-slope linear first stage on 50-day bin means.
* Run after 01 and 02 via run_all.do. See docs/development_notes.md for provenance.
* Delta method assumes independent samples (zero cross-sample covariance).
if missing(scalar(mlda_fs)) | scalar(mlda_fs) == 0 {
    display as error "The first-stage coefficient must be nonzero and nonmissing."
    exit 498
}
use "data/Arrest.dta", clear
gen over21 = (days_to_21 >= 0)
gen age = 21 + days_to_21/365
gen age_c = age - 21
gen age_cXover21 = age_c * over21
tempname results
tempfile iv_results
postfile `results' str24 outcome double rf rf_se first_stage first_stage_se iv iv_se iv_per_pp se_per_pp using `iv_results', replace
foreach outcome in all drunk_risk dui liquor_laws combined_oth robbery ot_assault aggravated_assault {
    quietly reg `outcome' over21 age_c age_cXover21 if age >= 19 & age <= 23
    scalar mlda_rf = _b[over21]
    scalar mlda_rf_se = _se[over21]
    scalar mlda_iv = mlda_rf / mlda_fs
    scalar mlda_iv_se = sqrt((mlda_rf_se^2 / mlda_fs^2) + (mlda_rf^2 * mlda_fs_se^2 / mlda_fs^4))
    post `results' ("`outcome'") (mlda_rf) (mlda_rf_se) (mlda_fs) (mlda_fs_se) (mlda_iv) (mlda_iv_se) (mlda_iv/100) (mlda_iv_se/100)
}
postclose `results'
use `iv_results', clear
label var iv "Arrests per 10,000 per unit change in drinking proportion"
label var iv_per_pp "Arrests per 10,000 per percentage-point change in drinking"
export delimited using "outputs/tables/drinking_arrests_iv.csv", replace
list, noobs abbreviate(24)
