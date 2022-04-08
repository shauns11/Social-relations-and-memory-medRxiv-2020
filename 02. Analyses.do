
use "N:\Temp\AnalysisFile_medRxiv_2020.dta", clear

********************************************
*Table 1 
*Unweighted.
*Analytical sample by study wave
********************************************8

preserve
keep if inrange(memory0,0,20)     /* Analytical sample at Wave 1 */
tabstat memory0 PSall0 NSall0 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

preserve
keep if inrange(memory1,0,20)   /* Analytical sample at Wave 2 */
tabstat memory1 PSall1 NSall1 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

preserve
keep if inrange(memory2,0,20) /* Analytical sample at Wave 3 */
tabstat memory2 PSall2 NSall2 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

preserve
keep if inrange(memory3,0,20) /* Analytical sample at Wave 4 */
tabstat memory3 PSall3 NSall3 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

preserve
keep if inrange(memory4,0,20) /* Analytical sample at Wave 5 */
tabstat memory4 PSall4 NSall4 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

preserve
keep if inrange(memory5,0,20) /* Analytical sample at Wave 6 */
tabstat memory5 PSall5 NSall5 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

preserve
keep if inrange(memory6,0,20) /* Analytical sample at Wave 7 */
tabstat memory6 PSall6 NSall6 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

preserve
keep if inrange(memory7,0,20) /* Analytical sample at Wave 8 */
tabstat memory7 PSall7 NSall7 age1, stat(n mean sd) format(%9.1f)  columns(statistics) /* time-varying */
tab1 indsex topqual wealthq1 smoke1 drink1 actlevel1 SPart1 CESD1 ADL1 
restore

keep idauniq indsex memory* w1wgt CESD1 ADL1 iADL1 wealthq1 topqual ///
PSall* NSall* age1 agebl_65 agesq wave* numwaves w8w1lwgt ///
smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 

*Reshape data.
reshape long memory PSall NSall, i(idauniq) j(occasion)
generate occasionsq = occasion*occasion
*histogram memory,by(occasion)       /* Normal distributions */

*******************************************
*Baseline model (Supplementary Table S3).
*******************************************

mixed memory c.occasion c.occasionsq c.agebl_65 c.agesq ///
c.occasion#c.agebl_65 c.occasion#c.agesq ///
|| idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)
gen asample=e(sample)
keep if asample==1     
drop asample

*Number of prior word-recall assessments.
by idauniq, sort: generate ptests=_n

*Subtract by 1.
replace ptests = ptests-1

*Reference categories.
replace smoke1=0 if idauniq==106217

*Variables to impute*.

mi set mlong
mi misstable summarize PSall NSall topqual wealthq1 CESD1 drink1 actlevel1 SPart1 ADL1
mi reshape wide memory PSall NSall occasionsq ptests, i(idauniq) j(occasion)

*Variables to impute.
mi register imputed topqual wealthq1 CESD1 drink1 actlevel1 SPart1  ///
PSall0 PSall1 PSall2 PSall3 PSall4 PSall5 PSall6 PSall7 ///
NSall0 NSall1 NSall2 NSall3 NSall4 NSall5 NSall6 NSall7 

mi impute chained ///
(pmm,knn(2)) PSall0  ///
(pmm,knn(2) include(PSall0)) PSall1  ///
(pmm,knn(2) include(PSall0 PSall1)) PSall2 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2)) PSall3 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3)) PSall4 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3 PSall4)) PSall5 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3 PSall4 PSall5)) PSall6 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3 PSall4 PSall5 PSall6)) PSall7 ///
(pmm,knn(2)) NSall0  ///
(pmm,knn(2) include(NSall0)) NSall1  ///
(pmm,knn(2) include(NSall0 NSall1)) NSall2 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2)) NSall3 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3)) NSall4 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3 NSall4)) NSall5 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3 NSall4 NSall5)) NSall6 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3 NSall4 NSall5 NSall6)) NSall7 ///
(mlogit) topqual wealthq1 ///
(logit,omit(agebl_65)) actlevel1 SPart1 CESD1 drink1 = w1wgt indsex agebl_65 smoke1 ADL1 iADL1 memory0 i.couple ProblemsW1 DiagnosedW1 ///
,add(10) rseed (06599023) force augment orderasis noimputed 

*Data in wide form.
mi xeq: egen PSmean=rowmean(PSall0 PSall1 PSall2 PSall3 PSall4 PSall5 PSall6 PSall7)
mi xeq: egen NSmean=rowmean(NSall0 NSall1 NSall2 NSall3 NSall4 NSall5 NSall6 NSall7)
mi xeq: egen PSgrand = mean(PSmean)
mi xeq: egen NSgrand = mean(NSmean)

*Centre person-mean variables.
mi xeq: gen PSallBP = PSmean-PSgrand
mi xeq: gen NSallBP = NSmean-NSgrand

*within-person variables
mi xeq: gen PSallWP0 = (PSall0 - PSmean)
mi xeq: gen PSallWP1 = (PSall1 - PSmean)
mi xeq: gen PSallWP2 = (PSall2 - PSmean)
mi xeq: gen PSallWP3 = (PSall3 - PSmean)
mi xeq: gen PSallWP4 = (PSall4 - PSmean)
mi xeq: gen PSallWP5 = (PSall5 - PSmean)
mi xeq: gen PSallWP6 = (PSall6 - PSmean)
mi xeq: gen PSallWP7 = (PSall7 - PSmean)
mi xeq: gen NSallWP0 = (NSall0 - NSmean)
mi xeq: gen NSallWP1 = (NSall1 - NSmean)
mi xeq: gen NSallWP2 = (NSall2 - NSmean)
mi xeq: gen NSallWP3 = (NSall3 - NSmean)
mi xeq: gen NSallWP4 = (NSall4 - NSmean)
mi xeq: gen NSallWP5 = (NSall5 - NSmean)
mi xeq: gen NSallWP6 = (NSall6 - NSmean)
mi xeq: gen NSallWP7 = (NSall7 - NSmean)

