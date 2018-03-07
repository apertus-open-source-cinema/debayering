/*
 * The debayering project is intended to provide a platform independent 
 * debayering software for processing any RAW image data for film, movie, cinema, 
 * photography to provide a natural touch and 35mm film look
 *
 * For further information about the debayering project, please see the
 * project website: http://www.debayering.com
 *
 * The debayering project features several different debayering algorithms
 * like bilinear, shoodak and gaussian. Some debayering algorithms offer a 
 * variable mix of random distortion. Images can be softened by the built-in 
 * variable gaussian blur. It comes with an artificial film grain, 
 * offers color transformation by LUT cube and variable rescaling.
 * All effects can be mixed at a variable ratio
 *
 * Copyright (C) 2015 Peter Sreckovic, Stephan Schuh.
 * 
 * For further information about the authors, please see the company websites: 
 * http://www.da-agency.de
 * http://www.at-digital.de
 * http://www.shoodak.com
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#include <Foundation/Foundation.h>  
#include <stdio.h>
/*
 * Declare the Test class that implements the class method (classStringValue).
 */
@interface ImageDebayering

extern NSMutableArray *memPointers;
extern NSPointerArray *memBlockPointers;
extern NSMutableArray *memBlockArray;
extern int memCounter;
extern bool colorRedo;
extern int colorCorrectionMethod;
extern bool testLoopFirstPixels;


typedef struct
{
	NSMutableData *buffer;
	int cols;
	int rows;
} processedImageData;


typedef struct
{	
	float red;
	float green;
	float blue;
   //unsigned char array[3];
} rgbBytes;
//} rgbBytes32Bit;


typedef struct
{
		bool doRescale;
		float resize; // this deactivates Rescaling entirely
		int rescaleMethod;
		int debayeringMethod;
		bool doBlur;
		int patternSize;
		float randomMix; // only for debyeringMethod = 3, 5, 7
		int randIts;		// only for debyeringMethod = 3, 5, 7
		float debayeringVariance;		//only for debyeringMethod == 7
		float blurVariance;		
		bool doGrain;
		int grainPatternSize;
		float mixGrain;
		int grainDeviation;
		bool colorRedo;
		int colorCorrectionMethod;
} inputParams;

typedef struct
{
	unsigned char red;
	unsigned char green;
	unsigned char blue;
	unsigned char x;
	unsigned char y;
} pixelRgbXy;


+ (const char *) classStringValue;
+ (NSMutableData *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes scaleFactor:(float)resize rescaleMethod:(int)rescaleMethod params:(inputParams)settings;
- (float)roundedFloat:(float)orig postDecimals:(int)postDec;
-(float)randomPixelValue:(float)pixel bitsPerSample:(int)bitsPerSample pixRange:(float)pixRange;
-(float)randomPixelDeviation:(float)pixel bitsPerSample:(int)bitsPerSample rangePercent:(float)range;




@end