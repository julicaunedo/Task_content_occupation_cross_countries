***************************************************************************************
*** Intro:  This do-file is used for constructing occupation indicator from STEP data 
***************************************************************************************


***************************************************************************************
*** Data Combining
***************************************************************************************
*
local folders ARM_W2 BOL_W1 CHN_W1 COL_W1 GEO_W2 GHA_W2 KEN_W2 LAO_W1 LKA_W1 MKD_W2 PHL_W3 UKR_W1 VNM_W1

foreach f in `folders' {
	local files: dir "$rawdata/STEP/Household_Study/`f'/`g'" files "*_working.dta"
    foreach g in `files' {
	preserve
    use "$rawdata/STEP/Household_Study/`f'/`g'", clear
	tempfile temp
	save `temp', replace
    restore
    append using `temp', force
	}
}

preserve
use "$rawdata/STEP/Household_Study/PHL_W3/step_ph_weights_merged_public.dta", clear
tempfile temp
save `temp', replace
restore
append using `temp', force

save "$workingdata/STEP_Combined.dta", replace
*/
***************************************************************************************
*** Data Recode
***************************************************************************************

***************************************************************************************
* I. Non-routine Analytical
*    1. Type of document read: 
*       W1: m5a_q05_01~05 W1: m5a_q05_01~04,06 W3: m6a_q05_01~05
*    2. Length of longest document typically read: 
*       W1/W2: m5a_q04*m5a_q06 W3: m6a_q04*m6a_q06
*    3. Math tasks: 
*       W1/W2: m5a_q18 W3: m6a_q13
*    4. Thinking for at least 30 mins to do tasks: 
*       W1: m5b_q09 W2: m5b_q10 W3: m6b_q10
*   *5. Fill the form/bill:
*       W1/W2: m5a_q11 W3: m6a_q11
*
* II. Non-routine Interpersonal
*    1. Supervising coworkers: 
*       W1: m5b_q11 W2: m5b_q13 W3: m6b_q13
*    2. Contact with clients: 
*       W1: m5b_q04*m5b_q05 W2: m5b_q05*m5b_q06 W3: m6b_q05*m6b_q06
*   *3. Presentations:
*       W1: m5b_q10 W2: m5b_q12 W2: m6b_q12 
*
* III. Routine Cognitive
*    1. How often your work involves learning new things: 
*       W1: m5b_q15 W2: m5b_q17 W3: m6b_q17
*    2. Autonomy: 
*       W1: m5b_q12 W2: m5b_q14 W3: m6b_q14
*    3. Repetitiveness: 
*		W1: m5b_q14 W2: m5b_q16 W4: m6b_q16
*
* IV. Routine Manual
*    1. Operate: 
*		W1: m5b_q08 W2: m5b_q09 W3: m6b_q09
*    2. Physical demanding: 
*       W1/W2: m5b_q03  W3: m6b_q03
*
* V. Non-routine Manual
*    1. Driving: 
*       W1: m5b_q06 W2: m5b_q07 W3: m6b_q07
*    2. Repair: 
*       W1: m5b_q07 W2: m5b_q08 W3: m6b_q08
*
* V. ICT
*    1. Computers: 
*       W1: m5b_q16 W2: m5b_q18 W3: m6b_q18
*    2. Software: 
*       W1: m5b_q18_01_02_04~06 W2: m5b_q20_01_02_04~06 W3: m6b_q20_01_02_04~06

***************************************************************************************

use "$workingdata/STEP_Combined.dta", clear

gen Wave = 1 if country == "Bolivia" | country == "Colombia" | country == "Laos" |  ///
				country == "Sri_Lanka" | country == "Ukraine" | country == "Vietnam" |  ///
				country == "Yunnan"
replace Wave = 2 if country == "Kenya" | country == "Georgia" | country == "Ghana" |  ///
				country == "Macedonia" | country == "Armenia"
replace Wave = 3 if country == "PHL"

