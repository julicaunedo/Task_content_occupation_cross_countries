***************************************************************************************
*** Intro:  This do-file is used for data clean using ILO Statistics
***************************************************************************************


*************** Employment share by occupation/year imputed

insheet using "$rawdata/ILO/ILO_by_Sex_Occ_Emp.csv", clear 
keep if sex == "SEX_T"
gen occup_code2 = substr(classif1, 1, 10)
gen occup_code3= substr(occup_code2,-2,2)

gen classif2 = substr(classif1, 1, 8)
keep if classif2 == "OCU_ISCO"
gen occupation = substr(classif1, -1, 1)
drop if occupation == "F" | occupation == "L" | occupation == "X" 
destring occupation, replace
drop if occupation == 0 | occupation==6

ren ref_arealabel country
ren obs_value employment
ren time year
keep country occupation year employment

replace country = "Korea"        if country == "Korea, Republic of"  
replace country = "Russia"       if country == "Russian Federation"  
replace country = "UK"     	     if country == "United Kingdom"  
replace country = "USA"    		 if country == "United States"
replace country = "Laos"   		 if country == "Lao People's Democratic Republic"
replace country = "Macedonia"    if country == "North Macedonia"
replace country = "Sri_Lanka"    if country == "Sri Lanka"
replace country = "Vietnam"      if country == "Viet Nam"

keep if country == "Austria" 	 | country == "Belgium"     | country == "Canada"     | country == "Chile"     | country == "Czechia"   | ///
		country == "Denmark" 	 | country == "Ecuador"     | country == "Estonia"    | country == "Finland"   | country == "France"    | ///
		country == "Germany"     | country == "Greece"  	| country == "Hungary"    | country == "Ireland"   | country == "Israel"    | ///
		country == "Italy"       | country == "Japan"   	| country == "Korea"      | country == "Lithuania" | country == "Mexico"    | ///
		country == "Netherlands" | country == "New Zealand" | country == "Norway"     | country == "Peru"      | country == "Poland"    | ///
		country == "Russia"      | country == "Singapore"   | country == "Slovakia"   | country == "Slovenia"  | country == "Spain"     | ///
		country == "Sweden"      | country == "Turkey" 	    | country == "UK" 	      | country == "USA"       | country == "Bolivia"   | ///
		country == "Colombia"    | country == "Laos"        | country == "Sri_Lanka"  | country == "Ukraine"   | country == "Vietnam" 	| ///
		country == "Yunnan"      | country == "Kenya"       | country == "Georgia"    | country == "Ghana"     | country == "Macedonia" | ///
		country == "Armenia"     | country == "Philippines"

reshape wide employment, i(country occupation) j(year)
replace employment2006 = employment2008 if country == "Armenia"
replace employment2006 = employment2010 if country == "Laos"
replace employment2006 = employment2004 if country == "Mexico"
replace employment2006 = employment2007 if country == "Vietnam"

replace employment2015 = employment2014 if country == "Canada"
replace employment2015 = employment2017 if country == "Laos"

reshape long employment, i(country occupation) j(year)
keep if year == 2006 | year == 2015
reshape wide employment, i(country year) j(occupation)
reshape long employment, i(country year) j(occupation)
replace employment = 0 if employment == .
bys country year: egen employ_cty = sum(employment)
gen employshare = employment/employ_cty

save "$workingdata/ILO_Cleaned_by_Occ_Imputed_noag.dta", replace
preserve
keep if year == 2015
save "$workingdata/ILO_Cleaned_by_Occ_2015_Imputed_noag.dta", replace
restore
preserve
keep if year == 2006
save "$workingdata/ILO_Cleaned_by_Occ_2006_Imputed_noag.dta", replace
restore



***************************************************************************************
*** WDI 
***************************************************************************************

