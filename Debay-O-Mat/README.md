# "Debay-O-Mat" Debayering Test Tool

Copyright: Peter Sreckovic

# License
Thi software is released under GNU GPL V3 as is and without any warranty.

# Usage
Default Parameters:

	inputParams settings; 
	//Initialize with default values

	settings.doRescale = false;
	settings.resize = 1.0; // ==1.0  deactivates Rescaling entirely
	settings.rescaleMethod=0;
	settings.debayeringMethod=7;
	settings.doBlur = true;
	settings.patternSize = 7;
	settings.randomMix = 0.15; // only for debyeringMethod = 3, 5, 7 - DEFAULT: 33%, FAVORITE: 15%
	settings.randIts = 5;		// only for debyeringMethod = 3, 5, 7
	settings.debayeringVariance=2.5;		//only for debyeringMethod == 7
	settings.blurVariance=5.0;	//DEFAULT: 2.5, FAVORITE: 5.0			
	settings.doGrain = false;
	settings.grainPatternSize = 5;
	settings.mixGrain = 0.33;
	settings.grainDeviation = 5.0;
	settings.colorRedo = true;
	settings.colorCorrectionMethod = 1; // 0=gradient / 1=LUT cube



All parameters can be altered through the commandline like:
Debay-O-Mat doGrain=true resize=0.5 colorRedo=false