* I. Non-routine Analytical

	* 1. Read

    forv i = 1(1)2{
		gen m5a_q05_`i's = 1     if m5a_q05_`i' == 1 & (Wave == 1 | Wave == 2)
		replace m5a_q05_`i's = 0 if m5a_q05_`i' == 2 & (Wave == 1 | Wave == 2)
		replace m5a_q05_`i's = 1 if m6a_q05_`i' == 1 & Wave == 3
		replace m5a_q05_`i's = 0 if m6a_q05_`i' == 2 & Wave == 3
	}

	gen m5a_q05_3s = 1     if m5a_q05_3 == 1 & Wave == 1 
	replace m5a_q05_3s = 0 if m5a_q05_3 == 2 & Wave == 1 
	replace m5a_q05_3s = 1 if m5a_q05_4 == 1 & Wave == 2
	replace m5a_q05_3s = 0 if m5a_q05_4 == 2 & Wave == 2
	replace m5a_q05_3s = 1 if m6a_q05_3 == 1 & Wave == 3
	replace m5a_q05_3s = 0 if m6a_q05_3 == 2 & Wave == 3

	gen m5a_q05_4s = 1     if m5a_q05_4 == 1 & Wave == 1 
	replace m5a_q05_4s = 0 if m5a_q05_4 == 2 & Wave == 1 
	replace m5a_q05_4s = 1 if m5a_q05_6 == 1 & Wave == 2
	replace m5a_q05_4s = 0 if m5a_q05_6 == 2 & Wave == 2
	replace m5a_q05_4s = 1 if m6a_q05_4 == 1 & Wave == 3
	replace m5a_q05_4s = 0 if m6a_q05_4 == 2 & Wave == 3

	gen m5a_q05_5s = 1     if m5a_q05_5 == 1 & Wave == 1 
	replace m5a_q05_5s = 0 if m5a_q05_5 == 2 & Wave == 1 
	replace m5a_q05_5s = 1 if (m5a_q05_3 == 1 | m5a_q05_5 == 1) & Wave == 2
	replace m5a_q05_5s = 0 if (m5a_q05_3 == 2 & m5a_q05_5 == 2) & Wave == 2
	replace m5a_q05_5s = 1 if m6a_q05_5 == 1 & Wave == 3
	replace m5a_q05_5s = 0 if m6a_q05_5 == 2 & Wave == 3

	gen m5a_q04s = 1       if m5a_q04 == 1 & (Wave == 1 | Wave == 2)
	replace m5a_q04s = 0   if m5a_q04 == 2 & (Wave == 1 | Wave == 2)
	replace m5a_q04s = 1   if m6a_q04 == 1 & Wave == 3
	replace m5a_q04s = 0   if m6a_q04 == 2 & Wave == 3

	* * 2. Length of longest document typically read

	* gen m5a_q04s = 1       if m5a_q04 == 1 & (Wave == 1 | Wave == 2)
	* replace m5a_q04s = 0   if m5a_q04 == 2 & (Wave == 1 | Wave == 2)
	* replace m5a_q04s = 1   if m6a_q04 == 1 & Wave == 3
	* replace m5a_q04s = 0   if m6a_q04 == 2 & Wave == 3

	* gen m5a_q06s = m5a_q06 if m5a_q06 >= 1 & m5a_q06 <= 5 & (Wave == 1 | Wave == 2)
	* replace m5a_q06s = 0   if m5a_q06 == 6 & (Wave == 1 | Wave == 2)
	* replace m5a_q06s = m6a_q06 if m6a_q06 >= 1 & m6a_q06 <= 5 & Wave == 3
	* replace m5a_q06s = 0   if m6a_q06 == 6 & Wave == 3

	* gen Loldtr = m5a_q04s * m5a_q06s
	* replace Loldtr = 0 if m5a_q04s == 0

	* replace Todr = 0 if m5a_q04s == 0

	* * 3. Math tasks

	* forv i = 1(1)5{
	* 	gen m5a_q18_`i's = 1     if m5a_q18_`i' == 1 & (Wave == 1 | Wave == 2)
	* 	replace m5a_q18_`i's = 0 if m5a_q18_`i' == 2 & (Wave == 1 | Wave == 2)
	* 	replace m5a_q18_`i's = 1 if m6a_q13_`i' == 1 & Wave == 3
	* 	replace m5a_q18_`i's = 0 if m6a_q13_`i' == 2 & Wave == 3

	* }

	* gen Mt = m5a_q18_1s + m5a_q18_2s + m5a_q18_3s + m5a_q18_4s + m5a_q18_5s

	* 2. Thinking for at least 30 mins to do tasks

	gen m5b_q10s = m5b_q09 if m5b_q09 >= 1 & m5b_q09 <= 5 & Wave == 1
	replace m5b_q10s = m5b_q10 if m5b_q10 >= 1 & m5b_q10 <= 5 & Wave == 2
	replace m5b_q10s = m6b_q10 if m6b_q10 >= 1 & m6b_q10 <= 5 & Wave == 3

	* *** 5. Fill the form/bill

	* gen Ffb = 1 if m5a_q11 == 1 & (Wave == 1 | Wave == 2)
	* replace Ffb = 0 if m5a_q11 == 2 & (Wave == 1 | Wave == 2)
	* replace Ffb = 1 if m6a_q11 == 1 & Wave == 3
	* replace Ffb = 0 if m6a_q11 == 2 & Wave == 3

***************************************************************************************

