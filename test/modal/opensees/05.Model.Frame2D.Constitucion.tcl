# --------------------------------------------------------------
# SET UP -------------------------------------------------------
wipe;								# Clear memory of all past model definitions
model BasicBuilder -ndm 2 -ndf 3;	# Define the model builder, ndm=#dimension, ndf=#dofs		http://opensees.berkeley.edu/wiki/index.php/Model_command
set dataDir Data/Constitucion;					# set up name of data directory (can remove this)
file mkdir $dataDir; 				# create data directory
set GMdir "../GMfiles/";			# ground-motion file directory

source LibUnits.tcl;				# define units
source DisplayPlane.tcl;			# procedure for displaying a plane in model
source DisplayModel2D.tcl;			# procedure for displaying 2D perspective of model
set CaseofStudy 2;					# Caso de estudio 0 [original] 1,2,3,4 ver dibujo guía.
# DEFINE GEOMETRY -----------------------------------------------------------------------------------------------------
# define structure-geometry paramters
set LCol [expr 4.*$m];				# column height
set LCol_1f [expr 5.5*$m];			# first floor column height
set LBeam [expr 8.*$m];				# beam length
set NStory 5;						# number of stories above ground level
set NBay 9;							# number of bays

# DEFINE NODAL COORDINATES --------------------------------------------------------------------------------------------
set offset [expr $NBay*$LBeam + 100.]; # Distancia a Marco aledaño.

for {set iStory 1} {$iStory <=[expr $NStory+1]} {incr iStory 1} {
	if {$iStory == 1} {
		# BASE
		set Y [expr 0];
		for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {
			set X [expr ($pier-1)*$LBeam];
			set nodeIDm1 [expr 100+$pier]
			node $nodeIDm1 $X $Y;
			set nodeIDm2 [expr 100+$pier+($NBay+1)]; 				# Marco 2
			node $nodeIDm2 [expr $X+$offset] $Y; 					# Marco 2

		}
	} else {
		set Y [expr ($iStory-2)*$LCol+$LCol_1f];
		for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {
			set X [expr ($pier-1)*$LBeam];
			set nodeIDm1 [expr $iStory*100+$pier]
			node $nodeIDm1 $X $Y;
			set nodeIDm2 [expr $iStory*100+$pier+($NBay+1)]; 		# Marco 2
			node $nodeIDm2 [expr $X+$offset] $Y; 						# Marco 2
			
		}		
	}
}

# Boundary Conditions
for {set pier 1} {$pier <= [expr 2*($NBay+1)]} {incr pier 1} {
	set node [expr 100+$pier]
	fix $node 1 1 1;
}

# Rigid Diaphragm
for {set iStory 2} {$iStory <=[expr $NStory+1]} {incr iStory 1} {
	for {set pier 1} {$pier <= $NBay} {incr pier 1} {
		set node1 [expr $iStory*100+$pier]
		set node2 [expr $iStory*100+$pier+$NBay]
		equalDOF $node1 $node2 1
	}
}

# Plot info
puts "Number of Stories: $NStory Number of bays: $NBay"

# DEFINE SECTIONS -----------------------------------------------------------------------------------------------------

# Define Section tags:
set ColSecTag 1
set BeamSecTag 2

# Section Properties:
set HCol [expr 100*$cm];		# Col height -- // analysis direction
set BCol [expr 100*$cm];		# Col width
set HBeam [expr 100*$cm];	# Beam depth -- perpendicular to bending axis
set BBeam [expr 75*$cm];	# Beam width -- parallel to bending axis

# Material Properties:
set fc 300*$kgr_cm2;							# concrete nominal compressive strength
set Ec [expr (15100*pow($fc,0.5))*$kgr_cm2];	# concrete Young's Modulus
# Column Section Properties:
set AgCol [expr $HCol*$BCol*$cm2];				# rectuangular-Column cross-sectional area
set IzCol [expr (1./12)*$BCol*pow($HCol,3)*$cm4];	# about-local-z Rect-Column gross moment of inertial
# Beam Section Properties:
set AgBeam [expr $HBeam*$BBeam*$cm2];			# rectuangular-Beam cross-sectional area
set IzBeam [expr (1./12)*$BBeam*pow($HBeam,3)*$cm4];	# about-local-z Rect-Beam cracked moment of inertial
# Sections:
section Elastic $ColSecTag $Ec $AgCol $IzCol 
section Elastic $BeamSecTag $Ec $AgBeam $IzBeam 

