***************************************************************************************
*** Intro:  This do-file is used for constructing occupation indicator from O*NET
***************************************************************************************


***************************************************************************************
*** Data Clean
***************************************************************************************
*
import excel using "$rawdata/O*NET/O*NET20.0/Abilities.xlsx", clear first

preserve
import excel using "$rawdata/O*NET/O*NET20.0/Work Activities.xlsx", clear first
tempfile temp
save `temp', replace
restore
append using `temp', force

preserve
import excel using "$rawdata/O*NET/O*NET20.0/Work Context.xlsx", clear first
tempfile temp
save `temp', replace
restore
append using `temp', force

save "$workingdata/O_NET_Combined.dta", replace

***************************************************************************************
* I. Non-routine Analytical
*    1. Analyzing data/information	4.A.2.a.4
*    2. Thinking creatively	4.A.2.b.2
*
* II. Non-routine Interpersonal
*    1. Establishing and maintaining personal relationships	4.A.4.a.4
*    2. Guiding, directing and motivating subordinates	4.A.4.b.4
*    3. Coaching/developing others	4.A.4.b.5

* III. Routine Cognitive
*    1. Structured v. Unstructured work (reverse)	4.C.3.b.8
*    2. Importance of repeating the same tasks	4.C.3.b.7
*
* IV. Routine Manual
*    1. Controlling machines and processes	4.A.3.a.3
*
* V. Non-routine Manual
*    1. Operating vehicles, mechanized devices, or equipment	4.A.3.a.4
*    2. Spend time using hands to handle, control or feel	4.C.2.d.1.g
*    3.	Manual dexterity	1.A.2.a.2
***************************************************************************************

* I. Non-routine Analytical

	* 1. Analyzing data/information

	use "$workingdata/O_NET_Combined.dta", clear
	gen Adi = DataValue if ElementID == "4.A.2.a.4" & ScaleName == "Importance"
	keep if Adi != .

	preserve

	* 2. Thinking creatively
	use "$workingdata/O_NET_Combined.dta", clear
	gen Tc = DataValue if ElementID == "4.A.2.b.2" & ScaleName == "Importance"
	keep if Tc != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve

* II. Non-routine Interpersonal

	* 1. Establishing and maintaining personal relationships

	use "$workingdata/O_NET_Combined.dta", clear
	gen Empr = DataValue if ElementID == "4.A.4.a.4" & ScaleName == "Importance"
	keep if Empr != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve

	* 2. Guiding, directing and motivating subordinates	

	use "$workingdata/O_NET_Combined.dta", clear
	gen Gdms = DataValue if ElementID == "4.A.4.b.4" & ScaleName == "Importance"
	keep if Gdms != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve

	* 3. Coaching/developing others	

	use "$workingdata/O_NET_Combined.dta", clear
	gen Cdo = DataValue if ElementID == "4.A.4.b.5" & ScaleName == "Importance"
	keep if Cdo != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve

* III. Routine Cognitive

	* 1. Structured v. Unstructured work (reverse)

	use "$workingdata/O_NET_Combined.dta", clear
	gen Suw = 6 - DataValue if ElementID == "4.C.3.b.8" & ScaleName == "Context"
	keep if Suw != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(1 3)

	preserve

	* 2. Importance of repeating the same tasks

	use "$workingdata/O_NET_Combined.dta", clear
	gen Irst = DataValue if ElementID == "4.C.3.b.7" & ScaleName == "Context"
	keep if Irst != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve

* IV. Routine Manual

	* 1. Controlling machines and processes

	use "$workingdata/O_NET_Combined.dta", clear
	gen Cmp = DataValue if ElementID == "4.A.3.a.3" & ScaleName == "Importance"
	keep if Cmp != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve
	
* V. Non-routine Manual

	* 1. Operating vehicles, mechanized devices, or equipment	

	use "$workingdata/O_NET_Combined.dta", clear
	gen Ovmde = DataValue if ElementID == "4.A.3.a.4" & ScaleName == "Importance"
	keep if Ovmde != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve
	
	* 2. Spend time using hands to handle, control or feel	

	use "$workingdata/O_NET_Combined.dta", clear
	gen Stuhth = DataValue if ElementID == "4.C.2.d.1.g" & ScaleName == "Context"
	keep if Stuhth != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

	preserve

	* 3.Manual dexterity

	use "$workingdata/O_NET_Combined.dta", clear
	gen Md = DataValue if ElementID == "1.A.2.a.2" & ScaleName == "Importance"
	keep if Md != .
	tempfile temp
	save `temp', replace
	restore

	merge 1:1 ONETSOCCode using `temp', nogen assert(3)

save "$workingdata/O_NET_measure.dta", replace
*/
***************************************************************************************
*** Measure Construction
***************************************************************************************

use "$workingdata/O_NET_measure.dta", clear

gen onetsoc10 = subinstr(ONETSOCCode, "-", "", 1)
destring onetsoc10, replace

gen occsoc = int(onetsoc10)
tostring occsoc, replace

joinby occsoc using "$workingdata/soc10_isco88_IPUMS.dta"

ren weight_con weight
ren occisco occupation



keep if occupation <= 9 & occupation >= 1

*
foreach i in Adi Tc Empr Gdms Cdo Suw Irst Cmp Ovmde Stuhth Md{
	summarize `i' [aw  = weight]
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}


gen READ   = Adi 
gen THINK  = Tc
gen PERSON = Empr
gen GUIDE  = (Gdms + Cdo)/2
gen STRUC  = (Suw + Irst)/2
gen CONTRO = Cmp
gen OPER   = (Ovmde + Stuhth + Md)/3

foreach i in READ THINK PERSON GUIDE STRUC CONTRO OPER{
	summarize `i' [aw  = weight]
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

keep NRA NRI RC RM NRM occupation weight

foreach i in NRA NRI RC RM NRM{
	summarize `i' [aw  = weight]
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

keep NRA NRI RC RM NRM occupation weight

** These are normalized to the US
collapse (mean) NRA NRI RC RM NRM [aw  = weight], by(occupation)

** Check O*NET
foreach i in NRA NRI RC RM NRM{
	summarize `i' 
	scalar `i'_mean = r(mean)  
	disp `i'_mean
	scalar `i'_sd = r(sd)  
	disp `i'_sd
	replace `i' = (`i' - `i'_mean)/`i'_sd
}

foreach i in NRA NRI RC RM NRM{
	ren `i' `i'_onet
}

save "$workingdata/O_NET_occupation_measure_raw.dta", replace