* II. Non-routine Interpersonal

	* 1. Contact with clients

	gen m5b_q06s = 0      if m5b_q04 == 2 & Wave == 1
	replace m5b_q06s = 0  if m5b_q05 == 2 & Wave == 2
	replace m5b_q06s = 0  if m6b_q05 == 2 & Wave == 3
	replace m5b_q06s = m5b_q05 if (m5b_q05 >= 1 & m5b_q05 <= 10) & m5b_q04 == 1 & Wave == 1
	replace m5b_q06s = m5b_q06 if (m5b_q06 >= 1 & m5b_q06 <= 10) & m5b_q05 == 1 & Wave == 2
	replace m5b_q06s = m6b_q06 if (m6b_q05 >= 1 & m6b_q05 <= 10) & m6b_q05 == 1 & Wave == 3

	* 2. Supervising coworkers

	gen m6b_q13s = 1     if m5b_q11 == 1 & Wave == 1
	replace m6b_q13s = 0 if m5b_q11 == 2 & Wave == 1
	replace m6b_q13s = 1 if m5b_q13 == 1 & Wave == 2
	replace m6b_q13s = 0 if m5b_q13 == 2 & Wave == 2
	replace m6b_q13s = 1 if m6b_q13 == 1 & Wave == 3
	replace m6b_q13s = 0 if m6b_q13 == 2 & Wave == 3

	/**** 3. Presentations:

	gen Pre = 1 if m5b_q10 == 1 & Wave == 1
	replace Pre = 0 if m5b_q10 == 2 & Wave == 1
	replace Pre = 1 if m5b_q12 == 1 & Wave == 2
	replace Pre = 0 if m5b_q12 == 2 & Wave == 2
	replace Pre = 1 if m6b_q12 == 1 & Wave == 3
	replace Pre = 0 if m6b_q12 == 2 & Wave == 3*/
	
***************************************************************************************

* III. Routine Cognitive

	* 1. How often your work involves learning new things

	gen m6b_q17s = m5b_q15 if m5b_q15 >= 1 & m5b_q15 <= 5 & Wave == 1
	replace m6b_q17s = m5b_q17 if m5b_q17 >= 1 & m5b_q17 <= 5 & Wave == 2
	replace m6b_q17s = m6b_q17 if m6b_q17 >= 1 & m6b_q17 <= 5 & Wave == 3

	* 2. Autonomy: m5b_q14

	gen m5b_q14s = 11 - m5b_q12 if m5b_q12 >= 1 & m5b_q12 <= 10 & Wave == 1
	replace m5b_q14s = 11 - m5b_q14 if m5b_q14 >= 1 & m5b_q14 <= 10 & Wave == 2
	replace m5b_q14s = 11 - m6b_q14 if m6b_q14 >= 1 & m6b_q14 <= 10 & Wave == 3

	* 3. Repetitiveness: m5b_q16

	gen m5b_q16s = 5 - m5b_q14 if m5b_q14 >= 1 & m5b_q14 <= 4 & Wave == 1
	replace m5b_q16s = 5 - m5b_q16 if m5b_q16 >= 1 & m5b_q16 <= 4 & Wave == 2
	replace m5b_q16s = 5 - m6b_q16 if m6b_q16 >= 1 & m6b_q16 <= 4 & Wave == 3

***************************************************************************************

* IV. Routine Manual

	* * 1. Operate: m5b_q09

	* gen Oper = 1     if m5b_q08 == 1 & Wave == 1
	* replace Oper = 0 if m5b_q08 == 2 & Wave == 1
	* replace Oper = 1 if m5b_q09 == 1 & Wave == 2
	* replace Oper = 0 if m5b_q09 == 2 & Wave == 2
	* replace Oper = 1 if m6b_q09 == 1 & Wave == 3
	* replace Oper = 0 if m6b_q09 == 2 & Wave == 3

	* replace Oper = Oper * 4

	* 2. Physical demanding: m5b_q03

	gen m5b_q03s = m5b_q03 if m5b_q03 >= 1 & m5b_q03 <= 10 & Wave == 1
	replace m5b_q03s = m5b_q03 if m5b_q03 >= 1 & m5b_q03 <= 10 & Wave == 2
	replace m5b_q03s = m6b_q03 if m6b_q03 >= 1 & m6b_q03 <= 10 & Wave == 3

***************************************************************************************

* V. Non-routine Manual

	* 1. Driving

	gen m5b_q07s = 1        if m5b_q06 == 1 & Wave == 1
	replace m5b_q07s = 0    if m5b_q06 == 2 & Wave == 1
	replace m5b_q07s = 1    if m5b_q07 == 1 & Wave == 2
	replace m5b_q07s = 0    if m5b_q07 == 2 & Wave == 2
	replace m5b_q07s = 1    if m6b_q07 == 1 & Wave == 3
	replace m5b_q07s = 0    if m6b_q07 == 2 & Wave == 3

	* 2. Repair

	gen m5b_q08s = 1     if m5b_q07 == 1 & Wave == 1
	replace m5b_q08s = 0 if m5b_q07 == 2 & Wave == 1
	replace m5b_q08s = 1 if m5b_q08 == 1 & Wave == 2
	replace m5b_q08s = 0 if m5b_q08 == 2 & Wave == 2
	replace m5b_q08s = 1 if m6b_q08 == 1 & Wave == 3
	replace m5b_q08s = 0 if m6b_q08 == 2 & Wave == 3