# DEFINE ELEMENTS -----------------------------------------------------------------------------------------------------
# set up geometric transformations of element
#   separate columns and beams, in case of P-Delta analysis for columns
set IDColTransf 1; # all columns
set IDBeamTransf 2; # all beams
set ColTransfType Linear ;			# options, Linear PDelta Corotational
set BeamTransfType Linear ;			# options, Linear PDelta Corotational 
geomTransf $ColTransfType $IDColTransf  ; 	# only columns can have PDelta effects (gravity effects)
geomTransf $BeamTransfType $IDBeamTransf

set numIntgrPts 2

# Define Elements

# Hinges
set matID_COL 1
set matID_VIG 2

#Fisurado
uniaxialMaterial Bilin $matID_COL 10593750000. 0.05 0.05 34600000. -34600000. 1000. 1000. 1000. 1000. 1. 1. 1. 1. 0.023 0.023 0.00001 0.00001 0.182 0.182 0.058266 0.058266 1. 1.
uniaxialMaterial Bilin $matID_VIG 3972656250. 0.05 0.05 20600000. -20600000. 1000. 1000. 1000. 1000. 1. 1. 1. 1. 0.02 0.02 0.00001 0.00001 0.2 0.2 0.045185 0.045185 1. 1.
#set MyCol [expr 1500000]
#set MyVig [expr 500000]
#set thCol [expr 0.001]
#set thVig [expr 0.001]
	
#uniaxialMaterial Steel01 $matID_COL $MyCol [expr $MyCol/$thCol] 0.1
#uniaxialMaterial Steel01 $matID_VIG $MyVig [expr $MyVig/$thVig] 0.1	

#section Aggregator $secTag $matTag1 $dof1 $matTag2 $dof2 .
# For COLUMNs:
section Aggregator 3 $matID_COL Mz -section 1
# For BEAMs:
section Aggregator 4 $matID_VIG Mz -section 2


# Columns
set N0col 10000;	# column element numbers
for {set iStory 1} {$iStory <=$NStory} {incr iStory 1} {
	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {
		set elemIDm1 [expr $N0col+$iStory*100+$pier];					
		set nodeIm1 [expr $iStory*100 + $pier];							# Node Master I
		set nodeJm1 [expr ($iStory+1)*100 + $pier];						# Node Master J
		
		set elemIDm2 [expr $N0col+$iStory*100 + $pier + ($NBay+1)];						# Marco 2
		set nodeIm2  [expr $iStory*100        + $pier + ($NBay+1)];		# Node Master I	# Marco 2
		set nodeJm2  [expr ($iStory+1)*100    + $pier + ($NBay+1)];		# Node Master J # Marco 2
		
		set nodeI [expr $nodeIm1];			# Node Slave I (above)
		set nodeJ [expr $nodeJm1];			# Node Slave J (below)	

		set LpI 1
		set LpJ 1
		set secTagI 3
		set secTagJ 3

		element beamWithHinges $elemIDm1 $nodeI $nodeJ $secTagI $LpI $secTagJ $LpJ $Ec $AgCol $IzCol $IDColTransf
		
		set nodeI [expr $nodeIm2];			# Node Slave I (above)	# Marco 2
		set nodeJ [expr $nodeJm2];			# Node Slave J (below)	# Marco 2

		set LpI 1
		set LpJ 1
		set secTagI 3
		set secTagJ 3
		element beamWithHinges $elemIDm2 $nodeI $nodeJ $secTagI $LpI $secTagJ $LpJ $Ec $AgCol $IzCol $IDColTransf
	}
}

