	***************************************************************************************
*** Intro:  This do-file is used for exploring decomposition of task content
***************************************************************************************

*** Housekeeping

clear all
capture log close
set more off

global root         = "/Users/julieta.caunedo/Dropbox/STEG"
*global root         = "/Users/jdc364admin/Dropbox/STEG"
global rawdata      = "$root/Rawdata"
global replication         = "$root/Replication_package"
global workingdata  = "$root/Workingdata"
global output  = "$replication/Workingdata"
global tables       = "$replication/Tables"
global figures      = "$replication/Figures"
********************************************************************************
*** Decomposition
********************************************************************************

********************************************************************************
*** Decomposition Exercise 1: using O*NET as the benchmark
*

    local k="_Predicted_USbmk_occ" 

	use "$workingdata/STEP_PIAAC_occupation_measure`k'_raw_noag.dta", clear
	merge m:1 occupation using "$workingdata/O_NET_occupation_measure_raw.dta", nogen keep(3)
	merge 1:m country occupation using "$workingdata/ILO_Cleaned_by_Occ_2015_Imputed_noag.dta", nogen keep(3)
	drop if occupation == 0 | occupation==6 | country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"

	merge m:1 country using "$workingdata/WDI_Cleaned.dta", nogen
    drop if country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"
		
		

	preserve
	collapse (mean) NRA NRI RC RM NRM [pweight = employshare], by(country)
	tempfile temp
	save `temp', replace
	restore

	collapse (mean) NRA_onet NRI_onet RC_onet RM_onet NRM_onet [pweight = employshare], by(country)
	foreach i in NRA NRI RC RM NRM{
		ren `i'_onet `i'_fixed
	}

	merge 1:1 country using `temp', nogen keep(3)

	merge 1:1 country using "$workingdata/WDI_Cleaned.dta", nogen
    drop if country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"

	
	gen GDPPC = log(GDPPC2015)

	foreach i in NRA NRI RC RM {
reg `i' GDPPC
local corr0: display %5.2f _b[GDPPC]
local std0: display %5.1f _b[GDPPC]/_se[GDPPC]
reg `i'_fixed GDPPC
local corr0_fixed: display %5.2f _b[GDPPC]
local std0_fixed: display %5.1f _b[GDPPC]/_se[GDPPC]
		tw scatter `i' GDPPC, mc(red) msiz(1) mlabc(red) mlabs(2) mlabp(9) || ///
			scatter `i'_fixed GDPPC, m(smx) mc(blue) msiz(2) mlabc(blue) mlabs(2) mlabp(9) || ///
			lfit `i' GDPPC, lc(black) || ///
			lfit `i'_fixed GDPPC, lp(dahs_dot) lc(black) lp(dash) ///
			ytitle("Country Specific Task Measure",size(large)) ysc(r(-8 1)) ytick(-8(2)1) ///
			xtitle("GDP Per Capita",size(large)) xlab(7(1)11,labsize(large) nogrid) ylab(-8(2)1, nogrid labsize(large) ) ///
			note(beta=`corr0' t-stat=`std0'    O*NET beta=`corr0_fixed' t-stat=`std0_fixed', position(7) ring(0) size(medlarge)) legend(off) ///
            graphregion(col(white)) ///
		    xsize(5) ysize(4) 
		gr export "$figures/`i'_`i'onet_gdppc`k'_raw_noag.eps", replace
	}
	
	*			legend(order(1 "Country Specific Measure" 2 "O*NET Measure" 3 "Country Specific Measure" 4 "O*NET Measure") ///

reg NRM GDPPC
local corr0: display %5.2f _b[GDPPC]
local std0: display %5.1f _b[GDPPC]/_se[GDPPC]
reg NRM_fixed GDPPC
local corr0_fixed: display %5.2f _b[GDPPC]
local std0_fixed: display %5.1f _b[GDPPC]/_se[GDPPC]
	
	tw scatter NRM GDPPC, mc(red) msiz(1) mlabc(red) mlabs(2) mlabp(9) || ///
			scatter NRM_fixed GDPPC, m(smx) mc(blue) msiz(2) mlabc(blue) mlabs(2) mlabp(9) || ///
			lfit NRM GDPPC, lc(black) || ///
			lfit NRM_fixed GDPPC, lp(dahs_dot) lc(black) lp(dash) ///
			ytitle("Country Specific Task Measure",size(large)) ysc(r(-8 1)) ytick(-8(2)1) ///
			xtitle("GDP Per Capita",size(large)) xlab(7(1)11,labsize(large) nogrid) ylab(-8(2)1, nogrid labsize(large) ) ///
			note(beta=`corr0' t-stat=`std0'    O*NET beta=`corr0_fixed' t-stat=`std0_fixed', position(7) ring(0) size(medlarge)) legend(order(1 "Country Specific Measure" 2 "O*NET Measure" 3 "Country Specific Measure" 4 "O*NET Measure") ///
			row(2)) graphregion(col(white)) ///
		    xsize(5) ysize(4)
		gr export "$figures/NRM_NRMonet_gdppc`k'_raw_noag.eps", replace


		********Black and White******
		foreach i in NRA NRI RC RM {
reg `i' GDPPC
local corr0: display %5.2f _b[GDPPC]
local std0: display %5.1f _b[GDPPC]/_se[GDPPC]
reg `i'_fixed GDPPC
local corr0_fixed: display %5.2f _b[GDPPC]
local std0_fixed: display %5.1f _b[GDPPC]/_se[GDPPC]
		tw scatter `i' GDPPC, mc(gs1) msiz(1) mlabc(gs1) mlabs(2) mlabp(9) || ///
			scatter `i'_fixed GDPPC, m(smx) mc(gs5) msiz(2) mlabc(gs5) mlabs(2) mlabp(9) || ///
			lfit `i' GDPPC, lc(black) || ///
			lfit `i'_fixed GDPPC, lp(dahs_dot) lc(black) lp(dash) ///
			ytitle("Country Specific Task Measure",size(large)) ysc(r(-8 1)) ytick(-8(2)1) ///
			xtitle("GDP Per Capita",size(large)) xlab(7(1)11,labsize(large) nogrid) ylab(-8(2)1, nogrid labsize(large) ) ///
			note(beta=`corr0' t-stat=`std0'    O*NET beta=`corr0_fixed' t-stat=`std0_fixed', position(7) ring(0) size(medlarge)) legend(off) ///
            graphregion(col(white)) ///
		    xsize(5) ysize(4) 
		gr export "$figures/`i'_`i'onet_gdppc`k'_raw_noag_bw.eps", replace
	}
	
	*			legend(order(1 "Country Specific Measure" 2 "O*NET Measure" 3 "Country Specific Measure" 4 "O*NET Measure") ///

reg NRM GDPPC
local corr0: display %5.2f _b[GDPPC]
local std0: display %5.1f _b[GDPPC]/_se[GDPPC]
reg NRM_fixed GDPPC
local corr0_fixed: display %5.2f _b[GDPPC]
local std0_fixed: display %5.1f _b[GDPPC]/_se[GDPPC]
	
	tw scatter NRM GDPPC, mc(gs1) msiz(1) mlabc(gs1) mlabs(2) mlabp(9) || ///
			scatter NRM_fixed GDPPC, m(smx) mc(gs5) msiz(2) mlabc(gs5) mlabs(2) mlabp(9) || ///
			lfit NRM GDPPC, lc(black) || ///
			lfit NRM_fixed GDPPC, lp(dahs_dot) lc(black) lp(dash) ///
			ytitle("Country Specific Task Measure",size(large)) ysc(r(-8 1)) ytick(-8(2)1) ///
			xtitle("GDP Per Capita",size(large)) xlab(7(1)11,labsize(large) nogrid) ylab(-8(2)1, nogrid labsize(large) ) ///
			note(beta=`corr0' t-stat=`std0'    O*NET beta=`corr0_fixed' t-stat=`std0_fixed', position(7) ring(0) size(medlarge)) legend(order(1 "Country Specific Measure" 2 "O*NET Measure" 3 "Country Specific Measure" 4 "O*NET Measure") ///
			row(2)) graphregion(col(white)) ///
		    xsize(5) ysize(4)
		gr export "$figures/NRM_NRMonet_gdppc`k'_raw_noag_bw.eps", replace

