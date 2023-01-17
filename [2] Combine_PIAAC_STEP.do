
***************************************************************************************
*** Measure Construction
***************************************************************************************
use "$workingdata/WDI_Cleaned_All.dta", clear
drop if country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"

keep country countrycode Post_secondary GDP GDPPC year
keep if year==2015
replace GDP=log(GDP)

replace GDPPC=log(GDPPC)


duplicates drop country countrycode, force 
sort GDPPC
tempfile countrycode
save `countrycode', replace

***************************************************************************************
*** PIAAC and STEP Measures
use "$workingdata/PIAAC_occupation_measure_raw.dta", clear
append using "$workingdata/STEP_occupation_measure.dta"

drop if occupation==6

foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER COMP {
	summarize `i' [aw  = weight] if country=="USA"
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU   = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw  = weight] if country=="USA"
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

collapse (mean) NRA NRI RC RM NRM CU [aw  = weight], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_USbmk_raw_noag.dta", replace

preserve
merge 1:1 country occupation using "$workingdata/ILO_Cleaned_by_Occ_2015_Imputed_noag.dta", nogen keep(3)
collapse (mean) NRA NRI RC RM NRM CU [pweight = employshare], by(country SOURCE)
save "$workingdata/STEP_PIAAC_occupation_measure_by_country_USbmk_raw_noag.dta", replace
restore

preserve
merge 1:1 country occupation using "$workingdata/ILO_Cleaned_by_Occ_2006_Imputed_noag.dta", nogen keep(3)
collapse (mean) NRA_06 = NRA NRI_06 = NRI RC_06 = RC RM_06 = RM NRM_06 = NRM CU_06 = CU [pweight = employshare], by(country SOURCE)
save "$workingdata/STEP_PIAAC_occupation_measure_by_country_2006_USbmk_raw_noag.dta", replace
restore
*/

***************************************************************************************
*** PIAAC and STEP Measures with STEP from Prediction

use "$workingdata/PIAAC_occupation_measure_raw.dta", clear
append using "$workingdata/STEP_occupation_measure.dta"

drop if occupation==6

merge m:1 country using `countrycode', keep(3) nogen

eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP if SOURCE == "PIAAC" [aw = weight]
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}

esttab _all using "${tables}/task_content_computers_noag.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using PIAAC") nomtitles ///
keep(COMP) order(COMP) coeflabels(COMP "Computers") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

eststo clear
g interact=COMP*GDPPC
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP interact interact if SOURCE == "PIAAC" [aw = weight]
	predict `i'_Temp if SOURCE == "STEP", xb
	g `i'_gdp_control = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp 
}

esttab _all using "${tables}/task_content_computers_noag_GDPcontrol.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using PIAAC, GDP control") nomtitles ///
keep(COMP interact) order(COMP interact) coeflabels(COMP "Computers" interact "Interaction") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))


foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER COMP {
	summarize `i' [aw  = weight] if country=="USA"
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP


keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw  = weight] if country=="USA"
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

collapse (mean) NRA NRI RC RM NRM CU [aw  = weight], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_raw_noag.dta", replace
*/
*
**************Correlations raw_step and predicted step

use "$workingdata/STEP_PIAAC_occupation_measure_USbmk_raw_noag.dta", clear
foreach i in NRA NRI RC RM NRM {
	ren `i' `i'_raw
}
merge 1:1 country occupation SOURCE using "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_raw_noag.dta"

