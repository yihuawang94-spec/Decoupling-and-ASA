clear all
set more off

* Figure 2, scenario (i): rank-and-file face half the normative pressure of leaders
use "$data/P1x data", clear


loc counter = 0	
foreach OI_helper in $levels {
	
loc ++counter

bys norm_strength: egen conform_freq_`counter'_h_TMT = mean(conform_freq) if OI_helper == `OI_helper' & TMT == 1
bys norm_strength: egen conform_freq_`counter'_TMT = mean(conform_freq_`counter'_h_TMT)
bys norm_strength: egen conform_freq_`counter'_h = mean(conform_freq) if OI_helper == `OI_helper' & TMT == 0
bys norm_strength: egen conform_freq_`counter' = mean(conform_freq_`counter'_h)
g decouple_freq_`counter' = conform_freq_`counter'_TMT - conform_freq_`counter'

bys norm_strength: egen payoff_`counter' = mean(payoff) if OI_helper == `OI_helper' 

}

keep if id == 1 & firm == 1

bys norm_strength: egen payoff_max = max(payoff_11)

g payoff_2_rebase = payoff_2 - payoff_max
g payoff_5_rebase = payoff_5 - payoff_max
g payoff_8_rebase = payoff_8 - payoff_max
g payoff_11_rebase = payoff_11 - payoff_max


sa "$data/P1x analysis data", replace

use "$data/P1x analysis data", clear

lab var decouple_freq_2 "Very weak identification ({&beta}{sub:2} = 0.1)"
lab var decouple_freq_5 "Moderately weak identification ({&beta}{sub:2} = 0.4)"
lab var decouple_freq_8 "Moderately strong identification ({&beta}{sub:2} = 0.7)"
lab var decouple_freq_11 "Full identification ({&beta}{sub:2} = 1)"

twoway line decouple_freq_2 decouple_freq_5 decouple_freq_8 decouple_freq_11 norm_strength, ylabel(0 (.2) 1, format(%03.1f)) xtitle("Normative pressure ({&mu})") ytitle("Policy-practice gap (D)") xlab(, noticks) lpattern(dash dot dash_dot line) lcolor(red blue green black) xlab(0 (1) 5)
graph export "$output/Figure 2ai.svg", replace 

lab var payoff_2_rebase "Very weak identification ({&beta}{sub:2} = 0.1)"
lab var payoff_5_rebase "Moderately weak identification ({&beta}{sub:2} = 0.4)"
lab var payoff_8_rebase "Moderately strong identification ({&beta}{sub:2} = 0.7)"
lab var payoff_11_rebase "Full identification ({&beta}{sub:2} = 1)"

twoway line payoff_2_rebase payoff_5_rebase payoff_8_rebase payoff_11_rebase norm_strength, ylabel(-3 (1) 0, ) xtitle("Normative pressure ({&mu})") ytitle("Firm performance ({&Pi}) relative to {&beta}{sub:2} = 1") xlab(, noticks) lpattern(dash dot dash_dot line) lcolor(red blue green black) xlab(0 (1) 5)

graph export "$output/Figure 2bi.svg", replace 

/*



graph export "$output/Supplementary/Figure 2ai leaders and rank-and-file.svg", replace 

lab var conform_freq_2 "Very weak identification ({&beta}{sub:2} = 0.1)"
lab var conform_freq_5 "Moderately weak identification ({&beta}{sub:2} = 0.4)"
lab var conform_freq_8 "Moderately strong identification ({&beta}{sub:2} = 0.7)"
lab var conform_freq_11 "Full identification ({&beta}{sub:2} = 1)"

twoway line conform_freq_2 conform_freq_5 conform_freq_8 conform_freq_11 norm_strength, ylabel(0 (.2) 1, format(%03.1f)) xtitle("Normative pressure ({&mu})") ytitle("Implementation by rank-and-file") xlab(, noticks) lpattern(dash dot dash_dot line) lcolor(red blue green black) xlab(0 (1) 5)

graph export "$output/Supplementary/Figure 2ai rank-and-file.svg", replace 

lab var conform_freq_2_TMT "Very weak identification ({&beta}{sub:2} = 0.1)"
lab var conform_freq_5_TMT "Moderately weak identification ({&beta}{sub:2} = 0.4)"
lab var conform_freq_8_TMT "Moderately strong identification ({&beta}{sub:2} = 0.7)"
lab var conform_freq_11_TMT "Full identification ({&beta}{sub:2} = 1)"

twoway line conform_freq_2_TMT conform_freq_5_TMT conform_freq_8_TMT conform_freq_11_TMT norm_strength, ylabel(0 (.2) 1, format(%03.1f)) xtitle("Normative pressure ({&mu})") ytitle("Policy signaled by leaders") xlab(, noticks) lpattern(dash dot dash_dot line) lcolor(red blue green black) xlab(0 (1) 5)


*/