*Time-varying variables (back to long form).

mi reshape long memory PSallWP NSallWP occasionsq ptests,i(idauniq) j(occasion)   

********************************
*Table 2
*Full model in Table S4
********************************

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
i.indsex c.occasion#i.indsex ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq   ///
i.topqual  c.occasion#i.topqual  ///
i.wealthq1 c.occasion#i.wealthq1  ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel c.occasion#i.actlevel ///
i.SPart1 c.occasion#i.SPart1 ///
i.CESD1 c.occasion#i.CESD1 ///
i.ADL1 c.occasion#i.ADL1 ///
c.PSallBP c.occasion#c.PSallBP c.PSallWP c.occasion#c.PSallWP ///
c.NSallBP c.occasion#c.NSallBP c.NSallWP c.occasion#c.NSallWP /// 
|| idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)


*************************************
** Spouse/partner 
************************************

clear
use "N:\Temp\AnalysisFile_medRxiv_2020.dta", clear
replace smoke1=0 if idauniq==106217

keep idauniq indsex memory* w1wgt CESD1 CESD1 ADL1 iADL1 wealthq1 topqual ///
PS_Spouse* NS_Spouse* spouse* age1 agebl_65 agesq wave* numwaves w8w1lwgt ///
smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 

*Reshape data.
reshape long memory PS_Spouse NS_Spouse spouse, i(idauniq) j(occasion)
generate occasionsq = occasion*occasion

mixed memory c.occasion || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)
gen asample=e(sample)
keep if asample==1     
drop asample

*Create test variable here.
by idauniq, sort: generate ptests=_n

*Subtract by 1.
replace ptests = ptests-1

*Variables to impute*.
mi set mlong
mi misstable summarize PS_Spouse NS_Spouse spouse topqual wealthq1 CESD1 drink1 actlevel1 SPart1 
mi reshape wide memory PS_Spouse NS_Spouse spouse occasionsq ptests, i(idauniq) j(occasion)

*Variables to impute.
mi register imputed topqual wealthq1 CESD1 drink1 actlevel1 SPart1  ///
PS_Spouse0 PS_Spouse1 PS_Spouse2 PS_Spouse3 PS_Spouse4 PS_Spouse5 PS_Spouse6 PS_Spouse7 ///
NS_Spouse0 NS_Spouse1 NS_Spouse2 NS_Spouse3 NS_Spouse4 NS_Spouse5 NS_Spouse6 NS_Spouse7 ///
spouse0 spouse1 spouse2 spouse3 spouse4 spouse5 spouse6 spouse7

mi impute chained ///
(logit) spouse0 ///
(pmm, knn(2) cond(if spouse0==1)) PS_Spouse0 ///
(logit,include(spouse0)) spouse1 ///
(pmm, knn(2) include(PS_Spouse0) cond(if spouse1==1)) PS_Spouse1 ///
(logit,include(spouse0 spouse1)) spouse2 ///
(pmm, knn(2) include(PS_Spouse0 PS_Spouse1) cond(if spouse2==1)) PS_Spouse2 ///
(logit,include(spouse0 spouse1 spouse2)) spouse3 ///
(pmm, knn(2) include(PS_Spouse0 PS_Spouse1 PS_Spouse2) cond(if spouse3==1)) PS_Spouse3 ///
(logit,include(spouse0 spouse1 spouse2 spouse3)) spouse4 ///
(pmm, knn(2) include(PS_Spouse0 PS_Spouse1 PS_Spouse2 PS_Spouse3) cond(if spouse4==1)) PS_Spouse4 ///
(logit,include(spouse0 spouse1 spouse2 spouse3 spouse4)) spouse5 ///
(pmm, knn(2) include(PS_Spouse0 PS_Spouse1 PS_Spouse2 PS_Spouse3 PS_Spouse4) cond(if spouse5==1)) PS_Spouse5 ///
(logit,include(spouse0 spouse1 spouse2 spouse3 spouse4 spouse5)) spouse6 ///
(pmm, knn(2) include(PS_Spouse0 PS_Spouse1 PS_Spouse2 PS_Spouse3 PS_Spouse4 PS_Spouse5) cond(if spouse6==1)) PS_Spouse6 ///
(logit,include(spouse0 spouse1 spouse2 spouse3 spouse4 spouse5 spouse6)) spouse7 ///
(pmm, knn(2) include(PS_Spouse0 PS_Spouse1 PS_Spouse2 PS_Spouse3 PS_Spouse4 PS_Spouse5 PS_Spouse6) cond(if spouse7==1)) PS_Spouse7 ///
(pmm, knn(2) cond(if spouse0==1)) NS_Spouse0 ///
(pmm, knn(2) include(NS_Spouse0) cond(if spouse1==1)) NS_Spouse1 ///
(pmm, knn(2) include(NS_Spouse0 NS_Spouse1) cond(if spouse2==1)) NS_Spouse2 ///
(pmm, knn(2) include(NS_Spouse0 NS_Spouse1 NS_Spouse2) cond(if spouse3==1)) NS_Spouse3 ///
(pmm, knn(2) include(NS_Spouse0 NS_Spouse1 NS_Spouse2 NS_Spouse3) cond(if spouse4==1)) NS_Spouse4 ///
(pmm, knn(2) include(NS_Spouse0 NS_Spouse1 NS_Spouse2 NS_Spouse3 NS_Spouse4) cond(if spouse5==1)) NS_Spouse5 ///
(pmm, knn(2) include(NS_Spouse0 NS_Spouse1 NS_Spouse2 NS_Spouse3 NS_Spouse4 NS_Spouse5) cond(if spouse6==1)) NS_Spouse6 ///
(pmm, knn(2) include(NS_Spouse0 NS_Spouse1 NS_Spouse2 NS_Spouse3 NS_Spouse4 NS_Spouse5 NS_Spouse6) cond(if spouse7==1)) NS_Spouse7 ///
(mlogit) topqual wealthq1  ///
(logit,omit(agebl_65)) actlevel1 SPart1 CESD1 drink1 = w1wgt indsex agebl_65 smoke1 ADL1 iADL1 memory0 i.couple ProblemsW1 DiagnosedW1 ///
,add(10) rseed (01879004) force augment orderasis noimputed 

