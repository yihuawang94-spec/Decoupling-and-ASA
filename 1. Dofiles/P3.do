clear all
set seed 123

forval firm = 1 / $pop_firm {

clear

set obs $obs

g firm = `firm'
g panel = _n
g norm_strength = $norm_strength_1
g norm_strength_eff = norm_strength

g phi_std = $phi_1
replace phi_std = $phi_2 if _n > 1 * $pop_ind
replace phi_std = $phi_3 if _n > 2 * $pop_ind
replace phi_std = $phi_4 if _n > 3 * $pop_ind

g phi_std_helper = 1
replace phi_std_helper = 2 if _n > 1 * $pop_ind
replace phi_std_helper = 3 if _n > 2 * $pop_ind
replace phi_std_helper = 4 if _n > 3 * $pop_ind

bys phi_std_helper: g id = _n
g TMT = 0
replace TMT = 1 if id <= $TMT_pop 

g OI = $OI_lvl
g OI_helper = $OI_helper
g phi = rchi2(phi_std)        

g noise = rnormal(0, $std)

g util_c = OI * norm_strength_eff - $cost + noise + phi if TMT == 0
replace util_c = norm_strength_eff - $cost + noise + phi if TMT == 1

g util = 0
replace util = util_c if util_c > 0

g conform = 0
replace conform = 1 if util_c > 0
bys phi_std_helper TMT: egen conform_freq = mean(conform) 

g payoff = 0
replace payoff = norm_strength_eff - $cost + noise if conform == 1

g time = 0

tempfile `firm'_0
sa ``firm'_0'
}


forval firm = 1 / $pop_firm {
forval time = 1 / $maxtime {
clear

loc j = `time' - 1
use ``firm'_`j''

replace norm_strength_eff = $norm_strength_2 if time > $halftime
replace phi_std = $phi_1 if time > $halftime

drop conform_freq* 

replace noise = rnormal(0, $std)

replace util_c = OI * norm_strength_eff - $cost + noise + phi if TMT == 0
replace util_c = norm_strength_eff - $cost + noise + phi if TMT == 1 

replace util = 0
replace util = util_c if util_c > 0

replace conform = 0
replace conform = 1 if util_c > 0
bys phi_std_helper TMT: egen conform_freq = mean(conform)
bys phi_std_helper: egen conform_freq2 = mean(conform)
g conform_freq31 = conform_freq if TMT == 1
bys phi_std_helper: egen conform_freq31x = max(conform_freq31)
g conform_freq32 = conform_freq if TMT == 0
bys phi_std_helper: egen conform_freq32x = max(conform_freq32)
g attraction = conform_freq31x * conform_freq32x

replace payoff = 0
replace payoff = norm_strength_eff - $cost + noise if conform == 1

replace time = `time'

/* ---------- EXIT ---------- */
gen preferred_freq = exp(phi) / ($denom + exp(phi))
gen misalignment = (attraction - preferred_freq) ^ 2 
gen exit_threshold = runiform(0, 1)
gen exit_threshold2 = runiform(0, 1) 
gen exit_flag = 0
replace exit_flag = 1 if exit_threshold < misalignment

/* ---------- ENTRY ---------- */

quietly count if exit_flag          // <--- 1. how many vacancies?
if r(N) {                           // <--- 2. run the block only if r(N)>0
    quietly {
        preserve
        keep if exit_flag
        replace phi = .

        /* acceptance–rejection loop */
        gen join      = 0
		gen join_threshold = 0
        while sum(join==0) {
            replace phi       = rchi2(phi_std)        if join==0
			replace preferred_freq = exp(phi) / ($denom + exp(phi))
            replace misalignment = (attraction - preferred_freq) ^ 2 if join==0
			replace join_threshold = runiform(0, 1) 
            replace join      = 1 if misalignment < join_threshold & join==0 
			
        }
        replace util_c = .

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
drop exit_flag preferred_freq misalignment *threshold* attraction

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

sa "$data/P3 oi$OI_helper data", replace