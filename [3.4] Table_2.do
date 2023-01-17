
clear

foreach k in "_Predicted_USbmk_occ"{
	*foreach l in "" "_Male" "_Female"{
		*foreach t in "_2006" "_2015"{
local t="_2015"
			* Decomposition by country

			use "$workingdata/ILO_Cleaned_by_Occ`t'_Imputed_noag.dta", clear
			merge 1:1 country occupation using "$workingdata/STEP_PIAAC_occupation_measure`k'_raw_noag.dta", keep(3) nogen
			collapse (mean) empshare_mean = employshare, by(occupation)
			tempfile empshare_occ
			save `empshare_occ', replace

			use "$workingdata/STEP_PIAAC_occupation_measure`k'_raw_noag.dta", clear
			merge 1:1 country occupation using "$workingdata/ILO_Cleaned_by_Occ`t'_Imputed_noag.dta", keep(3) nogen
			collapse (mean) NRA_mean = NRA NRI_mean = NRI RC_mean = RC RM_mean = RM NRM_mean = NRM, by(occupation)
			tempfile taskcontent_occ
			save `taskcontent_occ', replace

			use "$workingdata/STEP_PIAAC_occupation_measure`k'_raw_noag.dta", clear
			merge m:1 occupation using `taskcontent_occ', nogen keep(3)
			merge m:1 occupation using `empshare_occ', nogen keep(3)
			merge 1:m country occupation using "$workingdata/ILO_Cleaned_by_Occ`t'_Imputed_noag.dta", nogen keep(3)
			drop if occupation == 0
			foreach i in NRA NRI RC RM NRM{
				gen `i'_total = `i' * employshare - `i'_mean * empshare_mean
				gen `i'_taskcontent = (`i' - `i'_mean) * empshare_mean
				gen `i'_empshare = `i'_mean * (employshare - empshare_mean)
				gen `i'_cross = (`i' - `i'_mean) *  (employshare - empshare_mean)
			}

			collapse (sum) NRA_total NRA_taskcontent NRA_empshare NRA_cross NRI_total NRI_taskcontent NRI_empshare NRI_cross ///
			RC_total RC_taskcontent RC_empshare RC_cross ///
			RM_total RM_taskcontent RM_empshare RM_cross NRM_total NRM_taskcontent NRM_empshare NRM_cross, by(country)

			merge 1:1 country using "$workingdata/WDI_Cleaned.dta", nogen keep(3)
			drop if country=="Laos" | country=="Colombia" |country=="Kenya" | country=="New Zealand"
			gen GDPPC         = log(GDPPC2015)
			sort GDPPC

			keep country NRA_total NRA_taskcontent NRA_empshare NRA_cross NRI_total NRI_taskcontent NRI_empshare NRI_cross ///
			RC_total RC_taskcontent RC_empshare RC_cross ///
			RM_total RM_taskcontent RM_empshare RM_cross NRM_total NRM_taskcontent NRM_empshare NRM_cross GDPPC 


			foreach i in NRA NRI RC RM NRM {

				eststo clear

    			foreach j in "_total" "_taskcontent" "_empshare" "_cross" {
					eststo: reg `i'`j' GDPPC
				}

				esttab _all using "$tables/Decomposition_GDPPC_`i'`t'`k'_raw_noag.tex", noconstant noobs se r2 star(* .1 ** .05 *** .01) nonotes nonumbers replace ///
				title("Task Content Decomposition and GDP Per Capita: `i'") nomtitles ///
				keep(GDPPC _cons) order(GDPPC _cons) coeflabels(GDPPC "log(GDP Per Capita)" _cons "Intercept") ///
				mgroups("Total" "Task Content" "Employment Share" "Cross Term", pattern(1 1 1 1) span prefix(/multicolumn{@span}{c}{) suffix(}))

			}

		}