***************************************************************************************

*  VI. ICT

	* 1. Use computers

	gen m5b_q18s = 1     if m5b_q16 == 1 & Wave == 1 
	replace m5b_q18s = 0 if m5b_q16 == 2 & Wave == 1 
	replace m5b_q18s = 1 if m5b_q18 == 1 & Wave == 2
	replace m5b_q18s = 0 if m5b_q18 == 2 & Wave == 2
	replace m5b_q18s = 1 if m6b_q18 == 1 & Wave == 3
	replace m5b_q18s = 0 if m6b_q18 == 2 & Wave == 3

	* 2. Use softwares

 *    foreach i in 1 2 4 5{
	* 	gen m5b_q20_`i's = 1     if m5b_q18_`i' == 1 & Wave == 1
	* 	replace m5b_q20_`i's = 0 if m5b_q18_`i' == 2 & Wave == 1 
	* 	replace m5b_q20_`i's = 1 if m5b_q20_`i' == 1 & Wave == 2
	* 	replace m5b_q20_`i's = 0 if m5b_q20_`i' == 2 & Wave == 2
	* 	replace m5b_q20_`i's = 1 if m6b_q20_`i' == 1 & Wave == 3
	* 	replace m5b_q20_`i's = 0 if m6b_q20_`i' == 2 & Wave == 3
	* }

	* gen m5b_q21s = 1     if m5b_q19 == 1 & Wave == 1 
	* replace m5b_q21s = 0 if m5b_q19 == 2 & Wave == 1 
	* replace m5b_q21s = 1 if m5b_q21 == 1 & Wave == 2
	* replace m5b_q21s = 0 if m5b_q21 == 2 & Wave == 2
	* replace m5b_q21s = 1 if m6b_q21 == 1 & Wave == 3
	* replace m5b_q21s = 0 if m6b_q21 == 2 & Wave == 3

***************************************************************************************
*** Measure Construction
***************************************************************************************

gen weight = W_FinSPwt      if Wave <= 2
replace weight = w3_finspwt if Wave == 3

keep m5a_q05_1s m5a_q05_2s m5a_q05_3s m5a_q05_4s m5a_q05_5s m5a_q04s ///
m5b_q10s m5b_q06s m6b_q13s m6b_q17s m5b_q14s m5b_q16s m5b_q03s m5b_q07s ///
m5b_q08s m5b_q18s country occupation weight occupationcode

keep if occupation != . & occupation != 0
/*
egen ID = group(country)
sum ID, d
local ID_max = r(max)  

foreach i in m5a_q05_1s m5a_q05_2s m5a_q05_3s m5a_q05_4s m5a_q05_5s m5a_q04s ///
m5b_q10s m5b_q06s m6b_q13s m6b_q17s m5b_q14s m5b_q16s m5b_q03s m5b_q07s ///
m5b_q08s m5b_q18s {
	forv j = 1(1)`ID_max'{
		summarize `i' [aw  = weight] if ID == `j'
		scalar `i'_mean = r(mean)  
		disp `i'_mean
		scalar `i'_sd = r(sd)  
		disp `i'_sd
		replace `i' = (`i' - `i'_mean)/`i'_sd if ID == `j'
	}
}
*/

gen READ   = (m5a_q05_1s + m5a_q05_2s + m5a_q05_3s + m5a_q05_4s + m5a_q05_5s + m5a_q04s)/6
gen THINK  = m5b_q10s
gen PERSON = m5b_q06s
gen GUIDE  = m6b_q13s
gen STRUC  = (m6b_q17s + m5b_q14s + m5b_q16s)/3
gen CONTRO = m5b_q03s
gen OPER   = (m5b_q07s + m5b_q08s)/2
gen COMP   = m5b_q18s
*gen SOFTW  = (m5b_q20_1s + m5b_q20_2s + m5b_q20_4s + m5b_q20_5s + m5b_q21s)/5

keep COMP OPER CONTRO STRUC GUIDE PERSON THINK READ occupation country weight occupationcode
replace occupationcode=. if occupationcode<10 | occupationcode>=100
rename occupationcode isco2c

replace country = "Philippines" if country == "PHL"

gen SOURCE = "STEP"

save "$workingdata/STEP_occupation_measure.dta", replace