# Beams
set N0beam 20000;	# beam element numbers
for {set iStory 2} {$iStory <=[expr $NStory+1]} {incr iStory 1} {
	for {set bay 1} {$bay <= $NBay} {incr bay 1} {
		set elemIDm1 [expr $N0beam + $iStory*100 + $bay]
		set nodeIm1 [expr $iStory*100 + $bay];			# Node Master I
		set nodeJm1 [expr $iStory*100 + $bay+1];		# Node Master J
		
		set elemIDm2 [expr $N0beam + $iStory*100 + $bay + $NBay]
		set nodeIm2 [expr $iStory*100 + $bay + ($NBay+1)];			# Node Master I
		set nodeJm2 [expr $iStory*100 + $bay+1 + ($NBay+1)];		# Node Master J
		
		set nodeI [expr $nodeIm1];			# Node Slave I (right)
		set nodeJ [expr $nodeJm1];			# Node Slave J (left)

		set LpI 1
		set LpJ 1
		set secTagI 4
		set secTagJ 4
		element beamWithHinges $elemIDm1 $nodeI $nodeJ $secTagI $LpI $secTagJ $LpJ $Ec $AgBeam $IzBeam $IDBeamTransf
		
		set nodeI [expr $nodeIm2];			# Node Slave I (right)
		set nodeJ [expr $nodeJm2];			# Node Slave J (left)

		set LpI 1
		set LpJ 1
		set secTagI 4
		set secTagJ 4
		element beamWithHinges $elemIDm2 $nodeI $nodeJ $secTagI $LpI $secTagJ $LpJ $Ec $AgBeam $IzBeam $IDBeamTransf
	}
}
#Definición del material:
set VscTag 3;
set C 45000.;
set alpha 0.3;

# Define Viscous Material
uniaxialMaterial Viscous $VscTag $C $alpha; #uniaxialMaterial Viscous $matTag $C $alpha

		if {$CaseofStudy == 1} {
		element zeroLength  90001  104  305  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90002  304  505  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90003  107  306  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90004  307  506  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		} elseif {$CaseofStudy == 2} {
		element zeroLength  90001  104  205  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90002  204  305  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90003  304  405  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90004  404  505  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90005  504  605  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90006  107  206  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90007  207  306  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90008  307  406  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90009  407  506  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90010  507  606  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		} elseif {$CaseofStudy == 3} {
		element zeroLength  90001  104  305  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90002  304  605  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90003  107  306  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90004  307  606  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		} elseif {$CaseofStudy == 4} {
		element zeroLength  90001  102  301  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90002  302  501  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90003  109  310  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90004  309  510  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		} elseif {$CaseofStudy == 5} {
		element zeroLength  90001  104  205  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90002  204  405  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90003  404  605  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90004  107  206  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90005  207  406  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		element zeroLength  90006  407  606  -mat $VscTag -dir 1 -orient 1 0 0 0 1 0
		}
	
		
# DEFINE GRAVITY LOADS, weight and masses -----------------------------------------------------------------------------
# calculate dead load of frame, assume this to be an internal frame (do LL in a similar manner)
# calculate distributed weight along the beam length
set GammaConcrete [expr 2.5*$ton_m3];  			# Reinforced-Concrete weight 
set Tslab [expr 0*$cm];	         				# Espesor de losa
set Lslab [expr $LBeam]; 						# Ancho tributario de vigas (fuera del plano)
set Qslab [expr $GammaConcrete*$Tslab*$Lslab]; 
set QdlCol [expr $GammaConcrete*$HCol*$BCol];	# Column, weight per length
set QBeam [expr $GammaConcrete*$HBeam*$BBeam];	# Beam, weight per length
set QdlBeam [expr $Qslab + $QBeam]; 			# Dead load distributed along beam.
set WeightCol [expr $QdlCol*$LCol];  			# total Column weight
set WeightCol_1f [expr $QdlCol*($LCol+$LCol_1f)/2];  			# total Column weight
set WeightBeam [expr $QdlBeam*$LBeam]; 			# total Beam weight

# CARGAS APLICADAS AL MODELO
set WD_f [expr 4.8*$ton_ml];  					# Dead Load Floor
set WD_r [expr 4*$ton_ml]; 						# Dead Load Roof
set WL_f [expr 4*$ton_ml];  					# Live Load Floor
set WL_r [expr 0*$ton_ml]; 						# Live Load Roof

set PS_f [expr ($WD_f+0.5*$WL_f)*$LBeam];
set PS_r [expr ($WD_r+0.5*$WL_r)*$LBeam];

