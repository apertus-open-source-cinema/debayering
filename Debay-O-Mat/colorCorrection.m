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


#import "colorCorrection.h"
#import "imageDebayering.h"
#import "cubePixel.h"
#import "cubeLut.h"
#include<math.h>
#include <stdlib.h>

/*
 * Define the ColorCorrection class and the class methods.
 */
@implementation ColorCorrection

bool debugColorCoreection = false;
bool testLoop = false;
unsigned long maxInputVal = 0XFFFFFFFF;

-(void)setMaxVal:(int)bitsPerSample{
	if(bitsPerSample==8)maxInputVal = 0XFF;
	else if(bitsPerSample==12)maxInputVal = 0X00000FFF;
	else if(bitsPerSample==16)maxInputVal = 0X0000FFFF;
	else if(bitsPerSample==20)maxInputVal = 0X000FFFFF;
	else if(bitsPerSample==24)maxInputVal = 0X00FFFFFF;
	else if(bitsPerSample==32)maxInputVal = 0XFFFFFFFF;
}

-(unsigned long)getMaxVal{
	return maxInputVal;
}

//Should return an equivalent between 1 (for max Value 255 in 32Bit) and 0 (for min Value 0) 
+ (float)normalize32BitFloatToPixelCodeValue:(float)colorValue32Bit{
//	unsigned long maxVal = 0XFFFFFFFF;
//	unsigned long maxVal = FLT_MAX;
//	float maxVal = 0XFFFF;
	unsigned long maxVal = [ColorCorrection getMaxVal];
	float outVal = (float)((float)colorValue32Bit/(float)maxVal);
	if(debugColorCoreection)NSLog(@"REDOING COLORS... normalize32BitFloatToPixelCodeValue outVal=%.16f / maxVal=%f / inputVal=%f",outVal, maxVal, colorValue32Bit);
	return (float)outVal;
}

+ (float)normalizePixelCodeValueTo32BitFloat:(float)pixelCodeValue{
	if(debugColorCoreection)NSLog(@"REDOING COLORS... entering normalizePixelCodeValueTo32BitFloat from test LOOP with inPut=%f",pixelCodeValue);
//	float maxVal = 0XFFFFFFFF;
//	unsigned long maxVal = FLT_MAX;
//	float maxVal = 0XFFFF;
	unsigned long maxVal = [ColorCorrection getMaxVal];
	unsigned long retVal= maxVal*pixelCodeValue;
	if(debugColorCoreection)NSLog(@"REDOING COLORS... normalizePixelCodeValueTo32BitFloat retVal=%u / maxVal=%f / inputVal=%.16f",retVal, maxVal, (float)pixelCodeValue);
	return (float)retVal;
}

