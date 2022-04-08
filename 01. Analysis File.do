**********************************************************************************
*Associations between social support and verbal memory: 14-year follow-up of the
*English Longitudinal Study of Ageing cohort
*medRxiv July 2020
**********************************************************************************

*Harmonised data.
*h_elsa.dta

***Archive datasets.
*index_file_wave_0-wave_5_v2.dta"
*Wave_1_Financial_Derived_Variables.dta"
*wave_1_core_data_v3.dta"
*wave_2_financial_derived_variables.dta", clear
*wave_2_core_data_v4.dta"
*wave_3_financial_derived_variables.dta"
*wave_3_elsa_data_v4.dta"
*wave_4_ifs_derived_variables.dta", clear
*wave_4_financial_derived_variables.dta"
*wave_4_elsa_data_v3.dta"
*wave_5_financial_derived_variables.dta"
*wave_5_elsa_data_v4.dta", clear
*wave_6_financial_derived_variables.dta"
*wave_6_elsa_data_v2.dta", clear
*wave_7_financial_derived_variables.dta"
*wave_7_elsa_data.dta", clear
*wave_8_elsa_financial_dvs_eul_v1.dta"
*wave_8_elsa_data_eul_v2.dta", clear


use "N:\ELSA\Datasets\h_elsa.dta", clear
keep idauniq r1smoken r1drink r1vgactx_e r1mdactx_e r1ltactx_e
sort idauniq
save "N:\Temp\W1_HRBs.dta",replace

use "N:\ELSA\Datasets\h_elsa.dta", clear
keep idauniq radyear
tab radyear    /* Year of Death */
sort idauniq
save "N:\Temp\IntDatesAndDeath.dta",replace

*Index File.
use "N:\ELSA\Datasets\index_file_wave_0-wave_5_v2.dta", clear
keep idauniq yrdeath mortstat mortwave
sort idauniq
save "N:\Temp\IndexFile.dta", replace

*Wave 1 (baseline).
use idauniq idahhw1 tnhwq5_bu_s tnhwq10_bu_s using "N:\ELSA\Datasets\Wave_1_Financial_Derived_Variables.dta", clear
sort idahhw1
collapse (mean) tnhwq5_bu_s,by(idahhw1)
replace tnhwq5_bu_s = round(tnhwq5_bu_s,1)
sort idahhw1
save "N:\Temp\W1_Wealthq.dta",replace

clear
use idauniq idahhw1 indsex finstat edqual cf* w1wgt askpx nmissed nrowclm dhager psc* headb01-headb13 sc* hedib01-hedib10 heska heacta heactb heactc hesmk heska heala dimar couple using "N:\ELSA\Datasets\wave_1_core_data_v3.dta"
renvars, lower
summ w1wgt if w1wgt>0
keep if inrange(w1wgt,0.2,8.9)                   
sort idahhw1
merge n:1 idahhw1 using "N:\Temp\W1_Wealthq.dta"
keep if _merge==3
drop _merge
generate ProblemsW1=0
replace ProblemsW1=1 if inrange(headb01,1,13)
generate DiagnosedW1=0
replace DiagnosedW1=1 if inrange(headb01,1,9)
keep idauniq indsex w1wgt edqual askpx tnhwq5_bu_s  dhager cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headb01-headb13 hedib01-hedib10 scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf ///
hesmk heska heacta heactb heactc heala scorg1 scorga2 scorg3 scorg4 scorg5 scorg6 scorg7 scorg8 couple ProblemsW1 DiagnosedW1 
rename scorga2 scorg2
order idauniq indsex w1wgt edqual askpx tnhwq5_bu_s  dhager cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headb01-headb13 hedib01-hedib10 scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf ///
hesmk heska heacta heactb heactc heala scorg1 scorg2 scorg3 scorg4 scorg5 scorg6 scorg7 scorg8 couple ProblemsW1 DiagnosedW1
merge 1:1 idauniq using "N:\Temp\W1_HRBs.dta"
keep if _merge==3
drop _merge
qui: mvdecode _all, mv(-90/-1)
egen dementia = anycount(hedib01-hedib10),values(6 8 9)
recode dementia (2=1)
drop if dementia==1                       
drop if askpx==1                         
drop if inrange(dhager,90,99)

* Currently smokes. (cigarettes only).
generate smoke1=.
replace smoke1=1 if hesmk==2
replace smoke1=2 if (hesmk==1 & heska==2)
replace smoke1=3 if (hesmk==1 & heska==1)
qui:tab smoke1 r1smoken  /* compare with harmonised data */
recode smoke1 (1=0) (2=0) (3=1)
label define smoke2lbl 0 "non-smoker" 1 "current smoker"  
label values smoke1 smoke2lbl

* Alcohol.
generate drink1=.
replace drink1 = 0 if inlist(heala,3,4,5,6)
replace drink1 = 1 if inlist(heala,1,2)
*tab drink1 r1drink     /* compare with harmonised data */
label define dlbl 0 "non-daily" 1 "daily" 
label values drink1 dlbl

