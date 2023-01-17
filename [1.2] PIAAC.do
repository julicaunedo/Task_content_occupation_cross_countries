***************************************************************************************
*** Intro:  This do-file is used for constructing occupation indicator from PIAAC data 
***************************************************************************************


***************************************************************************************
*** Data Recode
***************************************************************************************

***************************************************************************************
* I. Non-routine analytical
*    1. Reading: g_q01a ~ g_q01h
*    2. Math: g_q03
*    3. Take 30min to find a good solution: f_q05b
*   *4. Fill in forms: g_q02d
*
* II. Non-routine interpersonal
*    1. Sharing work-related information with co-workers: f_q02a
*    2. Selling a product or selling a service: f_q02d
*    3. Persuading or influencing people: f_q04a
*    4. Negotiating with people: f_q04b
*    5. Instructing, training or teaching people: f_q02b
*    6. Advising people: f_q02e
*    7. Planning the activities of others: f_q03b
*   *8. Making speeches or giving presentations: f_q02c
*
* III. Routine cognitive
*    1. Planning your own activities: f_q03a
*    2. Organising your own time: f_q03c
*
* IV. Routine manual
*    1. Working physically for a long period: f_q06b
*
*  V. Non-routine Manual
*    1. Using skill or accuracy with your hands or fingers: f_q06c
***************************************************************************************

use "$workingdata/PIAAC_Combined.dta", clear

* Country

gen country = "Austria"     	if cntryid == 40
replace country = "Belgium" 	if cntryid == 56
replace country = "Canada"  	if cntryid == 124
replace country = "Chile"   	if cntryid == 152
replace country = "Czechia" 	if cntryid == 203
replace country = "Denmark" 	if cntryid == 208
replace country = "Ecuador" 	if cntryid == 218
replace country = "Estonia" 	if cntryid == 233
replace country = "Finland" 	if cntryid == 246
replace country = "France"  	if cntryid == 250
replace country = "Germany" 	if cntryid == 276
replace country = "Greece"  	if cntryid == 300
replace country = "Hungary" 	if cntryid == 348
replace country = "Ireland" 	if cntryid == 372
replace country = "Israel"  	if cntryid == 376
replace country = "Italy"   	if cntryid == 380
replace country = "Japan"   	if cntryid == 392
replace country = "Korea"   	if cntryid == 410
replace country = "Lithuania"   if cntryid == 440
replace country = "Mexico"      if cntryid == 484
replace country = "Netherlands" if cntryid == 528
replace country = "New Zealand" if cntryid == 554
replace country = "Norway" 		if cntryid == 578
replace country = "Peru" 		if cntryid == 604
replace country = "Poland" 		if cntryid == 616
replace country = "Russia" 	    if cntryid == 643
replace country = "Singapore" 	if cntryid == 702
replace country = "Slovakia" 	if cntryid == 703
replace country = "Slovenia" 	if cntryid == 705
replace country = "Spain" 		if cntryid == 724
replace country = "Sweden" 		if cntryid == 752
replace country = "Turkey" 		if cntryid == 792
replace country = "UK" 			if cntryid == 826
replace country = "USA" 		if cntryid == 840
drop if country == ""

***************************************************************************************

* I. Non-routine analytical

    * 1. Reading

    foreach i in a b c d e f g h{
     	gen g_q01`i's = g_q01`i' if g_q01`i' >= 1 & g_q01`i' <= 5
    }

    * * 2. Math

    * foreach i in b c d f g h{
    *  	gen g_q03`i's = g_q03`i' if g_q03`i' >= 1 & g_q03`i' <= 5
    * }

    * gen Math = g_q03bs + g_q03cs + g_q03ds + g_q03fs + g_q03gs + g_q03hs

    * 3. Take 30min to find a good solution

    gen f_q05bs = f_q05b if f_q05b >= 1 & f_q05b <= 5

    * *** 4. Fill in forms

    * gen Fif = g_q02d if g_q02d >= 1 & g_q02d <= 5

***************************************************************************************