+(float)transformAscCdl:(float)i s:(float)s o:(float)o p:(float)p{
	//unsigned long output = 0.0;
	float output = 0.0;
	if(debugColorCoreection)	NSLog(@"REDOING COLORS... entered transformAscCdl with params i=%f / s=%f / o=%f / p=%f",i,s,o,p);
	output = powf(((float)i*s + (float)o),(float)p);
	
	//Diese Formel funktioniert nicht, da die Ausgangswerte unsinnig werden können
	//z.B. für i=0 (schwarz) und negativem offset o köönen die werte - abhängig von p positiv oder negativ ausfallen
	// verwendet man nur p, können die Werte größer als 1 werden, wobei 1=weiss -> normieren?
	
	//normieren outMin for inputVal=0 outMaxVal for inputVal=1.0
	float outMinVal=powf(((float)0.0*s + (float)o),(float)p);
	float outMaxVal=powf(((float)1.0*s + (float)o),(float)p);
	//normalize, so max is again 1.0
	//still min needs correction
	//if min output is negative, make a correction
/*
	if(outMinVal!=null && outMinVal<0){
		output = (float)output/(float)outMaxVal;
	}
*/
	float normalizedOutput = (float)output/(float)outMaxVal;
//	if(debugColorCoreection)	NSLog(@"REDOING COLORS... entered transformAscCdl with params i=%.16f / s=%f / o=%f / p=%f / output=%.16f / normalizedOutput=%f ",i,s,o,p, output,normalizedOutput);
//	if(debugColorCoreection)	NSLog(@"REDOING COLORS... outMinVal=%f, outMaxVal=%f",outMinVal, outMaxVal);

	/****************************************
	NOT WORKING CORRECTLY!
	Versuch, eine Gradationskurve mathematisch zu entwickeln
	Ausgang ist cos(x) funktion, die für x=0 y=1 und für x=pi y=-1 liefert ->invertieren und normieren
	f(x)=(1-cos(x*pi))/2
	Anhebung oder Absenkung der Mitten ggf. über sinus Anteil
	f(x)=sin(x*pi)(1-cos(x*pi))/2
AUS EXCEL selbst was gebastelt
mit 
=POTENZ((1-COS(POTENZ(A2;1/J2)*PI()))/2; I2)	
=POTENZ((1-COS(POTENZ(A2+K2*SIN(A2*PI());1/J2)*PI()))/2; I2)
=powf((1-cos(powf((float)i+k2*sin((float)i*PI);1/j2)*PI))/2, i2)
mit I2=1 bis 10000, J1=1 bis 50, K=0 bis 0,33

	*****************************************/
	float i2=30.0;
	float j2=8.0;
	float k2=0.2;
//	output = (1-cos(M_PI*(float)i))/2.0;
//	output = (float)i;
//	output = powf((float)i, 1.0/1.0);
//	output = powf((1-cos(powf((float)i+k2*sin((float)i*M_PI);1/j2)*M_PI))/2, i2);
	output = powf((1-cos(powf((float)i+k2*sin((float)i*M_PI), 1/j2)*M_PI))/2, i2);

	if(debugColorCoreection)	NSLog(@"REDOING COLORS... transformAscCdl - input i=%f, i2=%f, j2=%f, k2=%f output=%f",i,i2,j2,k2,output);
	
	
//	if(normalizedOutput<0.0)return 0.0;
//	return (float)normalizedOutput;
/*
	if(output<0.0)return 0.0;
	if(output>1.0)return 1.0;
*/
	return (float)output;
}

+(float)transform32BitFloatAscCdl:(float)colorValue32Bit{
	if(debugColorCoreection)	NSLog(@"REDOING COLORS... entered transform32BitFloatAscCdl:(unsigned long)colorValue32Bit with colorValue32Bit=%f",colorValue32Bit);

	int i=0;
	unsigned long maxVal = [ColorCorrection getMaxVal];
	if(testLoop){
		for(i=0;i<maxVal;i++){
			NSLog(@"REDOING COLORS... calling transformAscCdl from test LOOP");
			colorValue32Bit = (float)i;
			float pixelCodeValue = [ColorCorrection normalize32BitFloatToPixelCodeValue:colorValue32Bit];
			float transformedPixelCode = [ColorCorrection transformAscCdl:pixelCodeValue s:gradationSlope o:gradationOffset p:gradationPower];
			float returnValue = [ColorCorrection normalizePixelCodeValueTo32BitFloat:transformedPixelCode];
			NSLog(@"REDOING COLORS... test LOOP - input=%f / output=%f / pixelCodeValue=%f / transformedPixelCode=%f",colorValue32Bit, returnValue,pixelCodeValue,transformedPixelCode);
		}
	}

	float pixelCodeValue = [ColorCorrection normalize32BitFloatToPixelCodeValue:colorValue32Bit];
	float transformedPixelCode = [ColorCorrection transformAscCdl:pixelCodeValue s:gradationSlope o:gradationOffset p:gradationPower];
	return [ColorCorrection normalizePixelCodeValueTo32BitFloat:transformedPixelCode];
}

+(void)initializeGradation{
	//default Values - no changes to RGB colors
	gradationSlope = 1.35;  // works up to 1.3 -> clipping
	gradationOffset = 0.0; //black pictures, if different from 0.0
	gradationPower = 1.0; //does not work -> black pics, if different from 1.0
// clipping starts with GREEN -> maxValue needed for each color RGB
}

