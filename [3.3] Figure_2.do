****************************************************************************************************
*** Intro:  This do-file is used for decomposition of employment
****************************************************************************************************

*** Housekeeping

clear all
capture log close
set more off

global root         = "/Users/jdc364admin/Dropbox/STEG"
global root         = "/Users/julieta.caunedo/Dropbox/STEG"
global replication         = "$root/Replication_package"
global rawdata      = "$root/Rawdata"
global workingdata  = "$root/Workingdata"
global output  = "$replication/Workingdata"
global tables       = "$replication/Tables"
global figures      = "$replication/Figures"



***************************************************************************************
*** Employment Share by Industry
***************************************************************************************

foreach k in 1 2 3{

	use "$workingdata/ILO_Cleaned_by_Occ_Ind_`k'.dta", clear
	egen industry_id = group(industry)
	drop industry
	ren industry_id industry
	sum industry, d
	local maxind = r(max)

	keep country year occupation industry employment
	reshape wide employment, i(country year occupation) j(industry)
	drop if occupation == 0
	forv i = 1(1)`maxind'{
		replace employment`i' = 0 if employment`i' == .
	}
	reshape long employment, i(country year occupation) j(industry)
	bys country year: egen emp_sum = sum(employment)
	bys country year occupation: egen emp_sum_occ = sum(employment)
	bys country year industry: egen emp_sum_ind = sum(employment)
	gen emp_share_ind = emp_sum_ind/emp_sum
	gen emp_share_occ = emp_sum_occ/emp_sum
	gen emp_share = employment/emp_sum_ind

	egen ind_no = group(industry)
	egen country_no = group(country)
	egen occ_no = group(occupation)
	gen ID1 = country_no * 100 + ind_no
	gen ID2 = country_no * 10 + occ_no
	gen ID3 = country_no * 1000 + ind_no * 10 + occ_no

	preserve
	keep ID2 year emp_share_occ
	duplicates drop ID2 year, force
	xtset ID2 year
	gen eti = emp_share_occ
	gen d_eti = emp_share_occ - L.emp_share_occ
	tempfile occ_change
	save `occ_change', replace
	restore

	preserve
	keep ID1 year emp_share_ind
	duplicates drop ID1 year, force
	xtset ID1 year
	gen nth_bar = (emp_share_ind + L.emp_share_ind)/2
	gen d_nth   = emp_share_ind - L.emp_share_ind
	tempfile ind_change
	save `ind_change', replace
	restore

	xtset ID3 year
	gen etih_bar   = (emp_share + L.emp_share)/2
	gen d_etih     = emp_share - L.emp_share
	merge m:1 ID1 year using `ind_change', nogen
	merge m:1 ID2 year using `occ_change', nogen

	gen within_h  = nth_bar * d_etih 
	gen between_h = d_nth * etih_bar

	bys occupation country year: egen within = sum(within_h)
	bys occupation country year: egen between = sum(between_h)
	duplicates drop occupation country year, force

	statsby within=_b[d_eti], by(country) saving("$output/decomposition_within_employment_byind.dta", replace): reg within d_eti, nocons
	statsby between=_b[d_eti], by(country) saving("$output/decomposition_between_employment_byind.dta", replace): reg between d_eti, nocons


	use "$output/decomposition_within_employment_byind.dta", clear
	merge 1:1 country using "$output/decomposition_between_employment_byind.dta", nogen
	merge 1:1 country using "$workingdata/WDI_Cleaned.dta", keep(3) nogen
	gen lngdppc = log(GDPPC2015)
	sort lngdppc
	preserve
	keep country within between  
	keep if within != .
	export delim using "$tables/decomposition_employmentshare_byind.csv", replace
	restore

	tw scatter within lngdppc, mc(red) msiz(1) mlabc(blue) mlabs(2) mlabp(9) mlabel(countrycode) mlabsize(medium)  || ///
	    lfit within lngdppc, lc(red) ///
	    xtitle("GDP Per Capita",size(large)) xlab(7(1)11,labsize(large) nogrid) ///
		ytitle("",size(large)) ylab(0.7(.1)1.1, labsize(large) nogrid) ysc(r(0.7 1.1)) ytick(0.7(0.1)1.1) ///
		legend(off) graphregion(col(white)) ///
		xsize(5) ysize(4)
	gr export "$figures/Decomposition_Within_GDP_PC_byind_`k'.eps", replace
	
		tw scatter within lngdppc, mc(gs5) msiz(1) mlabc(gs1) mlabs(2) mlabp(9) mlabel(countrycode) mlabsize(medium)  || ///
	    lfit within lngdppc, lc(gs2) ///
	    xtitle("GDP Per Capita",size(large)) xlab(7(1)11,labsize(large) nogrid) ///
		ytitle("",size(large)) ylab(0.7(.1)1.1, labsize(large) nogrid) ysc(r(0.7 1.1)) ytick(0.7(0.1)1.1) ///
		legend(off) graphregion(col(white)) ///
		xsize(5) ysize(4)
	gr export "$figures/Decomposition_Within_GDP_PC_byind_`k'_bw.eps", replace
}