eststo clear
foreach i in NRA NRI RC RM NRM {
	eststo: reg `i' `i'_raw if SOURCE=="STEP"
}
esttab _all using "${tables}/rawSTEP_vs_predSTEP.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content, STEP") nomtitles ///
mgroups("NRA" "NRI" "RC" "RM" "NRM", pattern(1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

******************
*Prediction at the occupation level
*******************
use "$workingdata/PIAAC_occupation_measure_raw.dta", clear
append using "$workingdata/STEP_occupation_measure.dta"
*_computer

drop if occupation==6


g w_occ=1
collapse (mean) READ THINK PERSON GUIDE STRUC CONTRO OPER COMP (sum) w_occ [aw  = weight], by(country occupation SOURCE)
bys country: egen total_count=total(w_occ)
g weights_occ=w_occ/total_count
su weights_occ


merge m:1 country using `countrycode', keep(3) nogen



eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP 
	
}

esttab _all using "${tables}/task_content_computers_occ_noag.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using STEP") nomtitles ///
keep(COMP interact) order(COMP interact) coeflabels(COMP "Computers" interact "Computers#GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))


g dummy_rich=1 if GDPPC>9.499
replace dummy_rich=0 if dummy_rich==.
g interact=COMP*GDPPC
g interact_edu=COMP*Post_secondary
g interact_dum=COMP*dummy_rich

eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP interact 
}

esttab _all using "${tables}/task_content_computers_occ_noag_GDPcontrol.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using STEP") nomtitles ///
keep(COMP interact) order(COMP interact) coeflabels(COMP "Computers" interact "Computers#GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))



eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP interact interact_edu
}

esttab _all using "${tables}/task_content_computers_occ_noag_educontrol.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using STEP") nomtitles ///
keep(COMP interact interact_edu) order(COMP interact) coeflabels(COMP "Computers" interact "Computers#GDP" interact_edu "Computers#Educ") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

/*
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP GDPPC 
	
}

esttab _all using "${tables}/task_content_computers_occ_noag_GDPcontrol2.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using STEP") nomtitles ///
keep(COMP GDPPC) order(COMP GDPPC) coeflabels(COMP "Computers" GDPPC"GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP GDPPC interact 
	
}

esttab _all using "${tables}/task_content_computers_occ_noag_GDPcontrol3.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using STEP") nomtitles ///
keep(COMP GDPPC interact) order(COMP GDPPC interact) coeflabels(COMP "Computers" GDPPC "GDP" interact "Computers#GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
*/

eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	*scatter `i' `i'_Temp if SOURCE=="STEP", name(TASK_occ_`i')
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	
}

esttab _all using "${tables}/task_content_computers_occ_noag_piaac.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using PIAAC") nomtitles ///
keep(COMP) order(COMP) coeflabels(COMP "Computers") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

eststo clear
forvalues s=1(1)5{
	eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP  if occupation==`s' & SOURCE == "PIAAC"
	
}
esttab _all using "${tables}/task_content_computers_occ_noag_piaac_`s'.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using STEP") nomtitles ///
keep(COMP interact) order(COMP interact) coeflabels(COMP "Computers" interact "Computers#GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
}
forvalues s=7(1)9{
	eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP  if occupation==`s' & SOURCE == "PIAAC"
	
}
esttab _all using "${tables}/task_content_computers_occ_noag_piaac_`s'.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using STEP") nomtitles ///
keep(COMP interact) order(COMP interact) coeflabels(COMP "Computers" interact "Computers#GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
}

eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP c.COMP#c.GDPPC if SOURCE == "PIAAC" 
	margins 
	estimates store m`i'
	*predict `i'_Temp if SOURCE == "STEP", xb
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	*scatter `i' `i'_Temp if SOURCE=="STEP", name(TASK_occ_`i')
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	
}

esttab _all using "${tables}/task_content_computers_occ_noag_piaac_GDPcontrol.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using PIAAC") nomtitles ///
keep(COMP interact) order(COMP interact) coeflabels(COMP "Computers" interact "Computers*GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))


eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP interact_dum if SOURCE == "PIAAC" 
}

esttab _all using "${tables}/task_content_computers_occ_noag_piaac_GDPcontrol_dum.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using PIAAC") nomtitles ///
keep(COMP interact_dum) order(COMP interact_dum) coeflabels(COMP "Computers" interact "Computers#GDPdummy") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))



eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP interact interact_edu if SOURCE == "PIAAC" 
	*predict `i'_Temp if SOURCE == "STEP", xb
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	*scatter `i' `i'_Temp if SOURCE=="STEP", name(TASK_occ_`i')
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	
}

esttab _all using "${tables}/task_content_computers_occ_noag_piaac_educontrol.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using PIAAC") nomtitles ///
keep(COMP interact interact_edu) order(COMP interact) coeflabels(COMP "Computers" interact "Computers*GDP" interact_edu "Computers#Educ") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))


*
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' COMP c.COMP#c.GDPPC GDPPC if SOURCE == "PIAAC" 
	margins
	lrtest . m`i', stats
	*predict `i'_Temp if SOURCE == "STEP", xb
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	*scatter `i' `i'_Temp if SOURCE=="STEP", name(TASK_occ_`i')
	*replace `i' = `i'_Temp if SOURCE == "STEP"
	*drop `i'_Temp
	
}

esttab _all using "${tables}/task_content_computers_occ_noag_piaac_GDPcontrol3.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content and Computers using PIAAC") nomtitles ///
keep(COMP interact GDPPC) order(COMP interact GDPPC) coeflabels(COMP "Computers" interact "Computers*GDP" GDPPC "GDP") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
*/



eststo clear

foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' `i'_Temp if SOURCE == "STEP" 
	
}

esttab _all using "${tables}/task_content_computers_STEP_POST_occ_noag.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content Predicted (.Temp) and Rawdata STEP") nomtitles ///
keep(READ_Temp THINK_Temp PERSON_Temp GUIDE_Temp STRUC_Temp CONTRO_Temp OPER_Temp) ///*order(COMP) coeflabels(COMP "Computers") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