*------------------.
*Data in wide form.
*------------------.
mi xeq: egen PSmean=rowmean(PS_Spouse0 PS_Spouse1 PS_Spouse2 PS_Spouse3 PS_Spouse4 PS_Spouse5 PS_Spouse6 PS_Spouse7)
mi xeq: egen NSmean=rowmean(NS_Spouse0 NS_Spouse1 NS_Spouse2 NS_Spouse3 NS_Spouse4 NS_Spouse5 NS_Spouse6 NS_Spouse7)
mi xeq: egen PSgrand = mean(PSmean)
mi xeq: egen NSgrand = mean(NSmean)

*Centre person-mean variables.
mi xeq: gen PS_SpouseBP = PSmean-PSgrand
mi xeq: gen NS_SpouseBP = NSmean-NSgrand

mi xeq: gen PS_SpouseWP0 = (PS_Spouse0 - PSmean)
mi xeq: gen PS_SpouseWP1 = (PS_Spouse1 - PSmean)
mi xeq: gen PS_SpouseWP2 = (PS_Spouse2 - PSmean)
mi xeq: gen PS_SpouseWP3 = (PS_Spouse3 - PSmean)
mi xeq: gen PS_SpouseWP4 = (PS_Spouse4 - PSmean)
mi xeq: gen PS_SpouseWP5 = (PS_Spouse5 - PSmean)
mi xeq: gen PS_SpouseWP6 = (PS_Spouse6 - PSmean)
mi xeq: gen PS_SpouseWP7 = (PS_Spouse7 - PSmean)
mi xeq: gen NS_SpouseWP0 = (NS_Spouse0 - NSmean)
mi xeq: gen NS_SpouseWP1 = (NS_Spouse1 - NSmean)
mi xeq: gen NS_SpouseWP2 = (NS_Spouse2 - NSmean)
mi xeq: gen NS_SpouseWP3 = (NS_Spouse3 - NSmean)
mi xeq: gen NS_SpouseWP4 = (NS_Spouse4 - NSmean)
mi xeq: gen NS_SpouseWP5 = (NS_Spouse5 - NSmean)
mi xeq: gen NS_SpouseWP6 = (NS_Spouse6 - NSmean)
mi xeq: gen NS_SpouseWP7 = (NS_Spouse7 - NSmean)

*Time-varying variables (back to long form).

mi reshape long memory PS_SpouseWP NS_SpouseWP occasionsq ptests,i(idauniq) j(occasion)   

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq  ///
i.topqual c.occasion#i.topqual  ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel1 c.occasion#i.actlevel  ///
i.SPart1 c.occasion#i.SPart1 ///
i.CESD1 c.occasion#i.CESD1 ///
i.ADL c.occasion#i.ADL ///
c.PS_SpouseBP c.occasion#c.PS_SpouseBP c.PS_SpouseWP c.occasion#c.PS_SpouseWP  ///
c.NS_SpouseBP c.occasion#c.NS_SpouseBP c.NS_SpouseWP c.occasion#c.NS_SpouseWP  /// 
if indsex==1 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq  ///
i.topqual c.occasion#i.topqual  ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel1 c.occasion#i.actlevel  ///
i.SPart1 c.occasion#i.SPart1 ///
i.CESD1 c.occasion#i.CESD1 ///
i.ADL c.occasion#i.ADL ///
c.PS_SpouseBP c.occasion#c.PS_SpouseBP c.PS_SpouseWP c.occasion#c.PS_SpouseWP  ///
c.NS_SpouseBP c.occasion#c.NS_SpouseBP c.NS_SpouseWP c.occasion#c.NS_SpouseWP /// 
if indsex==2 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)


*************************************
** Children
************************************

clear
use "N:\Temp\AnalysisFile_medRxiv_2020.dta", clear
keep idauniq indsex memory* w1wgt CESD1 CESD1 ADL1 iADL1 wealthq1 topqual ///
PS_Child* NS_Child* child* age1 agebl_65 agesq wave* numwaves w8w1lwgt ///
smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 

*Reshape data.
reshape long memory PS_Child NS_Child child, i(idauniq) j(occasion)
generate occasionsq = occasion*occasion
mixed memory c.occasion || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)
gen asample=e(sample)
keep if asample==1     
drop asample

* create test variable here.
by idauniq, sort: generate ptests=_n

* subtract by 1.
replace ptests = ptests-1

*Variables to impute*.
mi set mlong
mi misstable summarize PS_Child NS_Child child topqual wealthq1 CESD1 drink1 actlevel1 SPart1 
mi reshape wide memory PS_Child NS_Child child occasionsq ptests, i(idauniq) j(occasion)

*Variables to impute.
mi register imputed topqual wealthq1 CESD1 drink1 actlevel1 SPart1  ///
PS_Child0 PS_Child1 PS_Child2 PS_Child3 PS_Child4 PS_Child5 PS_Child6 PS_Child7 ///
NS_Child0 NS_Child1 NS_Child2 NS_Child3 NS_Child4 NS_Child5 NS_Child6 NS_Child7 ///
child0 child1 child2 child3 child4 child5 child6 child7

