**********************************************************************************
*Associations between social support and verbal memory: 14-year follow-up of the
*English Longitudinal Study of Ageing cohort
*medRxiv July 2020
**********************************************************************************

**********************************************************************************
*** IPW-GEE
* Those with missing memory data at wave 1 are included in this analysis.
* No missing data on predictors.
* SEE: Daza EJ, Hudgens MG, Herring AH. Estimating inverse-probability weights for longitudinal data with dropout or truncation: The xtrccipw command. 
*Stata J. 2017 2nd Quarter;17(2):253-278. PMID: 29755297; PMCID: PMC5947963.
**********************************************************************************

*version 15 needed

clear
version 15

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
*Compute the memory scores.
generate memory0 = (cflisen0 + cflisd0)
generate memory1 = (cflisen1 + cflisd1)
generate memory2 = (cflisen2 + cflisd2)
generate memory3 = (cflisen3 + cflisd3)
generate memory4 = (cflisen4 + cflisd4)
generate memory5 = (cflisen5 + cflisd5)
generate memory6 = (cflisen6 + cflisd6)
generate memory7 = (cflisen7 + cflisd7)
*Condition on consent to linkage.
tab1 mortstat
drop if mortstat==-1  
gen agebl_65=age1-65                 
gen agesq = (agebl_65*agebl_65)

summ ADL1 iADL1 if inrange(memory0,0,20)
replace ADL1=0 if ADL1==. & inrange(memory0,0,20)    /* N=1  */
replace iADL1=0 if iADL1==. & inrange(memory0,0,20)    /*N=1  */
replace smoke1=0 if idauniq==106217

keep idauniq indsex memory* w1wgt CESD1 ADL1 iADL1 wealthq1 topqual ///
PSall* NSall* age1 agebl_65 agesq wave* w8w1lwgt ///
smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 radyear mortstat
label define Censlbl 0 "Censored" 1 "Not Censored" 2 "Died"

*Wave-specific outcome indicators (deceased; missing data; complete).
*Wave 1.
generate CensW0=1 if inrange(memory0,0,20)
replace CensW0=0 if (memory0==.)
*Wave 2.
generate CensW1=.
replace CensW1=1 if inrange(memory0,0,20) & inrange(memory1,0,20)    /* Not censored */
replace CensW1=2 if inrange(memory0,0,20) & inlist(radyear,2002,2003) /* Died before W2*/
replace CensW1=0 if inrange(memory0,0,20) & (memory1==. & radyear==.)|(memory1==. & inlist(radyear,2004,2005,2006,2007,2008,2009,2010,2011,2012))   /* Censored */
label values CensW1 Censlbl
*Wave 3.
generate CensW2=.
replace CensW2=1 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20)            /*Not censored */
replace CensW2=2 if inrange(memory0,0,20) & inrange(memory1,0,20) & inlist(radyear,2004,2005)              /*Died before W2*/
replace CensW2=0 if inrange(memory0,0,20) & inrange(memory1,0,20) & (memory2==. & radyear==.)|(memory2==. & inlist(radyear,2006,2007,2008,2009,2010,2011,2012))   /* censored */
*Wave 4.
generate CensW3=.
replace CensW3=1 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20)  & inrange(memory3,0,20)  /* Not censored */
replace CensW3=2 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & (memory3==. & inlist(radyear,2006,2007)) /* Died before W2*/
replace CensW3=0 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20)  & (memory3==. & radyear==.)|(memory3==. & inlist(radyear,2008,2009,2010,2011,2012))   /*Censored */
*Wave 5.
generate CensW4=.
replace CensW4=1 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20)  & inrange(memory4,0,20)     /* not censored */
replace CensW4=2 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20)  & inlist(radyear,2008,2009) /* died before W2*/
replace CensW4=0 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20)  & (memory4==. & radyear==.)|(memory4==. & inlist(radyear,2010,2011,2012))   
*Wave 6.
generate CensW5=.
replace CensW5=1 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) /*Not censored */
replace CensW5=2 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inlist(radyear,2010,2011,2012)  /* died before W6*/
replace CensW5=0 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & (memory5==. & radyear==.)   /* censored */
*Wave 7.

generate CensW6=.
replace CensW6=1 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) & inrange(memory6,0,20)      
replace CensW6=2 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) & inlist(radyear,2010,2011,2012)
replace CensW6=0 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) & (memory6==. & radyear==.)   
*Wave 8.