eststo clear
egen countryg=group(country)
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
	eststo: reg `i' `i'_Temp i.countryg if SOURCE == "STEP" 
	
}

esttab _all using "${tables}/task_content_computers_STEP_POST_occ_country_noag.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace title("Task Content Predicted (.Temp) and Rawdata STEP") nomtitles ///
keep(READ_Temp THINK_Temp PERSON_Temp GUIDE_Temp STRUC_Temp CONTRO_Temp OPER_Temp) ///*order(COMP) coeflabels(COMP "Computers") ///
mgroups("READ" "THINK" "PERSON" "GUIDE" "STRUC" "CONTRO" "OPER", pattern(1 1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

*/
*
	preserve
	gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU
		esttab _all using "${tables}/AG_Task_Content_computer_noag.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers") nomtitles ///
		keep(CU ) order(CU ) coeflabels(CU "Computers" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU GDPPC
		esttab _all using "${tables}/AG_Task_Content_computer_noag_GDPcontrol2.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers, GDP control") nomtitles ///
		keep(CU GDPPC ) order( CU GDPPC ) coeflabels(CU "Computer" GDPPC "GDP per capita" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	g interaction=GDPPC*CU
	g interaction_edu=Post_secondary*CU
	
	/*
	corr Post_secondary GDPPC CU  if SOURCE=="PIAAC"
	corr interaction interaction_edu CU if SOURCE=="PIAAC"
	su Post_secondary if SOURCE=="PIAAC", d 
*/
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU interaction
		esttab _all using "${tables}/AG_Task_Content_computer_noag_GDPcontrol.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers, interaction control ") nomtitles ///
		keep(CU interaction ) order( CU interaction ) coeflabels(CU "Computer" interaction "GDP*Computers" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU interaction interaction_edu
		esttab _all using "${tables}/AG_Task_Content_computer_noag_educontrol.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers, interaction GDP and Educ ") nomtitles ///
		keep(CU interaction interaction_edu) order( CU interaction ) coeflabels(CU "Computer" interaction "GDP*Computers" interaction_edu "Edu*Computers" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU interaction GDPPC
		esttab _all using "${tables}/AG_Task_Content_computer_noag_GDPcontrol3.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers, interaction and GDP control ") nomtitles ///
		keep(CU interaction GDPPC) order( CU interaction GDPPC) coeflabels(CU "Computer" interaction "GDP*Computers" GDPPC "GDP per capita" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU if SOURCE=="PIAAC"
		esttab _all using "${tables}/AG_Task_Content_computer_noag_piaac.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers, PIAAC sample") nomtitles ///
		keep(CU ) order(CU ) coeflabels(CU "Computers" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU GDPPC if SOURCE=="PIAAC"
		esttab _all using "${tables}/AG_Task_Content_computer_noag_GDPcontrol2_piaac.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers PIAAC sample, GDP control") nomtitles ///
		keep(CU GDPPC ) order( CU GDPPC ) coeflabels(CU "Computer" GDPPC "GDP per capita" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU interaction if SOURCE=="PIAAC"
		estimates store m`i'
		esttab _all using "${tables}/AG_Task_Content_computer_noag_GDPcontrol_piaac.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers PIAAC sample, interaction control ") nomtitles ///
		keep(CU interaction ) order( CU interaction ) coeflabels(CU "Computer" interaction "GDP*Computers" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU interact_dum if SOURCE=="PIAAC"
		esttab _all using "${tables}/AG_Task_Content_computer_noag_GDPcontrol_dum_piaac.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers PIAAC sample, interaction control dummy") nomtitles ///
		keep(CU interact_dum ) order( CU interact_dum ) coeflabels(CU "Computer" interaction "GDP_dum*Computers" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU interaction interaction_edu if SOURCE=="PIAAC"
		esttab _all using "${tables}/AG_Task_Content_computer_noag_educontrol_piaac.tex", se r2 ar2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers PIAAC sample, interaction education ") nomtitles ///
		keep(CU interaction interaction_edu) order( CU interaction ) coeflabels(CU "Computer" interaction "GDP*Computers" interaction_edu "Edu*Computers" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
	}
	
	
	eststo clear
	foreach i in NRA NRI RC RM NRM {
		eststo: reg `i' CU interaction GDPPC if SOURCE=="PIAAC"
		lrtest . m`i'
		*test GDPPC
		esttab _all using "${tables}/AG_Task_Content_computer_noag_GDPcontrol3_piaac.tex", se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
		title("Task Content and Computers PIAAC sample, interaction and GDP control ") nomtitles ///
		keep(CU interaction GDPPC) order( CU interaction GDPPC) coeflabels(CU "Computer" interaction "GDP*Computers" GDPPC "GDP per capita" ) ///
		mgroups("NRA" "NRI" "RC" "RM" "NRM" , pattern(1 1 1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))
		}

restore	
	

*/
*
*********************************Predictions at the aggregate level.
preserve
**SAVING THE SAMPLE
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}


gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE
gen oweight=1
collapse (mean) NRA NRI RC RM NRM CU (sum) oweight [aw  = weights_occ], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ_raw_noag.dta", replace
restore

***************************

preserve
**SAVING THE SAMPLE
eststo clear
forvalues s=1(1)5{
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP if SOURCE == "PIAAC" & occupation==`s'
	predict `i'_Temp if SOURCE == "STEP" & occupation==`s', xb
	replace `i' = `i'_Temp if SOURCE == "STEP" & occupation==`s'
	*drop `i'_Temp
}
}

forvalues s=7(1)9{
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP if SOURCE == "PIAAC" & occupation==`s'
	predict `i'_Temp if SOURCE == "STEP" & occupation==`s', xb
	replace `i' = `i'_Temp if SOURCE == "STEP" & occupation==`s'
	*drop `i'_Temp
}
}

gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE
gen oweight=1
collapse (mean) NRA NRI RC RM NRM CU (sum)oweight [aw  = weights_occ], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ_raw_noag_occspec.dta", replace
restore

***************************
preserve
**SAVING THE SAMPLE
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP interact if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}


gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

collapse (mean) NRA NRI RC RM NRM CU [aw  = weights_occ], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ_raw_noag_GDPcontrol.dta", replace
restore

***************************
*Sample with dummy for rich
preserve
**SAVING THE SAMPLE
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP interact_dum if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}


gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

collapse (mean) NRA NRI RC RM NRM CU [aw  = weights_occ], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ_raw_noag_GDPcontrol_dum.dta", replace
restore

preserve
**SAVING THE SAMPLE
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP interact interact_edu if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}


gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

collapse (mean) NRA NRI RC RM NRM CU [aw  = weights_occ], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ_raw_noag_educontrol.dta", replace
restore

preserve
**SAVING THE SAMPLE
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP GDPPC interact if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}


gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

collapse (mean) NRA NRI RC RM NRM CU [aw  = weights_occ], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ_raw_noag_GDPcontrol3.dta", replace
restore

preserve
**SAVING THE SAMPLE
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
drop `i'_Temp
	eststo: reg `i' COMP GDPPC if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}


gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE

collapse (mean) NRA NRI RC RM NRM CU [aw  = weights_occ], by(country occupation SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ_raw_noag_GDPcontrol2.dta", replace
restore

*/


******************
*Prediction at the 2-digit occupation level
*******************
use "$workingdata/PIAAC_occupation_measure_raw.dta", clear
append using "$workingdata/STEP_occupation_measure.dta"
*_computer


drop if occupation==6


g w_occ=1
collapse (mean) READ THINK PERSON GUIDE STRUC CONTRO OPER COMP (sum) w_occ (first) occupation [aw  = weight], by(country isco2c SOURCE)
bys country: egen total_count=total(w_occ)
g weights_occ=w_occ/total_count
su weights_occ


merge m:1 country using `countrycode', keep(3) nogen

preserve
**SAVING THE SAMPLE
eststo clear
foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER {
*drop `i'_Temp
	eststo: reg `i' COMP if SOURCE == "PIAAC" 
	predict `i'_Temp if SOURCE == "STEP", xb
	replace `i' = `i'_Temp if SOURCE == "STEP"
	drop `i'_Temp
}


gen NRA   = READ + THINK
gen NRI   = PERSON + GUIDE
gen RC    = STRUC
gen RM    = CONTRO
gen NRM   = OPER
gen CU    = COMP

keep NRA NRI RC RM NRM CU occupation country weight SOURCE isco2c

foreach i in NRA NRI RC RM NRM CU {
	summarize `i' [aw=weights_occ] if country=="USA"
	*already weighted by occupation
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM CU occupation country weight SOURCE isco2c
gen oweight=1
collapse (mean) NRA NRI RC RM NRM CU (sum)oweight (first) occupation [aw  = weights_occ], by(country isco2c SOURCE)

save "$workingdata/STEP_PIAAC_occupation_measure_Predicted_USbmk_occ2d_raw_noag.dta", replace
restore