mi impute chained ///
(logit) child0 ///
(pmm, knn(2) cond(if child0==1)) PS_Child0 ///
(logit,include(child0)) child1 ///
(pmm, knn(2) include(PS_Child0) cond(if child1==1)) PS_Child1 ///
(logit,include(child0 child1)) child2 ///
(pmm, knn(2) include(PS_Child0 PS_Child1) cond(if child2==1)) PS_Child2 ///
(logit,include(child0 child1 child2)) child3 ///
(pmm, knn(2) include(PS_Child0 PS_Child1 PS_Child2) cond(if child3==1)) PS_Child3 ///
(logit,include(child0 child1 child2 child3)) child4 ///
(pmm, knn(2) include(PS_Child0 PS_Child1 PS_Child2 PS_Child3) cond(if child4==1)) PS_Child4 ///
(logit,include(child0 child1 child2 child3 child4)) child5 ///
(pmm, knn(2) include(PS_Child0 PS_Child1 PS_Child2 PS_Child3 PS_Child4) cond(if child5==1)) PS_Child5 ///
(logit,include(child0 child1 child2 child3 child4 child5)) child6 ///
(pmm, knn(2) include(PS_Child0 PS_Child1 PS_Child2 PS_Child3 PS_Child4 PS_Child5) cond(if child6==1)) PS_Child6 ///
(logit,include(child0 child1 child2 child3 child4 child5 child6)) child7 ///
(pmm, knn(2) include(PS_Child0 PS_Child1 PS_Child2 PS_Child3 PS_Child4 PS_Child5 PS_Child6) cond(if child7==1)) PS_Child7 ///
(pmm, knn(2) cond(if child0==1)) NS_Child0 ///
(pmm, knn(2) include(NS_Child0) cond(if child1==1)) NS_Child1 ///
(pmm, knn(2) include(NS_Child0 NS_Child1) cond(if child2==1)) NS_Child2 ///
(pmm, knn(2) include(NS_Child0 NS_Child1 NS_Child2) cond(if child3==1)) NS_Child3 ///
(pmm, knn(2) include(NS_Child0 NS_Child1 NS_Child2 NS_Child3) cond(if child4==1)) NS_Child4 ///
(pmm, knn(2) include(NS_Child0 NS_Child1 NS_Child2 NS_Child3 NS_Child4) cond(if child5==1)) NS_Child5 ///
(pmm, knn(2) include(NS_Child0 NS_Child1 NS_Child2 NS_Child3 NS_Child4 NS_Child5) cond(if child6==1)) NS_Child6 ///
(pmm, knn(2) include(NS_Child0 NS_Child1 NS_Child2 NS_Child3 NS_Child4 NS_Child5 NS_Child6) cond(if child7==1)) NS_Child7 ///
(mlogit) topqual wealthq1 ///
(logit,omit(agebl_65)) actlevel1 SPart1 CESD1 drink1 = w1wgt indsex agebl_65 smoke1 ADL1 iADL1 memory0 i.couple ProblemsW1 DiagnosedW1 ///
,add(10) rseed (0094278) force augment orderasis noimputed 

*Data in wide form.
mi xeq: egen PSmean=rowmean(PS_Child0 PS_Child1 PS_Child2 PS_Child3 PS_Child4 PS_Child5 PS_Child6 PS_Child7)
mi xeq: egen NSmean=rowmean(NS_Child0 NS_Child1 NS_Child2 NS_Child3 NS_Child4 NS_Child5 NS_Child6 NS_Child7)
mi xeq: egen PSgrand = mean(PSmean)
mi xeq: egen NSgrand = mean(NSmean)

*Centre person-mean variables.
mi xeq: gen PS_ChildBP = PSmean-PSgrand
mi xeq: gen NS_ChildBP = NSmean-NSgrand

mi xeq: gen PS_ChildWP0 = (PS_Child0 - PSmean)
mi xeq: gen PS_ChildWP1 = (PS_Child1 - PSmean)
mi xeq: gen PS_ChildWP2 = (PS_Child2 - PSmean)
mi xeq: gen PS_ChildWP3 = (PS_Child3 - PSmean)
mi xeq: gen PS_ChildWP4 = (PS_Child4 - PSmean)
mi xeq: gen PS_ChildWP5 = (PS_Child5 - PSmean)
mi xeq: gen PS_ChildWP6 = (PS_Child6 - PSmean)
mi xeq: gen PS_ChildWP7 = (PS_Child7 - PSmean)
mi xeq: gen NS_ChildWP0 = (NS_Child0 - NSmean)
mi xeq: gen NS_ChildWP1 = (NS_Child1 - NSmean)
mi xeq: gen NS_ChildWP2 = (NS_Child2 - NSmean)
mi xeq: gen NS_ChildWP3 = (NS_Child3 - NSmean)
mi xeq: gen NS_ChildWP4 = (NS_Child4 - NSmean)
mi xeq: gen NS_ChildWP5 = (NS_Child5 - NSmean)
mi xeq: gen NS_ChildWP6 = (NS_Child6 - NSmean)
mi xeq: gen NS_ChildWP7 = (NS_Child7 - NSmean)

*Time-varying variables (back to long form).
mi reshape long memory PS_ChildWP NS_ChildWP occasionsq ptests,i(idauniq) j(occasion)   

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq ///
i.topqual c.occasion#i.topqual ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel1 c.occasion#i.actlevel ///
i.SPart1 c.occasion#i.SPart1 ///
i.ADL1 c.occasion#i.ADL ///
i.CESD1 c.occasion#i.CESD1 ///
c.PS_ChildBP c.occasion#c.PS_ChildBP c.PS_ChildWP c.occasion#c.PS_ChildWP   ///
c.NS_ChildBP c.occasion#c.NS_ChildBP c.NS_ChildWP c.occasion#c.NS_ChildWP  /// 
if indsex==1 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq  ///
i.topqual c.occasion#i.topqual ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel1 c.occasion#i.actlevel ///
i.SPart1 c.occasion#i.SPart1 ///
i.ADL1 c.occasion#i.ADL ///
i.CESD1 c.occasion#i.CESD1 ///
c.PS_ChildBP c.occasion#c.PS_ChildBP c.PS_ChildWP c.occasion#c.PS_ChildWP  ///
c.NS_ChildBP c.occasion#c.NS_ChildBP c.NS_ChildWP c.occasion#c.NS_ChildWP  /// 
if indsex==2 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)


