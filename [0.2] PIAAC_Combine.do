****This do file performs the following:
**** 1) Import all CSV Public Use Files present in the inputed directory
**** 2) Append all these files into a single STATA dataset
**** 3) Encode all missing value codes in the STATA format 
**** 4) Apply variable and value labels where appropriate.

**Loading intermediary programs into memory
qui {
cap program drop cleaning_missing 
cap program define  cleaning_missing // this program takes all missing value codes and turn them into proper stata missing value codes
									// with a '.' and a small letter
	dis "  Cleaning missing values..." _n "    This step can last up to one hour"
	qui {
		foreach var of varlist _all {
				tempvar k
				gen `k'= `var'
				 cap replace `k'="."+lower(`k') if inlist(`k',"N","V","D","R", "M","A","U","Z")==1
				 destring `k',  replace // destring will left unchanged variables with something else as numeric values or missing value codes.
				local isstring_k= (substr("`: format `k''",-1,1)=="s")
				dis "`isstring_k'"
				if `isstring_k'==0  & inlist(lower(substr("`var'",1,4)),"isce","isco","isic")==0 { 
						drop `var'
						  gen `var'=`k' 
					}
				drop `k'
			}
		}	
	end


cap prog drop Import_PIAAC
  prog define Import_PIAAC // This program is the master program and will be launched at the very end of the do file
	di _n
	*performs steps 1 and 2 defined at the very beggining of the file
	di `"  Type the filepath where the PUFs are located into the command window and then press Enter"' _n _request(Path)
	**puts path in global macro $Path
	**echo that back to the user:
	window stopbox note `"Path entered as : "'  `"$Path"'
	local your_cwd: pwd //save former working directory
	qui cd `"$Path"'
	tempfile PIAAC_allcountries
	dis   "  Importing PUF country files into Stata:"
	qui local list_files: dir `"$Path"' files "prg*.csv"
	foreach file in `list_files' {
		dis `"    Importing `file' ..."'
		qui import delimited `file',clear stringcols(_all) 
		qui cap   append using `PIAAC_allcountries'
		qui save `PIAAC_allcountries', replace
		}
	cleaning_missing //Step 3
	def_val_lab //Step 4
	lamf //Step 5
	qui cd `"`your_cwd'"' //reestablish former working directory
	end


cap prog drop def_val_lab
prog define def_val_lab //this program creates all value labels. 
	label define FNFAET12NJR 0 `"Did not participate in formal or non-formal AET for non JR reasons"', modify
	label define FNFAET12NJR 1 `"Participated in formal or non-formal AET for non JR reasons"', modify
	label define FNFAET12JR 0 `"Did not participate in formal or non-formal AET for JR reasons"', modify
	label define FNFAET12JR 1 `"Participated in formal or non-formal AET for JR reasons"', modify
	label define FNFE12JR 0 `"Did not participate in FE or NFE for JR reasons"', modify
	label define FNFE12JR 1 `"Participated in FE or NFE for JR reasons"', modify
	label define NFE12NJR 0 `"Did not participate in NFE for NJR reasons"', modify
	label define NFE12NJR 1 `"Participated in NFE for NJR reasons"', modify
	label define NFE12JR 0 `"Did not participate in NFE for JR reasons"', modify
	label define NFE12JR 1 `"Participated in NFE for JR reasons"', modify
	label define VEMETHODN 1 `"JK1 - Jackknife 1"', modify
	label define VEMETHODN 2 `"JK2 - Jackknife 2"', modify
	label define VEMETHODN 3 `"BRR - Balanced Repeated Replication"', modify
	label define VEMETHODN 4 `"FAY - Balanced Repeated Replication w Fay's adjustment"', modify
	label define PSLSTATUS 1 `"Has PV"', modify
	label define PSLSTATUS 2 `"Literacy Related Non-Response"', modify
	label define PSLSTATUS 3 `"CBA Non-Response"', modify
	label define NUMSTATUS 1 `"Has PV"', modify
	label define NUMSTATUS 2 `"Literacy Related Non-Response"', modify
	label define LITSTATUS 1 `"Has PV"', modify
	label define LITSTATUS 2 `"Literacy Related Non-Response"', modify
	label define WRITWORK_WLE_CA 0 `"All zero response"', modify
	label define WRITWORK_WLE_CA 1 `"Lowest to 20%"', modify
	label define WRITWORK_WLE_CA 2 `"More than 20% to 40%"', modify
	label define WRITWORK_WLE_CA 3 `"More than 40% to 60%"', modify
	label define WRITWORK_WLE_CA 4 `"More than 60% to 80%"', modify
	label define WRITWORK_WLE_CA 5 `"More than 80%"', modify
	label define WRITHOME_WLE_CA 0 `"All zero response"', modify
	label define WRITHOME_WLE_CA 1 `"Lowest to 20%"', modify
	label define WRITHOME_WLE_CA 2 `"More than 20% to 40%"', modify
	label define WRITHOME_WLE_CA 3 `"More than 40% to 60%"', modify
	label define WRITHOME_WLE_CA 4 `"More than 60% to 80%"', modify
	label define WRITHOME_WLE_CA 5 `"More than 80%"', modify
	label define TASKDISC_WLE_CA 0 `"All zero response"', modify
	label define TASKDISC_WLE_CA 1 `"Lowest to 20%"', modify
	label define TASKDISC_WLE_CA 2 `"More than 20% to 40%"', modify
	label define TASKDISC_WLE_CA 3 `"More than 40% to 60%"', modify
	label define TASKDISC_WLE_CA 4 `"More than 60% to 80%"', modify
	label define TASKDISC_WLE_CA 5 `"More than 80%"', modify
	label define READWORK_WLE_CA 0 `"All zero response"', modify
	label define READWORK_WLE_CA 1 `"Lowest to 20%"', modify
	label define READWORK_WLE_CA 2 `"More than 20% to 40%"', modify
	label define READWORK_WLE_CA 3 `"More than 40% to 60%"', modify
	label define READWORK_WLE_CA 4 `"More than 60% to 80%"', modify
	label define READWORK_WLE_CA 5 `"More than 80%"', modify
	label define READHOME_WLE_CA 0 `"All zero response"', modify
	label define READHOME_WLE_CA 1 `"Lowest to 20%"', modify
	label define READHOME_WLE_CA 2 `"More than 20% to 40%"', modify
	label define READHOME_WLE_CA 3 `"More than 40% to 60%"', modify
	label define READHOME_WLE_CA 4 `"More than 60% to 80%"', modify
	label define READHOME_WLE_CA 5 `"More than 80%"', modify
	label define PLANNING_WLE_CA 0 `"All zero response"', modify
	label define PLANNING_WLE_CA 1 `"Lowest to 20%"', modify
	label define PLANNING_WLE_CA 2 `"More than 20% to 40%"', modify
	label define PLANNING_WLE_CA 3 `"More than 40% to 60%"', modify
	label define PLANNING_WLE_CA 4 `"More than 60% to 80%"', modify
	label define PLANNING_WLE_CA 5 `"More than 80%"', modify
	label define NUMWORK_WLE_CA 0 `"All zero response"', modify
	label define NUMWORK_WLE_CA 1 `"Lowest to 20%"', modify
	label define NUMWORK_WLE_CA 2 `"More than 20% to 40%"', modify
	label define NUMWORK_WLE_CA 3 `"More than 40% to 60%"', modify
	label define NUMWORK_WLE_CA 4 `"More than 60% to 80%"', modify
	label define NUMWORK_WLE_CA 5 `"More than 80%"', modify
	label define NUMHOME_WLE_CA 0 `"All zero response"', modify
	label define NUMHOME_WLE_CA 1 `"Lowest to 20%"', modify
	label define NUMHOME_WLE_CA 2 `"More than 20% to 40%"', modify
	label define NUMHOME_WLE_CA 3 `"More than 40% to 60%"', modify
	label define NUMHOME_WLE_CA 4 `"More than 60% to 80%"', modify
	label define NUMHOME_WLE_CA 5 `"More than 80%"', modify
	label define INFLUENCE_WLE_CA 0 `"All zero response"', modify
	label define INFLUENCE_WLE_CA 1 `"Lowest to 20%"', modify
	label define INFLUENCE_WLE_CA 2 `"More than 20% to 40%"', modify
	label define INFLUENCE_WLE_CA 3 `"More than 40% to 60%"', modify
	label define INFLUENCE_WLE_CA 4 `"More than 60% to 80%"', modify
	label define INFLUENCE_WLE_CA 5 `"More than 80%"', modify
	label define ICTWORK_WLE_CA 0 `"All zero response"', modify
	label define ICTWORK_WLE_CA 1 `"Lowest to 20%"', modify
	label define ICTWORK_WLE_CA 2 `"More than 20% to 40%"', modify
	label define ICTWORK_WLE_CA 3 `"More than 40% to 60%"', modify
	label define ICTWORK_WLE_CA 4 `"More than 60% to 80%"', modify
	label define ICTWORK_WLE_CA 5 `"More than 80%"', modify
	label define ICTHOME_WLE_CA 0 `"All zero response"', modify
	label define ICTHOME_WLE_CA 1 `"Lowest to 20%"', modify
	label define ICTHOME_WLE_CA 2 `"More than 20% to 40%"', modify
	label define ICTHOME_WLE_CA 3 `"More than 40% to 60%"', modify
	label define ICTHOME_WLE_CA 4 `"More than 60% to 80%"', modify
	label define ICTHOME_WLE_CA 5 `"More than 80%"', modify
	label define READYTOLEARN_WLE_CA 0 `"All zero response"', modify
	label define READYTOLEARN_WLE_CA 1 `"Lowest to 20%"', modify
	label define READYTOLEARN_WLE_CA 2 `"More than 20% to 40%"', modify
	label define READYTOLEARN_WLE_CA 3 `"More than 40% to 60%"', modify
	label define READYTOLEARN_WLE_CA 4 `"More than 60% to 80%"', modify
	label define READYTOLEARN_WLE_CA 5 `"More than 80%"', modify
	label define LEARNATWORK_WLE_CA 0 `"All zero response"', modify
	label define LEARNATWORK_WLE_CA 1 `"Lowest to 20%"', modify
	label define LEARNATWORK_WLE_CA 2 `"More than 20% to 40%"', modify
	label define LEARNATWORK_WLE_CA 3 `"More than 40% to 60%"', modify
	label define LEARNATWORK_WLE_CA 4 `"More than 60% to 80%"', modify
	label define LEARNATWORK_WLE_CA 5 `"More than 80%"', modify
	label define EARNFLAG 1 `"Reported directly"', modify
	label define EARNFLAG 2 `"Earnings and/or bonuses imputed"', modify
	label define EARNMTHALLDCL 1 `"Lowest decile"', modify
	label define EARNMTHALLDCL 2 `"9th decile"', modify
	label define EARNMTHALLDCL 3 `"8th decile"', modify
	label define EARNMTHALLDCL 4 `"7th decile"', modify
	label define EARNMTHALLDCL 5 `"6th decile"', modify
	label define EARNMTHALLDCL 6 `"5th decile"', modify
	label define EARNMTHALLDCL 7 `"4th decile"', modify
	label define EARNMTHALLDCL 8 `"3rd decile"', modify
	label define EARNMTHALLDCL 9 `"2nd decile"', modify
	label define EARNMTHALLDCL 10 `"Highest decile"', modify
	label define EARNHRBONUSDCL 1 `"Lowest decile"', modify
	label define EARNHRBONUSDCL 2 `"9th decile"', modify
	label define EARNHRBONUSDCL 3 `"8th decile"', modify
	label define EARNHRBONUSDCL 4 `"7th decile"', modify
	label define EARNHRBONUSDCL 5 `"6th decile"', modify
	label define EARNHRBONUSDCL 6 `"5th decile"', modify
	label define EARNHRBONUSDCL 7 `"4th decile"', modify
	label define EARNHRBONUSDCL 8 `"3rd decile"', modify
	label define EARNHRBONUSDCL 9 `"2nd decile"', modify
	label define EARNHRBONUSDCL 10 `"Highest decile"', modify
	label define EARNHRDCL 1 `"Lowest decile"', modify
	label define EARNHRDCL 2 `"9th decile"', modify
	label define EARNHRDCL 3 `"8th decile"', modify
	label define EARNHRDCL 4 `"7th decile"', modify
	label define EARNHRDCL 5 `"6th decile"', modify
	label define EARNHRDCL 6 `"5th decile"', modify
	label define EARNHRDCL 7 `"4th decile"', modify
	label define EARNHRDCL 8 `"3rd decile"', modify
	label define EARNHRDCL 9 `"2nd decile"', modify
	label define EARNHRDCL 10 `"Highest decile"', modify
	label define ISCOSKIL4 1 `"Skilled occupations"', modify
	label define ISCOSKIL4 2 `"Semi-skilled white-collar occupations"', modify
	label define ISCOSKIL4 3 `"Semi-skilled blue-collar occupations"', modify
	label define ISCOSKIL4 4 `"Elementary occupations"', modify
	label define PAIDWORK5 0 `"Has not had paid work in past 5 years"', modify
	label define PAIDWORK5 1 `"Has had paid work in past 5 years"', modify
	label define PAIDWORK12 0 `"Has not had paid work during the 12 months preceding the survey"', modify
	label define PAIDWORK12 1 `"Has had paid work during the 12 months preceding the survey"', modify
	label define NOPAIDWORKEVER 0 `"Has had paid work"', modify
	label define NOPAIDWORKEVER 1 `"Has not has paid work ever"', modify
	label define NEET 0 `"Employed or participated in education or training in last 12 months"', modify
	label define NEET 1 `"Not currently employed and did not participate in education or training in last 12 months (NEET)"', modify
	label define EDWORK 1 `"In education only"', modify
	label define EDWORK 2 `"In education and work"', modify
	label define EDWORK 3 `"In work only"', modify
	label define EDWORK 4 `"Not in education or work but has participated in education or training in last 12 months"', modify
	label define EDWORK 5 `"Not in education or work and has not participated in education or training in last 12 months (NEET)"', modify
	label define FNFAET12 0 `"Did not participate in formal or non-formal AET"', modify
	label define FNFAET12 1 `"Participated in formal and/or non-formal AET"', modify
	label define NFE12 0 `"Did not participate in NFE"', modify
	label define NFE12 1 `"Participated in NFE"', modify
	label define FAET12NJR 0 `"Did not participate in FE for NJR reasons"', modify
	label define FAET12NJR 1 `"Participated in FE for NJR reasons"', modify
	label define FAET12JR 0 `"Did not participate in formal AET for JR reasons"', modify
	label define FAET12JR 1 `"Participated in formal AET for JR reasons"', modify
	label define FAET12 0 `"Did not participate in formal AET"', modify
	label define FAET12 1 `"Participated in formal AET"', modify
	label define AETPOP 0 `"Excluded from AET population"', modify
	label define AETPOP 1 `"AET population"', modify
	label define FE12 0 `"Did not participate in FE"', modify
	label define FE12 1 `"Participated in FE"', modify
	label define LEAVER1624 0 `"Completed ISCED 3 or is still in education, aged 16 to 24"', modify
	label define LEAVER1624 1 `"Not in education, did not complete ISCED 3, aged 16 to 24"', modify
	label define EDCAT6 1 `"Lower secondary or less (ISCED 1,2, 3C short or less) "', modify
	label define EDCAT6 2 `"Upper secondary (ISCED 3A-B, C long)"', modify
	label define EDCAT6 3 `"Post-secondary, non-tertiary (ISCED 4A-B-C)"', modify
	label define EDCAT6 4 `"Tertiary – professional degree (ISCED 5B)"', modify
	label define EDCAT6 5 `"Tertiary – bachelor degree (ISCED 5A)"', modify
	label define EDCAT6 6 `"Tertiary – master/research degree (ISCED 5A/6)"', modify
	label define EDCAT6 7 `"Tertiary - bachelor/master/research degree (ISCED 5A/6)"', modify
	label define EDCAT7 1 `"Primary or less (ISCED 1 or less)"', modify
	label define EDCAT7 2 `"Lower secondary (ISCED 2, ISCED 3C short)"', modify
	label define EDCAT7 3 `"Upper secondary (ISCED 3A-B, C long)"', modify
	label define EDCAT7 4 `"Post-secondary, non-tertiary (ISCED 4A-B-C)"', modify
	label define EDCAT7 5 `"Tertiary – professional degree (ISCED 5B)"', modify
	label define EDCAT7 6 `"Tertiary – bachelor degree (ISCED 5A)"', modify
	label define EDCAT7 7 `"Tertiary – master/research degree (ISCED 5A/6) "', modify
	label define EDCAT7 8 `"Tertiary - bachelor/master/research degree (ISCED 5A/6)"', modify
	label define EDCAT8 1 `"Primary or less (ISCED 1 or less)"', modify
	label define EDCAT8 2 `"Lower secondary (ISCED 2, ISCED 3C short)"', modify
	label define EDCAT8 3 `"Upper secondary (ISCED 3A-B, C long)"', modify
	label define EDCAT8 4 `"Post-secondary, non-tertiary (ISCED 4A-B-C)"', modify
	label define EDCAT8 5 `"Tertiary – professional degree (ISCED 5B)"', modify
	label define EDCAT8 6 `"Tertiary – bachelor degree (ISCED 5A)"', modify
	label define EDCAT8 7 `"Tertiary – master degree (ISCED 5A)"', modify
	label define EDCAT8 8 `"Tertiary – research degree (ISCED 6)"', modify
	label define EDCAT8 9 `"Tertiary - bachelor/master/research degree (ISCED 5A/6)"', modify
	label define AGEG10LFS_T 1 `"24 or less"', modify
	label define AGEG10LFS_T 2 `"25-34"', modify
	label define AGEG10LFS_T 3 `"35-44"', modify
	label define AGEG10LFS_T 4 `"45-54"', modify
	label define AGEG10LFS_T 5 `"55 plus"', modify
	label define AGEG10LFS 1 `"24 or less"', modify
	label define AGEG10LFS 2 `"25-34"', modify
	label define AGEG10LFS 3 `"35-44"', modify
	label define AGEG10LFS 4 `"45-54"', modify
	label define AGEG10LFS 5 `"55 plus"', modify
	label define AGEG5LFS 1 `"Aged 16-19"', modify
	label define AGEG5LFS 2 `"Aged 20-24"', modify
	label define AGEG5LFS 3 `"Aged 25-29"', modify
	label define AGEG5LFS 4 `"Aged 30-34"', modify
	label define AGEG5LFS 5 `"Aged 35-39"', modify
	label define AGEG5LFS 6 `"Aged 40-44"', modify
	label define AGEG5LFS 7 `"Aged 45-49"', modify
	label define AGEG5LFS 8 `"Aged 50-54"', modify
	label define AGEG5LFS 9 `"Aged 55-59"', modify
	label define AGEG5LFS 10 `"Aged 60-65"', modify
	label define IMYRCAT 1 `"In host country 5 or fewer years"', modify
	label define IMYRCAT 2 `"In host country more than 5 years"', modify
	label define IMYRCAT 3 `"Non-immigrants"', modify
	label define IMYRS_C 1 `"0-5 years"', modify
	label define IMYRS_C 2 `"6-10 years"', modify
	label define IMYRS_C 3 `"11-15 years"', modify
	label define IMYRS_C 4 `"more than 15 years"', modify
	label define IMGEN 1 `"1st generation immigrants"', modify
	label define IMGEN 2 `"2nd generation immigrants"', modify
	label define IMGEN 3 `"Non 1st or 2nd generation immigrants"', modify
	label define IMPAR 1 `"Both parents foreign-born"', modify
	label define IMPAR 2 `"One parent foreign-born"', modify
	label define IMPAR 3 `"Both parents native-born"', modify
	label define CTRYRGN 1 `"Arab States"', modify
	label define CTRYRGN 2 `"South and West Asia"', modify
	label define CTRYRGN 3 `"Latin America and the Caribbean"', modify
	label define CTRYRGN 4 `"Sub-Saharan Africa"', modify
	label define CTRYRGN 5 `"East Asia and the Pacific (poorer countries)"', modify
	label define CTRYRGN 6 `"Central Asia"', modify
	label define CTRYRGN 7 `"East Asia and the Pacific (richer countries)"', modify
	label define CTRYRGN 8 `"Central and Eastern Europe"', modify
	label define CTRYRGN 9 `"North America and Western Europe"', modify
	label define HOMLANG 0 `"Test language not same as home language"', modify
	label define HOMLANG 1 `"Test language same as home language"', modify
	label define FORBILANG 0 `"Monolingual or at least bilingual including test language"', modify
	label define FORBILANG 1 `"At least bilingual not including test language"', modify
	label define NATBILANG 0 `"Monolingual or at least bilingual not including test language"', modify
	label define NATBILANG 1 `"At least bilingual including test language"', modify
	label define BORNLANG 1 `"Native-born and native-language"', modify
	label define BORNLANG 2 `"Native-born and foreign-language"', modify
	label define BORNLANG 3 `"Foreign-born and native-language"', modify
	label define BORNLANG 4 `"Foreign-born and foreign-language"', modify
	label define NATIVELANG 0 `"Test language not same as native language"', modify
	label define NATIVELANG 1 `"Test language same as native language"', modify
	label define PARED 1 `"Neither parent has attained upper secondary"', modify
	label define PARED 2 `"At least one parent has attained secondary and post-secondary, non-tertiary"', modify
	label define PARED 3 `"At least one parent has attained tertiary"', modify
	label define FORBORNLANG 0 `"Either native-born or native-language"', modify
	label define FORBORNLANG 1 `"Foreign-born and foreign-language"', modify
	label define HOMLGRGN 1 `"Arab States"', modify
	label define HOMLGRGN 2 `"South and West Asia"', modify
	label define HOMLGRGN 3 `"Latin America and the Caribbean"', modify
	label define HOMLGRGN 4 `"Sub-Saharan Africa"', modify
	label define HOMLGRGN 5 `"East Asia and the Pacific (poorer countries)"', modify
	label define HOMLGRGN 6 `"Central Asia"', modify
	label define HOMLGRGN 7 `"East Asia and the Pacific (richer countries)"', modify
	label define HOMLGRGN 8 `"Central and Eastern Europe"', modify
	label define HOMLGRGN 9 `"North America and Western Europe"', modify
	label define SECLGRGN 1 `"Arab States"', modify
	label define SECLGRGN 2 `"South and West Asia"', modify
	label define SECLGRGN 3 `"Latin America and the Caribbean"', modify
	label define SECLGRGN 4 `"Sub-Saharan Africa"', modify
	label define SECLGRGN 5 `"East Asia and the Pacific (poorer countries)"', modify
	label define SECLGRGN 6 `"Central Asia"', modify
	label define SECLGRGN 7 `"East Asia and the Pacific (richer countries)"', modify
	label define SECLGRGN 8 `"Central and Eastern Europe"', modify
	label define SECLGRGN 9 `"North America and Western Europe"', modify
	label define FIRLGRGN 1 `"Arab States"', modify
	label define FIRLGRGN 2 `"South and West Asia"', modify
	label define FIRLGRGN 3 `"Latin America and the Caribbean"', modify
	label define FIRLGRGN 4 `"Sub-Saharan Africa"', modify
	label define FIRLGRGN 5 `"East Asia and the Pacific (poorer countries)"', modify
	label define FIRLGRGN 6 `"Central Asia"', modify
	label define FIRLGRGN 7 `"East Asia and the Pacific (richer countries)"', modify
	label define FIRLGRGN 8 `"Central and Eastern Europe"', modify
	label define FIRLGRGN 9 `"North America and Western Europe"', modify
	label define BIRTHRGN 1 `"Arab States"', modify
	label define BIRTHRGN 2 `"South and West Asia"', modify
	label define BIRTHRGN 3 `"Latin America and the Caribbean"', modify
	label define BIRTHRGN 4 `"Sub-Saharan Africa"', modify
	label define BIRTHRGN 5 `"East Asia and the Pacific (poorer countries)"', modify
	label define BIRTHRGN 6 `"Central Asia"', modify
	label define BIRTHRGN 7 `"East Asia and the Pacific (richer countries)"', modify
	label define BIRTHRGN 8 `"Central and Eastern Europe"', modify
	label define BIRTHRGN 9 `"North America and Western Europe"', modify
	label define CTRYQUAL 1 `"Arab States"', modify
	label define CTRYQUAL 2 `"South and West Asia"', modify
	label define CTRYQUAL 3 `"Latin America and the Caribbean"', modify
	label define CTRYQUAL 4 `"Sub-Saharan Africa"', modify
	label define CTRYQUAL 5 `"East Asia and the Pacific (poorer countries)"', modify
	label define CTRYQUAL 6 `"Central Asia"', modify
	label define CTRYQUAL 7 `"East Asia and the Pacific (richer countries)"', modify
	label define CTRYQUAL 8 `"Central and Eastern Europe"', modify
	label define CTRYQUAL 9 `"North America and Western Europe"', modify
	label define VET 0 `"False"', modify
	label define VET 1 `"True"', modify
	label define CNT_BRTH 4 `"Afghanistan"', modify
	label define CNT_BRTH 8 `"Albania"', modify
	label define CNT_BRTH 12 `"Algeria"', modify
	label define CNT_BRTH 16 `"American Samoa"', modify
	label define CNT_BRTH 20 `"Andorra"', modify
	label define CNT_BRTH 24 `"Angola"', modify
	label define CNT_BRTH 28 `"Antigua and Barbuda"', modify
	label define CNT_BRTH 31 `"Azerbaijan"', modify
	label define CNT_BRTH 32 `"Argentina"', modify
	label define CNT_BRTH 36 `"Australia"', modify
	label define CNT_BRTH 40 `"Austria"', modify
	label define CNT_BRTH 44 `"Bahamas"', modify
	label define CNT_BRTH 48 `"Bahrain"', modify
	label define CNT_BRTH 50 `"Bangladesh"', modify
	label define CNT_BRTH 51 `"Armenia"', modify
	label define CNT_BRTH 52 `"Barbados"', modify
	label define CNT_BRTH 56 `"Belgium"', modify
	label define CNT_BRTH 60 `"Bermuda"', modify
	label define CNT_BRTH 64 `"Bhutan"', modify
	label define CNT_BRTH 68 `"Bolivia"', modify
	label define CNT_BRTH 70 `"Bosnia and Herzegovina"', modify
	label define CNT_BRTH 72 `"Botswana"', modify
	label define CNT_BRTH 76 `"Brazil"', modify
	label define CNT_BRTH 84 `"Belize"', modify
	label define CNT_BRTH 90 `"Solomon Islands"', modify
	label define CNT_BRTH 92 `"British Virgin Islands"', modify
	label define CNT_BRTH 96 `"Brunei Darussalam"', modify
	label define CNT_BRTH 100 `"Bulgaria"', modify
	label define CNT_BRTH 104 `"Myanmar"', modify
	label define CNT_BRTH 108 `"Burundi"', modify
	label define CNT_BRTH 112 `"Belarus"', modify
	label define CNT_BRTH 116 `"Cambodia"', modify
	label define CNT_BRTH 120 `"Cameroon"', modify
	label define CNT_BRTH 124 `"Canada"', modify
	label define CNT_BRTH 132 `"Cape Verde"', modify
	label define CNT_BRTH 136 `"Cayman Islands"', modify
	label define CNT_BRTH 140 `"Central African Republic"', modify
	label define CNT_BRTH 144 `"Sri Lanka"', modify
	label define CNT_BRTH 148 `"Chad"', modify
	label define CNT_BRTH 152 `"Chile"', modify
	label define CNT_BRTH 156 `"China"', modify
	label define CNT_BRTH 170 `"Colombia"', modify
	label define CNT_BRTH 174 `"Comoros"', modify
	label define CNT_BRTH 175 `"Mayotte"', modify
	label define CNT_BRTH 178 `"Congo"', modify
	label define CNT_BRTH 180 `"Democratic Republic of the Congo"', modify
	label define CNT_BRTH 184 `"Cook Islands"', modify
	label define CNT_BRTH 188 `"Costa Rica"', modify
	label define CNT_BRTH 191 `"Croatia"', modify
	label define CNT_BRTH 192 `"Cuba"', modify
	label define CNT_BRTH 196 `"Cyprus"', modify
	label define CNT_BRTH 203 `"Czech Republic"', modify
	label define CNT_BRTH 204 `"Benin"', modify
	label define CNT_BRTH 208 `"Denmark"', modify
	label define CNT_BRTH 212 `"Dominica"', modify
	label define CNT_BRTH 214 `"Dominican Republic"', modify
	label define CNT_BRTH 218 `"Ecuador"', modify
	label define CNT_BRTH 222 `"El Salvador"', modify
	label define CNT_BRTH 226 `"Equatorial Guinea"', modify
	label define CNT_BRTH 231 `"Ethiopia"', modify
	label define CNT_BRTH 232 `"Eritrea"', modify
	label define CNT_BRTH 233 `"Estonia"', modify
	label define CNT_BRTH 234 `"Faeroe Islands"', modify
	label define CNT_BRTH 238 `"Falkland Islands (Malvinas)"', modify
	label define CNT_BRTH 242 `"Fiji"', modify
	label define CNT_BRTH 246 `"Finland"', modify
	label define CNT_BRTH 248 `"Åland Islands"', modify
	label define CNT_BRTH 250 `"France"', modify
	label define CNT_BRTH 254 `"French Guiana"', modify
	label define CNT_BRTH 258 `"French Polynesia"', modify
	label define CNT_BRTH 262 `"Djibouti"', modify
	label define CNT_BRTH 266 `"Gabon"', modify
	label define CNT_BRTH 268 `"Georgia"', modify
	label define CNT_BRTH 270 `"Gambia"', modify
	label define CNT_BRTH 275 `"Occupied Palestinian Territory"', modify
	label define CNT_BRTH 276 `"Germany"', modify
	label define CNT_BRTH 288 `"Ghana"', modify
	label define CNT_BRTH 292 `"Gibraltar"', modify
	label define CNT_BRTH 296 `"Kiribati"', modify
	label define CNT_BRTH 300 `"Greece"', modify
	label define CNT_BRTH 304 `"Greenland"', modify
	label define CNT_BRTH 308 `"Grenada"', modify
	label define CNT_BRTH 312 `"Guadeloupe"', modify
	label define CNT_BRTH 316 `"Guam"', modify
	label define CNT_BRTH 320 `"Guatemala"', modify
	label define CNT_BRTH 324 `"Guinea"', modify
	label define CNT_BRTH 328 `"Guyana"', modify
	label define CNT_BRTH 332 `"Haiti"', modify
	label define CNT_BRTH 336 `"Holy See"', modify
	label define CNT_BRTH 340 `"Honduras"', modify
	label define CNT_BRTH 344 `"Hong Kong Special Administrative Region of China"', modify
	label define CNT_BRTH 348 `"Hungary"', modify
	label define CNT_BRTH 352 `"Iceland"', modify
	label define CNT_BRTH 356 `"India"', modify
	label define CNT_BRTH 360 `"Indonesia"', modify
	label define CNT_BRTH 364 `"Iran, Islamic Republic of"', modify
	label define CNT_BRTH 368 `"Iraq"', modify
	label define CNT_BRTH 372 `"Ireland"', modify
	label define CNT_BRTH 376 `"Israel"', modify
	label define CNT_BRTH 380 `"Italy"', modify
	label define CNT_BRTH 384 `"Côte d'Ivoire"', modify
	label define CNT_BRTH 388 `"Jamaica"', modify
	label define CNT_BRTH 392 `"Japan"', modify
	label define CNT_BRTH 398 `"Kazakhstan"', modify
	label define CNT_BRTH 400 `"Jordan"', modify
	label define CNT_BRTH 404 `"Kenya"', modify
	label define CNT_BRTH 408 `"Democratic People's Republic of Korea"', modify
	label define CNT_BRTH 410 `"Republic of Korea"', modify
	label define CNT_BRTH 414 `"Kuwait"', modify
	label define CNT_BRTH 417 `"Kyrgyzstan"', modify
	label define CNT_BRTH 418 `"Lao People's Democratic Republic"', modify
	label define CNT_BRTH 422 `"Lebanon"', modify
	label define CNT_BRTH 426 `"Lesotho"', modify
	label define CNT_BRTH 428 `"Latvia"', modify
	label define CNT_BRTH 430 `"Liberia"', modify
	label define CNT_BRTH 434 `"Libyan Arab Jamahiriya"', modify
	label define CNT_BRTH 438 `"Liechtenstein"', modify
	label define CNT_BRTH 440 `"Lithuania"', modify
	label define CNT_BRTH 442 `"Luxembourg"', modify
	label define CNT_BRTH 446 `"Macao Special Administrative Region of China"', modify
	label define CNT_BRTH 450 `"Madagascar"', modify
	label define CNT_BRTH 454 `"Malawi"', modify
	label define CNT_BRTH 458 `"Malaysia"', modify
	label define CNT_BRTH 462 `"Maldives"', modify
	label define CNT_BRTH 466 `"Mali"', modify
	label define CNT_BRTH 470 `"Malta"', modify
	label define CNT_BRTH 474 `"Martinique"', modify
	label define CNT_BRTH 478 `"Mauritania"', modify
	label define CNT_BRTH 480 `"Mauritius"', modify
	label define CNT_BRTH 484 `"Mexico"', modify
	label define CNT_BRTH 492 `"Monaco"', modify
	label define CNT_BRTH 496 `"Mongolia"', modify
	label define CNT_BRTH 498 `"Republic of Moldova"', modify
	label define CNT_BRTH 499 `"Montenegro"', modify
	label define CNT_BRTH 500 `"Montserrat"', modify
	label define CNT_BRTH 504 `"Morocco"', modify
	label define CNT_BRTH 508 `"Mozambique"', modify
	label define CNT_BRTH 512 `"Oman"', modify
	label define CNT_BRTH 516 `"Namibia"', modify
	label define CNT_BRTH 520 `"Nauru"', modify
	label define CNT_BRTH 524 `"Nepal"', modify
	label define CNT_BRTH 528 `"Netherlands"', modify
	label define CNT_BRTH 530 `"Netherlands Antilles"', modify
	label define CNT_BRTH 533 `"Aruba"', modify
	label define CNT_BRTH 540 `"New Caledonia"', modify
	label define CNT_BRTH 548 `"Vanuatu"', modify
	label define CNT_BRTH 554 `"New Zealand"', modify
	label define CNT_BRTH 558 `"Nicaragua"', modify
	label define CNT_BRTH 562 `"Niger"', modify
	label define CNT_BRTH 566 `"Nigeria"', modify
	label define CNT_BRTH 570 `"Niue"', modify
	label define CNT_BRTH 574 `"Norfolk Island"', modify
	label define CNT_BRTH 578 `"Norway"', modify
	label define CNT_BRTH 580 `"Northern Mariana Islands"', modify
	label define CNT_BRTH 583 `"Micronesia, Federated States of"', modify
	label define CNT_BRTH 584 `"Marshall Islands"', modify
	label define CNT_BRTH 585 `"Palau"', modify
	label define CNT_BRTH 586 `"Pakistan"', modify
	label define CNT_BRTH 591 `"Panama"', modify
	label define CNT_BRTH 598 `"Papua New Guinea"', modify
	label define CNT_BRTH 600 `"Paraguay"', modify
	label define CNT_BRTH 604 `"Peru"', modify
	label define CNT_BRTH 608 `"Philippines"', modify
	label define CNT_BRTH 612 `"Pitcairn"', modify
	label define CNT_BRTH 616 `"Poland"', modify
	label define CNT_BRTH 620 `"Portugal"', modify
	label define CNT_BRTH 624 `"Guinea-Bissau"', modify
	label define CNT_BRTH 626 `"Timor-Leste"', modify
	label define CNT_BRTH 630 `"Puerto Rico"', modify
	label define CNT_BRTH 634 `"Qatar"', modify
	label define CNT_BRTH 638 `"Réunion"', modify
	label define CNT_BRTH 642 `"Romania"', modify
	label define CNT_BRTH 643 `"Russian Federation"', modify
	label define CNT_BRTH 646 `"Rwanda"', modify
	label define CNT_BRTH 652 `"Saint-Barthélemy"', modify
	label define CNT_BRTH 654 `"Saint Helena"', modify
	label define CNT_BRTH 659 `"Saint Kitts and Nevis"', modify
	label define CNT_BRTH 660 `"Anguilla"', modify
	label define CNT_BRTH 662 `"Saint Lucia"', modify
	label define CNT_BRTH 663 `"Saint-Martin (French part)"', modify
	label define CNT_BRTH 666 `"Saint Pierre and Miquelon"', modify
	label define CNT_BRTH 670 `"Saint Vincent and the Grenadines"', modify
	label define CNT_BRTH 674 `"San Marino"', modify
	label define CNT_BRTH 678 `"Sao Tome and Principe"', modify
	label define CNT_BRTH 682 `"Saudi Arabia"', modify
	label define CNT_BRTH 686 `"Senegal"', modify
	label define CNT_BRTH 688 `"Serbia"', modify
	label define CNT_BRTH 690 `"Seychelles"', modify
	label define CNT_BRTH 694 `"Sierra Leone"', modify
	label define CNT_BRTH 702 `"Singapore"', modify
	label define CNT_BRTH 703 `"Slovakia"', modify
	label define CNT_BRTH 704 `"Viet Nam"', modify
	label define CNT_BRTH 705 `"Slovenia"', modify
	label define CNT_BRTH 706 `"Somalia"', modify
	label define CNT_BRTH 710 `"South Africa"', modify
	label define CNT_BRTH 716 `"Zimbabwe"', modify
	label define CNT_BRTH 724 `"Spain"', modify
	label define CNT_BRTH 732 `"Western Sahara"', modify
	label define CNT_BRTH 736 `"Sudan"', modify
	label define CNT_BRTH 740 `"Suriname"', modify
	label define CNT_BRTH 744 `"Svalbard and Jan Mayen Islands"', modify
	label define CNT_BRTH 748 `"Swaziland"', modify
	label define CNT_BRTH 752 `"Sweden"', modify
	label define CNT_BRTH 756 `"Switzerland"', modify
	label define CNT_BRTH 760 `"Syrian Arab Republic"', modify
	label define CNT_BRTH 762 `"Tajikistan"', modify
	label define CNT_BRTH 764 `"Thailand"', modify
	label define CNT_BRTH 768 `"Togo"', modify
	label define CNT_BRTH 772 `"Tokelau"', modify
	label define CNT_BRTH 776 `"Tonga"', modify
	label define CNT_BRTH 780 `"Trinidad and Tobago"', modify
	label define CNT_BRTH 784 `"United Arab Emirates"', modify
	label define CNT_BRTH 788 `"Tunisia"', modify
	label define CNT_BRTH 792 `"Turkey"', modify
	label define CNT_BRTH 795 `"Turkmenistan"', modify
	label define CNT_BRTH 796 `"Turks and Caicos Islands"', modify
	label define CNT_BRTH 798 `"Tuvalu"', modify
	label define CNT_BRTH 800 `"Uganda"', modify
	label define CNT_BRTH 804 `"Ukraine"', modify
	label define CNT_BRTH 807 `"The former Yugoslav Republic of Macedonia"', modify
	label define CNT_BRTH 818 `"Egypt"', modify
	label define CNT_BRTH 826 `"United Kingdom of Great Britain and Northern Ireland"', modify
	label define CNT_BRTH 830 `"Channel Islands"', modify
	label define CNT_BRTH 831 `"Guernsey"', modify
	label define CNT_BRTH 832 `"Jersey"', modify
	label define CNT_BRTH 833 `"Isle of Man"', modify
	label define CNT_BRTH 834 `"United Republic of Tanzania"', modify
	label define CNT_BRTH 840 `"United States of America"', modify
	label define CNT_BRTH 850 `"United States Virgin Islands"', modify
	label define CNT_BRTH 854 `"Burkina Faso"', modify
	label define CNT_BRTH 858 `"Uruguay"', modify
	label define CNT_BRTH 860 `"Uzbekistan"', modify
	label define CNT_BRTH 862 `"Venezuela (Bolivarian Republic of)"', modify
	label define CNT_BRTH 876 `"Wallis and Futuna Islands"', modify
	label define CNT_BRTH 882 `"Samoa"', modify
	label define CNT_BRTH 887 `"Yemen"', modify
	label define CNT_BRTH 894 `"Zambia"', modify
	label define CNT_H 4 `"Afghanistan"', modify
	label define CNT_H 8 `"Albania"', modify
	label define CNT_H 12 `"Algeria"', modify
	label define CNT_H 16 `"American Samoa"', modify
	label define CNT_H 20 `"Andorra"', modify
	label define CNT_H 24 `"Angola"', modify
	label define CNT_H 28 `"Antigua and Barbuda"', modify
	label define CNT_H 31 `"Azerbaijan"', modify
	label define CNT_H 32 `"Argentina"', modify
	label define CNT_H 36 `"Australia"', modify
	label define CNT_H 40 `"Austria"', modify
	label define CNT_H 44 `"Bahamas"', modify
	label define CNT_H 48 `"Bahrain"', modify
	label define CNT_H 50 `"Bangladesh"', modify
	label define CNT_H 51 `"Armenia"', modify
	label define CNT_H 52 `"Barbados"', modify
	label define CNT_H 56 `"Belgium"', modify
	label define CNT_H 60 `"Bermuda"', modify
	label define CNT_H 64 `"Bhutan"', modify
	label define CNT_H 68 `"Bolivia"', modify
	label define CNT_H 70 `"Bosnia and Herzegovina"', modify
	label define CNT_H 72 `"Botswana"', modify
	label define CNT_H 76 `"Brazil"', modify
	label define CNT_H 84 `"Belize"', modify
	label define CNT_H 90 `"Solomon Islands"', modify
	label define CNT_H 92 `"British Virgin Islands"', modify
	label define CNT_H 96 `"Brunei Darussalam"', modify
	label define CNT_H 100 `"Bulgaria"', modify
	label define CNT_H 104 `"Myanmar"', modify
	label define CNT_H 108 `"Burundi"', modify
	label define CNT_H 112 `"Belarus"', modify
	label define CNT_H 116 `"Cambodia"', modify
	label define CNT_H 120 `"Cameroon"', modify
	label define CNT_H 124 `"Canada"', modify
	label define CNT_H 132 `"Cape Verde"', modify
	label define CNT_H 136 `"Cayman Islands"', modify
	label define CNT_H 140 `"Central African Republic"', modify
	label define CNT_H 144 `"Sri Lanka"', modify
	label define CNT_H 148 `"Chad"', modify
	label define CNT_H 152 `"Chile"', modify
	label define CNT_H 156 `"China"', modify
	label define CNT_H 170 `"Colombia"', modify
	label define CNT_H 174 `"Comoros"', modify
	label define CNT_H 175 `"Mayotte"', modify
	label define CNT_H 178 `"Congo"', modify
	label define CNT_H 180 `"Democratic Republic of the Congo"', modify
	label define CNT_H 184 `"Cook Islands"', modify
	label define CNT_H 188 `"Costa Rica"', modify
	label define CNT_H 191 `"Croatia"', modify
	label define CNT_H 192 `"Cuba"', modify
	label define CNT_H 196 `"Cyprus"', modify
	label define CNT_H 203 `"Czech Republic"', modify
	label define CNT_H 204 `"Benin"', modify
	label define CNT_H 208 `"Denmark"', modify
	label define CNT_H 212 `"Dominica"', modify
	label define CNT_H 214 `"Dominican Republic"', modify
	label define CNT_H 218 `"Ecuador"', modify
	label define CNT_H 222 `"El Salvador"', modify
	label define CNT_H 226 `"Equatorial Guinea"', modify
	label define CNT_H 231 `"Ethiopia"', modify
	label define CNT_H 232 `"Eritrea"', modify
	label define CNT_H 233 `"Estonia"', modify
	label define CNT_H 234 `"Faeroe Islands"', modify
	label define CNT_H 238 `"Falkland Islands (Malvinas)"', modify
	label define CNT_H 242 `"Fiji"', modify
	label define CNT_H 246 `"Finland"', modify
	label define CNT_H 248 `"Åland Islands"', modify
	label define CNT_H 250 `"France"', modify
	label define CNT_H 254 `"French Guiana"', modify
	label define CNT_H 258 `"French Polynesia"', modify
	label define CNT_H 262 `"Djibouti"', modify
	label define CNT_H 266 `"Gabon"', modify
	label define CNT_H 268 `"Georgia"', modify
	label define CNT_H 270 `"Gambia"', modify
	label define CNT_H 275 `"Occupied Palestinian Territory"', modify
	label define CNT_H 276 `"Germany"', modify
	label define CNT_H 288 `"Ghana"', modify
	label define CNT_H 292 `"Gibraltar"', modify
	label define CNT_H 296 `"Kiribati"', modify
	label define CNT_H 300 `"Greece"', modify
	label define CNT_H 304 `"Greenland"', modify
	label define CNT_H 308 `"Grenada"', modify
	label define CNT_H 312 `"Guadeloupe"', modify
	label define CNT_H 316 `"Guam"', modify
	label define CNT_H 320 `"Guatemala"', modify
	label define CNT_H 324 `"Guinea"', modify
	label define CNT_H 328 `"Guyana"', modify
	label define CNT_H 332 `"Haiti"', modify
	label define CNT_H 336 `"Holy See"', modify
	label define CNT_H 340 `"Honduras"', modify
	label define CNT_H 344 `"Hong Kong Special Administrative Region of China"', modify
	label define CNT_H 348 `"Hungary"', modify
	label define CNT_H 352 `"Iceland"', modify
	label define CNT_H 356 `"India"', modify
	label define CNT_H 360 `"Indonesia"', modify
	label define CNT_H 364 `"Iran, Islamic Republic of"', modify
	label define CNT_H 368 `"Iraq"', modify
	label define CNT_H 372 `"Ireland"', modify
	label define CNT_H 376 `"Israel"', modify
	label define CNT_H 380 `"Italy"', modify
	label define CNT_H 384 `"Côte d'Ivoire"', modify
	label define CNT_H 388 `"Jamaica"', modify
	label define CNT_H 392 `"Japan"', modify
	label define CNT_H 398 `"Kazakhstan"', modify
	label define CNT_H 400 `"Jordan"', modify
	label define CNT_H 404 `"Kenya"', modify
	label define CNT_H 408 `"Democratic People`'s Republic of Korea"', modify
	label define CNT_H 410 `"Republic of Korea"', modify
	label define CNT_H 414 `"Kuwait"', modify
	label define CNT_H 417 `"Kyrgyzstan"', modify
	label define CNT_H 418 `"Lao People`'s Democratic Republic"', modify
	label define CNT_H 422 `"Lebanon"', modify
	label define CNT_H 426 `"Lesotho"', modify
	label define CNT_H 428 `"Latvia"', modify
	label define CNT_H 430 `"Liberia"', modify
	label define CNT_H 434 `"Libyan Arab Jamahiriya"', modify
	label define CNT_H 438 `"Liechtenstein"', modify
	label define CNT_H 440 `"Lithuania"', modify
	label define CNT_H 442 `"Luxembourg"', modify
	label define CNT_H 446 `"Macao Special Administrative Region of China"', modify
	label define CNT_H 450 `"Madagascar"', modify
	label define CNT_H 454 `"Malawi"', modify
	label define CNT_H 458 `"Malaysia"', modify
	label define CNT_H 462 `"Maldives"', modify
	label define CNT_H 466 `"Mali"', modify
	label define CNT_H 470 `"Malta"', modify
	label define CNT_H 474 `"Martinique"', modify
	label define CNT_H 478 `"Mauritania"', modify
	label define CNT_H 480 `"Mauritius"', modify
	label define CNT_H 484 `"Mexico"', modify
	label define CNT_H 492 `"Monaco"', modify
	label define CNT_H 496 `"Mongolia"', modify
	label define CNT_H 498 `"Republic of Moldova"', modify
	label define CNT_H 499 `"Montenegro"', modify
	label define CNT_H 500 `"Montserrat"', modify
	label define CNT_H 504 `"Morocco"', modify
	label define CNT_H 508 `"Mozambique"', modify
	label define CNT_H 512 `"Oman"', modify
	label define CNT_H 516 `"Namibia"', modify
	label define CNT_H 520 `"Nauru"', modify
	label define CNT_H 524 `"Nepal"', modify
	label define CNT_H 528 `"Netherlands"', modify
	label define CNT_H 530 `"Netherlands Antilles"', modify
	label define CNT_H 533 `"Aruba"', modify
	label define CNT_H 540 `"New Caledonia"', modify
	label define CNT_H 548 `"Vanuatu"', modify
	label define CNT_H 554 `"New Zealand"', modify
	label define CNT_H 558 `"Nicaragua"', modify
	label define CNT_H 562 `"Niger"', modify
	label define CNT_H 566 `"Nigeria"', modify
	label define CNT_H 570 `"Niue"', modify
	label define CNT_H 574 `"Norfolk Island"', modify
	label define CNT_H 578 `"Norway"', modify
	label define CNT_H 580 `"Northern Mariana Islands"', modify
	label define CNT_H 583 `"Micronesia, Federated States of"', modify
	label define CNT_H 584 `"Marshall Islands"', modify
	label define CNT_H 585 `"Palau"', modify
	label define CNT_H 586 `"Pakistan"', modify
	label define CNT_H 591 `"Panama"', modify
	label define CNT_H 598 `"Papua New Guinea"', modify
	label define CNT_H 600 `"Paraguay"', modify
	label define CNT_H 604 `"Peru"', modify
	label define CNT_H 608 `"Philippines"', modify
	label define CNT_H 612 `"Pitcairn"', modify
	label define CNT_H 616 `"Poland"', modify
	label define CNT_H 620 `"Portugal"', modify
	label define CNT_H 624 `"Guinea-Bissau"', modify
	label define CNT_H 626 `"Timor-Leste"', modify
	label define CNT_H 630 `"Puerto Rico"', modify
	label define CNT_H 634 `"Qatar"', modify
	label define CNT_H 638 `"Réunion"', modify
	label define CNT_H 642 `"Romania"', modify
	label define CNT_H 643 `"Russian Federation"', modify
	label define CNT_H 646 `"Rwanda"', modify
	label define CNT_H 652 `"Saint-Barthélemy"', modify
	label define CNT_H 654 `"Saint Helena"', modify
	label define CNT_H 659 `"Saint Kitts and Nevis"', modify
	label define CNT_H 660 `"Anguilla"', modify
	label define CNT_H 662 `"Saint Lucia"', modify
	label define CNT_H 663 `"Saint-Martin (French part)"', modify
	label define CNT_H 666 `"Saint Pierre and Miquelon"', modify
	label define CNT_H 670 `"Saint Vincent and the Grenadines"', modify
	label define CNT_H 674 `"San Marino"', modify
	label define CNT_H 678 `"Sao Tome and Principe"', modify
	label define CNT_H 682 `"Saudi Arabia"', modify
	label define CNT_H 686 `"Senegal"', modify
	label define CNT_H 688 `"Serbia"', modify
	label define CNT_H 690 `"Seychelles"', modify
	label define CNT_H 694 `"Sierra Leone"', modify
	label define CNT_H 702 `"Singapore"', modify
	label define CNT_H 703 `"Slovakia"', modify
	label define CNT_H 704 `"Viet Nam"', modify
	label define CNT_H 705 `"Slovenia"', modify
	label define CNT_H 706 `"Somalia"', modify
	label define CNT_H 710 `"South Africa"', modify
	label define CNT_H 716 `"Zimbabwe"', modify
	label define CNT_H 724 `"Spain"', modify
	label define CNT_H 732 `"Western Sahara"', modify
	label define CNT_H 736 `"Sudan"', modify
	label define CNT_H 740 `"Suriname"', modify
	label define CNT_H 744 `"Svalbard and Jan Mayen Islands"', modify
	label define CNT_H 748 `"Swaziland"', modify
	label define CNT_H 752 `"Sweden"', modify
	label define CNT_H 756 `"Switzerland"', modify
	label define CNT_H 760 `"Syrian Arab Republic"', modify
	label define CNT_H 762 `"Tajikistan"', modify
	label define CNT_H 764 `"Thailand"', modify
	label define CNT_H 768 `"Togo"', modify
	label define CNT_H 772 `"Tokelau"', modify
	label define CNT_H 776 `"Tonga"', modify
	label define CNT_H 780 `"Trinidad and Tobago"', modify
	label define CNT_H 784 `"United Arab Emirates"', modify
	label define CNT_H 788 `"Tunisia"', modify
	label define CNT_H 792 `"Turkey"', modify
	label define CNT_H 795 `"Turkmenistan"', modify
	label define CNT_H 796 `"Turks and Caicos Islands"', modify
	label define CNT_H 798 `"Tuvalu"', modify
	label define CNT_H 800 `"Uganda"', modify
	label define CNT_H 804 `"Ukraine"', modify
	label define CNT_H 807 `"The former Yugoslav Republic of Macedonia"', modify
	label define CNT_H 818 `"Egypt"', modify
	label define CNT_H 826 `"United Kingdom of Great Britain and Northern Ireland"', modify
	label define CNT_H 830 `"Channel Islands"', modify
	label define CNT_H 831 `"Guernsey"', modify
	label define CNT_H 832 `"Jersey"', modify
	label define CNT_H 833 `"Isle of Man"', modify
	label define CNT_H 834 `"United Republic of Tanzania"', modify
	label define CNT_H 840 `"United States of America"', modify
	label define CNT_H 850 `"United States Virgin Islands"', modify
	label define CNT_H 854 `"Burkina Faso"', modify
	label define CNT_H 858 `"Uruguay"', modify
	label define CNT_H 860 `"Uzbekistan"', modify
	label define CNT_H 862 `"Venezuela (Bolivarian Republic of)"', modify
	label define CNT_H 876 `"Wallis and Futuna Islands"', modify
	label define CNT_H 882 `"Samoa"', modify
	label define CNT_H 887 `"Yemen"', modify
	label define CNT_H 894 `"Zambia"', modify
	label define ISCED_HF_C 1 `"No formal qualification or below ISCED 1"', modify
	label define ISCED_HF_C 2 `"ISCED 1"', modify
	label define ISCED_HF_C 3 `"ISCED 2"', modify
	label define ISCED_HF_C 4 `"ISCED 3C shorter than 2 years"', modify
	label define ISCED_HF_C 5 `"ISCED 3C 2 years or more"', modify
	label define ISCED_HF_C 6 `"ISCED 3A-B"', modify
	label define ISCED_HF_C 7 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define ISCED_HF_C 8 `"ISCED 4C"', modify
	label define ISCED_HF_C 9 `"ISCED 4A-B"', modify
	label define ISCED_HF_C 10 `"ISCED 4 (without distinction A-B-C)"', modify
	label define ISCED_HF_C 11 `"ISCED 5B"', modify
	label define ISCED_HF_C 12 `"ISCED 5A, bachelor degree"', modify
	label define ISCED_HF_C 13 `"ISCED 5A, master degree, and 6 (without distinction)"', modify
	label define ISCED_HF_C 14 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define ISCED_HF 1 `"No formal qualification or below ISCED 1"', modify
	label define ISCED_HF 2 `"ISCED 1"', modify
	label define ISCED_HF 3 `"ISCED 2"', modify
	label define ISCED_HF 4 `"ISCED 3C shorter than 2 years"', modify
	label define ISCED_HF 5 `"ISCED 3C 2 years or more"', modify
	label define ISCED_HF 6 `"ISCED 3A-B"', modify
	label define ISCED_HF 7 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define ISCED_HF 8 `"ISCED 4C"', modify
	label define ISCED_HF 9 `"ISCED 4A-B"', modify
	label define ISCED_HF 10 `"ISCED 4 (without distinction A-B-C)"', modify
	label define ISCED_HF 11 `"ISCED 5B"', modify
	label define ISCED_HF 12 `"ISCED 5A, bachelor degree"', modify
	label define ISCED_HF 13 `"ISCED 5A, master degree"', modify
	label define ISCED_HF 14 `"ISCED 6"', modify
	label define ISCED_HF 15 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define PBROUTE 1 `"No computer experience"', modify
	label define PBROUTE 2 `"Failed ICT Core stage 1"', modify
	label define PBROUTE 3 `"Refused CBA"', modify
	label define PBROUTE 4 `"Took CBA"', modify
	label define PBROUTE 5 `"Uncategorized"', modify
	label define YEARLYINCPR 1 `"Less than 10"', modify
	label define YEARLYINCPR 2 `"10 to less than 25"', modify
	label define YEARLYINCPR 3 `"25 to less than 50"', modify
	label define YEARLYINCPR 4 `"50 to less than 75"', modify
	label define YEARLYINCPR 5 `"75 to less than 90"', modify
	label define YEARLYINCPR 6 `"90 or more"', modify
	label define MONTHLYINCPR 1 `"Less than 10"', modify
	label define MONTHLYINCPR 2 `"10 to less than 25"', modify
	label define MONTHLYINCPR 3 `"25 to less than 50"', modify
	label define MONTHLYINCPR 4 `"50 to less than 75"', modify
	label define MONTHLYINCPR 5 `"75 to less than 90"', modify
	label define MONTHLYINCPR 6 `"90 or more"', modify
	label define CBAMOD2STG2 0 `"Missing"', modify
	label define CBAMOD2STG2 1 `"Easy"', modify
	label define CBAMOD2STG2 2 `"Medium 1"', modify
	label define CBAMOD2STG2 3 `"Medium 2"', modify
	label define CBAMOD2STG2 4 `"Hard"', modify
	label define CBAMOD1STG2 0 `"Missing"', modify
	label define CBAMOD1STG2 1 `"Easy"', modify
	label define CBAMOD1STG2 2 `"Medium 1"', modify
	label define CBAMOD1STG2 3 `"Medium 2"', modify
	label define CBAMOD1STG2 4 `"Hard"', modify
	label define CBAMOD2STG1 0 `"Missing"', modify
	label define CBAMOD2STG1 1 `"Easy"', modify
	label define CBAMOD2STG1 2 `"Medium"', modify
	label define CBAMOD2STG1 3 `"Hard"', modify
	label define CBAMOD1STG1 0 `"Missing"', modify
	label define CBAMOD1STG1 1 `"Easy"', modify
	label define CBAMOD1STG1 2 `"Medium"', modify
	label define CBAMOD1STG1 3 `"Hard"', modify
	label define CBAMOD2ALT 0 `"Missing"', modify
	label define CBAMOD2ALT 12 `"LIT-NUM"', modify
	label define CBAMOD2ALT 13 `"LIT-PS2"', modify
	label define CBAMOD2ALT 21 `"NUM-LIT"', modify
	label define CBAMOD2ALT 23 `"NUM-PS2"', modify
	label define CBAMOD2ALT 31 `"PS1-LIT"', modify
	label define CBAMOD2ALT 32 `"PS1-NUM"', modify
	label define CBAMOD2ALT 33 `"PS1-PS2"', modify
	label define CBAMOD2 0 `"Missing"', modify
	label define CBAMOD2 1 `"lit"', modify
	label define CBAMOD2 2 `"num"', modify
	label define CBAMOD2 3 `"PS2"', modify
	label define CBAMOD1 0 `"Missing"', modify
	label define CBAMOD1 1 `"lit"', modify
	label define CBAMOD1 2 `"num"', modify
	label define CBAMOD1 3 `"PS1"', modify
	label define PAPER 0 `"Missing"', modify
	label define PAPER 1 `"PP1-LIT"', modify
	label define PAPER 2 `"PP2-NUM"', modify
	label define PAPER 3 `"Failed Paper Core"', modify
	label define CBA_START 1 `"Continue to computer based exercise"', modify
	label define CBA_START 2 `"Continue to paper based exercise"', modify
	label define CORESTAGE2_PASS 1 `"Passed"', modify
	label define CORESTAGE2_PASS 29 `"Not passed"', modify
	label define CORESTAGE1_PASS 1 `"Passed"', modify
	label define CORESTAGE1_PASS 29 `"Not passed"', modify
	label define EDLEVEL3 1 `"Low"', modify
	label define EDLEVEL3 2 `"Medium"', modify
	label define EDLEVEL3 3 `"High"', modify
	label define NATIVESPEAKER 1 `"Yes"', modify
	label define NATIVESPEAKER 2 `"No"', modify
	label define COMPUTEREXPERIENCE 1 `"Yes"', modify
	label define COMPUTEREXPERIENCE 2 `"No"', modify
	label define J_Q08 1 `"10 books or less"', modify
	label define J_Q08 2 `"11 to 25 books"', modify
	label define J_Q08 3 `"26 to 100 books"', modify
	label define J_Q08 4 `"101 to 200 books"', modify
	label define J_Q08 5 `"201 to 500 books"', modify
	label define J_Q08 6 `"More than 500 books"', modify
	label define J_Q07B_T 1 `"ISCED 1, 2, and 3C short"', modify
	label define J_Q07B_T 2 `"ISCED 3 (excluding 3C short) and 4"', modify
	label define J_Q07B_T 3 `"ISCED 5 and 6"', modify
	label define J_Q07B_T 4 `"Not definable"', modify
	label define J_Q07B 1 `"ISCED 1, 2, and 3C short"', modify
	label define J_Q07B 2 `"ISCED 3 (excluding 3C short) and 4"', modify
	label define J_Q07B 3 `"ISCED 5 and 6"', modify
	label define J_Q07A_T 1 `"Yes"', modify
	label define J_Q07A_T 2 `"No"', modify
	label define J_Q07A_T 3 `"Not applicable"', modify
	label define J_Q07A 1 `"Yes"', modify
	label define J_Q07A 2 `"No"', modify
	label define J_Q06B_T 1 `"ISCED 1, 2, and 3C short"', modify
	label define J_Q06B_T 2 `"ISCED 3 (excluding 3C short) and 4"', modify
	label define J_Q06B_T 3 `"ISCED 5 and 6"', modify
	label define J_Q06B_T 4 `"Not definable"', modify
	label define J_Q06B 1 `"ISCED 1, 2, and 3C short"', modify
	label define J_Q06B 2 `"ISCED 3 (excluding 3C short) and 4"', modify
	label define J_Q06B 3 `"ISCED 5 and 6"', modify
	label define J_Q06A_T 1 `"Yes"', modify
	label define J_Q06A_T 2 `"No"', modify
	label define J_Q06A_T 3 `"Not applicable"', modify
	label define J_Q06A 1 `"Yes"', modify
	label define J_Q06A 2 `"No"', modify
	label define J_N05A2 1 `"Yes"', modify
	label define J_N05A2 2 `"No"', modify
	label define J_Q04C2_T1 1 `"1900-1930"', modify
	label define J_Q04C2_T1 2 `"1931-1960"', modify
	label define J_Q04C2_T1 3 `"1961-1990"', modify
	label define J_Q04C2_T1 4 `"1991 or later"', modify
	label define J_Q04C2_T1 5 `"Citizen by birth"', modify
	label define J_Q04C1_C 1 `"Aged 0-5"', modify
	label define J_Q04C1_C 2 `"Aged 6-10"', modify
	label define J_Q04C1_C 3 `"Aged 11-15"', modify
	label define J_Q04C1_C 4 `"Aged 16-20"', modify
	label define J_Q04C1_C 5 `"Aged 21-25"', modify
	label define J_Q04C1_C 6 `"Aged 26-30"', modify
	label define J_Q04C1_C 7 `"Aged 31-35"', modify
	label define J_Q04C1_C 8 `"Aged 36-40"', modify
	label define J_Q04C1_C 9 `"Aged 41 or older"', modify
	label define J_Q04A_T 1 `"Yes"', modify
	label define J_Q04A_T 2 `"No"', modify
	label define J_Q04A 1 `"Yes"', modify
	label define J_Q04A 2 `"No"', modify
	label define J_Q03D2_C 1 `"Aged 2 or younger"', modify
	label define J_Q03D2_C 2 `"Aged 3-5"', modify
	label define J_Q03D2_C 3 `"Aged 6-12"', modify
	label define J_Q03D2_C 4 `"Aged 13 or older"', modify
	label define J_Q03D1_C 1 `"Aged 2 or younger"', modify
	label define J_Q03D1_C 2 `"Aged 3-5"', modify
	label define J_Q03D1_C 3 `"Aged 6-12"', modify
	label define J_Q03D1_C 4 `"Aged 13 or older"', modify
	label define J_Q03C_C 1 `"Aged 2 or younger"', modify
	label define J_Q03C_C 2 `"Aged 3-5"', modify
	label define J_Q03C_C 3 `"Aged 6-12"', modify
	label define J_Q03C_C 4 `"Aged 13 or older"', modify
	label define J_Q03A 1 `"Yes"', modify
	label define J_Q03A 2 `"No"', modify
	label define J_Q02C 1 `"Full-time employed (self-employed, employee)"', modify
	label define J_Q02C 2 `"Part-time employed (self-employed, employee)"', modify
	label define J_Q02C 3 `"Unemployed"', modify
	label define J_Q02C 4 `"Pupil, student"', modify
	label define J_Q02C 5 `"Apprentice, internship"', modify
	label define J_Q02C 6 `"In retirement or early retirement"', modify
	label define J_Q02C 7 `"Permanently disabled"', modify
	label define J_Q02C 8 `"In compulsory military or community service"', modify
	label define J_Q02C 9 `"Fulfilling domestic tasks or looking after children/family"', modify
	label define J_Q02C 10 `"Other"', modify
	label define J_Q02A 1 `"Yes"', modify
	label define J_Q02A 2 `"No"', modify
	label define J_Q01_T1 1 `"One person in the household"', modify
	label define J_Q01_T1 2 `"Two persons in the household"', modify
	label define J_Q01_T1 3 `"Three persons in the household"', modify
	label define J_Q01_T1 4 `"Four persons in the household"', modify
	label define J_Q01_T1 5 `"Five persons in the household"', modify
	label define J_Q01_T1 6 `"Six persons in the household"', modify
	label define J_Q01_T1 7 `"Seven persons or more in the household"', modify
	label define I_Q08_T 1 `"Excellent"', modify
	label define I_Q08_T 2 `"Very good"', modify
	label define I_Q08_T 3 `"Good"', modify
	label define I_Q08_T 4 `"Fair"', modify
	label define I_Q08_T 5 `"Poor"', modify
	label define I_Q08 1 `"Excellent"', modify
	label define I_Q08 2 `"Very good"', modify
	label define I_Q08 3 `"Good"', modify
	label define I_Q08 4 `"Fair"', modify
	label define I_Q08 5 `"Poor"', modify
	label define I_Q07B 1 `"Strongly agree"', modify
	label define I_Q07B 2 `"Agree"', modify
	label define I_Q07B 3 `"Neither agree nor disagree"', modify
	label define I_Q07B 4 `"Disagree"', modify
	label define I_Q07B 5 `"Strongly disagree"', modify
	label define I_Q07A 1 `"Strongly agree"', modify
	label define I_Q07A 2 `"Agree"', modify
	label define I_Q07A 3 `"Neither agree nor disagree"', modify
	label define I_Q07A 4 `"Disagree"', modify
	label define I_Q07A 5 `"Strongly disagree"', modify
	label define I_Q06A 1 `"Strongly agree"', modify
	label define I_Q06A 2 `"Agree"', modify
	label define I_Q06A 3 `"Neither agree nor disagree"', modify
	label define I_Q06A 4 `"Disagree"', modify
	label define I_Q06A 5 `"Strongly disagree"', modify
	label define I_Q05F 1 `"Never"', modify
	label define I_Q05F 2 `"Less than once a month"', modify
	label define I_Q05F 3 `"Less than once a week but at least once a month"', modify
	label define I_Q05F 4 `"At least once a week but not every day"', modify
	label define I_Q05F 5 `"Every day"', modify
	label define I_Q04M 1 `"Not at all"', modify
	label define I_Q04M 2 `"Very little"', modify
	label define I_Q04M 3 `"To some extent"', modify
	label define I_Q04M 4 `"To a high extent"', modify
	label define I_Q04M 5 `"To a very high extent"', modify
	label define I_Q04L 1 `"Not at all"', modify
	label define I_Q04L 2 `"Very little"', modify
	label define I_Q04L 3 `"To some extent"', modify
	label define I_Q04L 4 `"To a high extent"', modify
	label define I_Q04L 5 `"To a very high extent"', modify
	label define I_Q04J 1 `"Not at all"', modify
	label define I_Q04J 2 `"Very little"', modify
	label define I_Q04J 3 `"To some extent"', modify
	label define I_Q04J 4 `"To a high extent"', modify
	label define I_Q04J 5 `"To a very high extent"', modify
	label define I_Q04H 1 `"Not at all"', modify
	label define I_Q04H 2 `"Very little"', modify
	label define I_Q04H 3 `"To some extent"', modify
	label define I_Q04H 4 `"To a high extent"', modify
	label define I_Q04H 5 `"To a very high extent"', modify
	label define I_Q04D 1 `"Not at all"', modify
	label define I_Q04D 2 `"Very little"', modify
	label define I_Q04D 3 `"To some extent"', modify
	label define I_Q04D 4 `"To a high extent"', modify
	label define I_Q04D 5 `"To a very high extent"', modify
	label define I_Q04B 1 `"Not at all"', modify
	label define I_Q04B 2 `"Very little"', modify
	label define I_Q04B 3 `"To some extent"', modify
	label define I_Q04B 4 `"To a high extent"', modify
	label define I_Q04B 5 `"To a very high extent"', modify
	label define H_Q05H 1 `"Never"', modify
	label define H_Q05H 2 `"Less than once a month"', modify
	label define H_Q05H 3 `"Less than once a week but at least once a month"', modify
	label define H_Q05H 4 `"At least once a week but not every day"', modify
	label define H_Q05H 5 `"Every day"', modify
	label define H_Q05G 1 `"Never"', modify
	label define H_Q05G 2 `"Less than once a month"', modify
	label define H_Q05G 3 `"Less than once a week but at least once a month"', modify
	label define H_Q05G 4 `"At least once a week but not every day"', modify
	label define H_Q05G 5 `"Every day"', modify
	label define H_Q05F 1 `"Never"', modify
	label define H_Q05F 2 `"Less than once a month"', modify
	label define H_Q05F 3 `"Less than once a week but at least once a month"', modify
	label define H_Q05F 4 `"At least once a week but not every day"', modify
	label define H_Q05F 5 `"Every day"', modify
	label define H_Q05E 1 `"Never"', modify
	label define H_Q05E 2 `"Less than once a month"', modify
	label define H_Q05E 3 `"Less than once a week but at least once a month"', modify
	label define H_Q05E 4 `"At least once a week but not every day"', modify
	label define H_Q05E 5 `"Every day"', modify
	label define H_Q05D 1 `"Never"', modify
	label define H_Q05D 2 `"Less than once a month"', modify
	label define H_Q05D 3 `"Less than once a week but at least once a month"', modify
	label define H_Q05D 4 `"At least once a week but not every day"', modify
	label define H_Q05D 5 `"Every day"', modify
	label define H_Q05C 1 `"Never"', modify
	label define H_Q05C 2 `"Less than once a month"', modify
	label define H_Q05C 3 `"Less than once a week but at least once a month"', modify
	label define H_Q05C 4 `"At least once a week but not every day"', modify
	label define H_Q05C 5 `"Every day"', modify
	label define H_Q05A 1 `"Never"', modify
	label define H_Q05A 2 `"Less than once a month"', modify
	label define H_Q05A 3 `"Less than once a week but at least once a month"', modify
	label define H_Q05A 4 `"At least once a week but not every day"', modify
	label define H_Q05A 5 `"Every day"', modify
	label define H_Q04B 1 `"Yes"', modify
	label define H_Q04B 2 `"No"', modify
	label define H_Q04A 1 `"Yes"', modify
	label define H_Q04A 2 `"No"', modify
	label define H_Q03H 1 `"Never"', modify
	label define H_Q03H 2 `"Less than once a month"', modify
	label define H_Q03H 3 `"Less than once a week but at least once a month"', modify
	label define H_Q03H 4 `"At least once a week but not every day"', modify
	label define H_Q03H 5 `"Every day"', modify
	label define H_Q03G 1 `"Never"', modify
	label define H_Q03G 2 `"Less than once a month"', modify
	label define H_Q03G 3 `"Less than once a week but at least once a month"', modify
	label define H_Q03G 4 `"At least once a week but not every day"', modify
	label define H_Q03G 5 `"Every day"', modify
	label define H_Q03F 1 `"Never"', modify
	label define H_Q03F 2 `"Less than once a month"', modify
	label define H_Q03F 3 `"Less than once a week but at least once a month"', modify
	label define H_Q03F 4 `"At least once a week but not every day"', modify
	label define H_Q03F 5 `"Every day"', modify
	label define H_Q03D 1 `"Never"', modify
	label define H_Q03D 2 `"Less than once a month"', modify
	label define H_Q03D 3 `"Less than once a week but at least once a month"', modify
	label define H_Q03D 4 `"At least once a week but not every day"', modify
	label define H_Q03D 5 `"Every day"', modify
	label define H_Q03C 1 `"Never"', modify
	label define H_Q03C 2 `"Less than once a month"', modify
	label define H_Q03C 3 `"Less than once a week but at least once a month"', modify
	label define H_Q03C 4 `"At least once a week but not every day"', modify
	label define H_Q03C 5 `"Every day"', modify
	label define H_Q03B 1 `"Never"', modify
	label define H_Q03B 2 `"Less than once a month"', modify
	label define H_Q03B 3 `"Less than once a week but at least once a month"', modify
	label define H_Q03B 4 `"At least once a week but not every day"', modify
	label define H_Q03B 5 `"Every day"', modify
	label define H_Q02D 1 `"Never"', modify
	label define H_Q02D 2 `"Less than once a month"', modify
	label define H_Q02D 3 `"Less than once a week but at least once a month"', modify
	label define H_Q02D 4 `"At least once a week but not every day"', modify
	label define H_Q02D 5 `"Every day"', modify
	label define H_Q02C 1 `"Never"', modify
	label define H_Q02C 2 `"Less than once a month"', modify
	label define H_Q02C 3 `"Less than once a week but at least once a month"', modify
	label define H_Q02C 4 `"At least once a week but not every day"', modify
	label define H_Q02C 5 `"Every day"', modify
	label define H_Q02B 1 `"Never"', modify
	label define H_Q02B 2 `"Less than once a month"', modify
	label define H_Q02B 3 `"Less than once a week but at least once a month"', modify
	label define H_Q02B 4 `"At least once a week but not every day"', modify
	label define H_Q02B 5 `"Every day"', modify
	label define H_Q02A 1 `"Never"', modify
	label define H_Q02A 2 `"Less than once a month"', modify
	label define H_Q02A 3 `"Less than once a week but at least once a month"', modify
	label define H_Q02A 4 `"At least once a week but not every day"', modify
	label define H_Q02A 5 `"Every day"', modify
	label define H_Q01H 1 `"Never"', modify
	label define H_Q01H 2 `"Less than once a month"', modify
	label define H_Q01H 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01H 4 `"At least once a week but not every day"', modify
	label define H_Q01H 5 `"Every day"', modify
	label define H_Q01G 1 `"Never"', modify
	label define H_Q01G 2 `"Less than once a month"', modify
	label define H_Q01G 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01G 4 `"At least once a week but not every day"', modify
	label define H_Q01G 5 `"Every day"', modify
	label define H_Q01F 1 `"Never"', modify
	label define H_Q01F 2 `"Less than once a month"', modify
	label define H_Q01F 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01F 4 `"At least once a week but not every day"', modify
	label define H_Q01F 5 `"Every day"', modify
	label define H_Q01E_T 1 `"At least once a week"', modify
	label define H_Q01E_T 2 `"Less than once a week but at least once a month"', modify
	label define H_Q01E_T 3 `"Rarely"', modify
	label define H_Q01E_T 4 `"Never"', modify
	label define H_Q01E 1 `"Never"', modify
	label define H_Q01E 2 `"Less than once a month"', modify
	label define H_Q01E 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01E 4 `"At least once a week but not every day"', modify
	label define H_Q01E 5 `"Every day"', modify
	label define H_Q01D 1 `"Never"', modify
	label define H_Q01D 2 `"Less than once a month"', modify
	label define H_Q01D 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01D 4 `"At least once a week but not every day"', modify
	label define H_Q01D 5 `"Every day"', modify
	label define H_Q01C_T 1 `"At least once a week"', modify
	label define H_Q01C_T 2 `"Less than once a week but at least once a month"', modify
	label define H_Q01C_T 3 `"Rarely"', modify
	label define H_Q01C_T 4 `"Never"', modify
	label define H_Q01C 1 `"Never"', modify
	label define H_Q01C 2 `"Less than once a month"', modify
	label define H_Q01C 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01C 4 `"At least once a week but not every day"', modify
	label define H_Q01C 5 `"Every day"', modify
	label define H_Q01B_T 1 `"At least once a week"', modify
	label define H_Q01B_T 2 `"Less than once a week but at least once a month"', modify
	label define H_Q01B_T 3 `"Rarely"', modify
	label define H_Q01B_T 4 `"Never"', modify
	label define H_Q01B 1 `"Never"', modify
	label define H_Q01B 2 `"Less than once a month"', modify
	label define H_Q01B 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01B 4 `"At least once a week but not every day"', modify
	label define H_Q01B 5 `"Every day"', modify
	label define H_Q01A 1 `"Never"', modify
	label define H_Q01A 2 `"Less than once a month"', modify
	label define H_Q01A 3 `"Less than once a week but at least once a month"', modify
	label define H_Q01A 4 `"At least once a week but not every day"', modify
	label define H_Q01A 5 `"Every day"', modify
	label define G_Q08 1 `"Yes"', modify
	label define G_Q08 2 `"No"', modify
	label define G_Q07 1 `"Yes"', modify
	label define G_Q07 2 `"No"', modify
	label define G_Q06 1 `"Straightforward"', modify
	label define G_Q06 2 `"Moderate"', modify
	label define G_Q06 3 `"Complex"', modify
	label define G_Q05H 1 `"Never"', modify
	label define G_Q05H 2 `"Less than once a month"', modify
	label define G_Q05H 3 `"Less than once a week but at least once a month"', modify
	label define G_Q05H 4 `"At least once a week but not every day"', modify
	label define G_Q05H 5 `"Every day"', modify
	label define G_Q05G 1 `"Never"', modify
	label define G_Q05G 2 `"Less than once a month"', modify
	label define G_Q05G 3 `"Less than once a week but at least once a month"', modify
	label define G_Q05G 4 `"At least once a week but not every day"', modify
	label define G_Q05G 5 `"Every day"', modify
	label define G_Q05F 1 `"Never"', modify
	label define G_Q05F 2 `"Less than once a month"', modify
	label define G_Q05F 3 `"Less than once a week but at least once a month"', modify
	label define G_Q05F 4 `"At least once a week but not every day"', modify
	label define G_Q05F 5 `"Every day"', modify
	label define G_Q05E 1 `"Never"', modify
	label define G_Q05E 2 `"Less than once a month"', modify
	label define G_Q05E 3 `"Less than once a week but at least once a month"', modify
	label define G_Q05E 4 `"At least once a week but not every day"', modify
	label define G_Q05E 5 `"Every day"', modify
	label define G_Q05D 1 `"Never"', modify
	label define G_Q05D 2 `"Less than once a month"', modify
	label define G_Q05D 3 `"Less than once a week but at least once a month"', modify
	label define G_Q05D 4 `"At least once a week but not every day"', modify
	label define G_Q05D 5 `"Every day"', modify
	label define G_Q05C 1 `"Never"', modify
	label define G_Q05C 2 `"Less than once a month"', modify
	label define G_Q05C 3 `"Less than once a week but at least once a month"', modify
	label define G_Q05C 4 `"At least once a week but not every day"', modify
	label define G_Q05C 5 `"Every day"', modify
	label define G_Q05A 1 `"Never"', modify
	label define G_Q05A 2 `"Less than once a month"', modify
	label define G_Q05A 3 `"Less than once a week but at least once a month"', modify
	label define G_Q05A 4 `"At least once a week but not every day"', modify
	label define G_Q05A 5 `"Every day"', modify
	label define G_Q04_T 1 `"Yes"', modify
	label define G_Q04_T 2 `"No"', modify
	label define G_Q04 1 `"Yes"', modify
	label define G_Q04 2 `"No"', modify
	label define G_Q03H 1 `"Never"', modify
	label define G_Q03H 2 `"Less than once a month"', modify
	label define G_Q03H 3 `"Less than once a week but at least once a month"', modify
	label define G_Q03H 4 `"At least once a week but not every day"', modify
	label define G_Q03H 5 `"Every day"', modify
	label define G_Q03G 1 `"Never"', modify
	label define G_Q03G 2 `"Less than once a month"', modify
	label define G_Q03G 3 `"Less than once a week but at least once a month"', modify
	label define G_Q03G 4 `"At least once a week but not every day"', modify
	label define G_Q03G 5 `"Every day"', modify
	label define G_Q03F 1 `"Never"', modify
	label define G_Q03F 2 `"Less than once a month"', modify
	label define G_Q03F 3 `"Less than once a week but at least once a month"', modify
	label define G_Q03F 4 `"At least once a week but not every day"', modify
	label define G_Q03F 5 `"Every day"', modify
	label define G_Q03D 1 `"Never"', modify
	label define G_Q03D 2 `"Less than once a month"', modify
	label define G_Q03D 3 `"Less than once a week but at least once a month"', modify
	label define G_Q03D 4 `"At least once a week but not every day"', modify
	label define G_Q03D 5 `"Every day"', modify
	label define G_Q03C 1 `"Never"', modify
	label define G_Q03C 2 `"Less than once a month"', modify
	label define G_Q03C 3 `"Less than once a week but at least once a month"', modify
	label define G_Q03C 4 `"At least once a week but not every day"', modify
	label define G_Q03C 5 `"Every day"', modify
	label define G_Q03B 1 `"Never"', modify
	label define G_Q03B 2 `"Less than once a month"', modify
	label define G_Q03B 3 `"Less than once a week but at least once a month"', modify
	label define G_Q03B 4 `"At least once a week but not every day"', modify
	label define G_Q03B 5 `"Every day"', modify
	label define G_Q02D 1 `"Never"', modify
	label define G_Q02D 2 `"Less than once a month"', modify
	label define G_Q02D 3 `"Less than once a week but at least once a month"', modify
	label define G_Q02D 4 `"At least once a week but not every day"', modify
	label define G_Q02D 5 `"Every day"', modify
	label define G_Q02C 1 `"Never"', modify
	label define G_Q02C 2 `"Less than once a month"', modify
	label define G_Q02C 3 `"Less than once a week but at least once a month"', modify
	label define G_Q02C 4 `"At least once a week but not every day"', modify
	label define G_Q02C 5 `"Every day"', modify
	label define G_Q02B 1 `"Never"', modify
	label define G_Q02B 2 `"Less than once a month"', modify
	label define G_Q02B 3 `"Less than once a week but at least once a month"', modify
	label define G_Q02B 4 `"At least once a week but not every day"', modify
	label define G_Q02B 5 `"Every day"', modify
	label define G_Q02A 1 `"Never"', modify
	label define G_Q02A 2 `"Less than once a month"', modify
	label define G_Q02A 3 `"Less than once a week but at least once a month"', modify
	label define G_Q02A 4 `"At least once a week but not every day"', modify
	label define G_Q02A 5 `"Every day"', modify
	label define G_Q01H_T1 1 `"At least once a week"', modify
	label define G_Q01H_T1 2 `"Less than once a week"', modify
	label define G_Q01H_T1 3 `"Rarely or never"', modify
	label define G_Q01H_T 1 `"At least once a week"', modify
	label define G_Q01H_T 2 `"Less than once a week"', modify
	label define G_Q01H_T 3 `"Rarely"', modify
	label define G_Q01H_T 4 `"Never"', modify
	label define G_Q01H 1 `"Never"', modify
	label define G_Q01H 2 `"Less than once a month"', modify
	label define G_Q01H 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01H 4 `"At least once a week but not every day"', modify
	label define G_Q01H 5 `"Every day"', modify
	label define G_Q01G_T1 1 `"At least once a week"', modify
	label define G_Q01G_T1 2 `"Less than once a week"', modify
	label define G_Q01G_T1 3 `"Rarely or never"', modify
	label define G_Q01G_T 1 `"At least once a week"', modify
	label define G_Q01G_T 2 `"Less than once a week"', modify
	label define G_Q01G_T 3 `"Rarely"', modify
	label define G_Q01G_T 4 `"Never"', modify
	label define G_Q01G 1 `"Never"', modify
	label define G_Q01G 2 `"Less than once a month"', modify
	label define G_Q01G 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01G 4 `"At least once a week but not every day"', modify
	label define G_Q01G 5 `"Every day"', modify
	label define G_Q01F_T1 1 `"At least once a week"', modify
	label define G_Q01F_T1 2 `"Less than once a week"', modify
	label define G_Q01F_T1 3 `"Rarely or never"', modify
	label define G_Q01F_T 1 `"At least once a week"', modify
	label define G_Q01F_T 2 `"Less than once a week"', modify
	label define G_Q01F_T 3 `"Rarely"', modify
	label define G_Q01F_T 4 `"Never"', modify
	label define G_Q01F 1 `"Never"', modify
	label define G_Q01F 2 `"Less than once a month"', modify
	label define G_Q01F 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01F 4 `"At least once a week but not every day"', modify
	label define G_Q01F 5 `"Every day"', modify
	label define G_Q01E 1 `"Never"', modify
	label define G_Q01E 2 `"Less than once a month"', modify
	label define G_Q01E 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01E 4 `"At least once a week but not every day"', modify
	label define G_Q01E 5 `"Every day"', modify
	label define G_Q01D 1 `"Never"', modify
	label define G_Q01D 2 `"Less than once a month"', modify
	label define G_Q01D 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01D 4 `"At least once a week but not every day"', modify
	label define G_Q01D 5 `"Every day"', modify
	label define G_Q01C_T1 1 `"At least once a week"', modify
	label define G_Q01C_T1 2 `"Less than once a week"', modify
	label define G_Q01C_T1 3 `"Rarely or never"', modify
	label define G_Q01C_T 1 `"At least once a week"', modify
	label define G_Q01C_T 2 `"Less than once a week"', modify
	label define G_Q01C_T 3 `"Rarely"', modify
	label define G_Q01C_T 4 `"Never"', modify
	label define G_Q01C 1 `"Never"', modify
	label define G_Q01C 2 `"Less than once a month"', modify
	label define G_Q01C 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01C 4 `"At least once a week but not every day"', modify
	label define G_Q01C 5 `"Every day"', modify
	label define G_Q01B_T1 1 `"At least once a week"', modify
	label define G_Q01B_T1 2 `"Less than once a week"', modify
	label define G_Q01B_T1 3 `"Rarely or never"', modify
	label define G_Q01B_T 1 `"At least once a week"', modify
	label define G_Q01B_T 2 `"Less than once a week"', modify
	label define G_Q01B_T 3 `"Rarely"', modify
	label define G_Q01B_T 4 `"Never"', modify
	label define G_Q01B 1 `"Never"', modify
	label define G_Q01B 2 `"Less than once a month"', modify
	label define G_Q01B 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01B 4 `"At least once a week but not every day"', modify
	label define G_Q01B 5 `"Every day"', modify
	label define G_Q01A_T1 1 `"At least once a week"', modify
	label define G_Q01A_T1 2 `"Less than once a week"', modify
	label define G_Q01A_T1 3 `"Rarely or never"', modify
	label define G_Q01A_T 1 `"At least once a week"', modify
	label define G_Q01A_T 2 `"Less than once a week"', modify
	label define G_Q01A_T 3 `"Rarely"', modify
	label define G_Q01A_T 4 `"Never"', modify
	label define G_Q01A 1 `"Never"', modify
	label define G_Q01A 2 `"Less than once a month"', modify
	label define G_Q01A 3 `"Less than once a week but at least once a month"', modify
	label define G_Q01A 4 `"At least once a week but not every day"', modify
	label define G_Q01A 5 `"Every day"', modify
	label define F_Q07B 1 `"Yes"', modify
	label define F_Q07B 2 `"No"', modify
	label define F_Q07A 1 `"Yes"', modify
	label define F_Q07A 2 `"No"', modify
	label define F_Q06C 1 `"Never"', modify
	label define F_Q06C 2 `"Less than once a month"', modify
	label define F_Q06C 3 `"Less than once a week but at least once a month"', modify
	label define F_Q06C 4 `"At least once a week but not every day"', modify
	label define F_Q06C 5 `"Every day"', modify
	label define F_Q06B 1 `"Never"', modify
	label define F_Q06B 2 `"Less than once a month"', modify
	label define F_Q06B 3 `"Less than once a week but at least once a month"', modify
	label define F_Q06B 4 `"At least once a week but not every day"', modify
	label define F_Q06B 5 `"Every day"', modify
	label define F_Q05B 1 `"Never"', modify
	label define F_Q05B 2 `"Less than once a month"', modify
	label define F_Q05B 3 `"Less than once a week but at least once a month"', modify
	label define F_Q05B 4 `"At least once a week but not every day"', modify
	label define F_Q05B 5 `"Every day"', modify
	label define F_Q05A 1 `"Never"', modify
	label define F_Q05A 2 `"Less than once a month"', modify
	label define F_Q05A 3 `"Less than once a week but at least once a month"', modify
	label define F_Q05A 4 `"At least once a week but not every day"', modify
	label define F_Q05A 5 `"Every day"', modify
	label define F_Q04B 1 `"Never"', modify
	label define F_Q04B 2 `"Less than once a month"', modify
	label define F_Q04B 3 `"Less than once a week but at least once a month"', modify
	label define F_Q04B 4 `"At least once a week but not every day"', modify
	label define F_Q04B 5 `"Every day"', modify
	label define F_Q04A 1 `"Never"', modify
	label define F_Q04A 2 `"Less than once a month"', modify
	label define F_Q04A 3 `"Less than once a week but at least once a month"', modify
	label define F_Q04A 4 `"At least once a week but not every day"', modify
	label define F_Q04A 5 `"Every day"', modify
	label define F_Q03C 1 `"Never"', modify
	label define F_Q03C 2 `"Less than once a month"', modify
	label define F_Q03C 3 `"Less than once a week but at least once a month"', modify
	label define F_Q03C 4 `"At least once a week but not every day"', modify
	label define F_Q03C 5 `"Every day"', modify
	label define F_Q03B 1 `"Never"', modify
	label define F_Q03B 2 `"Less than once a month"', modify
	label define F_Q03B 3 `"Less than once a week but at least once a month"', modify
	label define F_Q03B 4 `"At least once a week but not every day"', modify
	label define F_Q03B 5 `"Every day"', modify
	label define F_Q03A 1 `"Never"', modify
	label define F_Q03A 2 `"Less than once a month"', modify
	label define F_Q03A 3 `"Less than once a week but at least once a month"', modify
	label define F_Q03A 4 `"At least once a week but not every day"', modify
	label define F_Q03A 5 `"Every day"', modify
	label define F_Q02E 1 `"Never"', modify
	label define F_Q02E 2 `"Less than once a month"', modify
	label define F_Q02E 3 `"Less than once a week but at least once a month"', modify
	label define F_Q02E 4 `"At least once a week but not every day"', modify
	label define F_Q02E 5 `"Every day"', modify
	label define F_Q02D 1 `"Never"', modify
	label define F_Q02D 2 `"Less than once a month"', modify
	label define F_Q02D 3 `"Less than once a week but at least once a month"', modify
	label define F_Q02D 4 `"At least once a week but not every day"', modify
	label define F_Q02D 5 `"Every day"', modify
	label define F_Q02C 1 `"Never"', modify
	label define F_Q02C 2 `"Less than once a month"', modify
	label define F_Q02C 3 `"Less than once a week but at least once a month"', modify
	label define F_Q02C 4 `"At least once a week but not every day"', modify
	label define F_Q02C 5 `"Every day"', modify
	label define F_Q02B 1 `"Never"', modify
	label define F_Q02B 2 `"Less than once a month"', modify
	label define F_Q02B 3 `"Less than once a week but at least once a month"', modify
	label define F_Q02B 4 `"At least once a week but not every day"', modify
	label define F_Q02B 5 `"Every day"', modify
	label define F_Q02A 1 `"Never"', modify
	label define F_Q02A 2 `"Less than once a month"', modify
	label define F_Q02A 3 `"Less than once a week but at least once a month"', modify
	label define F_Q02A 4 `"At least once a week but not every day"', modify
	label define F_Q02A 5 `"Every day"', modify
	label define F_Q01B 1 `"None of the time"', modify
	label define F_Q01B 2 `"Up to a quarter of the time"', modify
	label define F_Q01B 3 `"Up to half of the time"', modify
	label define F_Q01B 4 `"More than half of the time"', modify
	label define F_Q01B 5 `"All of the time"', modify
	label define E_Q10 1 `"I was dismissed"', modify
	label define E_Q10 2 `"I was made redundant or took voluntary redundancy"', modify
	label define E_Q10 3 `"It was a temporary job which came to an end"', modify
	label define E_Q10 4 `"I resigned"', modify
	label define E_Q10 5 `"I gave up work for health reasons"', modify
	label define E_Q10 6 `"I took early retirement"', modify
	label define E_Q10 7 `"I retired (at or after State Pension age)"', modify
	label define E_Q10 8 `"I gave up work because of family responsibilities or child care"', modify
	label define E_Q10 9 `"I gave up work in order to study"', modify
	label define E_Q10 10 `"I left for some other reason"', modify
	label define E_Q08 1 `"An indefinite contract"', modify
	label define E_Q08 2 `"A fixed term contract"', modify
	label define E_Q08 3 `"A temporary employment agency contract"', modify
	label define E_Q08 4 `"An apprenticeship or other training scheme"', modify
	label define E_Q08 5 `"No contract"', modify
	label define E_Q08 6 `"Other"', modify
	label define E_Q07B 1 `"1 to 10 people"', modify
	label define E_Q07B 2 `"11 to 50 people"', modify
	label define E_Q07B 3 `"51 to 250 people"', modify
	label define E_Q07B 4 `"251 to 1000 people"', modify
	label define E_Q07B 5 `"More than 1000 people"', modify
	label define E_Q07A 1 `"Yes"', modify
	label define E_Q07A 2 `"No"', modify
	label define E_Q06 1 `"1 to 10 people"', modify
	label define E_Q06 2 `"11 to 50 people"', modify
	label define E_Q06 3 `"51 to 250 people"', modify
	label define E_Q06 4 `"251 to 1000 people"', modify
	label define E_Q06 5 `"More than 1000 people"', modify
	label define E_Q05B1_C 1 `"Aged 19 or younger"', modify
	label define E_Q05B1_C 2 `"Aged 20-24"', modify
	label define E_Q05B1_C 3 `"Aged 25-29"', modify
	label define E_Q05B1_C 4 `"Aged 30-34"', modify
	label define E_Q05B1_C 5 `"Aged 35-39"', modify
	label define E_Q05B1_C 6 `"Aged 40-44"', modify
	label define E_Q05B1_C 7 `"Aged 45-49"', modify
	label define E_Q05B1_C 8 `"Aged 50-54"', modify
	label define E_Q05B1_C 9 `"Aged 55 or older"', modify
	label define E_Q05A1_C 1 `"Aged 19 or younger"', modify
	label define E_Q05A1_C 2 `"Aged 20-24"', modify
	label define E_Q05A1_C 3 `"Aged 25-29"', modify
	label define E_Q05A1_C 4 `"Aged 30-34"', modify
	label define E_Q05A1_C 5 `"Aged 35-39"', modify
	label define E_Q05A1_C 6 `"Aged 40-44"', modify
	label define E_Q05A1_C 7 `"Aged 45-49"', modify
	label define E_Q05A1_C 8 `"Aged 50-54"', modify
	label define E_Q05A1_C 9 `"Aged 55 or older"', modify
	label define E_Q04 1 `"Employee"', modify
	label define E_Q04 2 `"Self-employed"', modify
	label define E_Q03 1 `"The private sector (for example a company)"', modify
	label define E_Q03 2 `"The public sector (for example the local government or a state school)"', modify
	label define E_Q03 3 `"A non-profit organisation (for example a charity, professional association or religious organisation)"', modify
	label define D_Q18C2 1 `"Less than #10%"', modify
	label define D_Q18C2 2 `"#10% to less than #25%"', modify
	label define D_Q18C2 3 `"#25% to less than #50%"', modify
	label define D_Q18C2 4 `"#50% to less than #75%"', modify
	label define D_Q18C2 5 `"#75% to less than #90%"', modify
	label define D_Q18C2 6 `"#90% or more"', modify
	label define D_Q18C1 1 `"Less than #10%"', modify
	label define D_Q18C1 2 `"#10% to less than #25%"', modify
	label define D_Q18C1 3 `"#25% to less than #50%"', modify
	label define D_Q18C1 4 `"#50% to less than #75%"', modify
	label define D_Q18C1 5 `"#75% to less than #90%"', modify
	label define D_Q18C1 6 `"#90% or more"', modify
	label define D_Q18B 1 `"Yes"', modify
	label define D_Q18B 2 `"No"', modify
	label define D_Q18A_T 0 `"No income"', modify
	label define D_Q18A_T 1 `"Lowest quintile"', modify
	label define D_Q18A_T 2 `"Next lowest quintile"', modify
	label define D_Q18A_T 3 `"Mid-level quintile"', modify
	label define D_Q18A_T 4 `"Next to highest quintile"', modify
	label define D_Q18A_T 5 `"Highest quintile"', modify
	label define D_Q17D 1 `"Less than #5%"', modify
	label define D_Q17D 2 `"#5% to less than #10%"', modify
	label define D_Q17D 3 `"#10% or more"', modify
	label define D_Q17C 1 `"Yes"', modify
	label define D_Q17C 2 `"No"', modify
	label define D_Q17A 1 `"Yes"', modify
	label define D_Q17A 2 `"No"', modify
	label define D_Q16D6 1 `"Less than #10%"', modify
	label define D_Q16D6 2 `"#10% to less than #25%"', modify
	label define D_Q16D6 3 `"#25% to less than #50%"', modify
	label define D_Q16D6 4 `"#50% to less than #75%"', modify
	label define D_Q16D6 5 `"#75% to less than #90%"', modify
	label define D_Q16D6 6 `"#90% or more"', modify
	label define D_Q16D5 1 `"Less than #10%"', modify
	label define D_Q16D5 2 `"#10% to less than #25%"', modify
	label define D_Q16D5 3 `"#25% to less than #50%"', modify
	label define D_Q16D5 4 `"#50% to less than #75%"', modify
	label define D_Q16D5 5 `"#75% to less than #90%"', modify
	label define D_Q16D5 6 `"#90% or more"', modify
	label define D_Q16D4 1 `"Less than #10%"', modify
	label define D_Q16D4 2 `"#10% to less than #25%"', modify
	label define D_Q16D4 3 `"#25% to less than #50%"', modify
	label define D_Q16D4 4 `"#50% to less than #75%"', modify
	label define D_Q16D4 5 `"#75% to less than #90%"', modify
	label define D_Q16D4 6 `"#90% or more"', modify
	label define D_Q16D3 1 `"Less than #10%"', modify
	label define D_Q16D3 2 `"#10% to less than #25%"', modify
	label define D_Q16D3 3 `"#25% to less than #50%"', modify
	label define D_Q16D3 4 `"#50% to less than #75%"', modify
	label define D_Q16D3 5 `"#75% to less than #90%"', modify
	label define D_Q16D3 6 `"#90% or more"', modify
	label define D_Q16D2 1 `"Less than #10%"', modify
	label define D_Q16D2 2 `"#10% to less than #25%"', modify
	label define D_Q16D2 3 `"#25% to less than #50%"', modify
	label define D_Q16D2 4 `"#50% to less than #75%"', modify
	label define D_Q16D2 5 `"#75% to less than #90%"', modify
	label define D_Q16D2 6 `"#90% or more"', modify
	label define D_Q16D1 1 `"Less than #10%"', modify
	label define D_Q16D1 2 `"#10% to less than #25%"', modify
	label define D_Q16D1 3 `"#25% to less than #50%"', modify
	label define D_Q16D1 4 `"#50% to less than #75%"', modify
	label define D_Q16D1 5 `"#75% to less than #90%"', modify
	label define D_Q16D1 6 `"#90% or more"', modify
	label define D_Q16C 1 `"Yes"', modify
	label define D_Q16C 2 `"No"', modify
	label define D_Q16B_T 0 `"No income"', modify
	label define D_Q16B_T 1 `"Lowest quintile"', modify
	label define D_Q16B_T 2 `"Next lowest quintile"', modify
	label define D_Q16B_T 3 `"Mid-level quintile"', modify
	label define D_Q16B_T 4 `"Next to highest quintile"', modify
	label define D_Q16B_T 5 `"Highest quintile"', modify
	label define D_Q16A 1 `"Per hour"', modify
	label define D_Q16A 2 `"Per day"', modify
	label define D_Q16A 3 `"Per week"', modify
	label define D_Q16A 4 `"Per two weeks"', modify
	label define D_Q16A 5 `"Per month"', modify
	label define D_Q16A 6 `"Per year"', modify
	label define D_Q16A 7 `"Piece rate"', modify
	label define D_Q16A 8 `"I get no salary or wage at all"', modify
	label define D_Q14 1 `"Extremely satisfied"', modify
	label define D_Q14 2 `"Satisfied"', modify
	label define D_Q14 3 `"Neither satisfied nor dissatisfied"', modify
	label define D_Q14 4 `"Dissatisfied"', modify
	label define D_Q14 5 `"Extremely dissatisfied"', modify
	label define D_Q13C 1 `"Never"', modify
	label define D_Q13C 2 `"Less than once a month"', modify
	label define D_Q13C 3 `"Less than once a week but at least once a month"', modify
	label define D_Q13C 4 `"At least once a week but not every day"', modify
	label define D_Q13C 5 `"Every day"', modify
	label define D_Q13B 1 `"Never"', modify
	label define D_Q13B 2 `"Less than once a month"', modify
	label define D_Q13B 3 `"Less than once a week but at least once a month"', modify
	label define D_Q13B 4 `"At least once a week but not every day"', modify
	label define D_Q13B 5 `"Every day"', modify
	label define D_Q13A 1 `"Never"', modify
	label define D_Q13A 2 `"Less than once a month"', modify
	label define D_Q13A 3 `"Less than once a week but at least once a month"', modify
	label define D_Q13A 4 `"At least once a week but not every day"', modify
	label define D_Q13A 5 `"Every day"', modify
	label define D_Q12C 1 `"None"', modify
	label define D_Q12C 2 `"Less than 1 month"', modify
	label define D_Q12C 3 `"1 to 6 months"', modify
	label define D_Q12C 4 `"7 to 11 months"', modify
	label define D_Q12C 5 `"1 or 2 years"', modify
	label define D_Q12C 6 `"3 years or more"', modify
	label define D_Q12B 1 `"This level is necessary"', modify
	label define D_Q12B 2 `"A lower level would be sufficient"', modify
	label define D_Q12B 3 `"A higher level would be needed"', modify
	label define D_Q12A 1 `"No formal qualification or below ISCED 1"', modify
	label define D_Q12A 2 `"ISCED 1"', modify
	label define D_Q12A 3 `"ISCED 2"', modify
	label define D_Q12A 4 `"ISCED 3C shorter than 2 years"', modify
	label define D_Q12A 5 `"ISCED 3C 2 years or more"', modify
	label define D_Q12A 6 `"ISCED 3A-B"', modify
	label define D_Q12A 7 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define D_Q12A 8 `"ISCED 4C"', modify
	label define D_Q12A 9 `"ISCED 4A-B"', modify
	label define D_Q12A 10 `"ISCED 4 (without distinction A-B-C)"', modify
	label define D_Q12A 11 `"ISCED 5B"', modify
	label define D_Q12A 12 `"ISCED 5A, bachelor degree"', modify
	label define D_Q12A 13 `"ISCED 5A, master degree"', modify
	label define D_Q12A 14 `"ISCED 6"', modify
	label define D_Q12A 15 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define D_Q11D 1 `"Not at all"', modify
	label define D_Q11D 2 `"Very little"', modify
	label define D_Q11D 3 `"To some extent"', modify
	label define D_Q11D 4 `"To a high extent"', modify
	label define D_Q11D 5 `"To a very high extent"', modify
	label define D_Q11C 1 `"Not at all"', modify
	label define D_Q11C 2 `"Very little"', modify
	label define D_Q11C 3 `"To some extent"', modify
	label define D_Q11C 4 `"To a high extent"', modify
	label define D_Q11C 5 `"To a very high extent"', modify
	label define D_Q11B 1 `"Not at all"', modify
	label define D_Q11B 2 `"Very little"', modify
	label define D_Q11B 3 `"To some extent"', modify
	label define D_Q11B 4 `"To a high extent"', modify
	label define D_Q11B 5 `"To a very high extent"', modify
	label define D_Q11A 1 `"Not at all"', modify
	label define D_Q11A 2 `"Very little"', modify
	label define D_Q11A 3 `"To some extent"', modify
	label define D_Q11A 4 `"To a high extent"', modify
	label define D_Q11A 5 `"To a very high extent"', modify
	label define D_Q10_T1 1 `"0 - 20 hours"', modify
	label define D_Q10_T1 2 `"21 - 40 hours"', modify
	label define D_Q10_T1 3 `"41 - 60 hours"', modify
	label define D_Q10_T1 4 `"61 - 80 hours"', modify
	label define D_Q10_T1 5 `"81 - 100 hours"', modify
	label define D_Q10_T1 6 `"More than 100 hours"', modify
	label define D_Q09 1 `"An indefinite contract"', modify
	label define D_Q09 2 `"A fixed term contract"', modify
	label define D_Q09 3 `"A temporary employment agency contract"', modify
	label define D_Q09 4 `"An apprenticeship or other training scheme"', modify
	label define D_Q09 5 `"No contract"', modify
	label define D_Q09 6 `"Other"', modify
	label define D_Q08B 1 `"1 to 5 people"', modify
	label define D_Q08B 2 `"6 to 10 people"', modify
	label define D_Q08B 3 `"11 to 24 people"', modify
	label define D_Q08B 4 `"25 to 99 people"', modify
	label define D_Q08B 5 `"100 or more people"', modify
	label define D_Q08A 1 `"Yes"', modify
	label define D_Q08A 2 `"No"', modify
	label define D_Q07B_C 1 `"1 to 10 people"', modify
	label define D_Q07B_C 2 `"more than 10 people"', modify
	label define D_Q07B 1 `"1 to 10 people"', modify
	label define D_Q07B 2 `"11 to 50 people"', modify
	label define D_Q07B 3 `"51 to 250 people"', modify
	label define D_Q07B 4 `"251 to 1000 people"', modify
	label define D_Q07B 5 `"More than 1000 people"', modify
	label define D_Q07A 1 `"Yes"', modify
	label define D_Q07A 2 `"No"', modify
	label define D_Q06C 1 `"Yes"', modify
	label define D_Q06C 2 `"No"', modify
	label define D_Q06B 1 `"Increased"', modify
	label define D_Q06B 2 `"Decreased"', modify
	label define D_Q06B 3 `"Stayed more or less the same"', modify
	label define D_Q06A 1 `"1 to 10 people"', modify
	label define D_Q06A 2 `"11 to 50 people"', modify
	label define D_Q06A 3 `"51 to 250 people"', modify
	label define D_Q06A 4 `"251 to 1000 people"', modify
	label define D_Q06A 5 `"More than 1000 people"', modify
	label define D_Q05B3 1 `"January"', modify
	label define D_Q05B3 2 `"February"', modify
	label define D_Q05B3 3 `"March"', modify
	label define D_Q05B3 4 `"April"', modify
	label define D_Q05B3 5 `"May"', modify
	label define D_Q05B3 6 `"June"', modify
	label define D_Q05B3 7 `"July"', modify
	label define D_Q05B3 8 `"August"', modify
	label define D_Q05B3 9 `"September"', modify
	label define D_Q05B3 10 `"October"', modify
	label define D_Q05B3 11 `"November"', modify
	label define D_Q05B3 12 `"December"', modify
	label define D_Q05B1_C 1 `"Aged 19 or younger"', modify
	label define D_Q05B1_C 2 `"Aged 20-24"', modify
	label define D_Q05B1_C 3 `"Aged 25-29"', modify
	label define D_Q05B1_C 4 `"Aged 30-34"', modify
	label define D_Q05B1_C 5 `"Aged 35-39"', modify
	label define D_Q05B1_C 6 `"Aged 40-44"', modify
	label define D_Q05B1_C 7 `"Aged 45-49"', modify
	label define D_Q05B1_C 8 `"Aged 50-54"', modify
	label define D_Q05B1_C 9 `"Aged 55 or older"', modify
	label define D_Q05A3 1 `"January"', modify
	label define D_Q05A3 2 `"February"', modify
	label define D_Q05A3 3 `"March"', modify
	label define D_Q05A3 4 `"April"', modify
	label define D_Q05A3 5 `"May"', modify
	label define D_Q05A3 6 `"June"', modify
	label define D_Q05A3 7 `"July"', modify
	label define D_Q05A3 8 `"August"', modify
	label define D_Q05A3 9 `"September"', modify
	label define D_Q05A3 10 `"October"', modify
	label define D_Q05A3 11 `"November"', modify
	label define D_Q05A3 12 `"December"', modify
	label define D_Q05A1_C 1 `"Aged 19 or younger"', modify
	label define D_Q05A1_C 2 `"Aged 20-24"', modify
	label define D_Q05A1_C 3 `"Aged 25-29"', modify
	label define D_Q05A1_C 4 `"Aged 30-34"', modify
	label define D_Q05A1_C 5 `"Aged 35-39"', modify
	label define D_Q05A1_C 6 `"Aged 40-44"', modify
	label define D_Q05A1_C 7 `"Aged 45-49"', modify
	label define D_Q05A1_C 8 `"Aged 50-54"', modify
	label define D_Q05A1_C 9 `"Aged 55 or older"', modify
	label define D_Q04_T1 1 `"Employee, not supervisor"', modify
	label define D_Q04_T1 2 `"Employee, supervising fewer than 5 people"', modify
	label define D_Q04_T1 3 `"Employee, supervising more than 5 people"', modify
	label define D_Q04_T1 4 `"Self-employed or unpaid family worker"', modify
	label define D_Q04_T 1 `"Employee, not supervisor"', modify
	label define D_Q04_T 2 `"Employee, supervising fewer than 5 people"', modify
	label define D_Q04_T 3 `"Employee, supervising more than 5 people"', modify
	label define D_Q04_T 4 `"Self-employed, not supervisor"', modify
	label define D_Q04_T 5 `"Self-employed, supervisor"', modify
	label define D_Q04_T 6 `"Unpaid family worker"', modify
	label define D_Q04 1 `"Employee"', modify
	label define D_Q04 2 `"Self-employed"', modify
	label define D_Q03 1 `"The private sector (for example a company)"', modify
	label define D_Q03 2 `"The public sector (for example the local government or a state school)"', modify
	label define D_Q03 3 `"A non-profit organisation (for example a charity, professional association or religious organisation)"', modify
	label define C_D09_T 1 `"Yes"', modify
	label define C_D09_T 2 `"No"', modify
	label define C_D09 1 `"Currently working (paid or unpaid)"', modify
	label define C_D09 2 `"Recent work experience in last 12 months"', modify
	label define C_D09 3 `"Left paid work longer than 12 months ago"', modify
	label define C_D09 4 `"No work experience"', modify
	label define C_D09 5 `"Status unknown"', modify
	label define C_D08C 1 `"Yes"', modify
	label define C_D08C 2 `"No or unknown"', modify
	label define C_Q08C1_C 1 `"Aged 19 or younger"', modify
	label define C_Q08C1_C 2 `"Aged 20-24"', modify
	label define C_Q08C1_C 3 `"Aged 25-29"', modify
	label define C_Q08C1_C 4 `"Aged 30-34"', modify
	label define C_Q08C1_C 5 `"Aged 35-39"', modify
	label define C_Q08C1_C 6 `"Aged 40-44"', modify
	label define C_Q08C1_C 7 `"Aged 45-49"', modify
	label define C_Q08C1_C 8 `"Aged 50-54"', modify
	label define C_Q08C1_C 9 `"Aged 55-59"', modify
	label define C_Q08C1_C 10 `"Aged 60-65"', modify
	label define C_Q08B 1 `"Yes"', modify
	label define C_Q08B 2 `"No"', modify
	label define C_Q08A 1 `"Yes"', modify
	label define C_Q08A 2 `"No"', modify
	label define C_Q07_T 1 `"Employed or self employed"', modify
	label define C_Q07_T 2 `"Retired"', modify
	label define C_Q07_T 3 `"Not working and looking for work"', modify
	label define C_Q07_T 4 `"Student (including work programs)"', modify
	label define C_Q07_T 5 `"Doing unpaid household work"', modify
	label define C_Q07_T 6 `"Other"', modify
	label define C_Q07 1 `"Full-time employed (self-employed, employee)"', modify
	label define C_Q07 2 `"Part-time employed (self-employed, employee)"', modify
	label define C_Q07 3 `"Unemployed"', modify
	label define C_Q07 4 `"Pupil, student"', modify
	label define C_Q07 5 `"Apprentice, internship"', modify
	label define C_Q07 6 `"In retirement or early retirement"', modify
	label define C_Q07 7 `"Permanently disabled"', modify
	label define C_Q07 8 `"In compulsory military or community service"', modify
	label define C_Q07 9 `"Fulfilling domestic tasks or looking after children/family"', modify
	label define C_Q07 10 `"Other"', modify
	label define C_D06 1 `"Yes, paid work one job or business"', modify
	label define C_D06 2 `"Yes, paid work more than one job or business or number of jobs/businesses missing"', modify
	label define C_D06 3 `"Yes, unpaid work for family business"', modify
	label define C_D06 4 `"No"', modify
	label define C_D06 5 `"Not known"', modify
	label define C_Q06 1 `"One job or business"', modify
	label define C_Q06 2 `"More than one job or business"', modify
	label define C_D05 1 `"Employed"', modify
	label define C_D05 2 `"Unemployed"', modify
	label define C_D05 3 `"Out of the labour force"', modify
	label define C_D05 4 `"Not known"', modify
	label define C_Q05 1 `"Yes"', modify
	label define C_Q05 2 `"No"', modify
	label define C_D04 1 `"Yes"', modify
	label define C_D04 2 `"No"', modify
	label define C_D04 3 `"Not known"', modify
	label define C_Q04J 1 `"Yes"', modify
	label define C_Q04J 2 `"No"', modify
	label define C_Q04I 1 `"Yes"', modify
	label define C_Q04I 2 `"No"', modify
	label define C_Q04H 1 `"Yes"', modify
	label define C_Q04H 2 `"No"', modify
	label define C_Q04G 1 `"Yes"', modify
	label define C_Q04G 2 `"No"', modify
	label define C_Q04F 1 `"Yes"', modify
	label define C_Q04F 2 `"No"', modify
	label define C_Q04E 1 `"Yes"', modify
	label define C_Q04E 2 `"No"', modify
	label define C_Q04D 1 `"Yes"', modify
	label define C_Q04D 2 `"No"', modify
	label define C_Q04C 1 `"Yes"', modify
	label define C_Q04C 2 `"No"', modify
	label define C_Q04B 1 `"Yes"', modify
	label define C_Q04B 2 `"No"', modify
	label define C_Q04A 1 `"Yes"', modify
	label define C_Q04A 2 `"No"', modify
	label define C_Q03_10 1 `"Marked"', modify
	label define C_Q03_10 2 `"Not marked"', modify
	label define C_Q03_09 1 `"Marked"', modify
	label define C_Q03_09 2 `"Not marked"', modify
	label define C_Q03_08 1 `"Marked"', modify
	label define C_Q03_08 2 `"Not marked"', modify
	label define C_Q03_07 1 `"Marked"', modify
	label define C_Q03_07 2 `"Not marked"', modify
	label define C_Q03_06 1 `"Marked"', modify
	label define C_Q03_06 2 `"Not marked"', modify
	label define C_Q03_05 1 `"Marked"', modify
	label define C_Q03_05 2 `"Not marked"', modify
	label define C_Q03_04 1 `"Marked"', modify
	label define C_Q03_04 2 `"Not marked"', modify
	label define C_Q03_03 1 `"Marked"', modify
	label define C_Q03_03 2 `"Not marked"', modify
	label define C_Q03_02 1 `"Marked"', modify
	label define C_Q03_02 2 `"Not marked"', modify
	label define C_Q03_01 1 `"Marked"', modify
	label define C_Q03_01 2 `"Not marked"', modify
	label define C_Q02C 1 `"Within three months"', modify
	label define C_Q02C 2 `"In more than three months"', modify
	label define C_Q02B 1 `"Yes"', modify
	label define C_Q02B 2 `"No"', modify
	label define C_Q02A 1 `"Yes"', modify
	label define C_Q02A 2 `"No"', modify
	label define C_Q01C 1 `"Yes"', modify
	label define C_Q01C 2 `"No"', modify
	label define C_Q01B 1 `"Yes"', modify
	label define C_Q01B 2 `"No"', modify
	label define C_Q01A 1 `"Yes"', modify
	label define C_Q01A 2 `"No"', modify
	label define B_Q26B 1 `"I did not have the prerequisites"', modify
	label define B_Q26B 2 `"Education or training was too expensive/I could not afford it"', modify
	label define B_Q26B 3 `"Lack of employer’s support"', modify
	label define B_Q26B 4 `"I was too busy at work"', modify
	label define B_Q26B 5 `"The course or programme was offered at an inconvenient time or place"', modify
	label define B_Q26B 6 `"I did not have time because of child care or family responsibilities"', modify
	label define B_Q26B 7 `"Something unexpected came up that prevented me from taking education or training"', modify
	label define B_Q26B 8 `"Other"', modify
	label define B_Q26A_T 1 `"Yes"', modify
	label define B_Q26A_T 2 `"No"', modify
	label define B_Q26A 1 `"Yes"', modify
	label define B_Q26A 2 `"No"', modify
	label define B_Q20B 1 `"None of the time"', modify
	label define B_Q20B 2 `"Up to a quarter of the time"', modify
	label define B_Q20B 3 `"Up to half of the time"', modify
	label define B_Q20B 4 `"More than half of the time"', modify
	label define B_Q20B 5 `"All of the time"', modify
	label define B_Q17 1 `"Weeks"', modify
	label define B_Q17 2 `"Days"', modify
	label define B_Q17 3 `"Hours"', modify
	label define B_Q16 1 `"Yes, totally"', modify
	label define B_Q16 2 `"Yes, partly"', modify
	label define B_Q16 3 `"No, not at all"', modify
	label define B_Q16 4 `"There were no such costs"', modify
	label define B_Q16 5 `"No employer or prospective employer at that time"', modify
	label define B_Q15C 1 `"Not useful at all"', modify
	label define B_Q15C 2 `"Somewhat useful"', modify
	label define B_Q15C 3 `"Moderately useful"', modify
	label define B_Q15C 4 `"Very useful"', modify
	label define B_Q15B 1 `"Only during working hours"', modify
	label define B_Q15B 2 `"Mostly during working hours"', modify
	label define B_Q15B 3 `"Mostly outside working hours"', modify
	label define B_Q15B 4 `"Only outside working hours"', modify
	label define B_Q15A 1 `"Yes"', modify
	label define B_Q15A 2 `"No"', modify
	label define B_Q14B 1 `"To do my job better and/or improve career prospects"', modify
	label define B_Q14B 2 `"To be less likely to lose my job"', modify
	label define B_Q14B 3 `"To increase my possibilities of getting a job, or changing a job or profession"', modify
	label define B_Q14B 4 `"To start my own business"', modify
	label define B_Q14B 5 `"I was obliged to participate"', modify
	label define B_Q14B 6 `"To increase my knowledge or skills on a subject that interests me"', modify
	label define B_Q14B 7 `"To obtain a certificate"', modify
	label define B_Q14B 8 `"Other"', modify
	label define B_Q14A 1 `"Yes"', modify
	label define B_Q14A 2 `"No"', modify
	label define B_Q13 1 `"A course conducted through open or distance education"', modify
	label define B_Q13 2 `"An organised session for on-the-job training or training by supervisors or co-workers"', modify
	label define B_Q13 3 `"A seminar or workshop"', modify
	label define B_Q13 4 `"Other kind of course or private lesson"', modify
	label define B_D12H 1 `"Respondent reported 1 learning activity"', modify
	label define B_D12H 2 `"Respondent reported more than 1 learning activity"', modify
	label define B_D12H 3 `"Respondent reported no learning activities"', modify
	label define B_D12H 4 `"Respondent reported learning activities but number is not known"', modify
	label define B_D12H 5 `"Information on learning activities is not known"', modify
	label define B_Q12G 1 `"Yes"', modify
	label define B_Q12G 2 `"No"', modify
	label define B_Q12E 1 `"Yes"', modify
	label define B_Q12E 2 `"No"', modify
	label define B_Q12C 1 `"Yes"', modify
	label define B_Q12C 2 `"No"', modify
	label define B_Q12A_T 1 `"Yes"', modify
	label define B_Q12A_T 2 `"No"', modify
	label define B_Q12A 1 `"Yes"', modify
	label define B_Q12A 2 `"No"', modify
	label define B_Q11 1 `"Yes, totally"', modify
	label define B_Q11 2 `"Yes, partly"', modify
	label define B_Q11 3 `"No, not at all"', modify
	label define B_Q11 4 `"There were no such costs"', modify
	label define B_Q11 5 `"No employer or prospective employer at that time"', modify
	label define B_Q10C 1 `"Not useful at all"', modify
	label define B_Q10C 2 `"Somewhat useful"', modify
	label define B_Q10C 3 `"Moderately useful"', modify
	label define B_Q10C 4 `"Very useful"', modify
	label define B_Q10B 1 `"Only during working hours"', modify
	label define B_Q10B 2 `"Mostly during working hours"', modify
	label define B_Q10B 3 `"Mostly outside working hours"', modify
	label define B_Q10B 4 `"Only outside working hours"', modify
	label define B_Q10A 1 `"Yes"', modify
	label define B_Q10A 2 `"No"', modify
	label define B_Q05C_T 1 `"Yes"', modify
	label define B_Q05C_T 2 `"No"', modify
	label define B_Q05C 1 `"Yes"', modify
	label define B_Q05C 2 `"No"', modify
	label define B_Q05B 1 `"General programmes"', modify
	label define B_Q05B 2 `"Teacher training and education science"', modify
	label define B_Q05B 3 `"Humanities, languages and arts"', modify
	label define B_Q05B 4 `"Social sciences, business and law"', modify
	label define B_Q05B 5 `"Science, mathematics and computing"', modify
	label define B_Q05B 6 `"Engineering, manufacturing and construction"', modify
	label define B_Q05B 7 `"Agriculture and veterinary"', modify
	label define B_Q05B 8 `"Health and welfare"', modify
	label define B_Q05B 9 `"Services"', modify
	label define B_Q05A 1 `"ISCED 1"', modify
	label define B_Q05A 2 `"ISCED 2"', modify
	label define B_Q05A 3 `"ISCED 3C shorter than 2 years"', modify
	label define B_Q05A 4 `"ISCED 3C 2 years or more"', modify
	label define B_Q05A 5 `"ISCED 3A-B"', modify
	label define B_Q05A 6 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q05A 7 `"ISCED 4C"', modify
	label define B_Q05A 8 `"ISCED 4A-B"', modify
	label define B_Q05A 9 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q05A 10 `"ISCED 5B"', modify
	label define B_Q05A 11 `"ISCED 5A, bachelor degree"', modify
	label define B_Q05A 12 `"ISCED 5A, master degree"', modify
	label define B_Q05A 13 `"ISCED 6"', modify
	label define B_Q05A 14 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define B_Q04A 1 `"Yes"', modify
	label define B_Q04A 2 `"No"', modify
	label define B_D03D_C 1 `"less than 1 year"', modify
	label define B_D03D_C 2 `"1 to less than 2 years"', modify
	label define B_D03D_C 3 `"2 years or more"', modify
	label define B_Q03D 1 `"January"', modify
	label define B_Q03D 2 `"February"', modify
	label define B_Q03D 3 `"March"', modify
	label define B_Q03D 4 `"April"', modify
	label define B_Q03D 5 `"May"', modify
	label define B_Q03D 6 `"June"', modify
	label define B_Q03D 7 `"July"', modify
	label define B_Q03D 8 `"August"', modify
	label define B_Q03D 9 `"September"', modify
	label define B_Q03D 10 `"October"', modify
	label define B_Q03D 11 `"November"', modify
	label define B_Q03D 12 `"December"', modify
	label define B_Q03C1_C 1 `"Aged 15 or younger"', modify
	label define B_Q03C1_C 2 `"Aged 16-19"', modify
	label define B_Q03C1_C 3 `"Aged 20-24"', modify
	label define B_Q03C1_C 4 `"Aged 25-29"', modify
	label define B_Q03C1_C 5 `"Aged 30-34"', modify
	label define B_Q03C1_C 6 `"Aged 35 or older"', modify
	label define B_Q03B_C 1 `"ISCED 3c and below"', modify
	label define B_Q03B_C 2 `"ISCED 3c long, 3A-B"', modify
	label define B_Q03B_C 3 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q03B_C 4 `"ISCED 4C"', modify
	label define B_Q03B_C 5 `"ISCED 4A-B"', modify
	label define B_Q03B_C 6 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q03B_C 7 `"ISCED 5B"', modify
	label define B_Q03B_C 8 `"ISCED 5A, bachelor degree"', modify
	label define B_Q03B_C 9 `"ISCED 5A, master degree, and ISCED 6 (without distinction)"', modify
	label define B_Q03B_C 10 `"ISCED 5A bachelor degree, 5A master degree, and ISCED 6 (without distinction)"', modify
	label define B_Q03B 1 `"ISCED 1"', modify
	label define B_Q03B 2 `"ISCED 2"', modify
	label define B_Q03B 3 `"ISCED 3C shorter than 2 years"', modify
	label define B_Q03B 4 `"ISCED 3C 2 years or more"', modify
	label define B_Q03B 5 `"ISCED 3A-B"', modify
	label define B_Q03B 6 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q03B 7 `"ISCED 4C"', modify
	label define B_Q03B 8 `"ISCED 4A-B"', modify
	label define B_Q03B 9 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q03B 10 `"ISCED 5B"', modify
	label define B_Q03B 11 `"ISCED 5A, bachelor degree"', modify
	label define B_Q03B 12 `"ISCED 5A, master degree"', modify
	label define B_Q03B 13 `"ISCED 6"', modify
	label define B_Q03B 14 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define B_Q03A 1 `"Yes"', modify
	label define B_Q03A 2 `"No"', modify
	label define B_Q02C 1 `"General programmes"', modify
	label define B_Q02C 2 `"Teacher training and education science"', modify
	label define B_Q02C 3 `"Humanities, languages and arts"', modify
	label define B_Q02C 4 `"Social sciences, business and law"', modify
	label define B_Q02C 5 `"Science, mathematics and computing"', modify
	label define B_Q02C 6 `"Engineering, manufacturing and construction"', modify
	label define B_Q02C 7 `"Agriculture and veterinary"', modify
	label define B_Q02C 8 `"Health and welfare"', modify
	label define B_Q02C 9 `"Services"', modify
	label define B_Q02B_C 1 `"ISCED 3c and below"', modify
	label define B_Q02B_C 2 `"ISCED 3c long, 3A-B"', modify
	label define B_Q02B_C 3 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q02B_C 4 `"ISCED 4C"', modify
	label define B_Q02B_C 5 `"ISCED 4A-B"', modify
	label define B_Q02B_C 6 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q02B_C 7 `"ISCED 5B"', modify
	label define B_Q02B_C 8 `"ISCED 5A, bachelor degree"', modify
	label define B_Q02B_C 9 `"ISCED 5A, master degree, and ISCED 6 (without distinction)"', modify
	label define B_Q02B_C 10 `"ISCED 5A bachelor degree, 5A master degree, and ISCED 6 (without distinction)"', modify
	label define B_Q02B 1 `"ISCED 1"', modify
	label define B_Q02B 2 `"ISCED 2"', modify
	label define B_Q02B 3 `"ISCED 3C shorter than 2 years"', modify
	label define B_Q02B 4 `"ISCED 3C 2 years or more"', modify
	label define B_Q02B 5 `"ISCED 3A-B"', modify
	label define B_Q02B 6 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q02B 7 `"ISCED 4C"', modify
	label define B_Q02B 8 `"ISCED 4A-B"', modify
	label define B_Q02B 9 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q02B 10 `"ISCED 5B"', modify
	label define B_Q02B 11 `"ISCED 5A, bachelor degree"', modify
	label define B_Q02B 12 `"ISCED 5A, master degree"', modify
	label define B_Q02B 13 `"ISCED 6"', modify
	label define B_Q02B 14 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define B_Q02A_T2 1 `"Yes"', modify
	label define B_Q02A_T2 2 `"No"', modify
	label define B_Q02A_T1 1 `"Yes"', modify
	label define B_Q02A_T1 2 `"No"', modify
	label define B_Q02A 1 `"Yes"', modify
	label define B_Q02A 2 `"No"', modify
	label define B_D01D_C 1 `"less than 1 year"', modify
	label define B_D01D_C 2 `"1 to less than 2 years"', modify
	label define B_D01D_C 3 `"2 to less than 5 years"', modify
	label define B_D01D_C 4 `"5 to less than 10 years"', modify
	label define B_D01D_C 5 `"10 years or more"', modify
	label define B_Q01D 1 `"January"', modify
	label define B_Q01D 2 `"February"', modify
	label define B_Q01D 3 `"March"', modify
	label define B_Q01D 4 `"April"', modify
	label define B_Q01D 5 `"May"', modify
	label define B_Q01D 6 `"June"', modify
	label define B_Q01D 7 `"July"', modify
	label define B_Q01D 8 `"August"', modify
	label define B_Q01D 9 `"September"', modify
	label define B_Q01D 10 `"October"', modify
	label define B_Q01D 11 `"November"', modify
	label define B_Q01D 12 `"December"', modify
	label define B_Q01C1_C 1 `"Aged 15 or younger"', modify
	label define B_Q01C1_C 2 `"Aged 16-19"', modify
	label define B_Q01C1_C 3 `"Aged 20-24"', modify
	label define B_Q01C1_C 4 `"Aged 25-29"', modify
	label define B_Q01C1_C 5 `"Aged 30-34"', modify
	label define B_Q01C1_C 6 `"Aged 35 or older"', modify
	label define B_Q01B 1 `"General programmes"', modify
	label define B_Q01B 2 `"Teacher training and education science"', modify
	label define B_Q01B 3 `"Humanities, languages and arts"', modify
	label define B_Q01B 4 `"Social sciences, business and law"', modify
	label define B_Q01B 5 `"Science, mathematics and computing"', modify
	label define B_Q01B 6 `"Engineering, manufacturing and construction"', modify
	label define B_Q01B 7 `"Agriculture and veterinary"', modify
	label define B_Q01B 8 `"Health and welfare"', modify
	label define B_Q01B 9 `"Services"', modify
	label define B_Q01A3_C 1 `"No formal qualification or below ISCED 1"', modify
	label define B_Q01A3_C 2 `"ISCED 1"', modify
	label define B_Q01A3_C 3 `"ISCED 2"', modify
	label define B_Q01A3_C 4 `"ISCED 3C shorter than 2 years"', modify
	label define B_Q01A3_C 5 `"ISCED 3C 2 years or more"', modify
	label define B_Q01A3_C 6 `"ISCED 3A-B"', modify
	label define B_Q01A3_C 7 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q01A3_C 8 `"ISCED 4C"', modify
	label define B_Q01A3_C 9 `"ISCED 4A-B"', modify
	label define B_Q01A3_C 10 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q01A3_C 11 `"ISCED 5B"', modify
	label define B_Q01A3_C 12 `"ISCED 5A, bachelor degree"', modify
	label define B_Q01A3_C 13 `"ISCED 5A, master degree, and ISCED 6 (without distinction)"', modify
	label define B_Q01A3_C 14 `"ISCED 5A bachelor degree, 5A master degree, and ISCED 6 (without distinction)"', modify
	label define B_Q01A3 1 `"No formal qualification or below ISCED 1"', modify
	label define B_Q01A3 2 `"ISCED 1"', modify
	label define B_Q01A3 3 `"ISCED 2"', modify
	label define B_Q01A3 4 `"ISCED 3C shorter than 2 years"', modify
	label define B_Q01A3 5 `"ISCED 3C 2 years or more"', modify
	label define B_Q01A3 6 `"ISCED 3A-B"', modify
	label define B_Q01A3 7 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q01A3 8 `"ISCED 4C"', modify
	label define B_Q01A3 9 `"ISCED 4A-B"', modify
	label define B_Q01A3 10 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q01A3 11 `"ISCED 5B"', modify
	label define B_Q01A3 12 `"ISCED 5A, bachelor degree"', modify
	label define B_Q01A3 13 `"ISCED 5A, master degree"', modify
	label define B_Q01A3 14 `"ISCED 6"', modify
	label define B_Q01A3 15 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define B_Q01A_T 1 `"Less than high school"', modify
	label define B_Q01A_T 2 `"High school"', modify
	label define B_Q01A_T 3 `"Above high school"', modify
	label define B_Q01A_T 4 `"Not definable"', modify
	label define B_Q01A 1 `"No formal qualification or below ISCED 1"', modify
	label define B_Q01A 2 `"ISCED 1"', modify
	label define B_Q01A 3 `"ISCED 2"', modify
	label define B_Q01A 4 `"ISCED 3C shorter than 2 years"', modify
	label define B_Q01A 5 `"ISCED 3C 2 years or more"', modify
	label define B_Q01A 6 `"ISCED 3A-B"', modify
	label define B_Q01A 7 `"ISCED 3 (without distinction A-B-C, 2y+)"', modify
	label define B_Q01A 8 `"ISCED 4C"', modify
	label define B_Q01A 9 `"ISCED 4A-B"', modify
	label define B_Q01A 10 `"ISCED 4 (without distinction A-B-C)"', modify
	label define B_Q01A 11 `"ISCED 5B"', modify
	label define B_Q01A 12 `"ISCED 5A, bachelor degree"', modify
	label define B_Q01A 13 `"ISCED 5A, master degree"', modify
	label define B_Q01A 14 `"ISCED 6"', modify
	label define B_Q01A 15 `"Foreign qualification"', modify
	label define B_Q01A 16 `"ISCED 5A bachelor degree, 5A master degree, and 6 (without distinction)"', modify
	label define A_N01_T 1 `"Male"', modify
	label define A_N01_T 2 `"Female"', modify
	label define DISP_MAINWRC 0 `"Not assigned"', modify
	label define DISP_MAINWRC 1 `"Complete"', modify
	label define DISP_MAINWRC 3 `"Partial complete/breakoff"', modify
	label define DISP_MAINWRC 4 `"Refusal - Sample person"', modify
	label define DISP_MAINWRC 5 `"Refusal - Other"', modify
	label define DISP_MAINWRC 7 `"Language problem"', modify
	label define DISP_MAINWRC 8 `"Reading and writing difficulty"', modify
	label define DISP_MAINWRC 9 `"Learning/mental disability"', modify
	label define DISP_MAINWRC 12 `"Hearing impairment"', modify
	label define DISP_MAINWRC 13 `"Blindness/visual impairment"', modify
	label define DISP_MAINWRC 14 `"Speech impairment"', modify
	label define DISP_MAINWRC 15 `"Physical disability"', modify
	label define DISP_MAINWRC 16 `"Other disability"', modify
	label define DISP_MAINWRC 17 `"Other (unspecified), such as sickness or unusual circumstances"', modify
	label define DISP_MAINWRC 18 `"Death"', modify
	label define DISP_MAINWRC 21 `"Maximum number of calls"', modify
	label define DISP_MAINWRC 24 `"Temporarily absent/unavailable during field period"', modify
	label define DISP_MAINWRC 25 `"Ineligible"', modify
	label define DISP_MAINWRC 27 `"Duplication - already interviewed"', modify
	label define DISP_MAINWRC 90 `"Technical problem occurred"', modify
	label define DISP_MAINWRC 91 `"Missing paper booklet"', modify
	label define DISP_MAIN 0 `"Not assigned"', modify
	label define DISP_MAIN 1 `"Complete"', modify
	label define DISP_MAIN 3 `"Partial complete/breakoff"', modify
	label define DISP_MAIN 4 `"Refusal - Sample person"', modify
	label define DISP_MAIN 5 `"Refusal - Other"', modify
	label define DISP_MAIN 7 `"Language problem"', modify
	label define DISP_MAIN 8 `"Reading and writing difficulty"', modify
	label define DISP_MAIN 9 `"Learning/mental disability"', modify
	label define DISP_MAIN 12 `"Hearing impairment"', modify
	label define DISP_MAIN 13 `"Blindness/visual impairment"', modify
	label define DISP_MAIN 14 `"Speech impairment"', modify
	label define DISP_MAIN 15 `"Physical disability"', modify
	label define DISP_MAIN 16 `"Other disability"', modify
	label define DISP_MAIN 17 `"Other (unspecified), such as sickness or unusual circumstances"', modify
	label define DISP_MAIN 18 `"Death"', modify
	label define DISP_MAIN 21 `"Maximum number of calls"', modify
	label define DISP_MAIN 24 `"Temporarily absent/unavailable during field period"', modify
	label define DISP_MAIN 25 `"Ineligible"', modify
	label define DISP_MAIN 27 `"Duplication - already interviewed"', modify
	label define DISP_MAIN 90 `"Technical problem occurred"', modify
	label define DISP_MAIN 91 `"Missing paper booklet"', modify
	label define DISP_CIBQ 0 `"Not assigned"', modify
	label define DISP_CIBQ 1 `"Complete"', modify
	label define DISP_CIBQ 3 `"Partial complete/breakoff"', modify
	label define DISP_CIBQ 4 `"Refusal - Sample person"', modify
	label define DISP_CIBQ 5 `"Refusal - Other"', modify
	label define DISP_CIBQ 7 `"Language problem"', modify
	label define DISP_CIBQ 8 `"Reading and writing difficulty"', modify
	label define DISP_CIBQ 9 `"Learning/mental disability"', modify
	label define DISP_CIBQ 12 `"Hearing impairment"', modify
	label define DISP_CIBQ 13 `"Blindness/visual impairment"', modify
	label define DISP_CIBQ 14 `"Speech impairment"', modify
	label define DISP_CIBQ 15 `"Physical disability"', modify
	label define DISP_CIBQ 16 `"Other disability"', modify
	label define DISP_CIBQ 17 `"Other (unspecified), such as sickness or unusual circumstances"', modify
	label define DISP_CIBQ 18 `"Death"', modify
	label define DISP_CIBQ 21 `"Maximum number of calls"', modify
	label define DISP_CIBQ 24 `"Temporarily absent/unavailable during field period"', modify
	label define DISP_CIBQ 25 `"Ineligible"', modify
	label define DISP_CIBQ 27 `"Duplication - already interviewed"', modify
	label define DISP_CIBQ 90 `"Technical problem"', modify
	label define GENDER_R 1 `"Male"', modify
	label define GENDER_R 2 `"Female"', modify
	label define CNTRYID_E 36 `"Australia"', modify
	label define CNTRYID_E 40 `"Austria"', modify
	label define CNTRYID_E 124 `"Canada"', modify
	label define CNTRYID_E 196 `"Cyprus"', modify
	label define CNTRYID_E 203 `"Czech Republic"', modify
	label define CNTRYID_E 208 `"Denmark"', modify
	label define CNTRYID_E 233 `"Estonia"', modify
	label define CNTRYID_E 246 `"Finland"', modify
	label define CNTRYID_E 250 `"France"', modify
	label define CNTRYID_E 276 `"Germany"', modify
	label define CNTRYID_E 372 `"Ireland"', modify
	label define CNTRYID_E 380 `"Italy"', modify
	label define CNTRYID_E 392 `"Japan"', modify
	label define CNTRYID_E 410 `"Korea"', modify
	label define CNTRYID_E 528 `"Netherlands"', modify
	label define CNTRYID_E 578 `"Norway"', modify
	label define CNTRYID_E 616 `"Poland"', modify
	label define CNTRYID_E 643 `"Russian Federation"', modify
	label define CNTRYID_E 703 `"Slovak Republic"', modify
	label define CNTRYID_E 724 `"Spain"', modify
	label define CNTRYID_E 752 `"Sweden"', modify
	label define CNTRYID_E 840 `"United States"', modify
	label define CNTRYID_E 926 `"England (UK)"', modify
	label define CNTRYID_E 928 `"Northern Ireland (UK)"', modify
	label define CNTRYID_E 956 `"Flanders (Belgium)"', modify
	label define CNTRYID_E 1241 `"Canada (English)"', modify
	label define CNTRYID_E 1242 `"Canada (French)"', modify
	label define CNTRYID_E 8261 `"England/N. Ireland (UK)"', modify
	label define CNTRYID 36 `"Australia"', modify
	label define CNTRYID 40 `"Austria"', modify
	label define CNTRYID 56 `"Belgium"', modify
	label define CNTRYID 124 `"Canada"', modify
	label define CNTRYID 196 `"Cyprus"', modify
	label define CNTRYID 203 `"Czech Republic"', modify
	label define CNTRYID 208 `"Denmark"', modify
	label define CNTRYID 233 `"Estonia"', modify
	label define CNTRYID 246 `"Finland"', modify
	label define CNTRYID 250 `"France"', modify
	label define CNTRYID 276 `"Germany"', modify
	label define CNTRYID 372 `"Ireland"', modify
	label define CNTRYID 380 `"Italy"', modify
	label define CNTRYID 392 `"Japan"', modify
	label define CNTRYID 410 `"Korea"', modify
	label define CNTRYID 528 `"Netherlands"', modify
	label define CNTRYID 578 `"Norway"', modify
	label define CNTRYID 616 `"Poland"', modify
	label define CNTRYID 643 `"Russian Federation"', modify
	label define CNTRYID 703 `"Slovak Republic"', modify
	label define CNTRYID 724 `"Spain"', modify
	label define CNTRYID 752 `"Sweden"', modify
	label define CNTRYID 826 `"United Kingdom"', modify
	label define CNTRYID 840 `"United States"', modify
end

cap program drop lamf
program define lamf //this program creates all variable labels, and assign them to variables, along with with value labels.
		
	 dis "  Labelling..."
	 local cntryid_lab  `"Country ID (ISO 3166, numeric)"'
	 local cntry_lab  `"Country ID and sub-national entity sample code (string)"'
	 local cntryid_e_lab  `"Participating country or sub-national entity code (numeric)"'
	 local cntry_e_lab  `"Participating country or sub-national entity code (string)"'
	 local caseid_lab  `"Household operational ID"'
	 local seqid_lab  `"Sequential ID (randomly derived)"'
	 local samptype_lab  `"Flag for oversample"'
	 local calcage_lab  `"Person age (derived)"'
	 local dobyy_lab  `"Date of birth year (derived from BQ)"'
	 local dobmm_lab  `"Date of birth (derived from BQ)"'
	 local age_r_lab  `"Person resolved age from BQ and QC check (derived)"'
	 local gender_r_lab  `"Person resolved gender from BQ and QC check (derived)"'
	 local disp_scr_lab  `"Final disposition code for household screener"'
	 local ci_persid_lab  `"Sampled person ID entered during case initialization (with check digit)"'
	 local ci_gender_lab  `"Respondent gender"'
	 local ci_month_lab  `"Respondent month of birth"'
	 local ci_year_lab  `"Respondent year of birth"'
	 local ci_age_lab  `"Respondent age"'
	 local disp_ci_lab  `"Final disposition code for case initialization"'
	 local disp_ci_in_lab  `"Final disposition code for case initialization - write-in reason for ineligibili"'
	 local disp_8_lab  `"Final disposition code for case initialization - write-in reason for ineligibili"'
	 local disp_9_lab  `"Final disposition code for case initialization - write-in reason for ineligibili"'
	 local bqlang_lab  `"Language for background questionnaire"'
	 local a_d01a1_lab  `"General - Interview month (DERIVED BY CAPI)"'
	 local a_d01a2_lab  `"General - Year before interview (DERIVED BY CAPI)"'
	 local a_d01a3_lab  `"General - Interview year (DERIVED BY CAPI)"'
	 local a_q01a_lab  `"General - Year of birth"'
	 local a_q01b_lab  `"General - Month of birth"'
	 local a_n01_lab  `"General - Gender of respondent"'
	 local a_n01_t_lab  `"Gender (Trend-IALS/ALL)"'
	 local b_q01a_lab  `"Education - Highest qualification - Level"'
	 local b_q01a_t_lab  `"Highest level of schooling (Trend-IALS/ALL)"'
	 local b_s01a1_lab  `"Education - Highest qualification - Name of foreign qualification"'
	 local b_s016_lab  `"Education - Highest qualification - Name of foreign qualification"'
	 local b_s017_lab  `"Education - Highest qualification - Name of foreign qualification"'
	 local b_s01a2_lab  `"Education - Highest qualification - Country of foreign qualification (other)"'
	 local b_s014_lab  `"Education - Highest qualification - Country of foreign qualification (other)"'
	 local b_s015_lab  `"Education - Highest qualification - Country of foreign qualification (other)"'
	 local b_q01a3_lab  `"Education - Highest qualification - Level of foreign qualification"'
	 local b_q01a3_c_lab  `"Education - Highest Qualification - Level of foreign qualification (collapsed, 1"'
	 local b_q01b_lab  `"Education - Highest qualification - Area of study"'
	 local b_q01c1_lab  `"Education - Highest qualification - Age of finish"'
	 local b_q01c1_c_lab  `"Education - Highest qualification - Age of finish (categorised, 6 categories)"'
	 local b_q01c1_t_lab  `"Age at completion of highest level of schooling (Trend-IALS/ALL)"'
	 local b_q01c2_lab  `"Education - Highest qualification - Year of finish"'
	 local b_q01d_lab  `"Education - Highest qualification - Month of finish"'
	 local b_d01d_lab  `"Education - Highest qualification - Months elapsed since finished (DERIVED BY CA"'
	 local b_d01d_c_lab  `"Education - Time elapsed since finished highest qualification (categorised, 5 ca"'
	 local b_q02a_lab  `"Education - Current qualification"'
	 local b_q02a_t1_lab  `"Education or training in last 12 months (Trend-IALS/ALL)"'
	 local b_q02a_t2_lab  `"Courses toward certificate, diploma, or degree in program of studies in last 12 "'
	 local b_q02b_lab  `"Education - Current qualification - Level"'
	 local b_q02b_c_lab  `"Education - Current Qualification (collapsed, 10 categories)"'
	 local b_q02c_lab  `"Education - Current qualification - Area of study"'
	 local b_q03a_lab  `"Education - Uncompleted qualification"'
	 local b_q03b_lab  `"Education - Uncompleted qualification - Level"'
	 local b_q03b_c_lab  `"Education - Uncompleted qualification - Level (collapsed, 10 categories)"'
	 local b_q03c1_lab  `"Education - Uncompleted qualification - Age of dropout"'
	 local b_q03c1_c_lab  `"Education - Uncompleted qualification - Age of dropout (categorised, 6 categorie"'
	 local b_q03c2_lab  `"Education - Uncompleted qualification - Year of dropout"'
	 local b_q03d_lab  `"Education - Uncompleted qualification - Month of dropout"'
	 local b_d03d_lab  `"Education - Uncompleted qualification - Months elapsed since dropout (DERIVED BY"'
	 local b_d03d_c_lab  `"Education - Derived Months elapsed since leaving education without completing pr"'
	 local b_q04a_lab  `"Education - Formal qualification"'
	 local b_q04b_lab  `"Education - Formal qualification - Count"'
	 local b_q04b_c_lab  `"Education - Formal qualification - Count (top-coded at 2)"'
	 local b_q05a_lab  `"Education - Formal qualification - Level"'
	 local b_q05b_lab  `"Education - Formal qualification - Area of study"'
	 local b_q05c_lab  `"Education - Formal qualification - Reason job related"'
	 local b_q05c_t_lab  `"Main reason for program of studies (Trend-IALS/ALL)"'
	 local b_q10a_lab  `"Education - Formal qualification - Employed"'
	 local b_q10b_lab  `"Education - Formal qualification - Employed - Working hours"'
	 local b_q10c_lab  `"Education - Formal qualification - Employed - Useful for job"'
	 local b_q11_lab  `"Education - Formal qualification - Grant from employer"'
	 local b_q12a_lab  `"Activities - Last year - Open or distance education"'
	 local b_q12a_t_lab  `"Courses outside of program of studies in last 12 months (Trend-IALS/ALL)"'
	 local b_q12b_lab  `"Activities - Last year - Open or distance education - Count"'
	 local b_q12c_lab  `"Activities - Last year - On the job training"'
	 local b_q12d_lab  `"Activities - Last year - On the job training - Count"'
	 local b_q12d_c_lab  `"Activities - Last year - On the job training - Count (top-coded at 5)"'
	 local b_q12e_lab  `"Activities - Last year - Seminars or workshops"'
	 local b_q12f_lab  `"Activities - Last year - Seminars or workshops - Count"'
	 local b_q12f_c_lab  `"Activities - Last year - Seminars or workshops - Count (top-coded at 5)"'
	 local b_q12g_lab  `"Activities - Last year - Private lessons"'
	 local b_q12h_lab  `"Activities - Last year - Private lessons - Count"'
	 local b_q12h_c_lab  `"Activities - Last year - Private lessons - Count (top-coded at 5)"'
	 local b_d12h_lab  `"Activities - Last year - Number of learning activities (DERIVED BY CAPI)"'
	 local b_q13_lab  `"Activities - Last year - Activity specified"'
	 local b_q14a_lab  `"Activities - Last year - Job related"'
	 local b_q14b_lab  `"Activities - Last year - Reason for participating"'
	 local b_q15a_lab  `"Activities - Last year - Employed"'
	 local b_q15b_lab  `"Activities - Last year - During working hours"'
	 local b_q15c_lab  `"Activities - Last year - Useful for job"'
	 local b_q16_lab  `"Activities - Last year - Grant from employer"'
	 local b_q17_lab  `"Activities - Last year - Time spend - Unit"'
	 local b_q18a_lab  `"Activities - Last year - Time spend for activities - Weeks"'
	 local b_q19a_lab  `"Activities - Last year - Time spend for activities - Days"'
	 local b_q20a_lab  `"Activities - Last year - Time spend for activities - Hours"'
	 local b_q20b_lab  `"Activities - Last year - Time spend for activities - Proportion of job-related h"'
	 local b_q26a_lab  `"Activities - Last year - Wanted but didn`'t start"'
	 local b_q26a_t_lab  `"Training or education for career or job wanted but not taken in last 12 months ("'
	 local b_q26b_lab  `"Activities - Last year - Wanted but didn`'t start - Reason"'
	 local c_q01a_lab  `"Current status/work history - Last week - Paid work"'
	 local c_q01b_lab  `"Current status/work history - Last week - Away from job but will return"'
	 local c_q01c_lab  `"Current status/work history - Last week - Unpaid work for own business"'
	 local c_q02a_lab  `"Current status/work history - Last month - Looking for paid work"'
	 local c_q02b_lab  `"Current status/work history - Last month - Waiting to start job"'
	 local c_q02c_lab  `"Current status/work history - Last month - Waiting to start job - Next 3 months"'
	 local c_q03_01_lab  `"Current status/work history - Last month - Reason not looking for work - Waiting"'
	 local c_q03_02_lab  `"Current status/work history - Last month - Reason not looking for work - Being a"'
	 local c_q03_03_lab  `"Current status/work history - Last month - Reason not looking for work - Looking"'
	 local c_q03_04_lab  `"Current status/work history - Last month - Reason not looking for work - Temp si"'
	 local c_q03_05_lab  `"Current status/work history - Last month - Reason not looking for work - Long-te"'
	 local c_q03_06_lab  `"Current status/work history - Last month - Reason not looking for work - Nothing"'
	 local c_q03_07_lab  `"Current status/work history - Last month - Reason not looking for work - Did not"'
	 local c_q03_08_lab  `"Current status/work history - Last month - Reason not looking for work - No need"'
	 local c_q03_09_lab  `"Current status/work history - Last month - Reason not looking for work - Retired"'
	 local c_q03_10_lab  `"Current status/work history - Last month - Reason not looking for work - Other"'
	 local c_s03_lab  `"Current status/work history - Last month - Months looking for paid work"'
	 local c_q04a_lab  `"Current status/work history - Last month - Ways of looking for work - Contact pu"'
	 local c_q04b_lab  `"Current status/work history - Last month - Ways of looking for work - Contact pr"'
	 local c_q04c_lab  `"Current status/work history - Last month - Ways of looking for work - Apply to e"'
	 local c_q04d_lab  `"Current status/work history - Last month - Ways of looking for work - Ask family"'
	 local c_q04e_lab  `"Current status/work history - Last month - Ways of looking for work - Place/answ"'
	 local c_q04f_lab  `"Current status/work history - Last month - Ways of looking for work - Study adve"'
	 local c_q04g_lab  `"Current status/work history - Last month - Ways of looking for work - Recruitmen"'
	 local c_q04h_lab  `"Current status/work history - Last month - Ways of looking for work - Premises"'
	 local c_q04i_lab  `"Current status/work history - Last month - Ways of looking for work - Licenses/f"'
	 local c_q04j_lab  `"Current status/work history - Last month - Ways of looking for work - Other"'
	 local c_s04j_lab  `"Current status/work history - Last month - Ways of looking for work - Other spec"'
	 local c_s040_lab  `"Current status/work history - Last month - Ways of looking for work - Other spec"'
	 local c_d04_lab  `"Current status/work history - Last month - Active steps to find job (DERIVED BY "'
	 local c_q05_lab  `"Current status/work history - Ability to start job within 2 weeks"'
	 local c_d05_lab  `"Current status/work history - Employment status (DERIVED BY CAPI)"'
	 local c_q06_lab  `"Current status/work history - Last week - Number of jobs"'
	 local c_d06_lab  `"Current status/work history - Current - Paid job or family business (DERIVED BY "'
	 local c_q07_lab  `"Current status/work history - Subjective status"'
	 local c_q07_t_lab  `"Current work situation (Trend-IALS/ALL)"'
	 local c_q08a_lab  `"Current status/work history - Ever paid work"'
	 local c_q08b_lab  `"Current status/work history - Last year - Paid work"'
	 local c_q08c1_lab  `"Current status/work history - Age when stopped working in last job"'
	 local c_q08c1_c_lab  `"Current status/work history - Age when stopped working in last job (categorised,"'
	 local c_q08c2_lab  `"Current status/work history - Year when stopped working in last job"'
	 local c_d08c_lab  `"Current status/work history - Left work in past 5 years (DERIVED BY CAPI)"'
	 local c_q09_lab  `"Current status/work history - Years of paid work during lifetime"'
	 local c_q09_c_lab  `"Current status/work history - Years of paid work during lifetime (top-coded at 4"'
	 local c_d09_lab  `"Current status/work history - Work experience (DERIVED BY CAPI)"'
	 local c_d09_t_lab  `"Worked at job or business in last 12 months (any number of hours) (Trend-IALS/AL"'
	 local c_q10a_lab  `"Current status/work history - Last 5 years - How many different firms or organis"'
	 local c_q10a_c_lab  `"Current status/work history - Last 5 years - How many different firms or organis"'
	 local d_q01a_lab  `"Current work - Job title"'
	 local d_q012_lab  `"Current work - Job title"'
	 local d_q013_lab  `"Current work - Job title"'
	 local d_q01b_lab  `"Current work - Responsibilities"'
	 local d_q010_lab  `"Current work - Responsibilities"'
	 local d_q011_lab  `"Current work - Responsibilities"'
	 local d_q02a_lab  `"Current work - Kind of business, industry or service"'
	 local d_q022_lab  `"Current work - Kind of business, industry or service"'
	 local d_q023_lab  `"Current work - Kind of business, industry or service"'
	 local d_q02b_lab  `"Current work - Main product of firm or organisation"'
	 local d_q020_lab  `"Current work - Main product of firm or organisation"'
	 local d_q021_lab  `"Current work - Main product of firm or organisation"'
	 local d_q03_lab  `"Current work - Economic sector"'
	 local d_q04_lab  `"Current work - Employee or self-employed"'
	 local d_q04_t_lab  `"Status at this job or business - six levels (Trend-IALS/ALL)"'
	 local d_q04_t1_lab  `"Status at this job or business - four levels (Trend-IALS/ALL)"'
	 local d_q05a1_lab  `"Current work - Start of work for employer - Age"'
	 local d_q05a1_c_lab  `"Current work - Start of work for employer - Age (categorised, 9 categories)"'
	 local d_q05a2_lab  `"Current work - Start of work for employer - Year"'
	 local d_q05a3_lab  `"Current work - Start of work for employer - Month"'
	 local d_q05b1_lab  `"Current work - Start of work for business - Age"'
	 local d_q05b1_c_lab  `"Current work - Start of work for business - Age (categorised, 9 categories)"'
	 local d_q05b2_lab  `"Current work - Start of work for business - Year"'
	 local d_q05b3_lab  `"Current work - Start of work for business - Month"'
	 local d_q06a_lab  `"Current work - Amount of people working for employer"'
	 local d_q06b_lab  `"Current work - Amount of people working for employer increased"'
	 local d_q06c_lab  `"Current work - Part of a larger organisation"'
	 local d_q07a_lab  `"Current work - Employees working for you"'
	 local d_q07b_lab  `"Current work - Employees working for you - Count"'
	 local d_q07b_c_lab  `"Current work - Employees working for you - Count (collapsed, 2 categories)"'
	 local d_q08a_lab  `"Current work - Managing other employees"'
	 local d_q08b_lab  `"Current work - Managing other employees - Count"'
	 local d_q09_lab  `"Current work - Type of contract"'
	 local d_s09_lab  `"Current work - Other type of contract specified"'
	 local d_s090_lab  `"Current work - Other type of contract specified"'
	 local d_s091_lab  `"Current work - Other type of contract specified"'
	 local d_q10_lab  `"Current work - Hours/week"'
	 local d_q10_c_lab  `"Current work - Hours/week (top-coded at 60)"'
	 local d_q10_t_lab  `"Hours per week at this job or business - number of hours (top coded at 97, Trend"'
	 local d_q10_t1_lab  `"Hours per week at this job or business - range of hours (Trend-IALS/ALL)"'
	 local d_q11a_lab  `"Current work - Work flexibility - Sequence of tasks"'
	 local d_q11b_lab  `"Current work - Work flexibility - How to do the work"'
	 local d_q11c_lab  `"Current work - Work flexibility - Speed of work"'
	 local d_q11d_lab  `"Current work - Work flexibility - Working hours"'
	 local d_q12a_lab  `"Current work - Requirements - Education level"'
	 local d_q12b_lab  `"Current work - Requirements - To do the job satisfactorily"'
	 local d_q12c_lab  `"Current work - Requirements - Related work experience"'
	 local d_q13a_lab  `"Current work - Learning - Learning from co-workers/supervisors"'
	 local d_q13b_lab  `"Current work - Learning - Learning-by-doing"'
	 local d_q13c_lab  `"Current work - Learning - Keeping up to date"'
	 local d_q14_lab  `"Current work - Job satisfaction"'
	 local d_q16a_lab  `"Current work - Earnings - Salary interval"'
	 local d_s16a_lab  `"Current work - Earnings - Hours per piece"'
	 local d_d16a_lab  `"Current work - Earnings - Salary interval per hour (DERIVED BY CAPI)"'
	 local d_q16b_lab  `"Current work - Earnings - Gross pay"'
	 local d_q16b_t_lab  `"Wage or salary [weekly/hourly] before taxes and deductions (Trend-IALS/ALL)"'
	 local d_q16c_lab  `"Current work - Earnings - Gross pay in broad categories"'
	 local d_q16d1_lab  `"Current work - Earnings - Broad categories - Gross pay per hour"'
	 local d_q16d2_lab  `"Current work - Earnings - Broad categories - Gross pay per day"'
	 local d_q16d3_lab  `"Current work - Earnings - Broad categories - Gross pay per week"'
	 local d_q16d4_lab  `"Current work - Earnings - Broad categories - Gross pay per 2 weeks"'
	 local d_q16d5_lab  `"Current work - Earnings - Broad categories - Gross pay per month"'
	 local d_q16d6_lab  `"Current work - Earnings - Broad categories - Gross pay per year"'
	 local d_q17a_lab  `"Current work - Earnings - Additional payments"'
	 local d_q17b_lab  `"Current work - Earnings - Additional payments amount last year"'
	 local d_q17c_lab  `"Current work - Earnings - Additional payments in broad categories"'
	 local d_q17d_lab  `"Current work - Earnings - Additional payments - Broad - Last year"'
	 local d_q18a_lab  `"Current work - Earnings - Total earnings last year"'
	 local d_q18b_lab  `"Current work - Earnings - Total earnings broad categories"'
	 local d_q18c1_lab  `"Current work - Earnings - Broad categories - Total earnings last month"'
	 local d_q18c2_lab  `"Current work - Earnings - Broad categories - Total earnings last year"'
	 local e_q01a_lab  `"Last job - Job title"'
	 local e_q012_lab  `"Last job - Job title"'
	 local e_q013_lab  `"Last job - Job title"'
	 local e_q01b_lab  `"Last job - Responsibilities"'
	 local e_q010_lab  `"Last job - Responsibilities"'
	 local e_q011_lab  `"Last job - Responsibilities"'
	 local e_q02a_lab  `"Last job - Kind of business, industry or service"'
	 local e_q022_lab  `"Last job - Kind of business, industry or service"'
	 local e_q023_lab  `"Last job - Kind of business, industry or service"'
	 local e_q02b_lab  `"Last job - Main product of firm or organisation"'
	 local e_q020_lab  `"Last job - Main product of firm or organisation"'
	 local e_q021_lab  `"Last job - Main product of firm or organisation"'
	 local e_q03_lab  `"Last job - Economic sector"'
	 local e_q04_lab  `"Last job - Employee or self-employed"'
	 local e_q05a1_lab  `"Last job - Start of work for employer - Age"'
	 local e_q05a1_c_lab  `"Last job - Start of work for employer - Age (categorised, 9 categories)"'
	 local e_q05a2_lab  `"Last job - Start of work for employer - Year"'
	 local e_q05b1_lab  `"Last job - Start of work for business - Age"'
	 local e_q05b1_c_lab  `"Last job - Start of work for business - Age (categorised, 9 categories)"'
	 local e_q05b2_lab  `"Last job - Start of work for business - Year"'
	 local e_q06_lab  `"Last job - Amount of people working for employer"'
	 local e_q07a_lab  `"Last job - Employees working for you"'
	 local e_q07b_lab  `"Last job - Employees working for you - Count"'
	 local e_q08_lab  `"Last job - Type of contract"'
	 local e_s08_lab  `"Last job - Other type of contract specified"'
	 local e_s080_lab  `"Last job - Other type of contract specified"'
	 local e_s081_lab  `"Last job - Other type of contract specified"'
	 local e_q09_lab  `"Last job - Hours/week"'
	 local e_q09_c_lab  `"Last work - Hours/week (top-coded at 60)"'
	 local e_q10_lab  `"Last job - Reason for end of job"'
	 local f_q01b_lab  `"Skill use work - Time cooperating with co-workers"'
	 local f_q02a_lab  `"Skill use work - How often - Sharing work-related info"'
	 local f_q02b_lab  `"Skill use work - How often - Teaching people"'
	 local f_q02c_lab  `"Skill use work - How often - Presentations"'
	 local f_q02d_lab  `"Skill use work - How often - Selling"'
	 local f_q02e_lab  `"Skill use work - How often - Advising people"'
	 local f_q03a_lab  `"Skill use work - How often - Planning own activities"'
	 local f_q03b_lab  `"Skill use work - How often - Planning others activities"'
	 local f_q03c_lab  `"Skill use work - How often - Organising own time"'
	 local f_q04a_lab  `"Skill use work - How often - Influencing people"'
	 local f_q04b_lab  `"Skill use work - How often - Negotiating with people"'
	 local f_q05a_lab  `"Skill use work - Problem solving - Simple problems"'
	 local f_q05b_lab  `"Skill use work - Problem solving - Complex problems"'
	 local f_q06b_lab  `"Skill use work - How often - Working physically for long"'
	 local f_q06c_lab  `"Skill use work - How often - Using hands or fingers"'
	 local f_q07a_lab  `"Skill use work - Not challenged enough"'
	 local f_q07b_lab  `"Skill use work - Need more training"'
	 local g_q01a_lab  `"Skill use work - Literacy - Read directions or instructions"'
	 local g_q01a_t_lab  `"As part of job, read or use directions or instructions (Trend-IALS/ALL)"'
	 local g_q01a_t1_lab  `"As part of job, read or use directions or instructions - levels collapsed (Trend"'
	 local g_q01b_lab  `"Skill use work - Literacy - Read letters memos or mails"'
	 local g_q01b_t_lab  `"As part of job, read or use letters, memos, e-mails (Trend-IALS/ALL)"'
	 local g_q01b_t1_lab  `"As part of job, read or use letters, memos, e-mails - levels collapsed (Trend-IA"'
	 local g_q01c_lab  `"Skill use work - Literacy - Read newspapers or magazines"'
	 local g_q01c_t_lab  `"As part of job, read or use reports, articles, magazines, journals (Trend-IALS/A"'
	 local g_q01c_t1_lab  `"As part of job, read or use reports, articles, magazines, journals - levels coll"'
	 local g_q01d_lab  `"Skill use work - Literacy - Read professional journals or publications"'
	 local g_q01e_lab  `"Skill use work - Literacy - Read books"'
	 local g_q01f_lab  `"Skill use work - Literacy - Read manuals or reference materials"'
	 local g_q01f_t_lab  `"As part of job, read or use manuals, reference books, catalogues (Trend-IALS/ALL"'
	 local g_q01f_t1_lab  `"As part of job, read or use manuals, reference books, catalogues - levels collap"'
	 local g_q01g_lab  `"Skill use work - Literacy - Read financial statements"'
	 local g_q01g_t_lab  `"As part of job, read or use bills, invoices, spreadsheets, budget tables (Trend-"'
	 local g_q01g_t1_lab  `"As part of job, read or use bills, invoices, spreadsheets, budget tables - level"'
	 local g_q01h_lab  `"Skill use work - Literacy - Read diagrams maps or schematics"'
	 local g_q01h_t_lab  `"As part of job, read or use diagrams or schematics (Trend-IALS/ALL)"'
	 local g_q01h_t1_lab  `"As part of job, read or use diagrams or schematics - levels collapsed (Trend-IAL"'
	 local g_q02a_lab  `"Skill use work - Literacy - Write letters memos or mails"'
	 local g_q02b_lab  `"Skill use work - Literacy - Write articles"'
	 local g_q02c_lab  `"Skill use work - Literacy - Write reports"'
	 local g_q02d_lab  `"Skill use work - Literacy - Fill in forms"'
	 local g_q03b_lab  `"Skill use work - Numeracy - How often - Calculating costs or budgets"'
	 local g_q03c_lab  `"Skill use work - Numeracy - How often - Use or calculate fractions or percentage"'
	 local g_q03d_lab  `"Skill use work - Numeracy - How often - Use a calculator"'
	 local g_q03f_lab  `"Skill use work - Numeracy - How often - Prepare charts graphs or tables"'
	 local g_q03g_lab  `"Skill use work - Numeracy - How often - Use simple algebra or formulas"'
	 local g_q03h_lab  `"Skill use work - Numeracy - How often - Use advanced math or statistics"'
	 local g_q04_lab  `"Skill use work - ICT - Experience with computer in job"'
	 local g_q04_t_lab  `"Ever used computer (Trend-IALS/ALL)"'
	 local g_q05a_lab  `"Skill use work - ICT - Internet - How often - For mail"'
	 local g_q05c_lab  `"Skill use work - ICT - Internet - How often - Work related info"'
	 local g_q05d_lab  `"Skill use work - ICT - Internet - How often - Conduct transactions"'
	 local g_q05e_lab  `"Skill use work - ICT - Computer - How often - Spreadsheets"'
	 local g_q05f_lab  `"Skill use work - ICT - Computer - How often - Word"'
	 local g_q05g_lab  `"Skill use work - ICT - Computer - How often - Programming language"'
	 local g_q05h_lab  `"Skill use work - ICT - Computer - How often - Real-time discussions"'
	 local g_q06_lab  `"Skill use work - ICT - Computer - Level of computer use"'
	 local g_q07_lab  `"Skill use work - ICT - Computer - Got the skills needed"'
	 local g_q08_lab  `"Skill use work - ICT - Computer - Lack of skills affect career"'
	 local h_q01a_lab  `"Skill use everyday life - Literacy - Read directions or instructions"'
	 local h_q01b_lab  `"Skill use everyday life - Literacy - Read letters memos or mails"'
	 local h_q01b_t_lab  `"In daily life, read or use letters, notes, e-mails (Trend-IALS/ALL)"'
	 local h_q01c_lab  `"Skill use everyday life - Literacy - Read newspapers or magazines"'
	 local h_q01c_t_lab  `"In daily life, read or use newspapers, magazines, articles (Trend-IALS/ALL)"'
	 local h_q01d_lab  `"Skill use everyday life - Literacy - Read professional journals or publications"'
	 local h_q01e_lab  `"Skill use everyday life - Literacy - Read books"'
	 local h_q01e_t_lab  `"In daily life, read or use books (fiction or nonfiction; not for job or school) "'
	 local h_q01f_lab  `"Skill use everyday life - Literacy - Read manuals or reference materials"'
	 local h_q01g_lab  `"Skill use everyday life - Literacy - Read financial statements"'
	 local h_q01h_lab  `"Skill use everyday life - Literacy - Read diagrams maps or schematics"'
	 local h_q02a_lab  `"Skill use everyday life - Literacy - Write letters memos or mails"'
	 local h_q02b_lab  `"Skill use everyday life - Literacy - Write articles"'
	 local h_q02c_lab  `"Skill use everyday life - Literacy - Write reports"'
	 local h_q02d_lab  `"Skill use everyday life - Literacy - Fill in forms"'
	 local h_q03b_lab  `"Skill use everyday life - Numeracy - How often - Calculating costs or budgets"'
	 local h_q03c_lab  `"Skill use everyday life - Numeracy - How often - Use or calculate fractions or p"'
	 local h_q03d_lab  `"Skill use everyday life - Numeracy - How often - Use a calculator"'
	 local h_q03f_lab  `"Skill use everyday life - Numeracy - How often - Prepare charts graphs or tables"'
	 local h_q03g_lab  `"Skill use everyday life - Numeracy - How often - Use simple algebra or formulas"'
	 local h_q03h_lab  `"Skill use everyday life - Numeracy - How often - Use advanced math or statistics"'
	 local h_q04a_lab  `"Skill use everyday life - ICT - Ever used computer"'
	 local h_q04b_lab  `"Skill use everyday life - ICT - Experience with computer everyday life"'
	 local h_q05a_lab  `"Skill use everyday life - ICT - Internet - How often - For mail"'
	 local h_q05c_lab  `"Skill use everyday life - ICT - Internet - How often - In order to better unders"'
	 local h_q05d_lab  `"Skill use everyday life - ICT - Internet - How often - Conduct transactions"'
	 local h_q05e_lab  `"Skill use everyday life - ICT - Computer - How often - Spreadsheets"'
	 local h_q05f_lab  `"Skill use everyday life - ICT - Computer - How often - Word"'
	 local h_q05g_lab  `"Skill use everyday life - ICT - Computer - How often - Programming language"'
	 local h_q05h_lab  `"Skill use everyday life - ICT - Computer - How often - Real-time discussions"'
	 local i_q04b_lab  `"About yourself - Learning strategies - Relate new ideas into real life"'
	 local i_q04d_lab  `"About yourself - Learning strategies - Like learning new things"'
	 local i_q04h_lab  `"About yourself - Learning strategies - Attribute something new"'
	 local i_q04j_lab  `"About yourself - Learning strategies - Get to the bottom of difficult things"'
	 local i_q04l_lab  `"About yourself - Learning strategies - Figure out how different ideas fit togeth"'
	 local i_q04m_lab  `"About yourself - Learning strategies - Looking for additional info"'
	 local i_q05f_lab  `"About yourself - Cultural engagement - Voluntary work for non-profit organisatio"'
	 local i_q06a_lab  `"About yourself - Political efficacy - No influence on the government"'
	 local i_q07a_lab  `"About yourself - Social trust - Trust only few people"'
	 local i_q07b_lab  `"About yourself - Social trust - Other people take advantage of you"'
	 local i_q08_lab  `"About yourself - Health - State"'
	 local i_q08_t_lab  `"General health (Trend-IALS/ALL)"'
	 local j_q01_lab  `"Background - People in household"'
	 local j_q01_c_lab  `"Background - People in household (top-coded at 6)"'
	 local j_q01_t_lab  `"Number living in household (Trend-IALS/ALL)"'
	 local j_q01_t1_lab  `"Number living in household (from 1 to 7) (Trend-IALS/ALL)"'
	 local j_q02a_lab  `"Background - Living with spouse or partner"'
	 local j_q02c_lab  `"Background - Work situation of spouse or partner"'
	 local j_q03a_lab  `"Background - Children"'
	 local j_q03b_lab  `"Background - Number of children"'
	 local j_q03b_c_lab  `"Background - Number of children (top-coded at 4)"'
	 local j_q03c_lab  `"Background - Age of the child"'
	 local j_q03c_c_lab  `"Background - Age of the child (categorised, 4 categories)"'
	 local j_q03d1_lab  `"Background - Age of the youngest child"'
	 local j_q03d1_c_lab  `"Background - Age of the youngest child (categorised, 4 categories)"'
	 local j_q03d2_lab  `"Background - Age of the oldest child"'
	 local j_q03d2_c_lab  `"Background - Age of the oldest child (categorised, 4 categories)"'
	 local j_q04a_lab  `"Background - Born in country"'
	 local j_q04a_t_lab  `"Born in country (Trend-IALS/ALL)"'
	 local j_s04b_lab  `"Background - Country of birth (other)"'
	 local j_s042_lab  `"Background - Country of birth (other)"'
	 local j_s043_lab  `"Background - Country of birth (other)"'
	 local j_q04c1_lab  `"Background - Age of immigration"'
	 local j_q04c1_c_lab  `"Background - Age of immigration (categorised, 9 categories)"'
	 local j_q04c2_lab  `"Background - Year of immigration"'
	 local j_q04c2_t_lab  `"Year of immigration to country (Trend-IALS/ALL)"'
	 local j_q04c2_t1_lab  `"Year of immigration to country - range of years (Trend-IALS/ALL)"'
	 local j_s05a1_lab  `"Background - First learned language (other)"'
	 local j_s054_lab  `"Background - First learned language (other)"'
	 local j_s055_lab  `"Background - First learned language (other)"'
	 local j_n05a2_lab  `"Background - More than one language mentioned"'
	 local j_s05a2_lab  `"Background - Second learned language (other)"'
	 local j_s052_lab  `"Background - Second learned language (other)"'
	 local j_s053_lab  `"Background - Second learned language (other)"'
	 local j_s05b_lab  `"Background - Language spoken at home (other)"'
	 local j_s050_lab  `"Background - Language spoken at home (other)"'
	 local j_s051_lab  `"Background - Language spoken at home (other)"'
	 local j_q06a_lab  `"Background - Mother/female guardian - Whether born in country"'
	 local j_q06a_t_lab  `"Mother or female guardian born in country (Trend-IALS/ALL)"'
	 local j_q06b_lab  `"Background - Mother/female guardian - Highest level of education"'
	 local j_q06b_t_lab  `"Highest level of education - mother or female guardian (Trend-IALS/ALL)"'
	 local j_q07a_lab  `"Background - Father/male guardian - Whether born in #counrtyname"'
	 local j_q07a_t_lab  `"Father or male guardian born in country (Trend-IALS/ALL)"'
	 local j_q07b_lab  `"Background - Father/male guardian - Highest level of education"'
	 local j_q07b_t_lab  `"Highest level of education - father or male guardian (Trend-IALS/ALL)"'
	 local j_q08_lab  `"Background - Number of books at home"'
	 local computerexperience_lab  `"Respondent experience with computer (DERIVED BY CAPI)"'
	 local nativespeaker_lab  `"Respondent is a native speaker (DERIVED BY CAPI)"'
	 local edlevel3_lab  `"Educational level of the respondent (DERIVED BY CAPI)"'
	 local disp_bq_lab  `"Final disposition code for BQ/JRA"'
	 local disp_bq_in_lab  `"Final disposition code for BQ/JRA - write-in reason for ineligibility"'
	 local disp_6_lab  `"Final disposition code for BQ/JRA - write-in reason for ineligibility"'
	 local disp_7_lab  `"Final disposition code for BQ/JRA - write-in reason for ineligibility"'
	 local cilang_lab  `"Language for exercise"'
	 local cba_core_stage1_score_lab  `"CBA Core score for stage 1"'
	 local cba_core_stage2_score_lab  `"CBA Core score for stage 2"'
	 local corestage1_pass_lab  `"Core Stage 1 pass status"'
	 local corestage2_pass_lab  `"Core Stage 2 pass status"'
	 local random_cba_module1_lab  `"Random number for selection of domain (L/N/P) in CBA Module 1"'
	 local random_cba_module2_lab  `"Random number for selection of domain (L/N/P) in CBA Module 2"'
	 local random_cba_module1_stage1_lab  `"Random number for selection of domain (L/N) in stage1 of CBA Module 1"'
	 local random_cba_module1_stage2_lab  `"Random number for selection of domain (L/N) in stage2 of CBA Module 1"'
	 local random_cba_module2_stage1_lab  `"Random number for selection of domain (L/N) in stage1 of CBA Module 2"'
	 local random_cba_module2_stage2_lab  `"Random number for selection of domain (L/N) in stage2 of CBA Module 2"'
	 local disp_core_lab  `"Final disposition code for CBA Core Stage 1 and 2"'
	 local cba_start_lab  `"Computer-based exercise agreement"'
	 local disp_cba_lab  `"Final disposition code for main task instrument, computer"'
	 local disp_cba_in_lab  `"Final disposition code for main task instrument, computer - write-in reason for "'
	 local disp_4_lab  `"Final disposition code for main task instrument, computer - write-in reason for "'
	 local disp_5_lab  `"Final disposition code for main task instrument, computer - write-in reason for "'
	 local bookid_ppc_lab  `"Booklet ID / serial number (with check digit) - Main paper exercise core booklet"'
	 local ppc_u600_lab  `"PNC / 600 - Election results (Interviewer Scoring)"'
	 local ppc_u301_lab  `"PLC / 301 - SGIH (Interviewer Scoring)"'
	 local ppc_u330a_lab  `"PLC / 330 - Guadeloupe (Interviewer Scoring)"'
	 local ppc_u302_lab  `"PLC / 302 - Election Results (Interviewer Scoring)"'
	 local ppc_u300_lab  `"PLC / 300 - Employment Advertisement (Interviewer Scoring)"'
	 local ppc_u601_lab  `"PNC / 601 - Bottles (Interviewer Scoring)"'
	 local ppc_u614_lab  `"PNC / 614 - Watch (Interviewer Scoring)"'
	 local ppc_u645_lab  `"PNC / 645 - Airport Timetable (Interviewer Scoring)"'
	 local ppc_score_lab  `"Final score for the paper core assessment"'
	 local random_pp_lab  `"Random number for selection of Paper Booklets"'
	 local bookid_pp1_lab  `"Booklet ID / serial number (with check digit) - Main paper exercise literacy - W"'
	 local bookid_pp2_lab  `"Booklet ID / serial number (with check digit) - Main paper exercise numeracy - W"'
	 local disp_pp_lab  `"Final disposition code for main task instrument, paper literacy/numeracy"'
	 local disp_pp_in_lab  `"Final disposition code for main task instrument, paper literacy/numeracy - write"'
	 local disp_2_lab  `"Final disposition code for main task instrument, paper literacy/numeracy - write"'
	 local disp_3_lab  `"Final disposition code for main task instrument, paper literacy/numeracy - write"'
	 local bookid_prc_lab  `"Booklet ID / serial number (with check digit) - Reading components - Workflow"'
	 local prc_pv_q1_lab  `"Sentence Timer for Print Vocabulary items"'
	 local prc_sp_q1_lab  `"Sentence Timer for Sentence Processing items"'
	 local prc_pf_q1_lab  `"Sentence Timer for Passage Comprehension items - passage 1"'
	 local prc_pf_q2_lab  `"Sentence Timer for Passage Comprehension items - passage 2"'
	 local prc_pf_q3_lab  `"Sentence Timer for Passage Comprehension items - passage 3 and 4"'
	 local disp_prc_lab  `"Final disposition code for main task instrument, paper reading components"'
	 local disp_prc_in_lab  `"Final disposition code for main task instrument, paper reading components - writ"'
	 local disp_0_lab  `"Final disposition code for main task instrument, paper reading components - writ"'
	 local disp_1_lab  `"Final disposition code for main task instrument, paper reading components - writ"'
	 local paper_lab  `"Paper branch (derived)"'
	 local cbamod1_lab  `"CBA module 1 branch (derived)"'
	 local cbamod2_lab  `"CBA module 2 branch (derived)"'
	 local cbamod2alt_lab  `"CBA module 1 and 2 branch (derived)"'
	 local cbamod1stg1_lab  `"CBA module 1, stage 1 branch (derived)"'
	 local cbamod2stg1_lab  `"CBA module 2, stage 1 branch (derived)"'
	 local cbamod1stg2_lab  `"CBA module 1, stage 2 branch (derived)"'
	 local cbamod2stg2_lab  `"CBA module 2, stage 2 branch (derived)"'
	 local monthlyincpr_lab  `"Monthly income percentile rank category (derived)"'
	 local yearlyincpr_lab  `"Yearly income percentile rank category (derived)"'
	 local etsageg5_lab  `"Age groups in equal 5-year intervals of PIAAC base population ranging from 16 to"'
	 local pbroute_lab  `"Paper-based routing code (derived)"'
	 local active_section_lab  `"Active section (final state on export)"'
	 local globaldispcode_lab  `"Final disposition code for person"'
	 local isced_hf_lab  `"Level of Highest Qualification (Foreign) - Respondent (ISCED) (coded)"'
	 local isced_hf_c_lab  `"Level of Highest Qualification (collapsed, 14 categories)"'
	 local isco08_c_lab  `"Current Job Occupation - Respondent (ISCO 2008) (coded)"'
	 local isco88_c_lab  `"Current Job Occupation - Respondent (ISCO 1988) (coded)"'
	 local isco08_l_lab  `"Last Job Occupation - Respondent (ISCO 2008) (coded)"'
	 local isco88_l_lab  `"Last Job Occupation - Respondent (ISCO 1988) (coded)"'
	 local isic4_c_lab  `"Current Job Industry - Respondent (ISIC rev 4) (coded)"'
	 local isic4_l_lab  `"Last Job Industry - Respondent (ISIC rev 4) (coded)"'
	 local lng_l1_lab  `"First language learned at home in childhood and still understood - Respondent (I"'
	 local lng_l2_lab  `"Second language learned at home in childhood and still understood - Respondent ("'
	 local lng_home_lab  `"Language most often spoken at home - Respondent (ISO 639-2/T) (coded)"'
	 local cnt_h_lab  `"Country in which highest qualification was gained - Respondent (UN M49 numerical"'
	 local cnt_brth_lab  `"Country of birth - Respondent (UN M49 numerical) (coded)"'
	 local reg_tl2_lab  `"Geographical region - Respondent (OECD TL2) (coded)"'
	 local lng_bq_lab  `"Language for background questionnaire (derived, ISO 639-2/T)"'
	 local lng_ci_lab  `"Language for exercise (derived, ISO 639-2/T)"'
	 local yrsqual_lab  `"Highest level of education obtained imputed into years of education (derived)"'
	 local yrsqual_t_lab  `"Derived variable on total years of schooling during lifetime - top coded at 24 ("'
	 local yrsget_lab  `"Imputed years of formal education needed to get the job (self-reported - derived"'
	 local vet_lab  `"Respondent`'s highest level of education obtained is vocationally oriented (deriv"'
	 local ctryqual_lab  `"Country where highest qualification obtained (9 regions - derived)"'
	 local birthrgn_lab  `"Country of birth (9 regions - derived)"'
	 local firlgrgn_lab  `"Source region of first language learned at home in childhood and still understan"'
	 local seclgrgn_lab  `"Source region of second language learned at home in childhood and still understa"'
	 local homlgrgn_lab  `"Source region of language spoken most often at home (9 regions - derived)"'
	 local forbornlang_lab  `"Interactions between foreign-born and language status (2 categories - derived)"'
	 local pared_lab  `"Highest of mother or father’s level of education (derived)"'
	 local nativelang_lab  `"Test language same as native language  (derived)"'
	 local bornlang_lab  `"Interactions between place of birth and language status (derived)"'
	 local natbilang_lab  `"Has learned as a child and still understands at least two languages including te"'
	 local forbilang_lab  `"Has learned as a child and still understands at least two languages not includin"'
	 local homlang_lab  `"Test language same as language spoken most often at home (derived)"'
	 local ctryrgn_lab  `"Country region (9 regions)"'
	 local impar_lab  `"Parents’ immigration status (derived)"'
	 local imgen_lab  `"First and second generation immigrants (derived)"'
	 local imyrs_lab  `"Years in country (derived)"'
	 local imyrs_c_lab  `"Years in country (categorised, 4 categories)"'
	 local imyrcat_lab  `"Years in country (2-category - derived)"'
	 local ageg5lfs_lab  `"Age groups in 5-year intervals based on LFS groupings (derived)"'
	 local ageg10lfs_lab  `"Age in 10 year bands (derived)"'
	 local ageg10lfs_t_lab  `"Age in 10 year bands (Trend-IALS/ALL)"'
	 local edcat8_lab  `"Highest level of formal education obtained (8 categories - derived)"'
	 local edcat7_lab  `"Highest level of formal education obtained (7 categories - derived)"'
	 local edcat6_lab  `"Highest level of formal education obtained (6 categories - derived)"'
	 local leaver1624_lab  `"Youth aged 16 to 24 who have left education without completing ISCED 3 or higher"'
	 local leavedu_lab  `"Respondent’s age when leaving formal education (derived)"'
	 local fe12_lab  `"Participated in formal education in 12 months preceding survey (derived)"'
	 local aetpop_lab  `"Adult education/training population (AET) – excludes youths 16-24 in initial cyc"'
	 local faet12_lab  `"Participated in formal AET in 12 months preceding survey (see AETPOP - derived)"'
	 local faet12jr_lab  `"Participated in formal AET for job-related reasons in 12 months preceding survey"'
	 local faet12njr_lab  `"Participated in formal AET for non job-related reasons in 12 months preceding su"'
	 local nfe12_lab  `"Participated in non-formal education in 12 months preceding survey (derived)"'
	 local nfe12jr_lab  `"Participated in non-formal education for job-related reasons in 12 months preced"'
	 local nfe12njr_lab  `"Participated in non-formal education for non job-related reasons in 12 months pr"'
	 local fnfaet12_lab  `"Participated in formal or non-formal AET in 12 months preceding survey (see AETP"'
	 local fnfe12jr_lab  `"Participated in formal or non-formal education for job-related reasons in 12 mon"'
	 local fnfaet12jr_lab  `"Participated in formal or non-formal AET for job-related reasons in 12 months pr"'
	 local fnfaet12njr_lab  `"Participated in formal or non-formal AET for non job-related reasons in 12 mon. "'
	 local edwork_lab  `"Interaction between adults’ work and education status (derived)"'
	 local neet_lab  `"Adults not employed at time of survey and not in education or training in 12 mon"'
	 local nfehrsnjr_lab  `"Number of hours of participation in non-formal education for non-job-related rea"'
	 local nfehrsjr_lab  `"Number of hours of participation in non-formal education for job-related reasons"'
	 local nfehrs_lab  `"Number of hours of participation in non-formal education (derived)"'
	 local nopaidworkever_lab  `"Adults who never had paid work including self-employment in past (derived)"'
	 local paidwork12_lab  `"Adults who have had paid work during the 12 months preceding the survey (derived"'
	 local paidwork5_lab  `"Adults who have had paid work in last 5 years (derived)"'
	 local iscoskil4_lab  `"Occupational classification of respondent`'s job (4 skill based categories), last"'
	 local isic1l_lab  `"Industry classification of respondent`'s job at 1-digit level(ISIC rev 4), last j"'
	 local isic2l_lab  `"Industry classification of respondent`'s job at 2-digit level (ISIC rev 4), last "'
	 local isic1c_lab  `"Industry classification of respondent`'s job at 1-digit level (ISIC rev 4), curre"'
	 local isic2c_lab  `"Industry classification of respondent`'s job at 2-digit level (ISIC rev 4), curre"'
	 local isco1c_lab  `"Occupational classification of respondent`'s job at 1-digit level (ISCO 2008), cu"'
	 local isco2c_lab  `"Occupational classification of respondent`'s job at 2-digit level (ISCO 2008), cu"'
	 local isco1l_lab  `"Occupational classification of respondent`'s job at 1-digit level (ISCO 2008), la"'
	 local isco2l_lab  `"Occupational classification of respondent`'s job at 2-digit level (ISCO 2008), la"'
	 local pvlit1_lab  `"Literacy scale score - Plausible value 1"'
	 local pvlit2_lab  `"Literacy scale score - Plausible value 2"'
	 local pvlit3_lab  `"Literacy scale score - Plausible value 3"'
	 local pvlit4_lab  `"Literacy scale score - Plausible value 4"'
	 local pvlit5_lab  `"Literacy scale score - Plausible value 5"'
	 local pvlit6_lab  `"Literacy scale score - Plausible value 6"'
	 local pvlit7_lab  `"Literacy scale score - Plausible value 7"'
	 local pvlit8_lab  `"Literacy scale score - Plausible value 8"'
	 local pvlit9_lab  `"Literacy scale score - Plausible value 9"'
	 local pvlit10_lab  `"Literacy scale score - Plausible value 10"'
	 local pvnum1_lab  `"Numeracy scale score - Plausible value 1"'
	 local pvnum2_lab  `"Numeracy scale score - Plausible value 2"'
	 local pvnum3_lab  `"Numeracy scale score - Plausible value 3"'
	 local pvnum4_lab  `"Numeracy scale score - Plausible value 4"'
	 local pvnum5_lab  `"Numeracy scale score - Plausible value 5"'
	 local pvnum6_lab  `"Numeracy scale score - Plausible value 6"'
	 local pvnum7_lab  `"Numeracy scale score - Plausible value 7"'
	 local pvnum8_lab  `"Numeracy scale score - Plausible value 8"'
	 local pvnum9_lab  `"Numeracy scale score - Plausible value 9"'
	 local pvnum10_lab  `"Numeracy scale score - Plausible value 10"'
	 local pvpsl1_lab  `"Problem-solving scale score - Plausible value 1"'
	 local pvpsl2_lab  `"Problem-solving scale score - Plausible value 2"'
	 local pvpsl3_lab  `"Problem-solving scale score - Plausible value 3"'
	 local pvpsl4_lab  `"Problem-solving scale score - Plausible value 4"'
	 local pvpsl5_lab  `"Problem-solving scale score - Plausible value 5"'
	 local pvpsl6_lab  `"Problem-solving scale score - Plausible value 6"'
	 local pvpsl7_lab  `"Problem-solving scale score - Plausible value 7"'
	 local pvpsl8_lab  `"Problem-solving scale score - Plausible value 8"'
	 local pvpsl9_lab  `"Problem-solving scale score - Plausible value 9"'
	 local pvpsl10_lab  `"Problem-solving scale score - Plausible value 10"'
	 local vemethod_lab  `"Replication approach (string)"'
	 local vemethodn_lab  `"Replication approach (numeric)"'
	 local vefayfac_lab  `"Fay\'s K factor used in creating replicate weights (BRR only)"'
	 local venreps_lab  `"Number of replicate weights used"'
	 local varstrat_lab  `"Variance stratum"'
	 local varunit_lab  `"Variance unit"'
	 local spfwt0_lab  `"Final full sample weight"'
	 local spfwt1_lab  `"Final replicate weight (1)"'
	 local spfwt2_lab  `"Final replicate weight (2)"'
	 local spfwt3_lab  `"Final replicate weight (3)"'
	 local spfwt4_lab  `"Final replicate weight (4)"'
	 local spfwt5_lab  `"Final replicate weight (5)"'
	 local spfwt6_lab  `"Final replicate weight (6)"'
	 local spfwt7_lab  `"Final replicate weight (7)"'
	 local spfwt8_lab  `"Final replicate weight (8)"'
	 local spfwt9_lab  `"Final replicate weight (9)"'
	 local spfwt10_lab  `"Final replicate weight (10)"'
	 local spfwt11_lab  `"Final replicate weight (11)"'
	 local spfwt12_lab  `"Final replicate weight (12)"'
	 local spfwt13_lab  `"Final replicate weight (13)"'
	 local spfwt14_lab  `"Final replicate weight (14)"'
	 local spfwt15_lab  `"Final replicate weight (15)"'
	 local spfwt16_lab  `"Final replicate weight (16)"'
	 local spfwt17_lab  `"Final replicate weight (17)"'
	 local spfwt18_lab  `"Final replicate weight (18)"'
	 local spfwt19_lab  `"Final replicate weight (19)"'
	 local spfwt20_lab  `"Final replicate weight (20)"'
	 local spfwt21_lab  `"Final replicate weight (21)"'
	 local spfwt22_lab  `"Final replicate weight (22)"'
	 local spfwt23_lab  `"Final replicate weight (23)"'
	 local spfwt24_lab  `"Final replicate weight (24)"'
	 local spfwt25_lab  `"Final replicate weight (25)"'
	 local spfwt26_lab  `"Final replicate weight (26)"'
	 local spfwt27_lab  `"Final replicate weight (27)"'
	 local spfwt28_lab  `"Final replicate weight (28)"'
	 local spfwt29_lab  `"Final replicate weight (29)"'
	 local spfwt30_lab  `"Final replicate weight (30)"'
	 local spfwt31_lab  `"Final replicate weight (31)"'
	 local spfwt32_lab  `"Final replicate weight (32)"'
	 local spfwt33_lab  `"Final replicate weight (33)"'
	 local spfwt34_lab  `"Final replicate weight (34)"'
	 local spfwt35_lab  `"Final replicate weight (35)"'
	 local spfwt36_lab  `"Final replicate weight (36)"'
	 local spfwt37_lab  `"Final replicate weight (37)"'
	 local spfwt38_lab  `"Final replicate weight (38)"'
	 local spfwt39_lab  `"Final replicate weight (39)"'
	 local spfwt40_lab  `"Final replicate weight (40)"'
	 local spfwt41_lab  `"Final replicate weight (41)"'
	 local spfwt42_lab  `"Final replicate weight (42)"'
	 local spfwt43_lab  `"Final replicate weight (43)"'
	 local spfwt44_lab  `"Final replicate weight (44)"'
	 local spfwt45_lab  `"Final replicate weight (45)"'
	 local spfwt46_lab  `"Final replicate weight (46)"'
	 local spfwt47_lab  `"Final replicate weight (47)"'
	 local spfwt48_lab  `"Final replicate weight (48)"'
	 local spfwt49_lab  `"Final replicate weight (49)"'
	 local spfwt50_lab  `"Final replicate weight (50)"'
	 local spfwt51_lab  `"Final replicate weight (51)"'
	 local spfwt52_lab  `"Final replicate weight (52)"'
	 local spfwt53_lab  `"Final replicate weight (53)"'
	 local spfwt54_lab  `"Final replicate weight (54)"'
	 local spfwt55_lab  `"Final replicate weight (55)"'
	 local spfwt56_lab  `"Final replicate weight (56)"'
	 local spfwt57_lab  `"Final replicate weight (57)"'
	 local spfwt58_lab  `"Final replicate weight (58)"'
	 local spfwt59_lab  `"Final replicate weight (59)"'
	 local spfwt60_lab  `"Final replicate weight (60)"'
	 local spfwt61_lab  `"Final replicate weight (61)"'
	 local spfwt62_lab  `"Final replicate weight (62)"'
	 local spfwt63_lab  `"Final replicate weight (63)"'
	 local spfwt64_lab  `"Final replicate weight (64)"'
	 local spfwt65_lab  `"Final replicate weight (65)"'
	 local spfwt66_lab  `"Final replicate weight (66)"'
	 local spfwt67_lab  `"Final replicate weight (67)"'
	 local spfwt68_lab  `"Final replicate weight (68)"'
	 local spfwt69_lab  `"Final replicate weight (69)"'
	 local spfwt70_lab  `"Final replicate weight (70)"'
	 local spfwt71_lab  `"Final replicate weight (71)"'
	 local spfwt72_lab  `"Final replicate weight (72)"'
	 local spfwt73_lab  `"Final replicate weight (73)"'
	 local spfwt74_lab  `"Final replicate weight (74)"'
	 local spfwt75_lab  `"Final replicate weight (75)"'
	 local spfwt76_lab  `"Final replicate weight (76)"'
	 local spfwt77_lab  `"Final replicate weight (77)"'
	 local spfwt78_lab  `"Final replicate weight (78)"'
	 local spfwt79_lab  `"Final replicate weight (79)"'
	 local spfwt80_lab  `"Final replicate weight (80)"'
	 local inpiaac_lab  `"PIAAC Sample Indicator"'
	 local icthome_wle_lab  `"Index of use of ICT skills at home, WLE (derived)"'
	 local ictwork_wle_lab  `"Index of use of ICT skills at work, WLE (derived)"'
	 local influence_wle_lab  `"Index of use of influencing skills at work, WLE (derived)"'
	 local learnatwork_wle_lab  `"Index of learning at work, WLE (derived)"'
	 local numhome_wle_lab  `"Index of use of numeracy skills at home (basic and advanced), WLE (derived)"'
	 local numwork_wle_lab  `"Index of use of numeracy skills at work (basic and advanced), WLE (derived)"'
	 local planning_wle_lab  `"Index of use of planning skills at work, WLE (derived)"'
	 local readhome_wle_lab  `"Index of use of reading skills at home (prose and document texts), WLE (derived)"'
	 local readwork_wle_lab  `"Index of use of reading skills at work (prose and document texts), WLE (derived)"'
	 local readytolearn_wle_lab  `"Index of readiness to learn, WLE (derived)"'
	 local taskdisc_wle_lab  `"Index of use of task discretion at work, WLE (derived)"'
	 local writhome_wle_lab  `"Index of use of writing skills at home, WLE (derived)"'
	 local writwork_wle_lab  `"Index of use of writing skills at work, WLE (derived)"'
	 local icthome_lab  `"Index of use of ICT skills at home (derived)"'
	 local ictwork_lab  `"Index of use of ICT skills at work (derived)"'
	 local influence_lab  `"Index of use of influencing skills at work (derived)"'
	 local learnatwork_lab  `"Index of learning at work (derived)"'
	 local numhome_lab  `"Index of use of numeracy skills at home (basic and advanced - derived)"'
	 local numwork_lab  `"Index of use of numeracy skills at work (basic and advanced - derived)"'
	 local planning_lab  `"Index of use of planning skills at work (derived)"'
	 local readhome_lab  `"Index of use of reading skills at home (prose and document texts - derived)"'
	 local readwork_lab  `"Index of use of reading skills at work (prose and document texts - derived)"'
	 local readytolearn_lab  `"Index of readiness to learn (derived)"'
	 local taskdisc_lab  `"Index of use of task discretion at work (derived)"'
	 local writhome_lab  `"Index of use of writing skills at home (derived)"'
	 local writwork_lab  `"Index of use of writing skills at work (derived)"'
	 local icthome_wle_ca_lab  `"Index of use of ICT skills at home, categorised WLE (derived)"'
	 local ictwork_wle_ca_lab  `"Index of use of ICT skills at work, categorised WLE (derived)"'
	 local influence_wle_ca_lab  `"Index of use of influencing skills at work, categorised WLE (derived)"'
	 local learnatwork_wle_ca_lab  `"Index of learning at work, categorised WLE (derived)"'
	 local numhome_wle_ca_lab  `"Index of use of numeracy skills at home (basic and advanced), categorised WLE (d"'
	 local numwork_wle_ca_lab  `"Index of use of numeracy skills at work (basic and advanced), categorised WLE (d"'
	 local planning_wle_ca_lab  `"Index of use of planning skills at work, categorised WLE (derived)"'
	 local readhome_wle_ca_lab  `"Index of use of reading skills at home (prose and document texts), categorised W"'
	 local readwork_wle_ca_lab  `"Index of use of reading skills at work (prose and document texts), categorised W"'
	 local readytolearn_wle_ca_lab  `"Index of readiness to learn, categorised WLE (derived)"'
	 local taskdisc_wle_ca_lab  `"Index of use of task discretion at work, categorised WLE (derived)"'
	 local writhome_wle_ca_lab  `"Index of use of writing skills at home, categorised WLE (derived)"'
	 local writwork_wle_ca_lab  `"Index of use of writing skills at work, categorised WLE (derived)"'
	 local icthome_se_wle_lab  `"Index of use of ICT skills at home, WLE standard error (derived)"'
	 local ictwork_se_wle_lab  `"Index of use of ICT skills at work, WLE standard error (derived)"'
	 local influence_se_wle_lab  `"Index of use of influencing skills at work, WLE standard error (derived)"'
	 local learnatwork_se_wle_lab  `"Index of learning at work, WLE standard error (derived)"'
	 local numhome_se_wle_lab  `"Index of use of numeracy skills at home (basic and advanced), WLE standard error"'
	 local numwork_se_wle_lab  `"Index of use of numeracy skills at work (basic and advanced), WLE standard error"'
	 local planning_se_wle_lab  `"Index of use of planning skills at work, WLE standard error (derived)"'
	 local readhome_se_wle_lab  `"Index of use of reading skills at home (prose and document texts), WLE standard "'
	 local readwork_se_wle_lab  `"Index of use of reading skills at work (prose and document texts), WLE standard "'
	 local readytolearn_se_wle_lab  `"Index of readiness to learn, WLE standard error (derived)"'
	 local taskdisc_se_wle_lab  `"Index of use of task discretion at work, WLE standard error (derived)"'
	 local writhome_se_wle_lab  `"Index of use of writing skills at home, WLE standard error (derived)"'
	 local earnhr_lab  `"Hourly earnings excluding bonuses (wage and salary earners)"'
	 local earnhrbonus_lab  `"Hourly earnings including bonuses (wage and salary earners)"'
	 local earnmth_lab  `"Monthly earnings excluding bonuses (wage and salary earners)"'
	 local earnmthbonus_lab  `"Monthly earnings including bonuses (wage and salary earners)"'
	 local earnmthall_lab  `"Monthly earnings including bonuses (wage and salary earners and self-employed)"'
	 local earnhrppp_lab  `"Hourly earnings excluding bonuses - PPP corrected  (wage and salary earners)"'
	 local earnhrbonusppp_lab  `"Hourly earnings including bonuses - PPP corrected  (wage and salary earners)"'
	 local earnmthppp_lab  `"Monthly earnings excluding bonuses - PPP corrected  (wage and salary earners)"'
	 local earnmthbonusppp_lab  `"Monthly earnings including bonuses - PPP corrected  (wage and salary earners)"'
	 local earnmthselfppp_lab  `"Monthly earnings self-employed - PPP corrected "'
	 local earnmthallppp_lab  `"Monthly earnings including bonuses - PPP corrected  (wage and salary earners "'
	 local earnhrdcl_lab  `"Hourly earnings in deciles excluding bonuses (wage and salary earners)"'
	 local earnhrbonusdcl_lab  `"Hourly earnings in deciles including bonuses (wage and salary earners)"'
	 local earnmthalldcl_lab  `"Monthly earned income in deciles including bonuses (wage and salary earners and "'
	 local earnflag_lab  `"Earnings (incl. bonuses) reported directly or imputed?"'
	 local d_q18a_t_lab  `"Annual net income before taxes and deductions (Trend-IALS/ALL)"'
	 local persid_lab  `"Person operational identification number (with check digit)"'
	 local oecd_flag_lab  `"OECD_Flag"'
	 local round_lab  `"round"'
	 local cntry_out_lab  `"CNTRY_OUT"'
	 local techprob_lab  `"Technical problem flag"'
	 local disp_cibq_lab  `"Final disposition code for person - combining CI and BQ/JRA (derived)"'
	 local disp_main_lab  `"Final disposition code for person for Main task instrument (derived)"'
	 local disp_mainwrc_lab  `"Final disposition code for person for Main task instrument, including reading co"'
	 local trimgrps_lab  `"Trimming domains"'
	 local bookid_ppb_lab  `"Booklet ID / serial number (with check digit) - Paper exercise only"'
	 local isco1c_n_lab  `"Occupational classification of respondent\'s job at 1-digit level (ISCO 2008), cu"'
	 local isic1c_n_lab  `"Industry classification of respondent\'s job at 1-digit level(ISIC rev 4), curren"'
	 local litstatus_lab  `"Literacy - PV Status"'
	 local numstatus_lab  `"Numeracy - PV Status"'
	 local pslstatus_lab  `"Problem Solving - PV Status"'
	 local prc_pv_scr_lab  `"Total Score for Reading Components Section - Print Vocabulary (derived)"'
	 local prc_sp_scr_lab  `"Total Score for Reading Components Section - Sentence Processing (derived)"'
	 local prc_pc_scr_lab  `"Total Score for Reading Components Section - Passage Comprehension (derived)"'
	*the following loop assignes for each variable its variable label and then its value label taht was previously stored above: 
	foreach var of varlist _all {
		local up_lab=upper("`var'")
		cap label value `var' `up_lab'
		cap label variable `var'  `"``var'_lab'"'
		}
		
	dis "  Your PIAAC dataset is now ready to be used in Stata. Please consider saving this file."
	end
	
***this last line run all programs defined before.
* The user will have to input the filepath where files are located. 	
	
}
**Intermediary programs now loaded into memory

Import_PIAAC
