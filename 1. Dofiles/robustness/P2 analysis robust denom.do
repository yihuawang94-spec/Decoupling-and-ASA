clear all
foreach OI_helper in $levels {	
append using "$data/P2 oi`OI_helper' D$denom data" 
}

loc counter = 0	
forval phi_std_helper = 1 / 4 {	
loc ++counter
	
bys OI time: egen conform_freq_`counter'_h_TMT = mean(conform_freq) if phi_std_helper == `phi_std_helper' & TMT == 1
bys OI time: egen conform_freq_`counter'_TMT = max(conform_freq_`counter'_h_TMT) 
bys OI time: egen conform_freq_`counter'_h = mean(conform_freq) if phi_std_helper == `phi_std_helper' & TMT == 0
bys OI time: egen conform_freq_`counter' = max(conform_freq_`counter'_h) 
g decouple_freq_`counter' = conform_freq_`counter'_TMT - conform_freq_`counter'

bys OI time: egen payoff_`counter' = mean(payoff) if phi_std_helper == `phi_std_helper'
bys OI time: egen phi_`counter' = mean(phi) if phi_std_helper == `phi_std_helper'

}

sa "$data/P2 D$denom  data", replace

use "$data/P2 D$denom  data", clear

keep if firm ==1 & id == 1

* Figure 4, column a: weak normative pressure, alternative denominators
loc col "a"

foreach time in $halftime $maxtime {

preserve
keep if time == `time'

if `time' == $halftime {
	loc f_gap "Figure 4`col'i"
	loc f_pay "Figure 4`col'ii"
}
else {
	loc f_gap "Supplementary/Figure 4`col' gap t`time'"
	loc f_pay "Figure 4`col'iii"
}
loc f_phi "Supplementary/Figure 4`col' belief t`time'"

lab var decouple_freq_1 "No support ({&nu}{sub:{&phi}} = $phi_1)"
lab var decouple_freq_2 "Low support ({&nu}{sub:{&phi}} = $phi_2)"
lab var decouple_freq_3 "Moderate support ({&nu}{sub:{&phi}} = $phi_3)"
lab var decouple_freq_4 "Strong support ({&nu}{sub:{&phi}} = $phi_4)"

twoway line decouple_freq_1 decouple_freq_2 decouple_freq_3 decouple_freq_4 OI, xtitle("Rank-and-file organizational identification ({&beta}{sub:2})") ytitle("Policy-practice gap (D)") xlab(, noticks) lpattern(dash  dot   dash_dot  shortdash) lcolor(red  blue green purple ) xlab(, format(%4.1f)) ylab(, format(%4.1f))
graph export "$output_denom/`f_gap' D$denom.svg", replace 

lab var phi_1 "No support ({&nu}{sub:{&phi}} = $phi_1)"
lab var phi_2 "Low support ({&nu}{sub:{&phi}} = $phi_2)"
lab var phi_3 "Moderate support ({&nu}{sub:{&phi}} = $phi_3)"
lab var phi_4 "Strong support ({&nu}{sub:{&phi}} = $phi_4)"

forval i = 1 / 4 {
bys phi_std_helper time: g payoff_rebase_h_`i' = payoff_`i' if OI == 0
bys phi_std_helper time: egen payoff_rebase_`i' = max(payoff_rebase_h_`i') 
g payoff_`i'_rebase = payoff_`i' - payoff_rebase_`i'
}

sort firm panel norm_strength norm_strength_eff time phi_std phi_std_helper id TMT OI

twoway line phi_1 phi_2 phi_3 phi_4 OI, xtitle("Rank-and-file organizational identification ({&beta}{sub:2})") ytitle("Pro-normative belief ({&phi})") xlab(, noticks) lpattern(dash dot dash_dot shortdash) lcolor(red blue green purple) xlab(, format(%4.1f)) ylab(, format(%4.1f))
graph export "$output_denom/`f_phi' D$denom.svg", replace 

lab var payoff_1_rebase "No support ({&nu}{sub:{&phi}} = $phi_1)"
lab var payoff_2_rebase "Low support ({&nu}{sub:{&phi}} = $phi_2)"
lab var payoff_3_rebase "Moderate support ({&nu}{sub:{&phi}} = $phi_3)"
lab var payoff_4_rebase "Strong support ({&nu}{sub:{&phi}} = $phi_4)"

twoway line payoff_1_rebase payoff_2_rebase payoff_3_rebase payoff_4_rebase OI, xtitle("Rank-and-file organizational identification ({&beta}{sub:2})") ytitle("Firm performance ({&Pi}) relative to {&beta}{sub:2} = 0") xlab(, noticks) lpattern(dash dot dash_dot shortdash) lcolor(red blue green purple) xlab(, format(%4.1f)) ylab(, format(%4.1f))
graph export "$output_denom/`f_pay' D$denom.svg", replace 

restore

}