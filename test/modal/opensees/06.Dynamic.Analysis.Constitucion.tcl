# ------------------------------------------------------------------------
# DYNAMIC ANALYSIS -------------------------------------------------------
puts "Dynamic NL Analysis"

# Uniform Earthquake Ground Motion (uniform accel input at all support nodes)
set GMfile "Constitucion_0" ;			# ground-motion filenames
set FS 200.
set GMfact 1;							# ground-motion scaling factor

# Set Up Ground-Motion-Analysis Parameters
set DtAnalysis	[expr 0.01*$sec];		# time-step Dt for lateral analysis
set TmaxAnalysis	[expr 170. *$sec];	# maximum duration of ground-motion analysis

#Angol = 80 seg
#Concepcion = 160 seg
#Constitucion = 170 seg
#Curico = 115 seg
#Matanzas = 145 seg
#Mirador = 230 seg
#Vina = 78 seg

# Display Deformed Shape:
set ViewScale 200;				# amplify display of deformed shape
DisplayModel2D DeformedShape $ViewScale ;	# display deformed shape, the scaling factor needs to be adjusted for each model

# Define RAYLEIGH Damping
# RAYLEIGH damping parameters, Where to put M/K-prop damping, switches (http://opensees.berkeley.edu/OpenSees/manuals/usermanual/1099.htm)
# D=$alphaM*M + $betaKcurr*Kcurrent + $betaKcomm*KlastCommit + $beatKinit*$Kinitial
set xDamp 0.02;					# damping ratio
set nEigenI 1;		# mode 1
set nEigenJ 5;		# mode 2
set lambdaN [eigen [expr $nEigenJ]];			# eigenvalue analysis for nEigenJ modes
set lambdaI [lindex $lambdaN [expr $nEigenI-1]]; 	# eigenvalue mode i
set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]]; 	# eigenvalue mode j
set omegaI [expr pow($lambdaI,0.5)];
set omegaJ [expr pow($lambdaJ,0.5)];
set alphaM [expr $xDamp*(2*$omegaI*$omegaJ)/($omegaI+$omegaJ)];
set betaKinit [expr 2.*$xDamp/($omegaI+$omegaJ)];
rayleigh $alphaM $betaKinit 0.0 0.0; # rayleigh $alphaM $betaK $betaKinit $betaKcomm
#rayleigh $alphaM 0.0 0.0 0.0; # rayleigh $alphaM $betaK $betaKinit $betaKcomm
puts "Rayleigh $alphaM $betaKinit 0.0 0.0"

# Perform Dynamic Ground-Motion Analysis (the following commands are unique to the Uniform Earthquake excitation)
set dt [expr 1/$FS]
set FilePath GMFiles/$GMfile.txt
set GMfatt [expr $g*$GMfact];		# data in input file is in g Unifts -- ACCELERATION TH
puts "GM dt: $dt sec"
puts "Scale Factor: $GMfatt"
set IDloadTag 400;	# for uniformSupport excitation
set GMdirection 1;				# ground-motion direction
#set AccelSeries "Series -dt $dt -filePath $FilePath -factor  $GMfatt";	# time series information

set TSTag 1
timeSeries Path $TSTag -dt $dt -filePath $FilePath -factor $GMfatt

# pattern UniformExcitation $patternTag $dir -accel $tsTag <-vel0 $vel0> <-fact $cFactor>
pattern UniformExcitation  $IDloadTag  $GMdirection -accel $TSTag  ;		# create Unifform excitation

# RECORDERS -----------------------------------------------------------------------------------------------------------
set iNode 201
set jNode [expr ($NStory+1)*100+2*($NBay+1)]

recorder Node -file $dataDir/Nodes_AbsAcel.out -timeSeries 1 -time  -nodeRange $iNode $jNode -dof 1 accel;		# Aceleraciones Absolutas
recorder Node -file $dataDir/Nodes_RelAcel.out -time                -nodeRange $iNode $jNode -dof 1 accel;		# Aceleraciones Relativas
recorder Node -file $dataDir/Nodes_Disp.out    -time                -nodeRange $iNode $jNode -dof 1 disp;		# Desplazamientos
recorder Node -file $dataDir/Nodes_Velo.out    -time                -nodeRange $iNode $jNode -dof 1 vel;		# Velocidades

recorder Node -file $dataDir/Nodes_BaseAcel.out -timeSeries 1 -time -nodeRange 101 [expr 100+2*($NBay+1)] -dof 1 accel; # Aceleraciones Basales (ag(t))

recorder Node -file $dataDir/Nodes_Damp.out -time -nodeRange $iNode $jNode -dof 1 rayleighForces;	# Fuerzas Rayleigh

