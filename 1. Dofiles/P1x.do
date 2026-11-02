clear all
set seed 123

foreach levels in $levels {
forval firm = 1 / $pop_firm {

clear

set obs $obs

g firm = `firm'
g panel = _n
g norm_strength =  trunc((panel - 1)/ $pop_ind) / 2
bys norm_strength: g id = _n
g TMT = 0
replace TMT = 1 if id <= $TMT_pop  

g OI = `levels' / 100
g OI_helper = `levels' 
g cost = 1



g noise = rnormal(0, $std)

g util_c = OI * 0.5 * norm_strength - cost + noise 			if TMT == 0
replace util_c = norm_strength - cost + noise			if TMT == 1

g conform = 0
replace conform = 1 if util_c > 0
bys norm_strength TMT: egen conform_freq = mean(conform)

g payoff = 0
replace payoff = norm_strength - cost + noise if conform == 1

tempfile `firm'_`levels'
sa ``firm'_`levels''
}
}

clear all
foreach levels in $levels {
forval firm = 1 / $pop_firm {

append using ``firm'_`levels''

}
}

sa "$data/P1x data", replace 