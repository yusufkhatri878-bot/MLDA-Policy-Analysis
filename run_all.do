* Run from the repository root. Example: cd "/path/to/mlda-policy-analysis"
* Run the complete analysis and write figures, tables, and a session log.
clear all
set more off
capture mkdir outputs
capture mkdir outputs/figures
capture mkdir outputs/tables
capture mkdir outputs/logs
confirm file "data/NHIS Data.dta"
confirm file "data/Arrest.dta"
capture which outreg2
if _rc {
    display as error "Install the original table dependency first: ssc install outreg2"
    exit 199
}
capture log close
log using "outputs/logs/analysis.log", text replace
do "code/01_alcohol_consumption.do"
do "code/02_balance_and_arrests.do"
do "code/03_drinking_and_arrests_iv.do"
log close