* II. Non-routine interpersonal

    * 1. Sharing work-related information with co-workers

    gen f_q02as = f_q02a if f_q02a >= 1 & f_q02a <= 5

	* 2. Selling a product or selling a service

	gen f_q02ds = f_q02d if f_q02d >= 1 & f_q02d <= 5

	* 3. Persuading or influencing people

	gen f_q04as = f_q04a if f_q04a >= 1 & f_q04a <= 5

	* 4. Negotiating with people: f_q04b

	gen f_q04bs = f_q04b if f_q04b >= 1 & f_q04b <= 5

	* foreach i in Swiwc Spss Pip Nwp{
	* 	replace `i' = `i' - 1
	* }

	* 5. Instructing, training or teaching people

	gen f_q02bs = f_q02b if f_q02b >= 1 & f_q02b <= 5

	* 6. Advising people: f_q02e

	gen f_q02es = f_q02e if f_q02e >= 1 & f_q02e <= 5

	* 7. Planning the activities of others

	gen f_q03bs = f_q03b if f_q03b >= 1 & f_q03b <= 5

	* *** 8. Making speeches or giving presentations

	* gen Msgp = f_q02c if f_q02c >= 1 & f_q02c <= 5

***************************************************************************************

* III. Routine cognitive

	* 1. Planning your own activities

	gen f_q03as = 6-f_q03a if f_q03a >= 1 & f_q03a <= 5

	* replace Pyoa = Pyoa - 1

	* 2. Organising your own time

	gen f_q03cs = 6-f_q03c if f_q03c >= 1 & f_q03c <= 5

	* replace Oyot = Oyot - 1

***************************************************************************************

* IV. Routine manual

   * 1. Working physically for a long period

   gen f_q06bs = f_q06b if f_q06b >= 1 & f_q06b <= 5

   * eplace Wpflp = Wpflp - 1

***************************************************************************************

*  V. Non-routine Manual

	* 1. Using skill or accuracy with your hands or fingers

	gen f_q06cs = f_q06c if f_q06c >= 1 & f_q06c <= 5

***************************************************************************************

*  VI. ICT

	* 1. Use computers

	gen g_q04s = 1 if g_q04 == 1
	replace g_q04s = 0 if g_q04 == 2

	* replace Usawyhf = 0 if Usawyhf == 1
	* replace Usawyhf = 1 if Usawyhf >= 2 & Usawyhf <= 5

	* * 2. Use softwares

	* foreach i in a c e f g{
 *     	gen g_q05`i's = g_q05`i' if g_q05`i' >= 1 & g_q05`i' <= 5
 *    }

***************************************************************************************

gen weight = spfwt0


destring isco1c, replace
drop if isco1c == . | isco1c == 0 | isco1c >= 99
gen occupation = isco1c
destring isco2c, replace

keep g_q01as g_q01bs g_q01cs g_q01ds g_q01es g_q01fs g_q01gs g_q01hs ///
f_q05bs f_q02as f_q02ds f_q04as f_q04bs f_q02bs f_q02es f_q03bs f_q03as ///
f_q03cs f_q06bs f_q06cs g_q04s isco2c ///
occupation country weight

/*
egen ID = group(country)
sum ID, d
local ID_max = r(max)  

foreach i in g_q01as g_q01bs g_q01cs g_q01ds g_q01es g_q01fs g_q01gs g_q01hs ///
f_q05bs f_q02as f_q02ds f_q04as f_q04bs f_q02bs f_q02es f_q03bs f_q03as ///
f_q03cs f_q06bs f_q06cs g_q04s{
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
gen READ   = (g_q01as + g_q01bs + g_q01cs + g_q01ds + g_q01es + g_q01fs + g_q01gs + g_q01hs)/8
gen THINK  = f_q05bs
gen PERSON = (f_q02as + f_q02ds + f_q04as + f_q04bs)/4
gen GUIDE  =  (f_q02bs + f_q02es + f_q03bs)/3
gen STRUC  = (f_q03as + f_q03cs)/2
gen CONTRO = f_q06bs
gen OPER   = f_q06cs
gen COMP   = g_q04s
*gen SOFTW  = (g_q05as + g_q05cs + g_q05es + g_q05fs + g_q05gs)/5

keep READ THINK PERSON GUIDE STRUC CONTRO OPER COMP occupation country weight isco2c
replace isco2c=. if isco2c<10 | isco2c>=100

gen SOURCE = "PIAAC"


save "$workingdata/PIAAC_occupation_measure_raw.dta", replace
