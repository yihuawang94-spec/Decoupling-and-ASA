clear all
set seed 123

forval firm = 1 / $pop_firm {

clear

set obs $obs

g firm = `firm'
g panel = _n
g norm_strength_a = $norm_strength_1
g norm_strength_eff_a = norm_strength_a
g norm_strength_b = $norm_strength_2
g norm_strength_eff_b = norm_strength_b

g phi_std_a = $phi_1
replace phi_std_a = $phi_2 if _n > 1 * $pop_ind
replace phi_std_a = $phi_3 if _n > 2 * $pop_ind
replace phi_std_a = $phi_4 if _n > 3 * $pop_ind

g phi_std_b = $phi_1

g phi_std_helper = 1
replace phi_std_helper = 2 if _n > 1 * $pop_ind
replace phi_std_helper = 3 if _n > 2 * $pop_ind
replace phi_std_helper = 4 if _n > 3 * $pop_ind

bys phi_std_helper: g id = _n
g TMT = 0
replace TMT = 1 if id <= $TMT_pop 

g OI = $OI_lvl
g OI_helper = $OI_helper
g phi_a = rchi2(phi_std_a)  
g phi_b = rchi2(phi_std_b)      

g noise_a = rnormal(0, $std)
g noise_b = rnormal(0, $std)

g util_c_a = OI * norm_strength_eff_a - $cost + noise_a + phi_a if TMT == 0
replace util_c_a = norm_strength_eff_a - $cost + noise_a + phi_a if TMT == 1

g util_c_b = OI * norm_strength_eff_b - $cost + noise_b + phi_b if TMT == 0
replace util_c_b = norm_strength_eff_b - $cost + noise_b + phi_b if TMT == 1

g util = 0
replace util = util_c_a if util_c_a > 1 & util_c_a > util_c_b
replace util = util_c_b if util_c_b > 1 & util_c_b > util_c_a

g conform_a = 0
replace conform_a = 1 if util == util_c_a

g conform_b = 0
replace conform_b = 1 if util == util_c_b

bys phi_std_helper TMT: egen conform_freq_a = mean(conform_a) 
bys phi_std_helper TMT: egen conform_freq_b = mean(conform_b) 

g payoff = 0
replace payoff = norm_strength_eff_a - $cost + noise_a if conform_a == 1
replace payoff = norm_strength_eff_b - $cost + noise_b if conform_b == 1

g time = 0

tempfile `firm'_0
sa ``firm'_0'
}


forval firm = 1 / $pop_firm {
forval time = 1 / $maxtime {
clear

loc j = `time' - 1
use ``firm'_`j''

replace norm_strength_eff_a = $norm_strength_2 if time > 10
replace norm_strength_eff_b = $norm_strength_1 if time > 10

replace phi_std_a = $phi_1 if time > 10

replace phi_std_b = $phi_2 if _n > 1 * $pop_ind & time > 10
replace phi_std_b = $phi_3 if _n > 2 * $pop_ind & time > 10
replace phi_std_b = $phi_4 if _n > 3 * $pop_ind & time > 10

drop conform_freq* 

replace noise_a = rnormal(0, $std)
replace noise_b = rnormal(0, $std)

replace util_c_a = OI * norm_strength_eff_a - $cost + noise_a + phi_a if TMT == 0
replace util_c_a = norm_strength_eff_a - $cost + noise_a + phi_a if TMT == 1 

replace util_c_b = OI * norm_strength_eff_b - $cost + noise_b + phi_b if TMT == 0
replace util_c_b = norm_strength_eff_b - $cost + noise_b + phi_b if TMT == 1 

replace util = 0
replace util = util_c_a if util_c_a > 1 & util_c_a > util_c_b
replace util = util_c_b if util_c_b > 1 & util_c_b > util_c_a

replace conform_a = 0
replace conform_a = 1 if util == util_c_a

replace conform_b = 0
replace conform_b = 1 if util == util_c_b

bys phi_std_helper TMT: egen conform_freq_a = mean(conform_a) 
bys phi_std_helper TMT: egen conform_freq_b = mean(conform_b) 

replace payoff = 0
replace payoff = norm_strength_eff_a - $cost + noise_a if conform_a == 1
replace payoff = norm_strength_eff_b - $cost + noise_b if conform_b == 1

g conform_freq1_a_helper = conform_freq_a if TMT == 1
bys phi_std_helper: egen conform_freq1_a = max(conform_freq1_a_helper)
g conform_freq0_a_helper = conform_freq_a if TMT == 0
bys phi_std_helper: egen conform_freq0_a = max(conform_freq0_a_helper)
g attraction_a = conform_freq1_a * conform_freq0_a

g conform_freq1_b_helper = conform_freq_b if TMT == 1
bys phi_std_helper: egen conform_freq1_b = max(conform_freq1_b_helper)
g conform_freq0_b_helper = conform_freq_b if TMT == 0
bys phi_std_helper: egen conform_freq0_b = max(conform_freq0_b_helper)
g attraction_b = conform_freq1_b * conform_freq0_b


replace time = `time'

/* ---------- EXIT ---------- */
gen preferred_freq_a = exp(phi_a) / ($denom + exp(phi_a))
gen preferred_freq_b = exp(phi_b) / ($denom + exp(phi_b))
gen misalignment_a = (attraction_a - preferred_freq_a) ^ 2 
gen misalignment_b = (attraction_b - preferred_freq_b) ^ 2 
gen exit_threshold_a = runiform(0, 1)
gen exit_threshold_b = runiform(0, 1)
gen exit_flag = 0
replace exit_flag = 1 if exit_threshold_a < misalignment_a & exit_threshold_b < misalignment_b

/* ---------- ENTRY ---------- */

quietly count if exit_flag          // <--- 1. how many vacancies?
if r(N) {                           // <--- 2. run the block only if r(N)>0
    quietly {
        preserve
        keep if exit_flag
        replace phi_a = .
        replace phi_b = .

        /* acceptance–rejection loop */
        gen join      = 0
		gen join_threshold_a = 0
		gen join_threshold_b = 0
        while sum(join==0) {
            replace phi_a       = rchi2(phi_std_a)        if join==0
            replace phi_b       = rchi2(phi_std_b)        if join==0
			replace preferred_freq_a = exp(phi_a) / ($denom + exp(phi_a))
			replace preferred_freq_b = exp(phi_b) / ($denom + exp(phi_b))
            replace misalignment_a = (attraction_a - preferred_freq_a) ^ 2 if join==0
			replace misalignment_b = (attraction_b - preferred_freq_b) ^ 2 if join==0
			replace join_threshold_a = runiform(0, 1) 
			replace join_threshold_b = runiform(0, 1) 
            replace join      = 1 if join_threshold_a > misalignment_a & join_threshold_b > misalignment_b & join== 0
			
        }
        replace util_c_a = .
        replace util_c_b = .

        drop join  
        tempfile newhires
        save `newhires'

        restore
    }

    /* ---------- CLEAN UP ---------- */
    drop if exit_flag
    append using `newhires'
}

cap drop n_exit_tier
bys phi_std_helper TMT: egen n_exit_tier = total(exit_flag)

/* roster back to full size & tidy */
replace exit_flag = 0
drop exit_flag preferred_freq* misalignment* *threshold* attraction*

tempfile `firm'_`time'
sa ``firm'_`time''
}
}

clear all
forval firm = 1 / $pop_firm {
foreach time in $halftime $maxtime {
	append using ``firm'_`time''
}
}

sa "$data/P2x oi$OI_helper data", replace