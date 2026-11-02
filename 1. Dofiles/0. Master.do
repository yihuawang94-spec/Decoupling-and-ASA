*******************************************************************************
* Identity, Normative Sorting, and the Persistence of Organizational
* Responses to Social Norms
*
* Master do-file: reproduces every simulation figure in the paper.
* Run from the project folder (the one containing "1. Dofiles", "2. Data" and
* "3. Output") or from "1. Dofiles" itself, e.g.
*     cd "C:/Users/you/Decoupling-and-ASA"
*     do "1. Dofiles/0. Master.do"
*******************************************************************************

clear all
set more off

* Find the project folder. This works whether Stata's working directory is
* the project folder or the "1. Dofiles" folder (e.g. after double-clicking
* this file).
glo maindirectory "`c(pwd)'"
cap confirm file "$maindirectory/1. Dofiles/0. Master.do"
if _rc {
	qui cd ..
	glo maindirectory "`c(pwd)'"
	confirm file "$maindirectory/1. Dofiles/0. Master.do"
}
glo dofiles       "$maindirectory/1. Dofiles"
glo data          "$maindirectory/2. Data"
glo output        "$maindirectory/3. Output"

foreach d in "$data" "$output" "$output/Supplementary" {
	cap mkdir "`d'"
}

*** Graph styling (user-written packages from SSC; installed if missing) ***
cap which grstyle
if _rc ssc install grstyle
cap which colorpalette
if _rc ssc install palettes
cap findfile lcolrspace.mlib
if _rc ssc install colrspace

set scheme s2color
grstyle init
grstyle set horizontal // set tick labels horizontal
grstyle set compact // overall design compact
grstyle set size medium: subheading axis_title // subtitle and axis title set to small
grstyle set size vsmall: small_body // margin around notes
grstyle set legend 6 //legend position on 6 o'clock, removes box  , nobox
grstyle set linewidth thin: major_grid // set grid line thickness to thin
grstyle set linewidth thin: tick // set tick thickness to thin
grstyle set linewidth thin: axisline // set axislines thickness to thin
grstyle set linewidth vthin: xyline // reference line at 0

grstyle color background white // set overall background to white black*.05
grstyle set color black: tick tick_label // set tick and tick label color
grstyle set color white: plotregion plotregion_line //set plot area background color
grstyle set color black*.025:  major_grid // set axis and grid line color
grstyle set color black: axisline  // set axis and grid line color
grstyle set color black*.7: small_body // set note color
grstyle set color white*.08, opacity(0): pbarline // graph bar outline transparent
grstyle gsize axis_title_gap tiny

set seed 123

*** Population and grid (Appendix A.1) ***
glo pop_ind			= 100		// individuals per firm
glo pop_firm		= 1000		// firms per environment (set to 100 for a quick test run)
glo levels			= "0 10 20 30 40 50 60 70 80 90 100"	// rank-and-file identification x 100
glo cost_type		= "100 200"	// rank-and-file cost of conformity x 100
glo TMT_pop		 	= 20		// corporate leaders per firm
glo std				= 1			// s.d. of idiosyncratic shock

*******************************************************************************
*** Part 1: baseline model (Section 3, Appendix A.1, Figure 2) ***
*******************************************************************************
clear all

foreach cost in $cost_type {

glo str_lvl			= 11
glo obs				= $str_lvl * $pop_ind
glo cost			= `cost'
qui run "$dofiles/P1.do"			// scenarios (ii) and (iii)

}
qui run "$dofiles/P1 analysis.do"	// Figures 2aii, 2bii, 2aiii, 2biii

qui run "$dofiles/P1x.do"			// scenario (i)
qui run "$dofiles/P1x analysis.do"	// Figures 2ai, 2bi

*******************************************************************************
*** Parts 2 and 3: normative sorting and norm erosion ***
*** (Sections 4 and 5, Appendices A.2 and A.3, Figure 4) ***
*******************************************************************************
glo cost 			= 1
glo denom			= 5			// denominator in preferred conformity, exp(phi) / (denom + exp(phi))
glo phi_std			= 4			// number of belief environments
glo phi_1			= 0.1		// nu_phi: degrees of freedom of the chi-squared belief distribution
glo phi_2			= 0.5
glo phi_3			= 1
glo phi_4		 	= 2
glo obs				= $phi_std * $pop_ind
glo maxtime			= 20		// periods 0-20
glo halftime		= 10		// norm erodes after period 10

* Weak normative pressure (Figure 4, column a)
foreach levels in $levels {

clear all

glo norm_strength_1	= 1.2
glo norm_strength_2 = 0

glo OI_lvl		 	= `levels' / 100
glo OI_helper		= `levels'

qui run "$dofiles/P2.do"

}

qui run "$dofiles/P2 analysis.do"	// Figures 4ai, 4aii, 4aiii

* Strong normative pressure (Figure 4, column b)
foreach levels in $levels {

clear all

glo norm_strength_1	= 2
glo norm_strength_2 = 0

glo OI_lvl		 	= `levels' / 100
glo OI_helper		= `levels'

qui run "$dofiles/P3.do"

}

qui run "$dofiles/P3 analysis.do"	// Figures 4bi, 4bii, 4biii