*************************************
** Family
************************************

use "N:\Temp\AnalysisFile_medRxiv_2020.dta", clear
keep idauniq indsex memory* w1wgt CESD1 CESD1 ADL1 iADL1 wealthq1 topqual ///
PS_Family* NS_Family* family* age1 agebl_65 agesq wave* numwaves w8w1lwgt ///
smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 

*Reshape data.
reshape long memory PS_Family NS_Family family, i(idauniq) j(occasion)
gen occasionsq = occasion*occasion
mixed memory c.occasion || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)
gen asample=e(sample)
keep if asample==1     /* N=52,338 among N=10,837 */
drop asample

*Create test variable here.
by idauniq, sort: generate ptests=_n

*Subtract by 1.
replace ptests = ptests-1

*Variables to impute*.
mi set mlong
mi misstable summarize PS_Family NS_Family family topqual wealthq1 CESD1 drink1 actlevel1 SPart1 
mi reshape wide memory PS_Family NS_Family family occasionsq ptests, i(idauniq) j(occasion)

*Variables to impute.
mi register imputed topqual wealthq1 CESD1 drink1 actlevel1 SPart1  ///
PS_Family0 PS_Family1 PS_Family2 PS_Family3 PS_Family4 PS_Family5 PS_Family6 PS_Family7 ///
NS_Family0 NS_Family1 NS_Family2 NS_Family3 NS_Family4 NS_Family5 NS_Family6 NS_Family7 ///
family0 family1 family2 family3 family4 family5 family6 family7

mi impute chained ///
(logit) family0 ///
(pmm, knn(2) cond(if family0==1)) PS_Family0 ///
(logit,include(family0)) family1 ///
(pmm, knn(2) include(PS_Family0) cond(if family1==1)) PS_Family1 ///
(logit,include(family0 family1)) family2 ///
(pmm, knn(2) include(PS_Family0 PS_Family1) cond(if family2==1)) PS_Family2 ///
(logit,include(family0 family1 family2)) family3 ///
(pmm, knn(2) include(PS_Family0 PS_Family1 PS_Family2) cond(if family3==1)) PS_Family3 ///
(logit,include(family0 family1 family2 family3)) family4 ///
(pmm, knn(2) include(PS_Family0 PS_Family1 PS_Family2 PS_Family3) cond(if family4==1)) PS_Family4 ///
(logit,include(family0 family1 family2 family3 family4)) family5 ///
(pmm, knn(2) include(PS_Family0 PS_Family1 PS_Family2 PS_Family3 PS_Family4) cond(if family5==1)) PS_Family5 ///
(logit,include(family0 family1 family2 family3 family4 family5)) family6 ///
(pmm, knn(2) include(PS_Family0 PS_Family1 PS_Family2 PS_Family3 PS_Family4 PS_Family5) cond(if family6==1)) PS_Family6 ///
(logit,include(family0 family1 family2 family3 family4 family5 family6)) family7 ///
(pmm, knn(2) include(PS_Family0 PS_Family1 PS_Family2 PS_Family3 PS_Family4 PS_Family5 PS_Family6) cond(if family7==1)) PS_Family7 ///
(pmm, knn(2) cond(if family0==1)) NS_Family0 ///
(pmm, knn(2) include(NS_Family0) cond(if family1==1)) NS_Family1 ///
(pmm, knn(2) include(NS_Family0 NS_Family1) cond(if family2==1)) NS_Family2 ///
(pmm, knn(2) include(NS_Family0 NS_Family1 NS_Family2) cond(if family3==1)) NS_Family3 ///
(pmm, knn(2) include(NS_Family0 NS_Family1 NS_Family2 NS_Family3) cond(if family4==1)) NS_Family4 ///
(pmm, knn(2) include(NS_Family0 NS_Family1 NS_Family2 NS_Family3 NS_Family4) cond(if family5==1)) NS_Family5 ///
(pmm, knn(2) include(NS_Family0 NS_Family1 NS_Family2 NS_Family3 NS_Family4 NS_Family5) cond(if family6==1)) NS_Family6 ///
(pmm, knn(2) include(NS_Family0 NS_Family1 NS_Family2 NS_Family3 NS_Family4 NS_Family5 NS_Family6) cond(if family7==1)) NS_Family7 ///
(mlogit) topqual wealthq1 ///
(logit,omit(agebl_65)) actlevel1 SPart1 CESD1 drink1 = w1wgt indsex agebl_65 smoke1 ADL1 iADL1 memory0 i.couple ProblemsW1 DiagnosedW1 ///
,add(10) rseed (04129988) force augment orderasis noimputed 

*Data in wide form.
mi xeq: egen PSmean=rowmean(PS_Family0 PS_Family1 PS_Family2 PS_Family3 PS_Family4 PS_Family5 PS_Family6 PS_Family7)
mi xeq: egen NSmean=rowmean(NS_Family0 NS_Family1 NS_Family2 NS_Family3 NS_Family4 NS_Family5 NS_Family6 NS_Family7)
mi xeq: egen PSgrand = mean(PSmean)
mi xeq: egen NSgrand = mean(NSmean)

*Centre person-mean variables.
mi xeq: gen PS_FamilyBP = PSmean-PSgrand
mi xeq: gen NS_FamilyBP = NSmean-NSgrand