insheet using "$rawdata/WDI/b695c26c-539a-41f6-9fc5-522fa1f95a07_Data.csv", clear n
gen variable = 1     if seriesname == "Educational attainment, at least completed post-secondary, population 25+, total (%) (cumulative)"
replace variable = 2 if seriesname == "Educational attainment, at least completed primary, population 25+ years, total (%) (cumulative)"
replace variable = 3 if seriesname == "GDP (constant 2010 US$)"
replace variable = 4 if seriesname == "GDP growth (annual %)"
replace variable = 5 if seriesname == "GDP per capita (constant 2010 US$)"
replace variable = 6 if seriesname == "Industry (including construction), value added (% of GDP)"
replace variable = 7 if seriesname == "Services, value added (% of GDP)"
drop seriesname seriescode
ren CountryName country
drop if countrycode == ""
reshape long yr, i(country countrycode variable) j(Year)
ren yr value
destring value, replace force
replace country = "Czechia" 	if country == "Czech Republic"
replace country = "Korea" 		if country == "Korea, Rep."
replace country = "Laos" 		if country == "Lao PDR"
replace country = "Russia" 		if country == "Russian Federation"
replace country = "Slovakia" 	if country == "Slovak Republic"
replace country = "UK" 			if country == "United Kingdom"
replace country = "USA" 		if country == "United States"
replace country = "Sri_Lanka"   if country == "Sri Lanka"
replace country = "Macedonia"   if country == "North Macedonia"

keep if country == "Austria" 	 | country == "Belgium"     | country == "Canada"     | country == "Chile"     | country == "Czechia"   | ///
		country == "Denmark" 	 | country == "Ecuador"     | country == "Estonia"    | country == "Finland"   | country == "France"    | ///
		country == "Germany"     | country == "Greece"  	| country == "Hungary"    | country == "Ireland"   | country == "Israel"    | ///
		country == "Italy"       | country == "Japan"   	| country == "Korea"      | country == "Lithuania" | country == "Mexico"    | ///
		country == "Netherlands" | country == "New Zealand" | country == "Norway"     | country == "Peru"      | country == "Poland"    | ///
		country == "Russia"      | country == "Singapore"   | country == "Slovakia"   | country == "Slovenia"  | country == "Spain"     | ///
		country == "Sweden"      | country == "Turkey" 	    | country == "UK" 	      | country == "USA"       | country == "Bolivia"   | ///
		country == "Colombia"    | country == "Laos"        | country == "Sri_Lanka"  | country == "Ukraine"   | country == "Vietnam" 	| ///
		country == "Yunnan"      | country == "Kenya"       | country == "Georgia"    | country == "Ghana"     | country == "Macedonia" | ///
		country == "Armenia"     | country == "Philippines"

reshape wide value, i(country countrycode Year) j(variable)

ren value1 Post_secondary
ren value2 Primary
ren value3 GDP
ren value4 GDPGr
ren value5 GDPPC
ren value6 Industry
ren value7 Service

preserve
ren Year year
save "$workingdata/WDI_Cleaned_All.dta", replace
keep if country == "Austria" 	 | country == "Belgium"     | country == "Canada"     | country == "Chile"     | country == "Czechia"   | ///
		country == "Denmark" 	 | country == "Ecuador"     | country == "Estonia"    | country == "Finland"   | country == "France"    | ///
		country == "Germany"     | country == "Greece"  	| country == "Hungary"    | country == "Ireland"   | country == "Israel"    | ///
		country == "Italy"       | country == "Japan"   	| country == "Korea"      | country == "Lithuania" | country == "Mexico"    | ///
		country == "Netherlands" | country == "New Zealand" | country == "Norway"     | country == "Peru"      | country == "Poland"    | ///
		country == "Russia"      | country == "Singapore"   | country == "Slovakia"   | country == "Slovenia"  | country == "Spain"     | ///
		country == "Sweden"      | country == "Turkey" 	    | country == "UK" 	      | country == "USA" 
save "$workingdata/WDI_Cleaned_PIAAC.dta", replace
restore

keep if Year == 2006 | Year == 2015
reshape wide Post_secondary Primary GDP GDPGr GDPPC Industry Service, i(country countrycode) j(Year)
save "$workingdata/WDI_Cleaned.dta", replace


