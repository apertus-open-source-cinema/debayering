# New Document# "Debay-O-Mat" Debayering Test Tool
Copyright: Peter Sreckovic

# License
This software is released under GNU GPL V3 as is and without any warranty.

# Compiling
GNUStep framework is required

# Usage
All parameters can be altered through the commandline:

```Debay-O-Mat doGrain=true resize=0.5 colorRedo=false```

## Default Parameters:
```doRescale = false;
resize = 1.0; 				// ==1.0  deactivates Rescaling entirely
rescaleMethod = 0;
debayeringMethod = 7;
doBlur = true;
patternSize = 7;
randomMix = 0.15; 			// only for debayeringMethod = 3, 5, 7 - DEFAULT: 33%, FAVORITE: 15%
randIts = 5;				// only for debyeringMethod = 3, 5, 7
debayeringVariance = 2.5;	//only for debyeringMethod == 7
blurVariance = 5.0;			//DEFAULT: 2.5, FAVORITE: 5.0
doGrain = false;
grainPatternSize = 5;
mixGrain = 0.33;
grainDeviation = 5.0;
colorRedo = true;
colorCorrectionMethod = 1; 	// 0=gradient, 1=LUT cube
```
## Debayering Methods
```DEBAYERING METHOD 8 (luminosity - b/w)
EXPERIMENTAL - DEBAYERING METHOD 10 (black and white Bilinear: green to b/w, red and blue calculated b/w)
DEBAYERING METHOD 1 (Bilinear)
DEBAYERING METHOD 2 (with direction and gradient)
DEBAYERING METHOD 3 (With random choice)
DEBAYERING METHOD 5 (13Pixel Pattern with random choice)
DEBAYERING METHOD 6 (NxN Pixel Pattern with random choice)
DEBAYERING METHOD 7 (Experimental NxN Matrix with gaussian weight```

#References
The general idea behind this debayering method "SHOODAK" is explained here:
https://wiki.apertus.org/index.php/Shoodak

