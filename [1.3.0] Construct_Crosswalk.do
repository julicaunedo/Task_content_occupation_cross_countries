

********************************************************************************
*** IPUMS International Data
********************************************************************************
*
use "$rawdata/Crosswalks/Constructed_Crosswalk/Rawdata_for_Crosswalk/IPUMS_I_USA_2010.dta", clear

gen long ID = serial + pernum
keep ID perwt occisco occ
tab occisco 

ren occ occ3d
*
preserve
use "$rawdata/Crosswalks/Constructed_Crosswalk/Rawdata_for_Crosswalk/IPUMS_ACS_USA_2010.dta", clear
gen long ID = serial * 1000 + pernum
keep ID perwt occsoc occ

g occsoc_n=""
replace occsoc_n=substr(occsoc,1,2)
destring occsoc_n,replace


tempfile temp
save `temp', replace
restore
merge 1:1 ID using `temp', nogen assert(3)

gen weight_con = perwt/100


collapse (sum) weight_con , by(occisco occsoc)

save "$workingdata/soc10_isco88_IPUMS.dta", replace
