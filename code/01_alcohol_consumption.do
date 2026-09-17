* Alcohol consumption: graphical diagnostics and the age-21 first stage.
* Run through run_all.do from the repository root.
* Estimates linear and quadratic specifications on unweighted age-bin means.
* See docs/development_notes.md for the course origin and code preparation.
use "data/NHIS Data.dta", clear
gen age = 21 + days_21/365

* Compare 7-, 50-, and 150-day bins.
preserve
gen h = 21 + 7*floor(days_21/7)/365 + (7/2)/365
collapse (mean) drinks_alcohol age, by(h)
graph twoway (scatter drinks_alcohol h) if age >= 18 & age <= 24, ///
    title("Binwidth = 7 days") xtitle("Age at time of survey") ///
    ytitle("Proportion reporting alcohol consumption") scheme(s1mono) name(bin7, replace)
restore
preserve
gen h = 21 + 50*floor(days_21/50)/365 + (50/2)/365
collapse (mean) drinks_alcohol age, by(h)
graph twoway (scatter drinks_alcohol h) if age >= 18 & age <= 24, ///
    title("Binwidth = 50 days") xtitle("Age at time of survey") ///
    ytitle("Proportion reporting alcohol consumption") scheme(s1mono) name(bin50, replace)
restore
preserve
gen h = 21 + 150*floor(days_21/150)/365 + (150/2)/365
collapse (mean) drinks_alcohol age, by(h)
graph twoway (scatter drinks_alcohol h) if age >= 18 & age <= 24, ///
    title("Binwidth = 150 days") xtitle("Age at time of survey") ///
    ytitle("Proportion reporting alcohol consumption") scheme(s1mono) name(bin150, replace)
restore
graph combine bin7 bin50 bin150
graph export "outputs/figures/alcohol_bin_width_comparison.pdf", as(pdf) replace

* Compare age windows around the legal-access threshold.
preserve
gen h = 21 + 50*floor(days_21/50)/365 + (50/2)/365
collapse (mean) drinks_alcohol age, by(h)
graph twoway (scatter drinks_alcohol h) if age >= 18 & age <= 24, ///
    title("Bandwidth: 18 to 24") xtitle("Age at time of survey") ///
    ytitle("Proportion reporting alcohol consumption") xline(21, lcolor(red) lpattern(dash)) ///
    scheme(s1mono) name(band18_24, replace)
graph twoway (scatter drinks_alcohol h) if age >= 19 & age <= 23, ///
    title("Bandwidth: 19 to 23") xtitle("Age at time of survey") ///
    ytitle("Proportion reporting alcohol consumption") xline(21, lcolor(red) lpattern(dash)) ///
    scheme(s1mono) name(band19_23, replace)
graph twoway (scatter drinks_alcohol h) if age >= 20.5 & age <= 21.5, ///
    title("Bandwidth: 20.5 to 21.5") xtitle("Age at time of survey") ///
    ytitle("Proportion reporting alcohol consumption") xline(21, lcolor(red) lpattern(dash)) ///
    scheme(s1mono) name(band205_215, replace)
graph combine band18_24 band19_23 band205_215
graph export "outputs/figures/alcohol_age_window_comparison.pdf", as(pdf) replace
restore

* Compare y-axis tick choices; ylabel() does not clip observations.
preserve
gen h = 21 + 50*floor(days_21/50)/365 + (50/2)/365
collapse (mean) drinks_alcohol age, by(h)
graph twoway (scatter drinks_alcohol h) if age >= 19 & age <= 23, ///
    title("Y-axis ticks: 0 to 1.0") xtitle("Age") ytitle("Proportion drinking") ///
    xline(21, lcolor(red) lpattern(dash)) ylabel(0(0.2)1) scheme(s1mono) name(yrange_full, replace)
graph twoway (scatter drinks_alcohol h) if age >= 19 & age <= 23, ///
    title("Y-axis ticks: 0.2 to 0.8") xtitle("Age") ytitle("Proportion drinking") ///
    xline(21, lcolor(red) lpattern(dash)) ylabel(0.2(0.1)0.8) scheme(s1mono) name(yrange_med, replace)
graph twoway (scatter drinks_alcohol h) if age >= 19 & age <= 23, ///
    title("Y-axis ticks: 0.4 to 0.6") xtitle("Age") ytitle("Proportion drinking") ///
    xline(21, lcolor(red) lpattern(dash)) ylabel(0.4(0.05)0.6) scheme(s1mono) name(yrange_vnarrow, replace)

