cd "C:\Users\B059633\Desktop\pisa_2022_absence"
// Indlæs elevdata
	import sas CNT CNTSCHID W_FSTUWT ST034Q01TA ST034Q03TA ST034Q06TA ST062Q01TA  ST062Q02TA ST062Q03TA   ///
		ST005Q01JA /// 
		using "rawdata\CY08MSP_STU_QQQ.sas7bdat",  clear
	compress
	save "tempdata\pisa_2022_elev.dta",replace

	
// Analyse
use "tempdata\pisa_2022_elev.dta",clear
gen absence=inlist( ST062Q01TA,2,3,4) if  ST062Q01TA!=.	
gen lowedu=inlist(ST005Q01JA,3,4,5) if ST005Q01JA!=.

// Prepare data
gen loweduabsence=absence if lowedu==1
gen higheduabsence=absence if lowedu==0

sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT]
sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT] if CNT=="DNK"
sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT] if CNT=="SWE"
sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT] if CNT=="NOR"

collapse (mean) higheduabsence  loweduabsence absence [aweight=W_FSTUWT],by(CNT )
// Delta
gen delta=100*((loweduabsence/higheduabsence)-1)
// Sort 
sort delta
gen count=_n 
labmask count, value(CNT)
drop if delta==.
// Create figure
tw (bar delta count) ///
   , xlab(,valuelabel)

   replace loweduabsence=100*loweduabsence
   replace higheduabsence=100*higheduabsence
   
 gen labdk="Danmark" if CNT=="DNK" 
tw  (scatter  loweduabsence higheduabsence ,msize(tiny) mcolor(black) msymbol(D) mlabgap(relative0p3) ///
				mlabel(CNT) mlabsize(tiny) mlabcolor(black) mlabposition(12)) ///
	(scatter  loweduabsence higheduabsence if CNT=="FIN" ,mcolor(yellow) msymbol(D) ///
				mlabgap(tiny) ///
								mlabel(labdk) mlabsize(normal) mlabcolor(red) mlabposition(12)) ///
	(scatter  loweduabsence higheduabsence if CNT=="SWE" ,mcolor(yellow) msymbol(D) ///
				mlabgap(tiny) ///
								mlabel(labdk) mlabsize(normal) mlabcolor(red) mlabposition(12)) ///
	(scatter  loweduabsence higheduabsence if CNT=="NOR" ,mcolor(blue) msymbol(D) ///
				mlabgap(tiny) ///
				mlabel(labdk) mlabsize(normal) mlabcolor(red) mlabposition(12)) ///
	(scatter  loweduabsence higheduabsence if CNT=="DNK" ,mcolor(red) msymbol(D) ///
				mlabgap(tiny) ///
				mlabel(labdk) mlabsize(normal) mlabcolor(red) mlabposition(12)) ///
	(line high higheduabsence) ///
	,graphregion(color(white)) xlab(0(20)80) ylab(0(20)80) ///
	legend(off) xtitle("Fravær blandt børn af forældre med mere end grundskole (i%)") ///
	ytitle("Fravær blandt børn af forældre med højst grundskole (i%)")
	

	
	
// Selected countries

// Analyse
use "tempdata\pisa_2022_elev.dta",clear
gen absence=inlist( ST062Q01TA,2,3,4) if  ST062Q01TA!=.	
gen lowedu=inlist(ST005Q01JA,3,4,5) if ST005Q01JA!=.

// Prepare data
gen loweduabsence=absence if lowedu==1
gen higheduabsence=absence if lowedu==0

gen country="Sverige" if CNT=="SWE"
replace country="Danmark" if CNT=="DNK"
replace country="Norge" if CNT=="NOR" 
replace  country="Finland" if CNT=="FIN"
replace country="Tyskland" if CNT=="DEU"
replace country="Øvrige" if country==""
sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT]
sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT] if CNT=="DNK"
sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT] if CNT=="SWE"
sum higheduabsence  loweduabsence absence  [aweight=W_FSTUWT] if CNT=="NOR"

collapse (mean) higheduabsence  loweduabsence absence [aweight=W_FSTUWT],by(country )

sort lowedu
gen countlow=_n+0.2 
gen counthigh=_n-0.2
gen count=_n
labmask count,value(country)

replace low=low*100
replace high=high*100
format high low %3.1f
tw (bar low count,barwidth(0.4) fcolor(none) lcolor(none)) ///
	(bar low countlow,barwidth(0.4) fcolor(gs6) lcolor(gs6)) ///
   (bar high counthigh,barwidth(0.4) fcolor(gs11) lcolor(gs11)) ///
   (scatter  high counthigh, msymbol(none) mlabgap(relative0p3) ///
								mlabel(high) mlabsize(small) mlabcolor(gs11) mlabposition(12)) ///
	(scatter  low countlow, msymbol(none) mlabgap(relative0p3) ///
								mlabel(low) mlabsize(small) mlabcolor(gs6) mlabposition(12)) /// 
   ,ylab(0(10)40,angle(horizontal)) xlab(,valuelabel) ///
   legend(order(2 "Højst grundskole" 3 "Mere end grundskole") ///
   pos(11) ring(0) rows(2) region(lcolor(white)))  ///
   graphregion(color(white)) ytitle("Andel i %") title("Udeblevet mindst 1 skoledag de seneste 2 uger, i 2022", color(black))