/* -----------------------------------------------------------------------------
   (0) Dependencies
   -------------------------------------------------------------------------- */

cap pr drop require
pr de require
	syntax name(id="package name")
	cap which `1'
	if _rc == 111 {
		ssc inst `1'
	}
end

// coefplot
// estout
require coefplot
require estout

// xtcd2 (used pre-estimation)
cap which xtcd2
if _rc == 111 {
	net sj 18-3 st0536
	net install st0536
}

// xtcsd (used post-estimation)
cap which xtcsd
if _rc == 111 {
	net sj 6-4 st0113
	net install st0113
}

// xtistest (used post-estimation)
cap which xtistest
if _rc == 111 {
	net sj 18-1 st0514
	net install st0514
}

// xtserial (used pre-estimation)
cap which xtserial
if _rc == 111 {
	net sj 3-2 st0039
	net install st0039
}

// xttest3 (used post-estimation)
cap which xttest3
if _rc == 111 {
	net sj 4-2 st0004_2
	net install st0004_2
}

// scheme-modern
loc url "https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/"
cap which scheme-modern.scheme
if _rc == 111 {
	net install scheme-modern, from(`url')
}

// done
