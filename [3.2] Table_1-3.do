***************************************************************************************
*** Intro:  This do-file is used for comparing Task Content and Economic Statistics
***************************************************************************************

*** Housekeeping

clear all
capture log close
set more off
*

global root         = "/Users/julieta.caunedo/Dropbox/STEG"
*global root         = "/Users/jdc364admin/Dropbox/STEG"
global rawdata      = "$root/Rawdata"
global replication         = "$root/Replication_package"
global workingdata  = "$root/Workingdata"
global output  = "$replication/Workingdata"
global tables       = "$replication/Tables"
global figures      = "$replication/Figures"

***************************************************************************************
*** Country Ranking
*
use "$workingdata/WDI_Cleaned_All.dta", clear
drop if country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"

keep if year == 2015
sum GDPPC, d
gen rank = 1 if GDPPC <= r(p25)
replace rank = 2 if GDPPC <= r(p75) & GDPPC > r(p25)
replace rank = 3 if GDPPC > r(p75) & GDPPC != .
keep country rank
tempfile rank
save `rank', replace

*
use "$workingdata/WDI_Cleaned_All.dta", clear
drop if country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"
keep country countrycode
duplicates drop country countrycode, force 
tempfile countrycode
save `countrycode', replace

*
***************************************************************************************
*** Task Measures and Other Statistics
**
foreach k in "_Predicted_USbmk_occ" {
	*
	use "$workingdata/STEP_PIAAC_occupation_measure_by_country`k'_raw_noag.dta", clear
	merge 1:1 country using "$workingdata/STEP_PIAAC_occupation_measure_by_country_2006`k'_raw_noag.dta", nogen
	merge 1:1 country using `rank', keep(3) nogen
	merge 1:1 country using "$workingdata/WDI_Cleaned.dta", nogen
    drop if country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"
	
	gen GDP           = log(GDP2015)
	gen GDPPC         = log(GDPPC2015)
	gen GDPPC06       = log(GDPPC2006)
	gen Primary       = Primary2015
	gen PostSecondary = Post_secondary2015
*
/*
**TABLE 1. need to append them

eststo clear
	foreach i in NRA NRI RC RM NRM CU{
		eststo: reg `i' GDPPC
		esttab _all using "${tables}/Task_Content_GDPPC_`k'_raw_noag.tex", noconstant se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and GDP Per Capita") nomtitles ///
		keep(GDPPC) order(GDPPC) coeflabels(GDPPC "GDP Per Capita") ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" "CU", pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}


	eststo clear
	foreach i in NRA NRI RC RM NRM CU{
		eststo: reg `i' GDPPC PostSecondary
		esttab _all using "${tables}/Task_Content_GDPPC_Educ`k'_raw_noag.tex", noconstant se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and GDP Per Capita") nomtitles ///
		keep(GDPPC PostSecondary) order(GDPPC PostSecondary) coeflabels(GDPPC "GDP Per Capita" PostSecondary "Post Secondary Education") ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" "CU", pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}

	
	eststo clear
	foreach i in NRA NRI RC RM NRM CU{
		eststo: reg `i' GDPPC if PostSecondary != .
		esttab _all using "${tables}/Task_Content_GDPPC_withEduc`k'_raw_noag.tex", noconstant se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and GDP Per Capita") nomtitles ///
		keep(GDPPC) order(GDPPC) coeflabels(GDPPC "GDP Per Capita") ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" "CU", pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
*/

*
***Table 3, MISSING ELIMINATE THE R^2

	gen GDPGR = (GDP2015/GDP2006)^(1/9)-1
	gen IndustryShareGR = (Industry2015/Industry2006)^(1/9)-1
	gen ServiceShareGR = (Service2015/Service2006)^(1/9)-1
	replace IndustryShareGR = . if country == "Ghana"
	replace ServiceShareGR = . if country == "Ghana"
	g one=1
	egen constant=mean(one)
	eststo clear
	foreach i in NRA NRI RC RM NRM CU{
		*gen `i'_Diff = (`i'/`i'_06)^(1/9)-1
		gen `i'_Diff = (`i'-`i'_06)
		reg `i'_Diff constant
		reg `i'_06 constant

		foreach j in GDPPC{
			

			eststo: reg `i'_Diff `j'06

		}
		
		}
		
	esttab _all using "$tables/Decomposition_GDPPC_Diff_`k'_raw_noag.tex", noconstant se star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
				title("Task Content Change and GDP Per Capita") nomtitles ///
				keep(GDPPC06 _cons) order(GDPPC06 _cons) coeflabels(GDPPC "log(GDP Per Capita)" _cons "Intercept") ///
				mgroups("NRA" "NRI" "RC" "RM" "NRM" "CU", pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
				*/

				
    ******Top panel Table 3
	su *_Diff
	
	
}