mi xeq: gen PS_FamilyWP0 = (PS_Family0 - PSmean)
mi xeq: gen PS_FamilyWP1 = (PS_Family1 - PSmean)
mi xeq: gen PS_FamilyWP2 = (PS_Family2 - PSmean)
mi xeq: gen PS_FamilyWP3 = (PS_Family3 - PSmean)
mi xeq: gen PS_FamilyWP4 = (PS_Family4 - PSmean)
mi xeq: gen PS_FamilyWP5 = (PS_Family5 - PSmean)
mi xeq: gen PS_FamilyWP6 = (PS_Family6 - PSmean)
mi xeq: gen PS_FamilyWP7 = (PS_Family7 - PSmean)
mi xeq: gen NS_FamilyWP0 = (NS_Family0 - NSmean)
mi xeq: gen NS_FamilyWP1 = (NS_Family1 - NSmean)
mi xeq: gen NS_FamilyWP2 = (NS_Family2 - NSmean)
mi xeq: gen NS_FamilyWP3 = (NS_Family3 - NSmean)
mi xeq: gen NS_FamilyWP4 = (NS_Family4 - NSmean)
mi xeq: gen NS_FamilyWP5 = (NS_Family5 - NSmean)
mi xeq: gen NS_FamilyWP6 = (NS_Family6 - NSmean)
mi xeq: gen NS_FamilyWP7 = (NS_Family7 - NSmean)

*Time-varying variables (back to long form).
mi reshape long memory PS_FamilyWP NS_FamilyWP occasionsq ptests,i(idauniq) j(occasion)   

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq  ///
i.topqual c.occasion#i.topqual ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel1 c.occasion#i.actlevel1 /// 
i.SPart1 c.occasion#i.SPart1 ///
i.ADL1 c.occasion#i.ADL ///
i.CESD1 c.occasion#i.CESD1 ///
c.PS_FamilyBP c.occasion#c.PS_FamilyBP c.PS_FamilyWP c.occasion#c.PS_FamilyWP   ///
c.NS_FamilyBP c.occasion#c.NS_FamilyBP c.NS_FamilyWP c.occasion#c.NS_FamilyWP  /// 
if indsex==1 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq  ///
i.topqual c.occasion#i.topqual ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel1 c.occasion#i.actlevel1 ///
i.SPart1 c.occasion#i.SPart1 ///
i.ADL1 c.occasion#i.ADL ///
i.CESD1 c.occasion#i.CESD1 ///
c.PS_FamilyBP c.occasion#c.PS_FamilyBP c.PS_FamilyWP c.occasion#c.PS_FamilyWP   ///
c.NS_FamilyBP c.occasion#c.NS_FamilyBP c.NS_FamilyWP c.occasion#c.NS_FamilyWP  /// 
if indsex==2 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)

*************************************
** Friends
************************************

use "N:\Temp\AnalysisFile_medRxiv_2020.dta", clear
keep idauniq indsex memory* w1wgt CESD1 ADL1 iADL1 wealthq1 topqual ///
PS_Friend* NS_Friend* friend* age1 agebl_65 agesq wave* numwaves w8w1lwgt ///
smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 

*Reshape data.
reshape long memory PS_Friend NS_Friend friend, i(idauniq) j(occasion)
gen occasionsq = occasion*occasion

mixed memory c.occasion || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)
gen asample=e(sample)
keep if asample==1     /* N=52,338 among N=10,837 */
drop asample

* create test variable here.
by idauniq, sort: generate ptests=_n

* subtract by 1.
replace ptests = ptests-1

*Variables to impute*.
mi set mlong
mi misstable summarize PS_Friend NS_Friend friend topqual wealthq1 CESD1 drink1 actlevel1 SPart1 
mi reshape wide memory PS_Friend NS_Friend friend occasionsq ptests, i(idauniq) j(occasion)

*Variables to impute.
mi register imputed topqual wealthq1 CESD1 drink1 actlevel1 SPart1  ///
PS_Friend0 PS_Friend1 PS_Friend2 PS_Friend3 PS_Friend4 PS_Friend5 PS_Friend6 PS_Friend7 ///
NS_Friend0 NS_Friend1 NS_Friend2 NS_Friend3 NS_Friend4 NS_Friend5 NS_Friend6 NS_Friend7 ///
friend0 friend1 friend2 friend3 friend4 friend5 friend6 friend7

