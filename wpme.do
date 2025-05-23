set more off
clear all
cls

*Import data

import excel "F:\Laptop\D\University Term 8\Econometircs\Project\Book1.xlsx", sheet("Sheet1") firstrow

*Rename variable

rename Womeninnationalparliaments wp
rename Militaryexpenditureofgener me

*Brief look at data

tsset Year

scatter me wp
graph twoway (scatter me wp) (lfit me wp)
tsline me
tsline wp

*Checking stationarity

ac me
ac wp
pperron me, reg trend
pperron wp, reg nocons

*First difference of variable

ac d.me
ac d.wp
pperron d.me, reg nocons
pperron d.wp, reg

*Primary regression

reg me l.wp
estat dwatson

*Breusch–Godfrey test for the presence of serial correlation

estat bgodfrey, lags(2)
*H0 is not rejected.

*Test whether residuals are normally distributed

predict uhat, residuals
swilk uhat
hist uhat, bin(7)

*Heteroscedasticity test of residuals

estat imtest, white
rvfplot
*Variance is constant.

*Tests for structural breaks(intercept)

tsline me

gen d2011 = 0
replace d2011 = 1 if Year == 2012

gen du2011 = 0
replace du2011 = 1 if Year > 2011

reg me d2011 du2011 Year l.me
display (_b[l.me] - 1)/_se[l.me]
display 11/21
*H0 is not rejected and me is non-stationary.

tsline wp

gen d2018 = 0
replace d2018 = 1 if Year == 2019

gen du2018 = 0
replace du2018 = 1 if Year > 2018

reg wp d2018 du2018 Year l.wp
display (_b[l.wp] - 1)/_se[l.wp]
display 18/21
*H0 is not rejected and wp is non-stationary.

*Tests for structural breaks(trend)

gen dts2011 = cond(Year <= 2012, 0, Year - 2012)
reg me du2011 Year dts2011 l.me l.d.me 

display (_b[l.me] - 1)/_se[l.me]
display 11/21
*H0 is not rejected and me is non-stationary.

gen dts2018 = cond(Year <= 2018, 0, Year - 2012)
reg wp du2018 Year dts2018 l.wp l.d.wp 

display (_b[l.wp] - 1)/_se[l.wp]
display 18/21
*H0 is not rejected and wp is non-stationary.

*Tests for structural breaks(trend and intercept)

gen dt2011 = cond(Year <= 2012, 0, Year - 2001)
reg me du2011 d2011 Year dt2011 l.me

display (_b[l.me] - 1)/_se[l.me]
display 11/21
*H0 is not rejected and me is non-stationary.

gen dt2018 = cond(Year <= 2018, 0, Year - 2001)
reg wp du2018 d2018 Year dt2018 l.wp

display (_b[l.wp] - 1)/_se[l.wp]
display 18/21
*H0 is not rejected and me is non-stationary.

*Co-integration test

*ssc install egranger
egranger me l.wp
egranger l.wp me

*wp and me are not co-integrated.

*ARDL Model

*ssc install ardl
gen lagwp = l.wp
ardl me lagwp, maxlags(3) dots
estat bgodfrey, lags(1/3)
*The Lagrange multiplier test does not provide reason for concern about residual serial correlation.

ardl me lagwp, maxlags(3) ec restricted

estat ectest
*There is no level relationship between variables.

*VAR model

varsoc d.me d.l.wp
varbasic d.me d.l.wp, lags(1/4)
vargranger