# assign masses to the nodes that the columns are connected to 
# each connection takes the mass of 1/2 of each element framing into it (mass=weight/$g)
set WeightTotal 0.0
for {set iStory 2} {$iStory <=[expr $NStory+1]} {incr iStory 1} {
	set FloorWeight 0.0
	if {$iStory == [expr $NStory+1]} {
		set ColWeightFact 1;		# one column in top story
	} else {
		set ColWeightFact 2;		# two columns elsewhere
	}
	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {;
		if {$pier == 1 || $pier == [expr $NBay+1]} {
			set BeamWeightFact 1;	# one beam at exterior nodes
		} else {;
			set BeamWeightFact 2;	# two beams elewhere
		}
		if {$iStory == 2} {
			set WeightNode [expr $ColWeightFact*$WeightCol_1f/2 + $BeamWeightFact*$WeightBeam/2 + $BeamWeightFact*$PS_f/2]
		} elseif {$iStory == [expr $NStory+1]} {
			set WeightNode [expr $ColWeightFact*$WeightCol/2 + $BeamWeightFact*$WeightBeam/2 + $BeamWeightFact*$PS_r/2]
		} else {
			set WeightNode [expr $ColWeightFact*$WeightCol/2 + $BeamWeightFact*$WeightBeam/2 + $BeamWeightFact*$PS_f/2]		
		}
		set MassNode [expr $WeightNode/$g];
		
		set nodeID [expr $iStory*100+$pier]
		mass $nodeID $MassNode 0.0 0.0;			# define mass
		puts "Node: $nodeID, Mass: $MassNode"
		set nodeID [expr $iStory*100+$pier+($NBay+1)]
		mass $nodeID $MassNode 0.0 0.0;			# define mass
		puts "Node: $nodeID, Mass: $MassNode"
		
		set FloorWeight [expr $FloorWeight+$WeightNode*2];
	}
	set WeightTotal [expr $WeightTotal+ $FloorWeight]
}
set MassTotal [expr $WeightTotal/$g];						# total mass
# puts "Total Weigth: $WeightTotal"
puts "Total Mass: $MassTotal"

# DISPLAY ------------------------------------------------------------------------------------------------------
DisplayModel2D NodeNumbers

# define GRAVITY -----------------------------------------------------------------------------------------------
# GRAVITY LOADS # define gravity load applied to beams and columns -- eleLoad applies loads in local coordinate axis
pattern Plain 101 Linear {
	for {set iStory 1} {$iStory <=$NStory} {incr iStory 1} {
		for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {

			set elemID [expr $N0col  + $iStory*100 +$pier]
			eleLoad -ele $elemID -type -beamUniform 0 -$QdlCol; 	# COLUMNS MARCO 1
			
			set elemID [expr $N0col  + $iStory*100 +$pier +($NBay+1)]
			eleLoad -ele $elemID -type -beamUniform 0 -$QdlCol; 	# COLUMNS MARCO 2
		}
	}
	for {set iStory 2} {$iStory <=[expr $NStory+1]} {incr iStory 1} {
		for {set bay 1} {$bay <= $NBay} {incr bay 1} {
		
			set elemID [expr $N0beam + $iStory*100 + $bay]; # BEAM MARCO 1
			if {$iStory == [expr $NStory+1]}  {
				eleLoad -ele $elemID  -type -beamUniform [expr -$QdlBeam-$WD_r-$WL_r]; 	# BEAMS AT ROOF
			} else {
				eleLoad -ele $elemID  -type -beamUniform [expr -$QdlBeam-$WD_f-$WL_f]; 	# BEAMS FLOORS
			}
			
			set elemID [expr $N0beam + $iStory*100 + $bay + $NBay]; # BEAM MARCO 2
			if {$iStory == [expr $NStory+1]}  {
				eleLoad -ele $elemID  -type -beamUniform [expr -$QdlBeam-$WD_r-$WL_r]; 	# BEAMS AT ROOF
			} else {
				eleLoad -ele $elemID  -type -beamUniform [expr -$QdlBeam-$WD_f-$WL_f]; 	# BEAMS FLOORS
			}	
			
		}
	}
}

# Gravity-analysis parameters -- load-controlled static analysis

set Tol 1.0e-3;							# convergence tolerance for test
constraints Plain ;     				# how it handles boundary conditions
numberer Plain;							# renumber dof's to minimize band-width (optimization), if you want to
system BandGeneral ;					# how to store and solve the system of equations in the analysis (large model: try UmfPack)
test NormDispIncr $Tol 6 ; 				# determine if convergence has been achieved at the end of an iteration step
algorithm Newton;						# use Newton's solution algorithm: updates tangent stiffness at every iteration
set NstepGravity 50;  					# apply gravity in 1 steps
set DGravity [expr 1./$NstepGravity]; 	# first load increment;
integrator LoadControl $DGravity;		# determine the next time step for an analysis
analysis Static;						# define type of analysis static or transient
analyze $NstepGravity;					# apply gravity
# ------------------------------------------------- maintain constant gravity loads and reset time to zero
loadConst -time 0.0

puts "Model Built"