mi impute chained ///
(logit) friend0 ///
(pmm, knn(2) cond(if friend0==1)) PS_Friend0 ///
(logit,include(friend0)) friend1 ///
(pmm, knn(2) include(PS_Friend0) cond(if friend1==1)) PS_Friend1 ///
(logit,include(friend0 friend1)) friend2 ///
(pmm, knn(2) include(PS_Friend0 PS_Friend1) cond(if friend2==1)) PS_Friend2 ///
(logit,include(friend0 friend1 friend2)) friend3 ///
(pmm, knn(2) include(PS_Friend0 PS_Friend1 PS_Friend2) cond(if friend3==1)) PS_Friend3 ///
(logit,include(friend0 friend1 friend2 friend3)) friend4 ///
(pmm, knn(2) include(PS_Friend0 PS_Friend1 PS_Friend2 PS_Friend3) cond(if friend4==1)) PS_Friend4 ///
(logit,include(friend0 friend1 friend2 friend3 friend4)) friend5 ///
(pmm, knn(2) include(PS_Friend0 PS_Friend1 PS_Friend2 PS_Friend3 PS_Friend4) cond(if friend5==1)) PS_Friend5 ///
(logit,include(friend0 friend1 friend2 friend3 friend4 friend5)) friend6 ///
(pmm, knn(2) include(PS_Friend0 PS_Friend1 PS_Friend2 PS_Friend3 PS_Friend4 PS_Friend5) cond(if friend6==1)) PS_Friend6 ///
(logit,include(friend0 friend1 friend2 friend3 friend4 friend5 friend6)) friend7 ///
(pmm, knn(2) include(PS_Friend0 PS_Friend1 PS_Friend2 PS_Friend3 PS_Friend4 PS_Friend5 PS_Friend6) cond(if friend7==1)) PS_Friend7 ///
(pmm, knn(2) cond(if friend0==1)) NS_Friend0 ///
(pmm, knn(2) include(NS_Friend0) cond(if friend1==1)) NS_Friend1 ///
(pmm, knn(2) include(NS_Friend0 NS_Friend1) cond(if friend2==1)) NS_Friend2 ///
(pmm, knn(2) include(NS_Friend0 NS_Friend1 NS_Friend2) cond(if friend3==1)) NS_Friend3 ///
(pmm, knn(2) include(NS_Friend0 NS_Friend1 NS_Friend2 NS_Friend3) cond(if friend4==1)) NS_Friend4 ///
(pmm, knn(2) include(NS_Friend0 NS_Friend1 NS_Friend2 NS_Friend3 NS_Friend4) cond(if friend5==1)) NS_Friend5 ///
(pmm, knn(2) include(NS_Friend0 NS_Friend1 NS_Friend2 NS_Friend3 NS_Friend4 NS_Friend5) cond(if friend6==1)) NS_Friend6 ///
(pmm, knn(2) include(NS_Friend0 NS_Friend1 NS_Friend2 NS_Friend3 NS_Friend4 NS_Friend5 NS_Friend6) cond(if friend7==1)) NS_Friend7 ///
(mlogit) topqual wealthq1 ///
(logit,omit(agebl_65)) actlevel1 SPart1 CESD1 drink1 = w1wgt indsex agebl_65 smoke1 ADL1 iADL1 memory0 i.couple ProblemsW1 DiagnosedW1 ///
,add(10) rseed (019172894) force augment orderasis noimputed 

*Data in wide form.
mi xeq: egen PSmean=rowmean(PS_Friend0 PS_Friend1 PS_Friend2 PS_Friend3 PS_Friend4 PS_Friend5 PS_Friend6 PS_Friend7)
mi xeq: egen NSmean=rowmean(NS_Friend0 NS_Friend1 NS_Friend2 NS_Friend3 NS_Friend4 NS_Friend5 NS_Friend6 NS_Friend7)
mi xeq: egen PSgrand = mean(PSmean)
mi xeq: egen NSgrand = mean(NSmean)

*Centre person-mean variables.
mi xeq: gen PS_FriendBP = PSmean-PSgrand
mi xeq: gen NS_FriendBP = NSmean-NSgrand

mi xeq: gen PS_FriendWP0 = (PS_Friend0 - PSmean)
mi xeq: gen PS_FriendWP1 = (PS_Friend1 - PSmean)
mi xeq: gen PS_FriendWP2 = (PS_Friend2 - PSmean)
mi xeq: gen PS_FriendWP3 = (PS_Friend3 - PSmean)
mi xeq: gen PS_FriendWP4 = (PS_Friend4 - PSmean)
mi xeq: gen PS_FriendWP5 = (PS_Friend5 - PSmean)
mi xeq: gen PS_FriendWP6 = (PS_Friend6 - PSmean)
mi xeq: gen PS_FriendWP7 = (PS_Friend7 - PSmean)
mi xeq: gen NS_FriendWP0 = (NS_Friend0 - NSmean)
mi xeq: gen NS_FriendWP1 = (NS_Friend1 - NSmean)
mi xeq: gen NS_FriendWP2 = (NS_Friend2 - NSmean)
mi xeq: gen NS_FriendWP3 = (NS_Friend3 - NSmean)
mi xeq: gen NS_FriendWP4 = (NS_Friend4 - NSmean)
mi xeq: gen NS_FriendWP5 = (NS_Friend5 - NSmean)
mi xeq: gen NS_FriendWP6 = (NS_Friend6 - NSmean)
mi xeq: gen NS_FriendWP7 = (NS_Friend7 - NSmean)

*Time-varying variables (back to long form).

mi reshape long memory PS_FriendWP NS_FriendWP occasionsq ptests,i(idauniq) j(occasion)   

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq  ///
i.topqual c.occasion#i.topqual ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel c.occasion#i.actlevel /// 
i.SPart1 c.occasion#i.SPart1 ///
i.CESD1 c.occasion#i.CESD1 ///
i.ADL1 c.occasion#i.ADL ///
c.PS_FriendBP c.occasion#c.PS_FriendBP c.PS_FriendWP c.occasion#c.PS_FriendWP  ///
c.NS_FriendBP c.occasion#c.NS_FriendBP c.NS_FriendWP c.occasion#c.NS_FriendWP /// 
if indsex==1 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)

mi estimate: mixed memory c.occasion c.occasionsq c.ptests c.agebl_65 c.agesq ///
c.occasion#c.ptests c.occasion#c.agebl_65 c.occasion#c.agesq  ///
i.topqual c.occasion#i.topqual ///
i.wealthq1 c.occasion#i.wealthq1 ///
i.smoke1 c.occasion#i.smoke1 ///
i.drink1 c.occasion#i.drink1 ///
i.actlevel c.occasion#i.actlevel /// 
i.SPart1 c.occasion#i.SPart1 ///
i.CESD1 c.occasion#i.CESD1 ///
i.ADL1 c.occasion#i.ADL ///
c.PS_FriendBP c.occasion#c.PS_FriendBP c.PS_FriendWP c.occasion#c.PS_FriendWP   ///
c.NS_FriendBP c.occasion#c.NS_FriendBP c.NS_FriendWP c.occasion#c.NS_FriendWP  /// 
if indsex==2 || idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)


*****************************************
*Table S6: Completers 
*****************************************

