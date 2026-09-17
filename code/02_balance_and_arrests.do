* Demographic balance and arrest-rate discontinuities at age 21.
* Demographic models use age_yrs; arrest models use day-derived age.
use "data/NHIS Data.dta", clear
gen over21 = (days_21 >= 0)
gen age = 21 + days_21/365
gen age_c = age - 21
gen age_cXover21 = age_c * over21
label var age_c "Centered Age"
quietly reg hs_diploma over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) replace label
quietly reg hispanic over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg white over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg black over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg uninsured over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg employed over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg married over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg working_lw over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg going_school over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label
quietly reg male over21 age_c age_cXover21 if age_yrs >= 19 & age_yrs <= 23
outreg2 using "outputs/tables/demographic_balance.rtf", word bdec(3) append label


* Plot overall arrest rates, with fits estimated on 30-day bin means.
use "data/Arrest.dta", clear
gen age = 21 + days_to_21/365
gen age_c = age - 21
gen age_30days = 21 + 30*floor(days_to_21/30)/365 + (30/2)/365
preserve
collapse (mean) all age age_c, by(age_30days)
reg all age_c if age >= 19 & age < 21
predict fit_l_left if age >= 19 & age < 21
reg all age_c if age >= 21 & age <= 23
predict fit_l_right if age >= 21 & age <= 23
graph twoway (scatter all age_30days) ///
    (line fit_l_left age_30days, sort lcolor(blue)) ///
    (line fit_l_right age_30days, sort lcolor(blue)) if age >= 19 & age <= 23, ///
    scheme(s1mono) title("Age Profile of All Arrests") xtitle("Age") ///
    ytitle("Arrests (per 10,000)") legend(off)
graph export "outputs/figures/overall_arrest_rates.png", as(png) replace
restore

* Compare DUI and liquor-law arrest profiles using separate y-axes.
preserve
collapse (mean) dui liquor_laws age age_c, by(age_30days)
reg dui age_c if age >= 19 & age < 21
predict fit_l_left_dui if age >= 19 & age < 21
reg dui age_c if age >= 21 & age <= 23
predict fit_l_right_dui if age >= 21 & age <= 23
reg liquor_laws age_c if age >= 19 & age < 21
predict fit_l_left_liquor if age >= 19 & age < 21
reg liquor_laws age_c if age >= 21 & age <= 23
predict fit_l_right_liquor if age >= 21 & age <= 23
graph twoway (scatter dui age_30days, yaxis(1)) ///
    (scatter liquor_laws age_30days, yaxis(2)) ///
    (line fit_l_left_dui age_30days, sort lcolor(blue) yaxis(1)) ///
    (line fit_l_left_liquor age_30days, sort lcolor(red) yaxis(2)) ///
    (line fit_l_right_dui age_30days, sort lcolor(blue) yaxis(1)) ///
    (line fit_l_right_liquor age_30days, sort lcolor(red) yaxis(2)) ///
    if age >= 19 & age <= 23, scheme(s1mono) title("DUI and Liquor Laws") xtitle("Age") ///
    ytitle("DUI (per 10,000)", axis(1)) ytitle("Liquor Laws (per 10,000)", axis(2)) ///
    legend(off) note("Circles: DUI (left axis). Diamonds: liquor laws (right axis).")
graph export "outputs/figures/dui_and_liquor_law_arrests.png", as(png) replace
restore

* Estimate discontinuities using original age-level arrest rates.
use "data/Arrest.dta", clear
gen over21 = (days_to_21 >= 0)
gen age = 21 + days_to_21/365
gen age_c = age - 21
gen age_cXover21 = age_c * over21
label var age_c "Centered Age"
quietly reg all over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) replace label ctitle("All Arrests")
quietly reg drunk_risk over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) append label ctitle("Drunk/Risk")
quietly reg dui over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) append label ctitle("DUI")
quietly reg liquor_laws over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) append label ctitle("Liquor Laws")
quietly reg combined_oth over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) append label ctitle("Disorderly")
quietly reg robbery over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) append label ctitle("Robbery")
quietly reg ot_assault over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) append label ctitle("Simple Assault")
quietly reg aggravated_assault over21 age_c age_cXover21 if age >= 19 & age <= 23
outreg2 using "outputs/tables/arrest_regressions.rtf", word bdec(3) append label ctitle("Agg. Assault")