# Drifts
recorder Drift -file $dataDir/Drift01.out -time -iNode 101 -jNode 201 -dof 1 -perpDirn 2;	# lateral drift
recorder Drift -file $dataDir/Drift12.out -time -iNode 201 -jNode 301 -dof 1 -perpDirn 2;	# lateral drift
recorder Drift -file $dataDir/Drift23.out -time -iNode 301 -jNode 401 -dof 1 -perpDirn 2;	# lateral drift
recorder Drift -file $dataDir/Drift34.out -time -iNode 401 -jNode 501 -dof 1 -perpDirn 2;	# lateral drift
recorder Drift -file $dataDir/Drift45.out -time -iNode 501 -jNode 601 -dof 1 -perpDirn 2;	# lateral drift



# Element Response
set FirstCol [expr $N0col+100+1];
set LastBeam [expr $N0beam+($NStory+1)*100+$NBay*2];
recorder Element -file $dataDir/R_Spr_i.out -time -eleRange $FirstCol $LastBeam -dof 3 section 1 deformation; 
recorder Element -file $dataDir/R_Spr_j.out -time -eleRange $FirstCol $LastBeam -dof 3 section 6 deformation; 
#recorder Element -file $dataDir/M_Spr.out   -time -eleRange $FirstCol $LastBeam -dof 3 6 force;
recorder Element -file $dataDir/M_Spr_i.out   -time -eleRange $FirstCol $LastBeam -dof 3 section 1 force;
recorder Element -file $dataDir/M_Spr_j.out   -time -eleRange $FirstCol $LastBeam -dof 3 section 6 force;

# Base Reaction (Element forces 1st floor)
recorder Element -file $dataDir/Elem_Forces.out -time -eleRange $FirstCol [expr $N0col+100+2*($NBay+1)] -dof 1 globalForce

if {$CaseofStudy == 1} {
		recorder Element -file  $dataDir/ViscDampforce.out -time -eleRange 90001 90004 localForce;
		recorder Element -file  $dataDir/ViscDef.out -time -eleRange 90001 90004 -dof 1  deformation;
		} elseif {$CaseofStudy == 2} {
		recorder Element -file  $dataDir/ViscDampforce.out -time -eleRange 90001 90010 localForce;
		recorder Element -file  $dataDir/ViscDef.out -time -eleRange 90001 90010 -dof 1  deformation;
		} elseif {$CaseofStudy == 3} {
		recorder Element -file  $dataDir/ViscDampforce.out -time -eleRange 90001 90004 localForce;
		recorder Element -file  $dataDir/ViscDef.out -time -eleRange 90001 90004 -dof 1  deformation;
		} elseif {$CaseofStudy == 4} {
		recorder Element -file  $dataDir/ViscDampforce.out -time -eleRange 90001 90004 localForce;
		recorder Element -file  $dataDir/ViscDef.out -time -eleRange 90001 90004 -dof 1  deformation;
		} elseif {$CaseofStudy == 5} {
		recorder Element -file  $dataDir/ViscDampforce.out -time -eleRange 90001 90006 localForce;
		recorder Element -file  $dataDir/ViscDef.out -time -eleRange 90001 90006 -dof 1  deformation;
		}
# ANALYSIS PARAMETERS -----------------------------------------------------------------------------------------------------------
constraints Plain	
system SparseGeneral
numberer RCM
set tol [expr 10000*1.e-2]; #set tol [expr 10000*1.e-2]
set iter 5000; #5000
set pFlag 0
set nType 2
test EnergyIncr $tol $iter $pFlag $nType
set gamma 0.5;	# gamma value for newmark integration
set beta 0.25;	# beta value for newmark integration
integrator Newmark $gamma $beta
algorithm KrylovNewton -initial
analysis Transient
	
set Nsteps [expr int($TmaxAnalysis/$DtAnalysis)];
set ok [analyze $Nsteps $DtAnalysis];			# actually perform analysis; returns ok=0 if analysis was successful

if {$ok != 0} {      ;					# analysis was not successful.
	# --------------------------------------------------------------------------------------------------
	# change some analysis parameters to achieve convergence
	# performance is slower inside this loop
	#    Time-controlled analysis
	set ok 0;
	set controlTime [getTime];
	while {$controlTime < $TmaxAnalysis && $ok == 0} {
		set controlTime [getTime]
		set ok [analyze 1 $DtAnalysis]
		if {$ok != 0} {
			puts "Trying Newton with Initial Tangent .."
			test NormDispIncr   $Tol 1000  0
			algorithm KrylovNewton -initial
			set ok [analyze 1 $DtAnalysis]
			test $testTypeDynamic $TolDynamic $maxNumIterDynamic  0
			algorithm $algorithmTypeDynamic
		}
		if {$ok != 0} {
			puts "Trying Broyden .."
			algorithm Broyden 8
			set ok [analyze 1 $DtAnalysis]
			algorithm $algorithmTypeDynamic
		}
		if {$ok != 0} {
			puts "Trying NewtonWithLineSearch .."
			algorithm NewtonLineSearch .8
			set ok [analyze 1 $DtAnalysis]
			algorithm $algorithmTypeDynamic
		}
	}
};      # end if ok !0

puts "Ground Motion Done. End Time: [getTime]"
