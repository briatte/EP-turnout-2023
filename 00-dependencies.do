/* -----------------------------------------------------------------------------
   (0) Dependencies
   -------------------------------------------------------------------------- */

// coefplot
// estout
cap pr drop require
pr de require
	syntax name(id="package name")
	cap which `1'
	if _rc == 111 {
		ssc inst `1'
	}
end

require coefplot
require estout

// xtcd2
cap which xtcd2
if _rc == 111 {
	net sj 18-3 st0536
	net install st0536
}

if _rc == 111 {
}

// xtserial
cap which xtserial
if _rc == 111 {
	net sj 3-2 st0039
	net install st0039
}

// xttest2
// xttest3
cap which xttest2
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