clear
use "N:\Temp\AnalysisFile_medRxiv_2020.dta", clear
replace smoke1=0 if idauniq==106217
keep idauniq indsex memory* w1wgt CESD1 ADL1 iADL1 wealthq1 topqual ///
PSall* NSall* age1 agebl_65 agesq wave* w8w1lwgt ///
smoke1 drink1 actlevel1 SPart1 couple ProblemsW1 DiagnosedW1 
*Reshape data.
reshape long memory PSall NSall, i(idauniq) j(occasion)
generate occasionsq = occasion*occasion

*Baseline model.
mixed memory c.occasion c.occasionsq c.agebl_65 c.agesq ///
c.occasion#c.agebl_65 c.occasion#c.agesq ///
|| idauniq: c.occasion, pweight(w1wgt)  variance ml covariance(un) residuals(independent)
gen asample=e(sample)
keep if asample==1     
drop asample

* create test variable here.
by idauniq, sort: generate ptests=_n

* subtract by 1.
replace ptests = ptests-1

generate monotonic=0
replace monotonic=1 if (occasion==ptests)
keep if monotonic==1

* sum number of observations.
by idauniq, sort: generate records =  _N
keep if records==8
replace w8w1lwgt=1 if w8w1lwgt==.

*Variables to impute*.
mi set mlong
mi misstable summarize PSall NSall topqual wealthq1 CESD1 drink1 actlevel1 SPart1 ADL1
mi reshape wide memory PSall NSall occasionsq ptests, i(idauniq) j(occasion)

*Variables to impute.
mi register imputed topqual wealthq1 CESD1 drink1 actlevel1 SPart1 ///
PSall0 PSall1 PSall2 PSall3 PSall4 PSall5 PSall6 PSall7 ///
NSall0 NSall1 NSall2 NSall3 NSall4 NSall5 NSall6 NSall7 

mi impute chained ///
(pmm,knn(2)) PSall0  ///
(pmm,knn(2) include(PSall0)) PSall1  ///
(pmm,knn(2) include(PSall0 PSall1)) PSall2 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2)) PSall3 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3)) PSall4 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3 PSall4)) PSall5 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3 PSall4 PSall5)) PSall6 ///
(pmm,knn(2) include(PSall0 PSall1 PSall2 PSall3 PSall4 PSall5 PSall6)) PSall7 ///
(pmm,knn(2)) NSall0  ///
(pmm,knn(2) include(NSall0)) NSall1  ///
(pmm,knn(2) include(NSall0 NSall1)) NSall2 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2)) NSall3 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3)) NSall4 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3 NSall4)) NSall5 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3 NSall4 NSall5)) NSall6 ///
(pmm,knn(2) include(NSall0 NSall1 NSall2 NSall3 NSall4 NSall5 NSall6)) NSall7 ///
(mlogit) topqual wealthq1 ///
(logit,omit(agebl_65)) actlevel1 SPart1 CESD1 drink1 = w1wgt w8w1lwgt indsex agebl_65 smoke1 ADL1 iADL1 memory0 i.couple ProblemsW1 DiagnosedW1 ///
,add(10) rseed (11993535) force augment orderasis noimputed 

*Data in wide form.
mi xeq: egen PSmean=rowmean(PSall0 PSall1 PSall2 PSall3 PSall4 PSall5 PSall6 PSall7)
mi xeq: egen NSmean=rowmean(NSall0 NSall1 NSall2 NSall3 NSall4 NSall5 NSall6 NSall7)
mi xeq: egen PSgrand = mean(PSmean)
mi xeq: egen NSgrand = mean(NSmean)

*Centre person-mean variables.
mi xeq: gen PSallBP = PSmean-PSgrand
mi xeq: gen NSallBP = NSmean-NSgrand

mi xeq: gen PSallWP0 = (PSall0 - PSmean)
mi xeq: gen PSallWP1 = (PSall1 - PSmean)
mi xeq: gen PSallWP2 = (PSall2 - PSmean)
mi xeq: gen PSallWP3 = (PSall3 - PSmean)
mi xeq: gen PSallWP4 = (PSall4 - PSmean)
mi xeq: gen PSallWP5 = (PSall5 - PSmean)
mi xeq: gen PSallWP6 = (PSall6 - PSmean)
mi xeq: gen PSallWP7 = (PSall7 - PSmean)
mi xeq: gen NSallWP0 = (NSall0 - NSmean)
mi xeq: gen NSallWP1 = (NSall1 - NSmean)
mi xeq: gen NSallWP2 = (NSall2 - NSmean)
mi xeq: gen NSallWP3 = (NSall3 - NSmean)
mi xeq: gen NSallWP4 = (NSall4 - NSmean)
mi xeq: gen NSallWP5 = (NSall5 - NSmean)
mi xeq: gen NSallWP6 = (NSall6 - NSmean)
mi xeq: gen NSallWP7 = (NSall7 - NSmean)

*Time-varying variables (back to long form).

mi reshape long memory PSallWP NSallWP occasionsq ptests,i(idauniq) j(occasion)  

mi estimate: mixed memory c.occasion c.occasionsq c.agebl_65 c.agesq i.indsex ///
i.topqual i.wealthq1 i.CESD1 i.smoke1 i.drink1 i.actlevel i.SPart1 ///
c.occasion#c.agebl_65 c.occasion#c.agesq c.occasion#i.indsex ///
c.occasion#i.topqual c.occasion#i.wealthq1 c.occasion#i.CESD1 c.occasion#i.smoke1 c.occasion#i.drink1 c.occasion#i.actlevel c.occasion#i.SPart1 ///
i.ADL1 c.occasion#i.ADL1 ///
c.PSallBP c.occasion#c.PSallBP c.PSallWP c.occasion#c.PSallWP ///
c.NSallBP c.occasion#c.NSallBP c.NSallWP c.occasion#c.NSallWP /// 
|| idauniq: c.occasion, pweight(w8w1lwgt) variance ml covariance(un) residuals(independent)





















