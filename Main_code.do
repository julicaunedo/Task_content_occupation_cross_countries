***************************************************************************************
*** Intro:  This do-file builds the datasets and main tables reported in 
*** Technology and the Task Content of Jobs across the Development Spectrum
*** Caunedo, Keller, Shin
***************************************************************************************


clear all
capture log close
set more off

global replication         = "/Users/julieta.caunedo/Dropbox/STEG/Replication_package"

global dofiles         = "$replication"
global rawdata      = "$replication/Rawdata"
global workingdata  = "$replication/Workingdata"
global output  = "$replication/Workingdata"
global tables       = "$replication/Tables"
global dataset       = "$replication/Dataset"
global figures      = "$replication/Figures"

*** Data Preparation
*
do "$dofiles/[0.2] PIACC_Combine.do"

do "$dofiles/[1.1] STEP.do"

do "$dofiles/[1.2] PIAAC.do"

do "$dofiles/[1.3.0] Construct_Crosswalk.do"

do "$dofiles/[1.3] O_NET.do"

do "$dofiles/[1.4] Supp_Statistics.do"


*** Generate Task Measures

do "$dofiles/[2] Combine_PIAAC_STEP.do"

***Output
do "$dofiles/[3.1] Figure_1.do"
do "$dofiles/[3.2] Table_1-3.do"
do "$dofiles/[3.3] Figure_2.do"
do "$dofiles/[3.4] Table_2.do"