+(rgbBytes)correctColors:(rgbBytes)inputPix bitsPerSample:(int)bitsPerSample{
	if(debugColorCoreection)	NSLog(@"REDOING COLORS... entered correctColors:(rgbBytes)inputPix\n#############################");
	if(debugColorCoreection)NSLog(@"REDOING COLORS... inputPix.red=(%f/%f/%f)",inputPix.red,inputPix.green,inputPix.blue);
	rgbBytes outPix;
	[ColorCorrection setMaxVal:bitsPerSample];
	outPix.red = [ColorCorrection transform32BitFloatAscCdl:inputPix.red];
	outPix.green = [ColorCorrection transform32BitFloatAscCdl:inputPix.green];
	outPix.blue = [ColorCorrection transform32BitFloatAscCdl:inputPix.blue];
	if(debugColorCoreection)NSLog(@"REDOING COLORS... outPix.red=(%f/%f/%f)",outPix.red,outPix.green,outPix.blue);
	return outPix;
}

//-(rgbBytes)lutCubeTransform:(rgbBytes)rgbPix bitsPerSample:(int)bitsPerSample{
-(rgbBytes)lutCubeTransform:(rgbBytes)rgbPix bitsPerSample:(int)bitsPerSample debug:(bool)debug{
	rgbBytes outPix;
	bool debugLutCubeTransform=false;
	debugLutCubeTransform = debug;
	bool testMem = false;
	bool testMem2 = true;
	if(testMem)return rgbPix; // just return input value to find out where memory leaks reside
	if(debugLutCubeTransform)NSLog(@"FUNC lutCubeTransform entered...");
	[ColorCorrection setMaxVal:bitsPerSample];
	//IMPLEMENTATION...
	if(debugLutCubeTransform)NSLog(@"FUNC lutCubeTransform INPUT VALUES (%f/%f/%f)",rgbPix.red,rgbPix.green,rgbPix.blue);
	
	//TO DO: Transform RGB Color Value for given bitsPerSample to a value between 0.0 (black) and 1.0 (white) for each color channel
	outPix.red = [ColorCorrection normalize32BitFloatToPixelCodeValue:rgbPix.red];
	outPix.green = [ColorCorrection normalize32BitFloatToPixelCodeValue:rgbPix.green];
	outPix.blue = [ColorCorrection normalize32BitFloatToPixelCodeValue:rgbPix.blue];

	if(debugLutCubeTransform)NSLog(@"FUNC lutCubeTransform NORMALIZED INPUT VALUES (%f/%f/%f)",outPix.red,outPix.green,outPix.blue);
	
	//TO DO: get LUT CUBE
	// just assign input value to output to find out where memory leaks reside
	//if(!testMem2) outPix = [CubeLut transformByLut:outPix];
//	[MemoryManagement initializeMemoryBlock]; //too slow
//	[CubeLut initCoefficientsNSArray];
//	outPix = [CubeLut transformByLut:outPix];
	outPix = [CubeLut transformByLutSmallMem:outPix];
//	[MemoryManagement freeMemoryBlock]; //too slow
	if(debugLutCubeTransform)NSLog(@"FUNC lutCubeTransform NORMALIZED OUTPUT VALUES (%f/%f/%f)",outPix.red,outPix.green,outPix.blue);

	outPix.red = [ColorCorrection normalizePixelCodeValueTo32BitFloat:outPix.red];
	outPix.green = [ColorCorrection normalizePixelCodeValueTo32BitFloat:outPix.green];
	outPix.blue = [ColorCorrection normalizePixelCodeValueTo32BitFloat:outPix.blue];

	if(debugLutCubeTransform)NSLog(@"FUNC lutCubeTransform OUTPUT VALUES (%f/%f/%f)",outPix.red,outPix.green,outPix.blue);
	
	
	//TO DO: size of LUT CUBE is nominally 1.0, with cubeDimensions parts (demo case: 17)
	//TO DO: get length of each block (1/17)
	//TO DO: get mini Cube, where RGB Color value is to be looked up
	
	//TO DO: estimate transformed color values by interpolation by distance from surrounding mini cube edges / values

	return outPix;
}


+(float)testMethod{
	return 0.0;
}

+(float)testMethod2:(float)col{
	return 0.0;
}
@end