graph combine yrange_full yrange_med yrange_vnarrow
graph export "outputs/figures/alcohol_axis_comparison.pdf", as(pdf) replace
restore

* Compare linear and quadratic specifications on 50-day bin means.
gen age_c = age - 21
gen age_c_sq = age_c^2
gen age_c_cu = age_c^3
gen over21 = (age >= 21)
gen over21Xage_c = over21 * age_c
gen over21Xage_c_sq = over21 * age_c_sq
preserve
gen h = 21 + 50*floor(days_21/50)/365 + (50/2)/365
collapse (mean) drinks_alcohol age age_c age_c_sq age_c_cu over21 over21Xage_c over21Xage_c_sq, by(h)
reg drinks_alcohol over21 age_c if age >= 19 & age <= 23
estimates store Linear_Same
reg drinks_alcohol over21 age_c over21Xage_c if age >= 19 & age <= 23
estimates store Linear_Diff
* Retain the full-precision first stage for the two-sample IV calculation.
scalar mlda_fs = _b[over21]
scalar mlda_fs_se = _se[over21]
reg drinks_alcohol over21 age_c over21Xage_c age_c_sq over21Xage_c_sq if age >= 19 & age <= 23
estimates store Quad_Diff
estimates table Linear_Same Linear_Diff Quad_Diff, b(%9.3f) star stats(N r2)
* Report standard errors and save the preferred first-stage estimates.
estimates table Linear_Same Linear_Diff Quad_Diff, b(%9.6f) se(%9.6f) stats(N r2)
estimates restore Linear_Diff
estimates save "outputs/tables/first_stage.ster", replace

reg drinks_alcohol age_c if age >= 19 & age < 21
predict fit_l_left if age >= 19 & age < 21
reg drinks_alcohol age_c if age >= 21 & age <= 23
predict fit_l_right if age >= 21 & age <= 23
reg drinks_alcohol age_c age_c_sq if age >= 19 & age < 21
predict fit_q_left if age >= 19 & age < 21
reg drinks_alcohol age_c age_c_sq if age >= 21 & age <= 23
predict fit_q_right if age >= 21 & age <= 23
graph twoway (scatter drinks_alcohol age) ///
    (line fit_l_left age, sort lcolor(red) lwidth(medthick)) ///
    (line fit_l_right age, sort lcolor(red) lwidth(medthick)) ///
    (line fit_q_left age, sort lcolor(blue) lwidth(medthick) lpattern(dash)) ///
    (line fit_q_right age, sort lcolor(blue) lwidth(medthick) lpattern(dash)) ///
    if age >= 19 & age <= 23, xline(21, lcolor(black) lpattern(dot)) scheme(s1mono) ///
    ytitle("Proportion reporting alcohol consumption") xtitle("Age") ///
    legend(order(1 "Data" 2 "Linear fit" 4 "Quadratic fit")) title("Linear vs Quadratic")
graph export "outputs/figures/alcohol_model_comparison.png", as(png) replace
restore

* Plot the preferred first-stage specification.
preserve
gen h = 21 + 50*floor(days_21/50)/365 + (50/2)/365
collapse (mean) drinks_alcohol age age_c, by(h)
reg drinks_alcohol age_c if age >= 19 & age < 21
predict fit_left if age >= 19 & age < 21
reg drinks_alcohol age_c if age >= 21 & age <= 23
predict fit_right if age >= 21 & age <= 23
graph twoway (scatter drinks_alcohol age, mcolor(gs8)) ///
    (line fit_left age, sort lcolor(red) lwidth(medthick)) ///
    (line fit_right age, sort lcolor(red) lwidth(medthick)) ///
    if age >= 19 & age <= 23, title("MLDA and Alcohol Consumption") ///
    xtitle("Age (Years)") ytitle("Proportion reporting alcohol consumption") ///
    xline(21, lcolor(black) lpattern(dash)) ylabel(0.2(0.1)0.8) ///
    legend(order(1 "Binned Data (50-day)" 2 "Linear Fit") position(6) rows(1)) ///
    scheme(s1mono) name(final_first_stage, replace)
graph export "outputs/figures/alcohol_consumption_first_stage.png", as(png) replace
restore