generate CensW7=.
replace CensW7=1 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) ///
& inrange(memory6,0,20) & inrange(memory7,0,20)      /* not censored */
replace CensW7=2 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) ///
& inrange(memory6,0,20) & inlist(radyear,2010,2011,2012)              /* died before W6*/
replace CensW7=0 if inrange(memory0,0,20) & inrange(memory1,0,20) & inrange(memory2,0,20) & inrange(memory3,0,20) & inrange(memory4,0,20) & inrange(memory5,0,20) ///
& inrange(memory6,0,20) & (memory7==. & radyear==.)   /* censored */

generate truncyr=.
replace truncyr=0 if CensW0==2
replace truncyr=1 if CensW1==2   /* died before wave 2 */
replace truncyr=2 if CensW2==2   /* died before wave 3 */
replace truncyr=3 if CensW3==2   /* died before wave 4 */
replace truncyr=4 if CensW4==2   /* died before wave 5 */
replace truncyr=5 if CensW5==2   /* died before wave 6 */
replace truncyr=6 if CensW6==2   /* died before wave 7 */
replace truncyr=7 if CensW7==2   /* died before wave 8 */
*Data in wide form.
egen PSmean=rowmean(PSall0 PSall1 PSall2 PSall3 PSall4 PSall5 PSall6 PSall7)
egen NSmean=rowmean(NSall0 NSall1 NSall2 NSall3 NSall4 NSall5 NSall6 NSall7)
egen PSgrand = mean(PSmean)
egen NSgrand = mean(NSmean)

*Centre person-mean variables.
gen PSallBP = PSmean-PSgrand
gen NSallBP = NSmean-NSgrand

gen PSallWP0 = (PSall0 - PSmean)
gen PSallWP1 = (PSall1 - PSmean)
gen PSallWP2 = (PSall2 - PSmean)
gen PSallWP3 = (PSall3 - PSmean)
gen PSallWP4 = (PSall4 - PSmean)
gen PSallWP5 = (PSall5 - PSmean)
gen PSallWP6 = (PSall6 - PSmean)
gen PSallWP7 = (PSall7 - PSmean)
gen NSallWP0 = (NSall0 - NSmean)
gen NSallWP1 = (NSall1 - NSmean)
gen NSallWP2 = (NSall2 - NSmean)
gen NSallWP3 = (NSall3 - NSmean)
gen NSallWP4 = (NSall4 - NSmean)
gen NSallWP5 = (NSall5 - NSmean)
gen NSallWP6 = (NSall6 - NSmean)
gen NSallWP7 = (NSall7 - NSmean)

keep idauniq memory* indsex truncyr CensW0 CensW1 CensW2 CensW3 CensW4 CensW5 CensW6 CensW7 agebl_65 agesq ///
CESD1 ADL1 SPart1 topqual w1wgt drink1 actlevel1 smoke1 wealthq1 couple ProblemsW1 DiagnosedW1 PSall* NSall*

reshape long memory PSallWP NSallWP, i(idauniq) j(occasion)
gen occasionsq=occasion*occasion

*IPW-GEE model.
*Variables to predict probability of being censored:
*agebl_65;agesq;w1wgt;indsex;CESD1;ADL1;SPart1;topqual;wealthq1;drink1 ///
*actlevel1;smoke1;couple;ProblemsW1;DiagnosedW1 ///

xtrccipw memory, idvar(idauniq) timevar(occasion) timeidxvar(occasion) ///
generate(ipw_full) trtimevar(truncyr) linkfxn(logit) ///
tiindepvars(agebl_65 agesq w1wgt i.indsex i.CESD1 i.ADL1 i.SPart1 i.topqual i.wealthq1 i.drink1 i.actlevel1 i.smoke1 couple ProblemsW1 DiagnosedW1) ///
glmvars(occasion occasionsq agebl_65 agesq i.indsex i.topqual i.wealthq1 i.CESD1 i.smoke1 i.drink1 i.actlevel1 i.SPart1 ///
c.occasion#c.agebl_65 c.occasion#c.agesq ///
c.occasion#i.indsex c.occasion#i.topqual c.occasion#i.wealthq1 c.occasion#i.CESD1 ///
c.occasion#i.smoke1 c.occasion#i.drink1 c.occasion#i.actlevel1 c.occasion#i.ADL1 c.occasion#i.SPart1 ///
c.PSallBP c.occasion#c.PSallBP c.PSallWP c.occasion#c.PSallWP ///
c.NSallBP c.occasion#c.NSallBP c.NSallWP c.occasion#c.NSallWP) ///
glmfamily(gaussian)