* Physical activity.
generate actlevel1=.
replace actlevel1=1 if (r1vgactx_e==5) & (r1mdactx_e==5)                                    																									/* sedentary: hardly ever moderate (5) and hardly ever vigorous (5) */
replace actlevel1=2 if (r1vgactx_e==5) & inlist(r1mdactx_e,3,4)                 																												/* low moderate (3,4) */
replace actlevel1=3 if ((r1mdactx_e==2) & r1vgactx_e==5)|(r1vgactx_e==4 & r1mdactx_e==5)   																		/* some mod or vig */
replace actlevel1=4 if (inlist(r1mdactx_e,2,3) & inlist(r1vgactx_e,3,4))| inlist(r1mdactx_e,4,5) & inlist(r1vgactx_e,3) | inlist(r1mdactx_e,4) & inlist(r1vgactx_e,4)  					 /* more mod or vig */
replace actlevel1=5 if inlist(r1vgactx_e,2)                                              																														/* vigorous (2) */
label define actlbl 1 "sedentary" 2 "low moderate" 3 "some mod or vig" 4 "More mod or vig" 5 "Vig"
label values actlevel1 actlbl
*Dichotomous (actlevel1): inactive vs rest.
recode actlevel1 (1=1) (2/5=0)
label drop actlbl
label define actlbl 0 "active" 1 "inactive"
label values actlevel1 actlbl
* Educational attainment.
generate topqual=.
replace topqual=1 if edqual==1
replace topqual=2 if inrange(edqual,2,3)
replace topqual=3 if edqual==4
replace topqual=4 if inrange(edqual,5,6)
replace topqual=5 if edqual==7
label define blbl 1 "Degree or equivalent" 2 "A level/higher education below degree" 3 "O level or other" 4 "CSE or other" 5 "No qualifications" 
label values topqual blbl
*High/middle/low.
recode topqual (1=0) (2/4=1) (5=2)
label define b2lbl 0 "high" 1 "middle" 2 "low"  
label values topqual b2lbl
*Weath quintile.
rename tnhwq5_bu_s wealthq1
recode wealthq1 (1=5) (2=4) (3=3) (4=2) (5=1)
label define wlbl 1 "Highest" 2 "2" 3 "3" 4 "4" 5 "lowest"
label values wealthq1 wlbl
*Age.
generate age1 = dhager
generate agegroup=0
replace agegroup=1 if inrange(dhager,50,54)
replace agegroup=2 if inrange(dhager,55,59)
replace agegroup=3 if inrange(dhager,60,64)
replace agegroup=4 if inrange(dhager,65,69)
replace agegroup=5 if inrange(dhager,70,74)
replace agegroup=6 if inrange(dhager,75,79)
replace agegroup=7 if inrange(dhager,80,89)
label define albl 1 "50-54" 2 "55-59" 3 "60-64" 4 "65-69" 5 "70-74" 6 "75-79" 7 "80-89" 
label values agegroup albl
*CESD (number of depressive symptoms.
egen s = rowmiss(psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh)
forvalues i = 1/8 {
generate f`i'=-2
}
replace f1=0 if psceda==2
replace f2=0 if pscedb==2
replace f3=0 if pscedc==2
replace f4=0 if pscedd==1
replace f5=0 if pscede==2
replace f6=0 if pscedf==1
replace f7=0 if pscedg==2
replace f8=0 if pscedh==2
replace f1=1 if psceda==1
replace f2=1 if pscedb==1
replace f3=1 if pscedc==1
replace f4=1 if pscedd==2
replace f5=1 if pscede==1
replace f6=1 if pscedf==2
replace f7=1 if pscedg==1
replace f8=1 if pscedh==1
mvdecode f1-f8,mv(-2)
egen c = rsum(f1-f8) if s==0              /* must have valid values on all 8 items */
generate CESD1 = c
recode CESD1 (0/3=0) (4/8=1)
label define clbl 0 "not depressed" 1 "depressed"
label values CESD1 clbl
*ADL & iADL.
egen z1 = anycount(headb01-headb10),values(1)
egen z2 = anycount(headb01-headb10),values(2)
egen z3 = anycount(headb01-headb10),values(3)
egen z4 = anycount(headb01-headb10),values(4)
egen z5 = anycount(headb01-headb10),values(5)
egen z6 = anycount(headb01-headb10),values(6)
egen ADL1 = rsum(z1-z6) if headb01!=.    /* 11,121   */
recode ADL1 (0=0) (1/6=1)
label define ADLlbl 0 "no limitations" 1 "1+ limitations"
label values ADL1 ADLlbl
*iADL.
drop z1-z6
egen z1 = anycount(headb01-headb13),values(7)
egen z2 = anycount(headb01-headb13),values(8)
egen z3 = anycount(headb01-headb13),values(9)
egen z4 = anycount(headb01-headb13),values(10)
egen z5 = anycount(headb01-headb13),values(11)
egen z6 = anycount(headb01-headb13),values(12)
egen z7 = anycount(headb01-headb13),values(13)
egen iADL1 = rsum(z1-z7)  if headb01!=.    /* 11,121   */
*--------------------------------------.
*Positive and negative support.
*--------------------------------------.
* Spouse.
* Positive (Spouse).
recode scptra (1=3) (2=2) (3=1) (4=0)           /* positive views to high scores */
recode scptrb (1=3) (2=2) (3=1) (4=0) 			/* positive views to high scores */
recode scptrc (1=3) (2=2) (3=1) (4=0) 		 /* positive views to high scores */

* Negative (Spouse).
recode scptrd (1=3) (2=2) (3=1) (4=0)           		/* negative views to high scores */
recode scptre (1=3) (2=2) (3=1) (4=0) 					/* negative views to high scores */
recode scptrf (1=3) (2=2) (3=1) (4=0) 					/* negative views to high scores */

egen PS_Spouse0 = rowtotal(scptra scptrb scptrc), missing         /* set to missing if all are missing */
egen NS_Spouse0 = rowtotal(scptrd scptre scptrf), missing         /* set to missing if all are missing */

* recode no spouse to zero.
replace PS_Spouse0=0 if (scptr==2)
replace NS_Spouse0=0 if (scptr==2)

label variable PS_Spouse0 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse0 "Negative interaction spouse (no spouse zero)"

* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
*Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child0 = rowtotal(scchda scchdb scchdc), missing
egen NS_Child0 = rowtotal(scchdd scchde scchdf), missing 
* recode no children to zero.
replace PS_Child0=0 if scchd==2
replace NS_Child0=0 if scchd==2
label variable PS_Child0 "Positive interaction children (no child as zero)"
label variable NS_Child0 "Negative interaction children (no child as zero"

** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend0 = rowtotal(scfrda scfrdb scfrdc), missing
egen NS_Friend0 = rowtotal(scfrdd scfrde scfrdf), missing
* recode no friends to zero.
replace PS_Friend0=0 if scfrd==2
replace NS_Friend0=0 if scfrd==2
label variable PS_Friend0 "Positive interaction friends (no friends zero)"
label variable NS_Friend0 "Negative interaction friends (no friends zero)"
** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family0 = rowtotal(scfama scfamb scfamc), missing 
egen NS_Family0 = rowtotal(scfamd scfame scfamf), missing
* recode no immediate family members to zero.
replace PS_Family0=0 if scfam==2
replace NS_Family0=0 if scfam==2
label variable PS_Family0 "Positive interaction family (none to zero)"
label variable NS_Family0 "Negative interaction family (none to zero)"
* Overall summary.
egen PSall0 = rowtotal(PS_Spouse0 PS_Child0 PS_Friend0 PS_Family0), missing 
egen NSall0 = rowtotal(NS_Spouse0 NS_Child0 NS_Friend0 NS_Family0), missing 
label variable PSall0 "Positive support from spouse, children, family, friends"
label variable NSall0 "Negative support from spouse, children, family, friends"
generate spouse0=.
replace spouse0=0 if scptr==2
replace spouse0=1 if scptr==1
generate child0=.
replace child0=0 if scchd==2
replace child0=1 if scchd==1
generate friend0=.
replace friend0=0 if scfrd==2
replace friend0=1 if scfrd==1
generate family0=.
replace family0=0 if scfam==2
replace family0=1 if scfam==1

*Social Participation
egen sp = rowmiss(scorg1 scorg2 scorg3 scorg4 scorg5 scorg6 scorg7 scorg8)
generate SPart1 = (scorg1 + scorg2 + scorg3 + scorg4 + scorg5 + scorg6 + scorg7 + scorg8) if sp==0
label variable SPart1 "Social participation at Wave 1"
recode SPart1 (0=1) (1/8 = 0)
label define SPart1 0 "Active" 1 "Inactive"
*Rename memory scores.
rename cflisen cflisen0
rename cflisd cflisd0
summ cflisen0 cflisd0 

generate wave1=1
keep idauniq indsex wave1 age1 cflisen0 cflisd0 w1wgt age1 CESD1 ADL1 iADL1 wealthq1 askpx ///
PSall0 NSall0 PS_Spouse0 NS_Spouse0 PS_Child0 NS_Child0 PS_Friend0 NS_Friend0 PS_Family0 NS_Family0 ///
spouse0 child0 friend0 family0 ///
topqual smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 
save "N:\Temp\Wave1DVs.dta", replace

*Wave 2.
use idauniq tnhwq5_bu_s using "N:\ELSA\Datasets\wave_2_financial_derived_variables.dta", clear
sort idauniq
save "N:\Temp\Tempa.dta",replace
* Wave 2.
clear
use idauniq dhager finstat indsex w2wgt askpx outscw2 C* n* P* headb01-headb13 sc* using "N:\ELSA\Datasets\wave_2_core_data_v4.dta"
renvars,lower
rename dhager age2
keep if inrange(w2wgt,0.02,10)
keep if finstat=="C1CM"
sort idauniq
merge 1:1 idauniq using "N:\Temp\Tempa.dta"
keep if _merge==3
drop if askpx==1
keep idauniq tnhwq5_bu age2 cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headb01-headb13 scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf 
qui: mvdecode _all, mv(-90/-1)
rename tnhwq5_bu wealthq2
generate wave2=1
* Spouse.
* how close is your relationship.
* Positive.
recode scptra (1=3) (2=2) (3=1) (4=0)
recode scptrb (1=3) (2=2) (3=1) (4=0)
recode scptrc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scptrd (1=3) (2=2) (3=1) (4=0)
recode scptre (1=3) (2=2) (3=1) (4=0)
recode scptrf (1=3) (2=2) (3=1) (4=0)
egen PS_Spouse1 = rowtotal(scptra scptrb scptrc), missing
egen NS_Spouse1 = rowtotal(scptrd scptre scptrf), missing
* recode no spouse to zero.
replace PS_Spouse1=0 if scptr==2
replace NS_Spouse1=0 if scptr==2
label variable PS_Spouse1 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse1 "Negative interaction spouse (no spouse zero)"

* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child1 = rowtotal(scchda scchdb scchdc), missing 
egen NS_Child1 = rowtotal(scchdd scchde scchdf), missing
* recode no children to zero.
replace PS_Child1=0 if scchd==2
replace NS_Child1=0 if scchd==2
label variable PS_Child1 "Positive interaction children (no child zero)"
label variable NS_Child1 "Negative interaction children (no child zero)"
** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend1 = rowtotal(scfrda scfrdb scfrdc), missing 
egen NS_Friend1 = rowtotal(scfrdd scfrde scfrdf), missing
* recode no friends to zero.
replace PS_Friend1=0 if scfrd==2
replace NS_Friend1=0 if scfrd==2
label variable PS_Friend1 "Positive interaction friends (no friends zero)"
label variable NS_Friend1 "Negative interaction friends (no friends zero)"
** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family1 = rowtotal(scfama scfamb scfamc), missing 
egen NS_Family1 = rowtotal(scfamd scfame scfamf), missing
* recode no family to zero.
replace PS_Family1=0 if scfam==2
replace NS_Family1=0 if scfam==2
label variable PS_Family1 "Positive interaction family"
label variable NS_Family1 "Negative interaction family"
* Overall summary.
egen PSall1 = rowtotal(PS_Spouse1 PS_Child1 PS_Friend1 PS_Family1), missing 
egen NSall1 = rowtotal(NS_Spouse1 NS_Child1 NS_Friend1 NS_Family1), missing
label variable PSall1 "Positive support from spouse, children, family, friends"
label variable NSall1 "Negative support from spouse, children, family, friends"
rename cflisen cflisen1
rename cflisd cflisd1
generate spouse1=.
replace spouse1=0 if scptr==2
replace spouse1=1 if scptr==1
generate child1=.
replace child1=0 if scchd==2
replace child1=1 if scchd==1
generate friend1=.
replace friend1=0 if scfrd==2
replace friend1=1 if scfrd==1
generate family1=.
replace family1=0 if scfam==2
replace family1=1 if scfam==1
keep idauniq wave2 age2 cflisen1 cflisd1 wealthq2 ///
PSall1 NSall1 PS_Spouse1 NS_Spouse1 PS_Child1 NS_Child1 PS_Friend1 NS_Friend1 PS_Family1 NS_Family1 ///
spouse1 child1 friend1 family1
save "N:\Temp\Wave2DVs.dta", replace

* ELSA Wave 3.
clear
use idauniq tnhwq5_bu_s using "N:\ELSA\Datasets\wave_3_financial_derived_variables.dta"
sort idauniq
save "N:\Temp\Tempa.dta",replace

clear
use  idauniq dhager finstat indsex askpx w3lwgt sc* c* n* outscw3 psc* he* sc*  using "N:\ELSA\Datasets\wave_3_elsa_data_v4.dta"
renvars,lower
rename dhager age3
keep if finstat=="C1CM"
sort idauniq
merge 1:1 idauniq using "N:\Temp\Tempa.dta"
keep if _merge==3
drop if askpx==1
keep idauniq askpx tnhwq5_bu age3 cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headldr headlwa headlba headlea headlbe headlwc headlma headlpr headlsh headlph headlme headlho headlmo ///
scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf 
qui: mvdecode _all, mv(-90/-1)
rename tnhwq5_bu wealthq3
* Spouse.
* Positive.
recode scptra (1=3) (2=2) (3=1) (4=0)
recode scptrb (1=3) (2=2) (3=1) (4=0)
recode scptrc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scptrd (1=3) (2=2) (3=1) (4=0)
recode scptre (1=3) (2=2) (3=1) (4=0)
recode scptrf (1=3) (2=2) (3=1) (4=0)
egen PS_Spouse2 = rowtotal(scptra scptrb scptrc), missing 
egen NS_Spouse2 = rowtotal(scptrd scptre scptrf), missing 
* recode no spouse to zero.
replace PS_Spouse2=0 if scptr==2
replace NS_Spouse2=0 if scptr==2
label variable PS_Spouse2 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse2 "Negative interaction spouse (no spouse zero)"
* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child2 = rowtotal(scchda scchdb scchdc), missing 
egen NS_Child2 = rowtotal(scchdd scchde scchdf), missing
* recode no children to zero.
replace PS_Child2=0 if scchd==2
replace NS_Child2=0 if scchd==2
label variable PS_Child2 "Positive interaction children (no child zero)"
label variable NS_Child2 "Negative interaction children (no child zero)"
** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend2 = rowtotal(scfrda scfrdb scfrdc), missing
egen NS_Friend2 = rowtotal(scfrdd scfrde scfrdf), missing 
* recode no friends to zero.
replace PS_Friend2=0 if scfrd==2
replace NS_Friend2=0 if scfrd==2
label variable PS_Friend2 "Positive interaction friends (no friends zero)"
label variable NS_Friend2 "Negative interaction friends (no friends zero)"

** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family2 = rowtotal(scfama scfamb scfamc), missing
egen NS_Family2 = rowtotal(scfamd scfame scfamf), missing
* recode no friends to zero.
replace PS_Family2=0 if scfam==2
replace NS_Family2=0 if scfam==2
label variable PS_Family2 "Positive interaction family (no family zero)"
label variable NS_Family2 "Negative interaction family (no family zero)"
* Overall summary.
egen PSall2 = rowtotal(PS_Spouse2 PS_Child2 PS_Friend2 PS_Family2), missing 
egen NSall2 = rowtotal(NS_Spouse2 NS_Child2 NS_Friend2 NS_Family2), missing   
label variable PSall2 "Positive support from spouse, children, family, friends"
label variable NSall2 "Negative support from spouse, children, family, friends"
generate wave3=1
rename cflisen cflisen2
rename cflisd cflisd2
generate spouse2=.
replace spouse2=0 if scptr==2
replace spouse2=1 if scptr==1
generate child2=.
replace child2=0 if scchd==2
replace child2=1 if scchd==1
generate friend2=.
replace friend2=0 if scfrd==2
replace friend2=1 if scfrd==1
generate family2=.
replace family2=0 if scfam==2
replace family2=1 if scfam==1
keep idauniq wave3 age3 cflisen2 cflisd2 wealthq3 ///
PSall2 NSall2 PS_Spouse2 NS_Spouse2 PS_Child2 NS_Child2 PS_Friend2 NS_Friend2 PS_Family2 NS_Family2 ///
spouse2 child2 friend2 family2
save "N:\Temp\Wave3DVs.dta", replace

* Wave4.
use  "N:\ELSA\Datasets\wave_4_ifs_derived_variables.dta", clear
keep idauniq memtot memtotb
save "N:\Temp\Temp52.dta", replace
clear
use idauniq tnhwq5_bu_s using "N:\ELSA\Datasets\wave_4_financial_derived_variables.dta"
sort idauniq
save "N:\Temp\Tempa.dta",replace

* ELSA Wave 4.
clear
use idauniq indager finstat indsex askpx sc* c* n* psc* hea* sc* using "N:\ELSA\Datasets\wave_4_elsa_data_v3.dta"
renvars,lower
rename indager age4
keep if finstat=="C1CM"
sort idauniq
merge 1:1 idauniq using "N:\Temp\Tempa.dta"
keep if _merge==3
drop _merge
rename tnhwq5_bu wealthq4
merge 1:1 idauniq using "N:\Temp\Temp52.dta"
keep if _merge==3
drop if askpx==1
keep idauniq askpx wealthq4 age4 cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headldr headlwa headlba headlea headlbe headlwc headlma headlpr headlsh headlte headlme headlho headlmo ///
scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf 
qui: mvdecode _all, mv(-90/-1)
* Spouse.
* Positive.
recode scptra (1=3) (2=2) (3=1) (4=0)
recode scptrb (1=3) (2=2) (3=1) (4=0)
recode scptrc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scptrd (1=3) (2=2) (3=1) (4=0)
recode scptre (1=3) (2=2) (3=1) (4=0)
recode scptrf (1=3) (2=2) (3=1) (4=0)
egen PS_Spouse3 = rowtotal(scptra scptrb scptrc), missing
egen NS_Spouse3 = rowtotal(scptrd scptre scptrf), missing
* recode no spouse to zero.
replace PS_Spouse3=0 if scptr==2
replace NS_Spouse3=0 if scptr==2
label variable PS_Spouse3 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse3 "Negative interaction spouse (no spouse zero)"

* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child3 = rowtotal(scchda scchdb scchdc), missing 
egen NS_Child3 = rowtotal(scchdd scchde scchdf), missing 
* recode no children to zero.
replace PS_Child3=0 if scchd==2
replace NS_Child3=0 if scchd==2
label variable PS_Child3 "Positive interaction children (no children zero)"
label variable NS_Child3 "Negative interaction children (no children zero)"

** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend3 = rowtotal(scfrda scfrdb scfrdc), missing 
egen NS_Friend3 = rowtotal(scfrdd scfrde scfrdf), missing
* recode no friends to zero.
replace PS_Friend3=0 if scfrd==2
replace NS_Friend3=0 if scfrd==2
label variable PS_Friend3 "Positive interaction friends (no friends zero)"
label variable NS_Friend3 "Negative interaction friends (no friends zero)"
** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family3 = rowtotal(scfama scfamb scfamc), missing 
egen NS_Family3 = rowtotal(scfamd scfame scfamf), missing 
* recode no family to zero.
replace PS_Family3=0 if scfam==2
replace NS_Family3=0 if scfam==2
label variable PS_Family3 "Positive interaction family (no family zero)"
label variable NS_Family3 "Negative interaction family (no family zero)"
* Overall summary.
egen PSall3 = rowtotal(PS_Spouse3 PS_Child3 PS_Friend3 PS_Family3) , missing 
egen NSall3 = rowtotal(NS_Spouse3 NS_Child3 NS_Friend3 NS_Family3) , missing  
label variable PSall3 "Positive support from spouse, children, family, friends"
label variable NSall3 "Negative support from spouse, children, family, friends"
rename cflisen cflisen3
rename cflisd cflisd3
generate spouse3=.
replace spouse3=0 if scptr==2
replace spouse3=1 if scptr==1
generate child3=.
replace child3=0 if scchd==2
replace child3=1 if scchd==1
generate friend3=.
replace friend3=0 if scfrd==2
replace friend3=1 if scfrd==1
generate family3=.
replace family3=0 if scfam==2
replace family3=1 if scfam==1
generate wave4=1
keep idauniq wave4 age4 cflisen3 cflisd3 wealthq4 ///
PSall3 NSall3 PS_Spouse3 NS_Spouse3 PS_Child3 NS_Child3 PS_Friend3 NS_Friend3 PS_Family3 NS_Family3 ///
spouse3 child3 friend3 family3
save "N:\Temp\Wave4DVs.dta", replace

* Wave 5.
clear
use idauniq tnhwq5_bu_s using "N:\ELSA\Datasets\wave_5_financial_derived_variables.dta"
sort idauniq
save "N:\Temp\Tempa.dta",replace
use idauniq finstat indager indsex askpx cf* psc* head* sc* using "N:\ELSA\Datasets\wave_5_elsa_data_v4.dta", clear
rename indager age5
keep if finstat=="C1CM"
sort idauniq
merge 1:1 idauniq using "N:\Temp\Tempa.dta"
keep if _merge==3
rename tnhwq5_bu wealthq5
drop if askpx==1
keep idauniq askpx wealthq5 age5 cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headldr headlwa headlba headlea headlbe headlwc headlma headlpr headlsh headlte headlme headlho headlmo ///
scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf 
qui: mvdecode _all, mv(-90/-1)
* Spouse.
* Positive.
recode scptra (1=3) (2=2) (3=1) (4=0)
recode scptrb (1=3) (2=2) (3=1) (4=0)
recode scptrc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scptrd (1=3) (2=2) (3=1) (4=0)
recode scptre (1=3) (2=2) (3=1) (4=0)
recode scptrf (1=3) (2=2) (3=1) (4=0)
egen PS_Spouse4 = rowtotal(scptra scptrb scptrc), missing 
egen NS_Spouse4 = rowtotal(scptrd scptre scptrf), missing
* recode no spouse to zero.
replace PS_Spouse4=0 if scptr==2
replace NS_Spouse4=0 if scptr==2
label variable PS_Spouse4 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse4 "Negative interaction spouse (no spouse zero)"

* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child4 = rowtotal(scchda scchdb scchdc), missing 
egen NS_Child4 = rowtotal(scchdd scchde scchdf), missing 
* recode no children to zero.
replace PS_Child4=0 if scchd==2
replace NS_Child4=0 if scchd==2
label variable PS_Child4 "Positive interaction children (no child zero)"
label variable NS_Child4 "Negative interaction children (no child zero)"
** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend4 = rowtotal(scfrda scfrdb scfrdc), missing 
egen NS_Friend4 = rowtotal(scfrdd scfrde scfrdf), missing 
* recode no friends to zero.
replace PS_Friend4=0 if scfrd==2
replace NS_Friend4=0 if scfrd==2
label variable PS_Friend4 "Positive interaction friends (no friends zero)"
label variable NS_Friend4 "Negative interaction friends (no friends zero)"
** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family4 = rowtotal(scfama scfamb scfamc), missing 
egen NS_Family4 = rowtotal(scfamd scfame scfamf), missing 
* recode no family to zero.
replace PS_Family4=0 if scfam==2
replace NS_Family4=0 if scfam==2
label variable PS_Family4 "Positive interaction family (no family zero)"
label variable NS_Family4 "Negative interaction family (no family zero)"
* Overall summary.
egen PSall4 = rowtotal(PS_Spouse4 PS_Child4 PS_Friend4 PS_Family4), missing 
egen NSall4 = rowtotal(NS_Spouse4 NS_Child4 NS_Friend4 NS_Family4), missing  
label variable PSall4 "Positive support from children, family, friends"
label variable NSall4 "Negative support from children, family, friends"
generate wave5=1
rename cflisen cflisen4
rename cflisd cflisd4
generate spouse4=.
replace spouse4=0 if scptr==2
replace spouse4=1 if scptr==1
generate child4=.
replace child4=0 if scchd==2
replace child4=1 if scchd==1
generate friend4=.
replace friend4=0 if scfrd==2
replace friend4=1 if scfrd==1
generate family4=.
replace family4=0 if scfam==2
replace family4=1 if scfam==1
keep idauniq wave5 age5 cflisen4 cflisd4 wealthq5 ///
PSall4 NSall4 PS_Spouse4 NS_Spouse4 PS_Child4 NS_Child4 PS_Friend4 NS_Friend4 PS_Family4 NS_Family4 ///
spouse4 child4 friend4 family4
save "N:\Temp\Wave5DVs.dta", replace
* Wave 6.
clear
use idauniq tnhwq5_bu_s using "N:\ELSA\Datasets\wave_6_financial_derived_variables.dta"
sort idauniq
save "N:\Temp\Tempa.dta",replace
use idauniq finstat indager indsex askpx C* c* cf* PS* head*  sc* using "N:\ELSA\datasets\wave_6_elsa_data_v2.dta", clear
renvars, lower
keep if finstat==1
sort idauniq
merge 1:1 idauniq using "N:\Temp\Tempa.dta"
keep if _merge==3
rename tnhwq5_bu wealthq6
rename indager age6
rename scprtr scptr
drop if askpx==1
keep idauniq askpx wealthq6 age6 cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headldr headlwa headlba headlea headlbe headlwc headlma headlpr headlsh headlph headlme headlho headlmo ///
scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf 
qui:mvdecode _all, mv(-90/-1)
* Spouse.
* Positive.
recode scptra (1=3) (2=2) (3=1) (4=0)
recode scptrb (1=3) (2=2) (3=1) (4=0)
recode scptrc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scptrd (1=3) (2=2) (3=1) (4=0)
recode scptre (1=3) (2=2) (3=1) (4=0)
recode scptrf (1=3) (2=2) (3=1) (4=0)
egen PS_Spouse5 = rowtotal(scptra scptrb scptrc), missing 
egen NS_Spouse5 = rowtotal(scptrd scptre scptrf), missing
* recode no spouse to zero.
replace PS_Spouse5=0 if scptr==2
replace NS_Spouse5=0 if scptr==2
label variable PS_Spouse5 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse5 "Negative interaction spouse (no spouse zero)"
* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child5 = rowtotal(scchda scchdb scchdc), missing 
egen NS_Child5 = rowtotal(scchdd scchde scchdf), missing 
* recode no children to zero.
replace PS_Child5=0 if scchd==2
replace NS_Child5=0 if scchd==2
label variable PS_Child5 "Positive interaction children (no child zero)"
label variable NS_Child5 "Negative interaction children (no child zero)"
** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
*Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend5 = rowtotal(scfrda scfrdb scfrdc), missing 
egen NS_Friend5 = rowtotal(scfrdd scfrde scfrdf), missing 
* recode no friends to zero.
replace PS_Friend5=0 if scfrd==2
replace NS_Friend5=0 if scfrd==2
label variable PS_Friend5 "Positive interaction friends (no friends zero)"
label variable NS_Friend5 "Negative interaction friends (no friends zero)"
** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family5 = rowtotal(scfama scfamb scfamc), missing 
egen NS_Family5 = rowtotal(scfamd scfame scfamf), missing 
* recode no family to zero.
replace PS_Family5=0 if scfam==2
replace NS_Family5=0 if scfam==2
label variable PS_Family5 "Positive interaction family (no family zero)"
label variable NS_Family5 "Negative interaction family (no family zero)"
* Overall summary.
egen PSall5 = rowtotal(PS_Spouse5 PS_Child5 PS_Friend5 PS_Family5), missing 
egen NSall5 = rowtotal(NS_Spouse5 NS_Child5 NS_Friend5 NS_Family5), missing  
label variable PSall5 "Positive support from children, family, friends"
label variable NSall5 "Negative support from children, family, friends"
rename cflisen cflisen5
rename cflisd cflisd5
generate spouse5=.
replace spouse5=0 if scptr==2
replace spouse5=1 if scptr==1
generate child5=.
replace child5=0 if scchd==2
replace child5=1 if scchd==1
generate friend5=.
replace friend5=0 if scfrd==2
replace friend5=1 if scfrd==1
generate family5=.
replace family5=0 if scfam==2
replace family5=1 if scfam==1
generate wave6=1
keep idauniq wave6 age6 cflisen5 cflisd5 wealthq6 ///
PSall5 NSall5 PS_Spouse5 NS_Spouse5 PS_Child5 NS_Child5 PS_Friend5 NS_Friend5 PS_Family5 NS_Family5 ///
spouse5 child5 friend5 family5
save "N:\Temp\Wave6DVs.dta", replace

* Wave 7.
clear
use idauniq tnhwq5_bu_s using "N:\ELSA\Datasets\wave_7_financial_derived_variables.dta"
sort idauniq
save "N:\Temp\Tempa.dta",replace
use idauniq finstat indager indsex askpx C* c* cf* PS* head* sc* using "N:\ELSA\datasets\wave_7_elsa_data.dta", clear
renvars, lower
keep if finstat==1
sort idauniq
merge 1:1 idauniq using "N:\Temp\Tempa.dta"
keep if _merge==3
rename tnhwq5_bu wealthq7
rename indager age7
rename scprtr scptr
drop if askpx==1
keep idauniq askpx wealthq7 age7 cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headldr headlwa headlba headlea headlbe headlwc headlma headlpr headlsh headlph headlme headlho headlmo ///
scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf 
qui:mvdecode _all, mv(-90/-1)
* Spouse.
* Positive.
recode scptra (1=3) (2=2) (3=1) (4=0)
recode scptrb (1=3) (2=2) (3=1) (4=0)
recode scptrc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scptrd (1=3) (2=2) (3=1) (4=0)
recode scptre (1=3) (2=2) (3=1) (4=0)
recode scptrf (1=3) (2=2) (3=1) (4=0)
egen PS_Spouse6 = rowtotal(scptra scptrb scptrc), missing 
egen NS_Spouse6 = rowtotal(scptrd scptre scptrf), missing
* recode no spouse to zero.
replace PS_Spouse6=0 if scptr==2
replace NS_Spouse6=0 if scptr==2
label variable PS_Spouse6 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse6 "Negative interaction spouse (no spouse zero)"

* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child6 = rowtotal(scchda scchdb scchdc), missing 
egen NS_Child6 = rowtotal(scchdd scchde scchdf), missing 
* recode no children to zero.
replace PS_Child6=0 if scchd==2
replace NS_Child6=0 if scchd==2
label variable PS_Child6 "Positive interaction children (no child zero)"
label variable NS_Child6 "Negative interaction children (no child zero)"
** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend6 = rowtotal(scfrda scfrdb scfrdc), missing 
egen NS_Friend6 = rowtotal(scfrdd scfrde scfrdf), missing 
* recode no friends to zero.
replace PS_Friend6=0 if scfrd==2
replace NS_Friend6=0 if scfrd==2
label variable PS_Friend6 "Positive interaction friends (no friends zero)"
label variable NS_Friend6 "Negative interaction friends (no friends zero)"
** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family6 = rowtotal(scfama scfamb scfamc), missing 
egen NS_Family6 = rowtotal(scfamd scfame scfamf), missing 
* recode no family to zero.
replace PS_Family6=0 if scfam==2
replace NS_Family6=0 if scfam==2
label variable PS_Family6 "Positive interaction family (no family zero)"
label variable NS_Family6 "Negative interaction family (no family zero)"
* Overall summary.
egen PSall6 = rowtotal(PS_Spouse6 PS_Child6 PS_Friend6 PS_Family6), missing 
egen NSall6 = rowtotal(NS_Spouse6 NS_Child6 NS_Friend6 NS_Family6), missing  
label variable PSall6 "Positive support from children, family, friends"
label variable NSall6 "Negative support from children, family, friends"
rename cflisen cflisen6
rename cflisd cflisd6
generate spouse6=.
replace spouse6=0 if scptr==2
replace spouse6=1 if scptr==1
generate child6=.
replace child6=0 if scchd==2
replace child6=1 if scchd==1
generate friend6=.
replace friend6=0 if scfrd==2
replace friend6=1 if scfrd==1
generate family6=.
replace family6=0 if scfam==2
replace family6=1 if scfam==1
generate wave7=1
keep idauniq wave7 age7 cflisen6 cflisd6 wealthq7 ///
PSall6 NSall6 PS_Spouse6 NS_Spouse6 PS_Child6 NS_Child6 PS_Friend6 NS_Friend6 PS_Family6 NS_Family6 ///
spouse6 child6 friend6 family6
save "N:\Temp\Wave7DVs.dta", replace
* Wave 8.
clear
use idauniq tnhwq5_bu_s using "N:\ELSA\Datasets\wave_8_elsa_financial_dvs_eul_v1.dta"
sort idauniq
save "N:\Temp\Tempa.dta",replace
use idauniq finstat indager indsex askpx  c* cf* ps* head* sc* w8w1lwgt using "N:\ELSA\datasets\wave_8_elsa_data_eul_v2.dta", clear
renvars, lower
keep if finstat==1
sort idauniq
merge 1:1 idauniq using "N:\Temp\Tempa.dta"
keep if _merge==3
rename tnhwq5_bu wealthq8
rename indager age8
drop if askpx==1
rename scprt scptr
rename scprta scptra 
rename scprtb scptrb 
rename scprtc scptrc 
rename scprtd scptrd 
rename scprte scptre 
rename scprtf scptrf 
keep idauniq w8w1lwgt askpx wealthq8 age8 cflisen cflisd psceda pscedb pscedc pscedd pscede pscedf pscedg pscedh ///
headldr headlwa headlba headlea headlbe headlwc headlma headlpr headlsh headlph headlme headlho headlmo ///
scptr scchd scfrd scfam scptra scptrb scptrc  scptrd scptre scptrf  scchda scchdb scchdc  scchdd scchde scchdf scfrda scfrdb scfrdc scfrdd scfrde scfrdf scfama scfamb scfamc  scfamd scfame scfamf 
qui:mvdecode _all, mv(-90/-1)
* Spouse.
* Positive.
recode scptra (1=3) (2=2) (3=1) (4=0)
recode scptrb (1=3) (2=2) (3=1) (4=0)
recode scptrc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scptrd (1=3) (2=2) (3=1) (4=0)
recode scptre (1=3) (2=2) (3=1) (4=0)
recode scptrf (1=3) (2=2) (3=1) (4=0)
egen PS_Spouse7 = rowtotal(scptra scptrb scptrc), missing 
egen NS_Spouse7 = rowtotal(scptrd scptre scptrf), missing
* recode no spouse to zero.
replace PS_Spouse7=0 if scptr==2
replace NS_Spouse7=0 if scptr==2
label variable PS_Spouse7 "Positive interaction spouse (no spouse zero)"
label variable NS_Spouse7 "Negative interaction spouse (no spouse zero)"

* Children (3 positive items): high scores = high positive.
* Children (3 negative items): high scores = high negative.
* Positive.
recode scchda (1=3) (2=2) (3=1) (4=0)
recode scchdb (1=3) (2=2) (3=1) (4=0)
recode scchdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scchdd (1=3) (2=2) (3=1) (4=0)
recode scchde (1=3) (2=2) (3=1) (4=0)
recode scchdf (1=3) (2=2) (3=1) (4=0)
egen PS_Child7 = rowtotal(scchda scchdb scchdc), missing 
egen NS_Child7 = rowtotal(scchdd scchde scchdf), missing 
* recode no children to zero.
replace PS_Child7=0 if scchd==2
replace NS_Child7=0 if scchd==2
label variable PS_Child7 "Positive interaction children (no child zero)"
label variable NS_Child7 "Negative interaction children (no child zero)"
** Friends (3 positive items): high scores = high positive.
** Friends (3 negative items): high scores = high negative.
* Positive.
recode scfrda (1=3) (2=2) (3=1) (4=0)
recode scfrdb (1=3) (2=2) (3=1) (4=0)
recode scfrdc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfrdd (1=3) (2=2) (3=1) (4=0)
recode scfrde (1=3) (2=2) (3=1) (4=0)
recode scfrdf (1=3) (2=2) (3=1) (4=0)
egen PS_Friend7 = rowtotal(scfrda scfrdb scfrdc), missing 
egen NS_Friend7 = rowtotal(scfrdd scfrde scfrdf), missing 
* recode no friends to zero.
replace PS_Friend7=0 if scfrd==2
replace NS_Friend7=0 if scfrd==2
label variable PS_Friend7 "Positive interaction friends (no friends zero)"
label variable NS_Friend7 "Negative interaction friends (no friends zero)"
** Family members (3 positive items): high scores = high positive.
** Family members (3 negative items): high scores = high negative.
* Positive.
recode scfama (1=3) (2=2) (3=1) (4=0)
recode scfamb (1=3) (2=2) (3=1) (4=0)
recode scfamc (1=3) (2=2) (3=1) (4=0)
* Negative.
recode scfamd (1=3) (2=2) (3=1) (4=0)
recode scfame (1=3) (2=2) (3=1) (4=0)
recode scfamf (1=3) (2=2) (3=1) (4=0)
egen PS_Family7 = rowtotal(scfama scfamb scfamc), missing 
egen NS_Family7 = rowtotal(scfamd scfame scfamf), missing 
* recode no family to zero.
replace PS_Family7=0 if scfam==2
replace NS_Family7=0 if scfam==2
label variable PS_Family7 "Positive interaction family (no family zero)"
label variable NS_Family7 "Negative interaction family (no family zero)"
* Overall summary.
egen PSall7 = rowtotal(PS_Spouse7 PS_Child7 PS_Friend7 PS_Family7), missing 
egen NSall7 = rowtotal(NS_Spouse7 NS_Child7 NS_Friend7 NS_Family7), missing  
label variable PSall7 "Positive support from children, family, friends"
label variable NSall7 "Negative support from children, family, friends"
rename cflisen cflisen7
rename cflisd cflisd7
generate wave8=1
generate spouse7=.
replace spouse7=0 if scptr==2
replace spouse7=1 if scptr==1
generate child7=.
replace child7=0 if scchd==2
replace child7=1 if scchd==1
generate friend7=.
replace friend7=0 if scfrd==2
replace friend7=1 if scfrd==1
generate family7=.
replace family7=0 if scfam==2
replace family7=1 if scfam==1
keep idauniq w8w1lwgt wave8 age8 cflisen7 cflisd7 wealthq8 ///
PSall7 NSall7 PS_Spouse7 NS_Spouse7 PS_Child7 NS_Child7 PS_Friend7 NS_Friend7 PS_Family7 NS_Family7 ///
spouse7 child7 friend7 family7
save "N:\Temp\Wave8DVs.dta", replace

* Put the datasets together.

use "N:\Temp\Wave1DVs.dta", clear
merge 1:1 idauniq using "N:\Temp\Wave2DVs.dta" 
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\Wave3DVs.dta" 
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\Wave4DVs.dta" 
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\Wave5DVs.dta" 
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\Wave6DVs.dta" 
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\Wave7DVs.dta" 
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\Wave8DVs.dta" 
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\IntDatesAndDeath.dta"
keep if (_merge==1|_merge==3)
drop _merge
merge 1:1 idauniq using "N:\Temp\IndexFile.dta" 
keep if (_merge==1|_merge==3)
drop _merge
*Exclude missing memory at Wave 1.
drop if (cflisen0==.|cflisd0==.)
*Between-test Pearson correlation.
forvalues i = 0/7 {
pwcorr cflisen`i' cflisd`i'
}
*Compute the memory scores.
generate memory0 = (cflisen0 + cflisd0)
generate memory1 = (cflisen1 + cflisd1)
generate memory2 = (cflisen2 + cflisd2)
generate memory3 = (cflisen3 + cflisd3)
generate memory4 = (cflisen4 + cflisd4)
generate memory5 = (cflisen5 + cflisd5)
generate memory6 = (cflisen6 + cflisd6)
generate memory7 = (cflisen7 + cflisd7)
*Number of waves.
egen numwaves = rowtotal(wave1 wave2 wave3 wave4 wave5 wave6 wave7 wave8)
*Took part at wave 1 only 
generate wave1a=0
replace wave1a=1 if inrange(memory0,0,20) & (memory1==. & memory2==. & memory3==. & memory4==. & memory5==. & memory6==. & memory7==.)
*Took part at all waves
generate memoryall=0
replace memoryall=1 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) ///
& inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) & inrange(memory6,0,20) ///
& inrange(memory7,0,20)
*Centre age (at 65).
gen agebl_65=age1-65                 
gen agesq = (agebl_65*agebl_65)
replace ADL1=0 if ADL1==. & inrange(memory0,0,20)    /* N=1  */
replace iADL1=0 if iADL1==. & inrange(memory0,0,20)    /*N=1  */
save "N:\Temp\AnalysisFile_medRxiv_2020.dta", replace












