// required packages

which estout
which xtserial
which xtcd2

// graph scheme
which scheme-modern.scheme

// export folder
cap mkdir "outputs"

/* -----------------------------------------------------------------------------
   Data preparation
   -------------------------------------------------------------------------- */

// EP elections turnout, Feb 20, 2023
insheet using "data/2022-data-ep-elections.tsv", clear

// coerce VAP turnout to numeric (missing values NA -> .)
destring vap_turnout, force replace

// alternative measure of CV
gen cv2 = cv
replace cv2 = 0 if inlist(iso3c, "BGR", "ITA") | (iso3c == "GRC" & year > 2000)
li iso3c year cv* if cv != cv2 // n = 8 differences

// interaction between first-order elections and time since last election
gen lne_fo_x_ne_months = lne_fo * ne_months

/* -----------------------------------------------------------------------------
   Variable labels
   -------------------------------------------------------------------------- */

la var voter_turnout "Voter turnout (% registered)"
la var vap_turnout "Voter turnout (% voting-age)"
la var ne_count "Number of preceding electoral rounds"
la var ne_count2 "Number of preceding electoral contests"
la var ne_months "Time since last election (months)"
// la var tt_next "Time to NEXT election (months)"
la var lne_fo "First-order preceding election (FOPE)" // parl. or pres.
la var lne_fo_x_ne_months "FOPE x (Time since last election)"
la var concurrent "Concurrent election"
la var lne_turnout "FOPE turnout (%)" // parl. or pres.
la var first_ep "First EP election"
la var cv "Compulsory voting"
la var cv2 "Compulsory voting" // alt. measure

d

/* -----------------------------------------------------------------------------
   Descriptive statistics (Table 1)
   -------------------------------------------------------------------------- */

gl allvars "voter_turnout vap_turnout ne_months ne_count ne_count2 lne_turnout lne_fo concurrent cv"

eststo clear
estpost tabstat $allvars, columns(statistics) statistics(n mean sd min max)
esttab using "outputs/tbl-01-descriptives.rtf", ///, ///
	cells("count Mean(fmt(2)) SD(fmt(2)) Min(fmt(2)) Max(fmt(2))") ///
	lab nomti nonum noobs replace

estpost cor $allvars, mat
esttab using "outputs/tbl-03-correlations.rtf", ///
	unstack not nostar noobs nonote b(2) lab replace

/* -----------------------------------------------------------------------------
   Panel structure
   -------------------------------------------------------------------------- */

cap log using "outputs/tbl-00-panel-structure.log", replace

// group variable
encode iso3c, gen(cty)
sort iso3c year

// time index
by iso3c: gen t = _n

// panel structure
xtset cty year

// 15 distinct EP election years over 41 years
xtdes

// number of observations by panel 
egen cases = count(t), by(iso3c)
tabstat cases if t == 1, s(n mean p50) // mean 6.25, median 6

// Wooldridge autocorrelation test
xtset cty t
xtserial voter_turnout if cases > 2

// nonstationarity (Dicky-Fuller)
// note: won't run when T < 3
xtunitroot fisher voter_turnout if cases > 3, dfuller lags(1)

// cross-sectional dependence
// xtcsd voter_turnout // won't run, panel is too imbalanced
xtcd2 voter_turnout

cap log close

// lagged DV (not used, small T)
// by iso3c: gen voter_turnout_lag = voter_turnout[ _n-1 ]

// done
