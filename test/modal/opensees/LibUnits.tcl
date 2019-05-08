# --------------------------------------------------------------------------------------------------
# LibUnits.tcl -- define system of units
#		Silvia Mazzoni & Frank McKenna, 2006
#
# define UNITS ----------------------------------------------------------------------------
set cm 1.; 							# define basic units -- output units
set kgr 1.; 						# define basic units -- output units
set sec 1.; 						# define basic units -- output units
set m [expr 100.*$cm]; 				# m
set ton [expr 1000.*$kgr]; 			# ton
set kgr_cm2 [expr $kgr/pow($cm,2)];	# kgf/cm2
set ton_m3 [expr $ton/pow($m,3)];	# ton/m3
set ton_ml [expr $ton/$m];			# ton/ml
set cm2 [expr $cm*$cm]; 			# cm^2
set cm4 [expr $cm*$cm*$cm*$cm]; 	# cm^4
set m2 [expr $m*$m]; 				# m^2
set PI [expr 2*asin(1.0)]; 			# define constants
set g [expr 9.8065*$m/pow($sec,2)]; # gravitational acceleration
