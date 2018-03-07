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



#import "imageDebayering.h"
#import "memoryManagement.h"
#import "colorCorrection.h"

#include<math.h>
#include <stdlib.h>
#define ARC4RANDOM_MAX 0x100000000


/*
 * Define the Test class and the class method (classStringValue).
 */
@implementation ImageDebayering
+ (const char *) classStringValue;
{
  return "This is the string value of the Test class";
}

- (void)openFile:(NSString *)str{
	NSLog(@"NOW OPENING FILE: %@", str);
}

- (void)test{
	NSLog(@"TEST FUNC FROM SOURCE imageDebayering.m CALLED\n");
}

/*
- (char)normalizeTo8Bit:(int)colorValue bitsPerSample:(int)bitsPerSample{
	long long colVal = 0;
	int outputBits = 8;
	int maxOutputVal = 0XFF;
	int inputBits = bitsPerSample;
	int maxInputVal = 0X0FFF;
	
	colVal = (colorValue*maxOutputVal)/maxInputVal; //calculating needs more bits
	//NSLog(@"normalizeTo8Bit - colorValue=%i / bitsPerSample=%i / colVal=%i / outputBits=%i / maxOutputVal=%i / inputBits=%i / maxInputVal=%i\n", colorValue,bitsPerSample, colVal, outputBits, maxOutputVal, inputBits, maxInputVal);
	return (char)colVal;
	
}
*/


//- (char)normalizeTo8Bit:(int)colorValue bitsPerSample:(int)bitsPerSample{
- (unsigned char)normalizeTo8Bit:(long)colorValue bitsPerSample:(int)bitsPerSample{
	bool debugNormalize8Bit = false;
	/*
	float colVal = 0;
	int outputBits = 8;
	int maxOutputVal = 0XFF;
	int inputBits = bitsPerSample;
	int maxInputVal = 0X0FFF;
	*/

	float colVal = 0;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colorValue=%lu \n", colorValue);
	int outputBits = 8;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - outputBits=%i \n", outputBits);
	//unsigned long maxOutputVal = 0XFFFFFFFF;
	unsigned long maxOutputVal = UCHAR_MAX;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - maxOutputVal=%lu \n", maxOutputVal);
	int inputBits = bitsPerSample;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - inputBits=%i \n", inputBits);
	unsigned long maxInputVal = 0XFFFFFFFF;
//	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - maxInputVal=%lu \n", maxInputVal);	
	
	if(bitsPerSample==8)maxInputVal = 0XFF;
	else if(bitsPerSample==12)maxInputVal = 0X00000FFF;
	else if(bitsPerSample==16)maxInputVal = 0X0000FFFF;
	else if(bitsPerSample==20)maxInputVal = 0X000FFFFF;
	else if(bitsPerSample==24)maxInputVal = 0X00FFFFFF;
	else if(bitsPerSample==32)maxInputVal = 0XFFFFFFFF;

	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - maxInputVal=%lu \n", maxInputVal);	

	unsigned long normalizer = maxOutputVal/maxInputVal;
	float normalizerFloat = (double)maxOutputVal/(double)maxInputVal;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - normalizer=%lu / normalizerFloat=%.32f\n", normalizer, normalizerFloat);
	if(maxInputVal>maxOutputVal){
		colVal = (unsigned char)((float)colorValue*normalizerFloat); //calculating needs more bits
		if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colVal=%lu (with normalizerFloat)\n", colVal);	
	}
	else{
		colVal = colorValue*normalizer; //calculating needs more bits
		if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colVal=%lu (with normalizer)\n", colVal);	
		colVal = (colorValue*maxOutputVal)/maxInputVal; //calculating needs more bits
		if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colVal=%lu \n", colVal);	
	}
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colorValue=%i / bitsPerSample=%i / colVal=%i / outputBits=%i / maxOutputVal=%i / inputBits=%i / maxInputVal=%i\n", colorValue,bitsPerSample, colVal, outputBits, maxOutputVal, inputBits, maxInputVal);
	return (unsigned char)colVal;
	
}


- (unsigned char)normalizeFloatTo8Bit:(float)colorValue bitsPerSample:(int)bitsPerSample{
	bool debugNormalize8Bit = false;

	double colVal = 0;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colorValue=%lu \n", colorValue);
	int outputBits = 8;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - outputBits=%i \n", outputBits);
	//unsigned long maxOutputVal = 0XFFFFFFFF;
	unsigned long maxOutputVal = UCHAR_MAX;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - maxOutputVal=%lu \n", maxOutputVal);
	int inputBits = bitsPerSample;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - inputBits=%i \n", inputBits);
	unsigned long maxInputVal = 0XFFFFFFFF;
//	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - maxInputVal=%lu \n", maxInputVal);	
	
	if(bitsPerSample==8)maxInputVal = 0XFF;
	else if(bitsPerSample==12)maxInputVal = 0X00000FFF;
	else if(bitsPerSample==16)maxInputVal = 0X0000FFFF;
	else if(bitsPerSample==20)maxInputVal = 0X000FFFFF;
	else if(bitsPerSample==24)maxInputVal = 0X00FFFFFF;
	else if(bitsPerSample==32)maxInputVal = 0XFFFFFFFF;

	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - maxInputVal=%lu \n", maxInputVal);	

	unsigned long normalizer = maxOutputVal/maxInputVal;
	float normalizerFloat = (double)maxOutputVal/(double)maxInputVal;
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - normalizer=%lu / normalizerFloat=%.32f\n", normalizer, normalizerFloat);
	if(maxInputVal>maxOutputVal){
		colVal = (unsigned char)((float)colorValue*normalizerFloat); //calculating needs more bits
		if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colVal=%lu (with normalizerFloat)\n", colVal);	
	}
	else{
		colVal = colorValue*normalizer; //calculating needs more bits
		if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colVal=%lu (with normalizer)\n", colVal);	
		colVal = (colorValue*maxOutputVal)/maxInputVal; //calculating needs more bits
		if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colVal=%lu \n", colVal);	
	}
	if(debugNormalize8Bit)NSLog(@"normalizeTo8Bit - colorValue=%i / bitsPerSample=%i / colVal=%i / outputBits=%i / maxOutputVal=%i / inputBits=%i / maxInputVal=%i\n", colorValue,bitsPerSample, colVal, outputBits, maxOutputVal, inputBits, maxInputVal);
	return (unsigned char)colVal;
	
}


- (unsigned  int)normalizeTo16Bit:(long)colorValue bitsPerSample:(int)bitsPerSample{
	float colVal = 0;
//	int outputBits = 16;
	unsigned int maxOutputVal = 0XFFFF;
	int inputBits = bitsPerSample;
	unsigned long maxInputVal = 0X0FFF;
	
	if(inputBits==8)maxInputVal = 0X000000FF;
	else if(inputBits==12)maxInputVal = 0X00000FFF;
	else if(inputBits==16)maxInputVal = 0X0000FFFF;
	else if(inputBits==20)maxInputVal = 0X000FFFFF;
	else if(inputBits==24)maxInputVal = 0X00FFFFFF;
	else if(inputBits==32)maxInputVal = 0XFFFFFFFF;
	
	unsigned long normalizer = maxOutputVal/maxInputVal;
	colVal = colorValue*normalizer; //calculating needs more bits
	//colVal = (colorValue*maxOutputVal)/maxInputVal; //calculating needs more bits
	//NSLog(@"normalizeTo16Bit - colorValue=%i / bitsPerSample=%i / colVal=%i / outputBits=%i / maxOutputVal=%i / inputBits=%i / maxInputVal=%i\n", colorValue,bitsPerSample, colVal, outputBits, maxOutputVal, inputBits, maxInputVal);
	return (int)colVal;
	
}


- (unsigned long)normalizeTo32Bit:(unsigned long)colorValue bitsPerSample:(int *)bitsPerSample{
	bool debugNormalize32Bit = false;
	float colVal = 0;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - colorValue=%lu \n", colorValue);
	int outputBits = 32;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - outputBits=%i \n", outputBits);
	//unsigned long maxOutputVal = 0XFFFFFFFF;
	unsigned long maxOutputVal = ULONG_MAX;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - maxOutputVal=%lu \n", maxOutputVal);
	int inputBits = bitsPerSample;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - inputBits=%i \n", inputBits);
	unsigned long maxInputVal = 0XFFFFFFFF;
//	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - maxInputVal=%lu \n", maxInputVal);
	
	//bitsPerSample=16;
	if(bitsPerSample==8)maxInputVal = 0XFF;
	else if(bitsPerSample==12)maxInputVal = 0X00000FFF;
	else if(bitsPerSample==16)maxInputVal = 0X0000FFFF;
	else if(bitsPerSample==20)maxInputVal = 0X000FFFFF;
	else if(bitsPerSample==24)maxInputVal = 0X00FFFFFF;
	else if(bitsPerSample==32)maxInputVal = 0XFFFFFFFF;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - maxInputVal=%lu \n", maxInputVal);
	
	unsigned long normalizer = maxOutputVal/maxInputVal;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - normalizer=%lu \n", normalizer);

	//colVal = (colorValue*maxOutputVal)/maxInputVal; //calculating needs more bits
	colVal = colorValue*normalizer; //calculating needs more bits
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - colVal=%lu \n", colVal);
	//NSLog(@"normalizeTo32Bit - colorValue=%i / bitsPerSample=%i / colVal=%lu / outputBits=%i / maxOutputVal=%lu / inputBits=%i / maxInputVal=%08X / normalizer=%lu\n", colorValue,bitsPerSample, colVal, outputBits, maxOutputVal, inputBits, maxInputVal, normalizer);
	return (unsigned long)colVal;
	
}


- (float)normalizeTo32BitFloat:(unsigned long)colorValue bitsPerSample:(int *)bitsPerSample{
	bool debugNormalize32Bit = false;
	double colVal = 0;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - colorValue=%lu \n", colorValue);
	int outputBits = 32;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - outputBits=%i \n", outputBits);
	float maxOutputVal = FLT_MAX;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - maxOutputVal=%lu \n", maxOutputVal);
	int inputBits = bitsPerSample;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - inputBits=%i \n", inputBits);
	unsigned long maxInputVal = 0XFFFFFFFF;
//	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - maxInputVal=%lu \n", maxInputVal);
	
	//bitsPerSample=16;
	if(bitsPerSample==8)maxInputVal = 0XFF;
	else if(bitsPerSample==12)maxInputVal = 0X00000FFF;
	else if(bitsPerSample==16)maxInputVal = 0X0000FFFF;
	else if(bitsPerSample==20)maxInputVal = 0X000FFFFF;
	else if(bitsPerSample==24)maxInputVal = 0X00FFFFFF;
	else if(bitsPerSample==32)maxInputVal = 0XFFFFFFFF;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - maxInputVal=%lu \n", maxInputVal);
	
	float normalizer = maxOutputVal/(float)maxInputVal;
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - normalizer=%.8f \n", normalizer);

	//colVal = (colorValue*maxOutputVal)/maxInputVal; //calculating needs more bits
	colVal = colorValue*normalizer; //calculating needs more bits
	if(debugNormalize32Bit)NSLog(@"normalizeTo32Bit - colVal=%lu \n", colVal);
	//NSLog(@"normalizeTo32Bit - colorValue=%i / bitsPerSample=%i / colVal=%lu / outputBits=%i / maxOutputVal=%lu / inputBits=%i / maxInputVal=%08X / normalizer=%lu\n", colorValue,bitsPerSample, colVal, outputBits, maxOutputVal, inputBits, maxInputVal, normalizer);
	return (float)colVal;
	
}

//- (long)extract12BitValues:(NSData * imageRawBuffer) pixelCount:(int)pixelCount{}

-(NSData *)toOutput:(rgbBytes *)pixMem rows:(int)rows cols:(int)cols{
}

//-(NSData *)writeRgbPixelsToBuffer:(rgbBytes *)pixels{
-(NSData *)writeRgbPixelsToBufferXY:(rgbBytes *)pixels rows:(int)rows cols:(int)cols{
	//NSLog(@"writeRgbPixelsToBuffer: pixels=%@\n",pixels);
//	int i =0;
//	int j=0;
	NSMutableData *dataBuffer = [NSMutableData data];
	//int byteSize = [pixels count];
//	rgbBytes *pixel;
	//NSLog(@"writeRgbPixelsToBuffer: byteSize=%i\n",byteSize);
//	unsigned char *pixelRgbBytes[3];
	/*
	for(i=0; i<rows; i++){
		for(j=0; j<cols; j++){
			pixel = pixels[j][i];
			pixelRgbBytes[0]=pixel.red;
			pixelRgbBytes[1]=(char)rgbBytes[j][i].green;
			pixelRgbBytes[2]=(char)rgbBytes[j][i].blue;
			NSLog(@"writeRgbPixelsToBufferXY: RGB PIX[%i][%i]=(%i/%i/%i)\n",i,j,pixel.red,pixel.green,pixel.blue);
		}
	}
	*/
	/*
	for(i=0;i<byteSize;i++){
		pixel = (pixels +i);
		
		pixelRgbBytes[0]=*pixel.red;
		pixelRgbBytes[1]=pixel.green;
		pixelRgbBytes[2]=pixel.blue;
		
	}
	*/
	return dataBuffer;
}

-(rgbBytes**)make2DRgbArray:(int)arraySizeX y:(int)arraySizeY {  
NSLog(@"function make2DRgbArray arraySizeX=%d / arraySizeY=%d\n",arraySizeX,arraySizeY);
rgbBytes** theArray;  
//theArray = (rgbBytes**) malloc(arraySizeX*sizeof(rgbBytes*));  
theArray = (rgbBytes**)[MemoryManagement memBlock:(arraySizeX*sizeof(rgbBytes*))];
int i=0;
for (i = 0; i < arraySizeX; i++)  {
//   theArray[i] = (rgbBytes*) malloc(arraySizeY*sizeof(rgbBytes));  
   theArray[i] = (rgbBytes*)[MemoryManagement memBlock:(arraySizeY*sizeof(rgbBytes))];
}
   return theArray;  
}   


	-(int)getColor:(unsigned char[3])pixel{
		int i=0;
		int color=0X00;
		for(i=0;i<3;i++){
			color = color<<8;
			color = color|pixel[i];
		}
	}

	
-(bool)randomBoolean{
	int value = rand() % 2;
	if(value==0)return false;
	else return true;
}

-(int)randomBinary{
	int value = rand() % 2;
	return value;
}


/*-(int)randomRgbVal:(int)pixelVal{
	int dif = rand() % pixelVal;
	if([ImageDebayering randomBoolean])return (pixelVal+dif)%256;
	else return (pixelVal-dif)%256;
}*/

-(int)randomPixel:(int)pixel{
	if(pixel>0)	return rand()%pixel;
	else return 0;
}

-(float)randomPixelValue:(float)pixel bitsPerSample:(int)bitsPerSample pixRange:(float)pixRange{
	bool debugGrain = false;
	if(debugGrain)NSLog(@"randomPixelValue entered... pixel=%f / bitsPerSample=%d / pixRange=%f",pixel,bitsPerSample,pixRange);
//	float minValue =0;
	float deviation = 0;
	unsigned long maxValue = 0XFFFFFFF;
	float outputValue = 0.0;
//	if(debugGrain)NSLog(@"randomPixelValue check 1");
	if(bitsPerSample==8)maxValue = 0XFF;
	else if(bitsPerSample==12)maxValue = 0X00000FFF;
	else if(bitsPerSample==16)maxValue = 0X0000FFFF;
	else if(bitsPerSample==20)maxValue = 0X000FFFFF;
	else if(bitsPerSample==24)maxValue = 0X00FFFFFF;
	else if(bitsPerSample==32)maxValue = 0XFFFFFFFF;
//	if(debugGrain)NSLog(@"randomPixelValue check 2");
	
	

	//if(pixel>0)	outputValue = rand()%pixel;
	deviation = maxValue*pixRange;
	deviation = (float)(rand()%(int)deviation);
	if(debugGrain)NSLog(@"randomPixelValue check 3: deviation=%f",deviation);
	if([ImageDebayering randomBoolean]) deviation=(-1)*deviation;
	if(debugGrain)NSLog(@"randomPixelValue check 4: deviation=%f",deviation);
	outputValue= (float)pixel+deviation;
	if(debugGrain)NSLog(@"randomPixelValue check 5: outputValue=%f",outputValue);
	if(outputValue<0)outputValue =0.0;
	if(debugGrain)NSLog(@"randomPixelValue check 6: outputValue=%f",outputValue);
	if(outputValue>maxValue)outputValue=maxValue;
	if(debugGrain)NSLog(@"randomPixelValue check 7: outputValue=%f",outputValue);
	return outputValue;
	//else return 0;
}

-(float)randomPixelDeviation:(float)pixel bitsPerSample:(int)bitsPerSample rangePercent:(float)range{
//	int minValue =0;
	int deviation = 0;
	unsigned long maxValue = 0XFFFFFFF;
//	float outputValue = 0;
	if(bitsPerSample==8)maxValue = 0XFF;
	else if(bitsPerSample==12)maxValue = 0X00000FFF;
	else if(bitsPerSample==16)maxValue = 0X0000FFFF;
	else if(bitsPerSample==20)maxValue = 0X000FFFFF;
	else if(bitsPerSample==24)maxValue = 0X00FFFFFF;
	else if(bitsPerSample==32)maxValue = 0XFFFFFFFF;

	//if(pixel>0)	outputValue = rand()%pixel;
	float desc = 2.0-pixel/(float)maxValue;
//	NSLog(@"FUNC randomPixelDeviation: desc = %f",desc);
	deviation = ((float)range/100.0)*maxValue;
	deviation = (float) (rand()%(int)deviation);
	if([ImageDebayering randomBoolean]) deviation=(-1)*deviation;
	deviation = desc*deviation;
	return (float)deviation;
	//else return 0;
}


-(int)getMaxValue:(int)a value2:(int)b value3:(int)c value4:(int)d{
	int max1 = (a>b)?a:b;
	int max2 = (c>d)?c:d;
	int max = (max1>max2)?max1:max2;
	return max;
}

-(int)getMinValue:(int)a value2:(int)b value3:(int)c value4:(int)d{
	int min1 = (a>b)?b:a;
	int min2 = (c>d)?d:c;
	int min = (min1>min2)?min2:min1;
	return min;
}

-(int)getPatternVariance:(int *)lumValPattern{
	int i=0;
	int min=255;
	int max=0;
	for(i=0;i<sizeof(lumValPattern);i++){
		//NSLog(@"lumValPattern[%d]=%d\n",i,lumValPattern[i]);
		min=(min>lumValPattern[i])?lumValPattern[i]:min;
		max=(max>lumValPattern[i])?max:lumValPattern[i];
	}
	return max-min;
}
	
-(NSMutableData *)linearDebayering:(NSMutableData *)imgBuf imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel {
	NSLog(@"Call to func linearDebayering\n");
	
}	
/*
-(void)initializeMemory{
//Initialize Memory 

		NSPointerFunctionsOptions options=(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality);
		memBlockPointers=[NSPointerArray pointerArrayWithOptions: options];

//		memBlockPointers=[NSPointerArray strongObjectsPointerArray];
}

-(void *)memBlock:(long *)size{
//NSLog(@"ENTERED memBlock");	
	void * p;
	p = malloc(size);
//NSLog(@"memBlock malloc done");	
//	[memPointers addObject:p];
	[memBlockPointers addPointer:p];
//	memCounter++;
//NSLog(@"FINISHED memBlock");	
return p;
}

-(int)countMemObjects{
	int objCount = [memBlockPointers count];
//	int objCount2 = [memPointers count];
		NSLog(@"~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+* COUNTING MEMORY OBJECTS (Pointers):  - COUNT: %d\n", objCount);
//		NSLog(@"~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+* COUNTING MEMORY OBJECTS (Pointers):  - COUNT2: %d\n", objCount2);
//		NSLog(@"~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+* COUNTING MEMORY OBJECTS (Pointers):  - COUNT2: %d\n", memCounter);

	return objCount;
}

-(void)freeAllMemObjects{
	@try{
		int i=0;
		[memBlockPointers compact]; //Removes NULL values
		int total = memBlockPointers.count;
		//This iteration breaks, might be of freeing memory parts first, that store more memory parts -> try LIFO
		for (i=total-1; i>=0; i--) {
			void *seg = [memBlockPointers pointerAtIndex:i];
	//		NSLog(@"free memory...i=%d / total=%d / seg=%p\n",i, total, seg);
			free(seg);
	//		seg = nil;
			[memBlockPointers removePointerAtIndex:i];
		}
	}
	@catch (NSException *e){
		NSLog(@"Something went wrong while freeing memory\n");
	}
	NSLog(@"imageDebayering.m - free memory - DONE\n");
//	memBlockPointers=nil;
//	[MemoryManagement initializeMemory];
//	[memBlockPointers release];
}
*/
//TO DO: still to solve: return 2D array of RGB pixels
//Return just dataBuffer NSData image data to append directly to the output TIFF file

//DEFINITION FROM .h
//+ (NSMutableData *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes scaleFactor:(float)resize rescaleMethod:(int)rescaleMethod params:(inputParams)settings;

//- (NSMutableData *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes scaleFactor:(float)resize{
//- (NSMutableData *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes{
//- (dataBlock *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes{
//- (rgbBytes *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel{
//- (void)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel{
//- (NSMutableData *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes scaleFactor:(float)resize rescaleMethod:(int)rescaleMethod{
+ (NSMutableData *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes scaleFactor:(float)resize rescaleMethod:(int)rescaleMethod params:(inputParams)settings{

NSLog(@"into it...");
	bool debug = false;
//	bool debug2 = false;
	bool debug3 = false;
	bool debug4 = false;
	bool debug32Bit = false;
	bool debugBuf2Bytes = false;
	bool debugColor = false;
	bool debugDebayering = false;
	bool debugExperimental = false;
	bool debug8Bit = false;
//	bool debugRescale = true;
	
//	NSData *imageData = nil;
	NSMutableData *dataBuffer = [NSMutableData data];
	NSMutableData *testBuffer = [NSMutableData data];
		//if(debug4)NSLog(@"testArray[]={%d,%d,%d,%d}\n", arr[0],arr[1],arr[2],arr[3]);
		if(debug4)NSLog(@"cfaPatternBytes[]={%d,%d,%d,%d}\n", cfaPatternBytes[0],cfaPatternBytes[1],cfaPatternBytes[2],cfaPatternBytes[3]);
		
	//check if settings are passed correctly
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
/*

		float resize; // this deactivates Rescaling entirely
		int rescaleMethod;
		int debayeringMethod;
		bool doBlur;
		float randomMix; // only for debyeringMethod = 3, 5, 7
		int randIts;		// only for debyeringMethod = 3, 5, 7
		float debayeringVariance;		//only for debyeringMethod == 7
		float blurVariance;		

*/	
NSLog(@"SETTINGS: settings.doRescale=%d",settings.doRescale);
NSLog(@"SETTINGS: settings.resize=%.2f",settings.resize);
NSLog(@"SETTINGS: settings.rescaleMethod=%d",settings.rescaleMethod);
NSLog(@"SETTINGS: settings.debayeringMethod=%d",settings.debayeringMethod);
NSLog(@"SETTINGS: settings.doBlur=%d",settings.doBlur);
NSLog(@"SETTINGS: settings.patternSize=%d",settings.patternSize);
NSLog(@"SETTINGS: settings.randomMix=%.2f",settings.randomMix);
NSLog(@"SETTINGS: settings.randIts=%d",settings.randIts);
NSLog(@"SETTINGS: settings.debayeringVariance=%.2f",settings.debayeringVariance);
NSLog(@"SETTINGS: settings.blurVariance=%.2f",settings.blurVariance);
	
	//TO DO:
	//still a line where the pattern breaks
	//going from top right in a -1 per row angle
	//Image of correct size and color patter
	//this happens, because the last Pixel per row is already as it should start the next row
	
	//der algorithmus bricht schon bei (imageWidth-1) die patternbildung um ->fehler irgendwo hier in dieser funktion
	
	long byteSize = [imageRawBuffer length];
	if(debug)NSLog(@"byteSize of ImageRawBuffer: %d Bytes\n" ,byteSize);
	
	//allocate memory on stack first
	long calcSize = 0;
	int bitsPerByte = 8;
	if(debug){
		//imageWidth = 16; //for testing
		imageHeight = 16; //for testing
		//calcSize = 256; //for testing
	}
	if(debug)NSLog(@"FUNCTION convertRawToRGB: imageWidth=%i / imageHeight=%i / bitsPerSample=%i: / samplesPerPixel=%i / bitsPerByte=%i\n" ,imageWidth, imageHeight, bitsPerSample, samplesPerPixel,bitsPerByte);
	long test1 = imageWidth*imageHeight;
	if(debug)NSLog(@"FUNCTION convertRawToRGB: calculate buffersize: test1=imageWidth*imageHeight=%i\n",imageWidth*imageHeight);
	long test2=bitsPerSample*samplesPerPixel;
	if(debug)NSLog(@"FUNCTION convertRawToRGB: calculate buffersize: test2=bitsPerSample*samplesPerPixel=%i\n",bitsPerSample*samplesPerPixel);
//	long test3=test1*test2;
	if(debug)NSLog(@"FUNCTION convertRawToRGB: calculate buffersize: test3=test1*test2=%i\n",test1*test2);

	calcSize = imageWidth*imageHeight*bitsPerSample*samplesPerPixel/bitsPerByte;
	//TO DO: check if calculated size is equal to buffer size, else error handling
	if(debug)NSLog(@"calculated size for image data: %d Bytes\n" ,calcSize);
	unsigned char *imageBytes = malloc(calcSize);
//	unsigned char *imageBytes = calloc(calcSize);
	if(imageBytes == NULL){
		if(debug)NSLog(@"ERROR IN ALLOCATING MEMORY FOR LARGE ARRAY of size[%l]!\n",calcSize);
	}
	if(debug)NSLog(@"FUNCTION convertRawToRGB DEBUG 1\n");
	
	
	
	
	
	
	
	int i,j =0;
//	int row =0;
	int rows =0;
//	int col = 0;
	int cols = 0;
//	long seqImagePix = 0; 
	if(debug)NSLog(@"FUNCTION convertRawToRGB DEBUG 2\n");

//	int colorValue=0;
	float rgbValue[3]; //8Bit per color, 3 colors R/G/B = 0/1/2
	unsigned char outputValue[3];
//	float rgbValue[3]; //8Bit per color, 3 colors R/G/B = 0/1/2
	unsigned long long  rgbValue32Bit[3]; //32Bit per color, 3 colors R/G/B = 0/1/2 (Fehler: Karo-Pattern und Rot-Stcih, bzw. nur Rot werte korrekt, restliche GRBG Pixel dunkel
//	unsigned char *byteMem;
//	byteMem = malloc(3); //allocate memory for 3 bytes of RGB Values (Default 8Bit per color)
	if(debug)NSLog(@"FUNCTION convertRawToRGB DEBUG 3\n");

	if(debug)NSLog(@"FUNCTION convertRawToRGB imageWidth=%d / imageHeight=%d\n",imageWidth,imageHeight);

	//might be smart to use long instead and return array[x][y] of long[3]
	
	NSLog(@"Malloc START");
	//Allocate memory on heap for 2D-Array of imageWidth*ImageHeight (*RGB Pixels?)
	//Allocate first, then initialize array?
	rgbBytes** pixel = [ImageDebayering make2DRgbArray:imageWidth y:imageHeight];
	rgbBytes** pixel32Bit = [ImageDebayering make2DRgbArray:imageWidth y:imageHeight];
	rgbBytes** processedPixel = [ImageDebayering make2DRgbArray:imageWidth y:imageHeight];
	rgbBytes** blurredPixel = [ImageDebayering make2DRgbArray:imageWidth y:imageHeight];
	NSLog(@"Malloc DONE");

	
	
	//cfaPattern
	//fallback, if not set or not found
	if( (cfaPatternBytes[0]==0) && (cfaPatternBytes[1]==0) && (cfaPatternBytes[2]==0) && (cfaPatternBytes[3]==0)){
		cfaPatternBytes[0]=1;
		cfaPatternBytes[1]=2;
		cfaPatternBytes[2]=0;
		cfaPatternBytes[3]=1;
	}
	//topLeft = cfaPatternBytes[0];
	
	
	long pixelCount = imageWidth*imageHeight;
	int k,l=0;
//	unsigned char onePixel[3]; //not 3byte, should be 12 bit = 1 1/2 byte
//	unsigned char resetPixel[3];
	int imgCol, imgRow = 0;
	int pixel12Bit = 0;
//	int pixel8Bit = 0; //should be a long for any BitsPerSample Value of pixel
	unsigned long pixel4Byte = 0; //should be a long for any BitsPerSample Value of pixel
	//int color=0;
	float color=0; //make 32Bit ready
//	int internalBitRes = 8;
//	bool is32BitFloat =true;
//	bool test32Bit = false;


	/****************************************/
	//	READ IN DATA BUFFER
	/****************************************/
	
	if(debug)NSLog(@"pixelCount=%ld\n",pixelCount);
/*	
	if (bitsPerSample ==8){
			NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
			pixelCount = imageWidth*imageHeight;
			k=0;l=0;
			//unsigned char onePixel[3]; //not 3byte, should be 12 bit = 1 1/2 byte
			//unsigned char resetPixel[3];
			imgCol=0; imgRow = 0;
			pixel8Bit = 0;
			color=0;
			
			//CFA Pattern ->try to fill from IFD CFAPttern
			unsigned char pattern[2][2];
			pattern[0][0]=cfaPatternBytes[0]; //=1;
			pattern[1][0]=cfaPatternBytes[1]; //=0;
			pattern[0][1]=cfaPatternBytes[2]; //=2;
			pattern[1][1]=cfaPatternBytes[3]; //=1;
			if(debugBuf2Bytes)NSLog(@"cfaPatternBytes[]={%d,%d,%d,%d}\n", cfaPatternBytes[0],cfaPatternBytes[1],cfaPatternBytes[2],cfaPatternBytes[3]);
			if(debugBuf2Bytes)NSLog(@"cfaPatternBytes + i ={%d,%d,%d,%d}\n", cfaPatternBytes ,cfaPatternBytes +1,cfaPatternBytes + 2,cfaPatternBytes+3);
			
			[imageRawBuffer getBytes:imageBytes length:calcSize]; 
			NSLog(@"DEBUG - before malloc\n");
			int *pixelArray = malloc(pixelCount * samplesPerPixel * sizeof(long));
			NSLog(@"DEBUG - after malloc\n");
			NSLog(@"DEBUG - calcSize=%d / array sizeof=%d / pixelCount=%d\n",calcSize, sizeof(imageBytes),pixelCount);
			for(i=0;i<calcSize;i++){
				if(debug && ((l%10000==0) || (i>calcSize-127 && i<calcSize)))
				{
					NSLog(@"imageBytes[%d]=",i);
					int testThis = imageBytes[i];
					NSLog(@"%d",testThis);
				}
				pixel8Bit=(int)(imageBytes[i]&0XFF);
				if(debug && ((l%10000==0) || (i>calcSize-127 && i<calcSize)))NSLog(@"imageBytes[%d]=%02X / imageBytes[%d]=%02X / \n",i, i+1,imageBytes[i],imageBytes[i+1] );
				pixelArray[l]=pixel8Bit;
				l++;
			}
			NSLog(@"DEBUG - copy imageBytes to pixelArray done - pixelCount=%d / sizeof(pixelArray)=%d\n",pixelCount, sizeof(pixelArray));
			

			NSLog(@"samplesPerPixel=%d\n",samplesPerPixel);
			//for(k=0;k<pixelCount;k++){
	//		for(k=0;k<pixelCount*samplesPerPixel;k++){
			for(k=0;k<calcSize;k++){
				rgbValue[0]=rgbValue[1]=rgbValue[2]=0;
				rgbValue32Bit[0]=rgbValue32Bit[1]=rgbValue32Bit[2]=0;
				//color=pixelArray[k];
				color=(float)(imageBytes[i]&0XFF);
	//NSLog(@"color=%d (%04X)/ k=%d / imgCol=%d / imgRow=%d \n",color, color,k, imgCol, imgRow);
			
				//imgCol = k%imageWidth;
				//if(k!=0 && k%imageWidth==0)	imgRow++;
				imgCol = (k/samplesPerPixel)%imageWidth;
				if(k!=0 && (k/samplesPerPixel)%imageWidth==0)	imgRow++;
				//if(debugColor)NSLog(@"color=%d (%04X)/ k=%d / imgCol=%d / imgRow=%d \n",color, color,k, imgCol, imgRow);
				rgbBytes rgbPixel;
				rgbBytes rgbPixel32Bit;
				
	if(debug8Bit && ((l%100==0) || (i>calcSize-127 && i<calcSize)))NSLog(@"(2) color=%lu (%04X)/ k=%d / imgCol=%d / imgRow=%d \n",color, color,k, imgCol, imgRow);
				if(samplesPerPixel==1){
					//TO DO: toogle pattern every row
//					color = [ImageDebayering normalizeTo8Bit:color bitsPerSample:bitsPerSample];

					int toggleCol=imgCol%2; 
					int toggleRow=imgRow%2;
					int daPattern = pattern[toggleCol][toggleRow];
					if(debugColor)NSLog(@"pattern[%d][%d]]=%d\n",toggleCol, toggleRow, daPattern);
					if(debugColor)NSLog(@"COLOR=%lu\n",color);
					
					//rgbValue[pattern[imgCol%2][imgRow%2]]=[ImageDebayering normalizeTo8Bit:color bitsPerSample:bitsPerSample];
					rgbValue[daPattern]=color;
					//rgbValue32Bit[daPattern]=color;

					//rgbBytes rgbPixel;
					rgbPixel.red = rgbValue[0];
					rgbPixel.green = rgbValue[1];
					rgbPixel.blue = rgbValue[2];

					
					if(debugBuf2Bytes||imgRow>1363)NSLog(@"pixel[%d][%d] - pattern[%d][%d] - rgbValue[%d] (%lu/%lu/%lu) \n",imgCol,imgRow, toggleCol, toggleRow,daPattern,rgbValue[0],rgbValue[1],rgbValue[2]);
					pixel[imgCol][imgRow] = rgbPixel;
					//pixel32Bit[imgCol][imgRow] = rgbPixel32Bit;
				}
				else if(samplesPerPixel==3){
	//NSLog(@"CHECK 1\n");
					
					int toggleCol=imgCol%2; 
					int toggleRow=imgRow%2;
					int daPattern = pattern[toggleCol][toggleRow];

					
					//causes somehow a NSMallocException (default zone has run out of memory)
					//ERROR in imgRow! Greater than defined! factor 3 (+2): 4097 instead of 1366
					if(daPattern==0){
						rgbPixel.red = pixelArray[k];
						rgbPixel.green = 0;
						rgbPixel.blue = 0;	
					}
					if(daPattern==1){
						rgbPixel.red = 0;
						rgbPixel.green = pixelArray[k+1];
						rgbPixel.blue = 0;	
					}
					if(daPattern==2){
						rgbPixel.red = 0;
						rgbPixel.green = 0;
						rgbPixel.blue = pixelArray[k+2];	
					}
					k=k+2;
					

					int kModulo3 = k%3;
	//NSLog(@"CHECK 2: kModulo3=%d  / imgCol=%d / imgRow=%d /toggleCol=%d / toggleRow=%d / daPattern=%d\n",kModulo3 , imgCol , imgRow, toggleCol, toggleRow, daPattern);
	if(k%100000==0)NSLog(@"CHECK 2: k=%d / kModulo3=%d  / imgCol=%d / imgRow=%d /toggleCol=%d / toggleRow=%d / daPattern=%d\n",k, kModulo3 , imgCol , imgRow, toggleCol, toggleRow, daPattern);
	if(k>calcSize-100)NSLog(@"CHECK 2: k=%d / kModulo3=%d  / imgCol=%d / imgRow=%d /toggleCol=%d / toggleRow=%d / daPattern=%d\n",k, kModulo3 , imgCol , imgRow, toggleCol, toggleRow, daPattern);
					//if(k%3==2)pixel[imgCol][imgRow] = rgbPixel;
	//NSLog(@"CHECK 3\n");

					//if(k+1<pixelCount*samplesPerPixel)rgbPixel.green = pixelArray[++k];
					//if(k+1<pixelCount*samplesPerPixel)rgbPixel.blue = pixelArray[++k];			
				}
				else{
					//check specs for default and extraSamples
					// value could be greater than 3, with m extra components
					rgbPixel.red = pixelArray[k];
					if(k+1<pixelCount*samplesPerPixel)rgbPixel.green = pixelArray[k+1];
					if(k+1<pixelCount*samplesPerPixel)rgbPixel.blue = pixelArray[k+2];
					k=k+(samplesPerPixel-1); //cause will be increased k++ by the for loop
				}
				pixel[imgCol][imgRow] = rgbPixel;
			}
	NSLog(@"READING IMAGE DATA TO ARRAY - DONE - imgRow=%d / imgCol=%d\n",imgRow, imgCol);

			free(pixelArray);
			[pool drain];
	}
*/	

	//if (bitsPerSample ==8){}
	
	if(debug)NSLog(@"FUNCTION convertRawToRGB DEBUG 4\n");
	
	if (bitsPerSample ==12){
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	

			pixelCount = imageWidth*imageHeight;
			k=0;l=0;
			//unsigned char onePixel[3]; //not 3byte, should be 12 bit = 1 1/2 byte
			//unsigned char resetPixel[3];
			imgCol=imgRow = 0;
			pixel12Bit = 0;
			color=0;	
//			unsigned long color32Bit=0;			
			
			//CFA Pattern ->try to fill from IFD CFAPttern
			unsigned char pattern[2][2];
			pattern[0][0]=cfaPatternBytes[0]; //=1;
			pattern[1][0]=cfaPatternBytes[1]; //=0;
			pattern[0][1]=cfaPatternBytes[2]; //=2;
			pattern[1][1]=cfaPatternBytes[3]; //=1;
			if(debugBuf2Bytes)NSLog(@"cfaPatternBytes[]={%d,%d,%d,%d}\n", cfaPatternBytes[0],cfaPatternBytes[1],cfaPatternBytes[2],cfaPatternBytes[3]);
			if(debugBuf2Bytes)NSLog(@"cfaPatternBytes + i ={%d,%d,%d,%d}\n", cfaPatternBytes ,cfaPatternBytes +1,cfaPatternBytes + 2,cfaPatternBytes+3);
			
			[imageRawBuffer getBytes:imageBytes length:calcSize]; 
			//int pixelArray[pixelCount];
			NSLog(@"DEBUG - before malloc\n");
//			int *pixelArray = malloc(pixelCount * sizeof(int));
			float *pixelArray = malloc(pixelCount * sizeof(float)); //for 32Bit
//			unsigned long *pixelArray = malloc(pixelCount * sizeof(unsigned long)); //for 32Bit
			NSLog(@"DEBUG - after malloc\n");
			for(i=0;i<calcSize;i++){
				if(i%3==0) //read first half of 3 bytes
				{
					pixel12Bit=((int)(imageBytes[i]&0XFF))<<4 | ((int)(imageBytes[i+1]&0XF0))>>4;
					if(debug)NSLog(@"imageBytes[%d]=%02X / imageBytes[%d]=%02X / \n",i, i+1,imageBytes[i],imageBytes[i+1] );
					if(debug)NSLog(@"imageBytes[%d]&0XFF<<4=%04X / (imageBytes[%d]&0XF0)>>4=%04X / \n",i,((imageBytes[i]&0XFF)<<4),i+1,((imageBytes[i+1]&0XF0)>>4));
					
				}
				else { //read last half of 3 bytes
					if(i+1 >= calcSize) break;			
					pixel12Bit=((int)(imageBytes[i]&0X0F))<<8 | (int)(imageBytes[i+1]&0XFF);
					if(debug)NSLog(@"imageBytes[%d]=%02X / imageBytes[%d]=%02X / \n",i, i+1,imageBytes[i],imageBytes[i+1] );
					if(debug)NSLog(@"imageBytes[%d]&0X0F))<<8=%04X / (imageBytes[%d]&0XFF=%04X / \n",i,((imageBytes[i]&0X0F)<<8),i+1,((imageBytes[i+1]&0XFF)));
					i=i++;
				}
				if(debug){
				if(0<=i && i<100)NSLog(@"DEBUG - i=%d / l=%d / pixelCount=%d / calcSize=%d / pixel12Bit=%04X\n",i,l,pixelCount, calcSize,pixel12Bit);
				if(l%10000==0)NSLog(@"DEBUG every 10.000- i=%d / l=%d / pixelCount=%d / calcSize=%d / pixel12Bit=%04X\n",i,l,pixelCount, calcSize,pixel12Bit);
				if((pixelCount-100)<i && (i<pixelCount))NSLog(@"DEBUG - i=%d / l=%d / pixelCount=%d / calcSize=%d / pixel12Bit=%04X\n",i,l,pixelCount, calcSize,pixel12Bit);
				}
				pixelArray[l]=pixel12Bit;
				l++;
			}
			

			for(k=0;k<pixelCount;k++){
				//rgbValue= resetPixel;
				rgbValue[0]=rgbValue[1]=rgbValue[2]=0;
				rgbValue32Bit[0]=rgbValue32Bit[1]=rgbValue32Bit[2]=0;
				//[imageRawBuffer getBytes:onePixel length:3]; //wrong, not 3 bytes - just 1 1/2 bytes = 12 bit
				color=(float)pixelArray[k];
			
				//color=[ImageDebayering getColor:onePixel];
				/*if(k<imageWidth)imgCol=k;
				else 
				*/
				imgCol = k%imageWidth;
				if(k!=0 && k%imageWidth==0)	imgRow++;
				if(debugColor)NSLog(@"color=%lu (%04X)/ k=%d / imgCol=%d / imgRow=%d \n",color, color,k, imgCol, imgRow);
				
				//TO DO: toogle pattern every row
//				color = [ImageDebayering normalizeTo8Bit:color bitsPerSample:bitsPerSample];
				/*
				if(internalBitRes==8)color = [ImageDebayering normalizeTo8Bit:color bitsPerSample:bitsPerSample];
				else color = [ImageDebayering normalizeTo32Bit:color bitsPerSample:bitsPerSample];
				*/
				//if(test32Bit) color = [ImageDebayering normalizeTo8Bit:color bitsPerSample:32];
				int toggleCol=imgCol%2; 
				int toggleRow=imgRow%2;
				int daPattern = pattern[toggleCol][toggleRow];
				if(debugColor)NSLog(@"pattern[%d][%d]]=%d\n",toggleCol, toggleRow, daPattern);
				if(debugColor)NSLog(@"COLOR=%lu\n",color);
				
				//rgbValue[pattern[imgCol%2][imgRow%2]]=[ImageDebayering normalizeTo8Bit:color bitsPerSample:bitsPerSample];
				rgbValue[daPattern]=color;
				rgbValue32Bit[daPattern]=color;

//				rgbValue[1]=color;
//				rgbValue32Bit[1]=color;
				
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];

				rgbBytes rgbPixel32Bit;
				rgbPixel32Bit.red = rgbValue32Bit[0];
				rgbPixel32Bit.green = rgbValue32Bit[1];
				rgbPixel32Bit.blue = rgbValue32Bit[2];
		/*
		int u=0;
		for(u=0;u<3;u++){
			NSLog(@"rgbValue[%d]=%d / rgbValue32Bit[%d]=%d \n", u, rgbValue[u], u, rgbValue32Bit[u]);
		}				
		*/	
				if(debugBuf2Bytes)NSLog(@"rgbPixel32Bit.red = %lu / rgbPixel32Bit.green =%lu / rgbPixel32Bit.blue =%lu / rgbValue32Bit[0]=%d, rgbValue32Bit[1]=%d, rgbValue32Bit[2]=%d\n",rgbPixel32Bit.red ,rgbPixel32Bit.green,rgbPixel32Bit.blue, rgbValue32Bit[0], rgbValue32Bit[1], rgbValue32Bit[2]);
				if(debugBuf2Bytes)NSLog(@"rgbPixel.red = %lu / rgbPixel.green =%lu / rgbPixel.blue =%lu / rgbValue[0]=%d, rgbValue[1]=%d, rgbValue[2]=%d\n",rgbPixel.red ,rgbPixel.green,rgbPixel.blue, rgbValue[0], rgbValue[1], rgbValue[2]);
//				if(debugBuf2Bytes)NSLog(@"pixel[%d][%d] - pattern[%d][%d] - rgbValue[%d] (%lu/%lu/%lu) \n",imgCol,imgRow, toggleCol, toggleRow,daPattern,rgbValue[0],rgbValue[1],rgbValue[2]);
//				if(debugBuf2Bytes)NSLog(@"32Bit: pixel[%d][%d] - pattern[%d][%d] - rgbValue32Bit[%d] (%lu/%lu/%lu) \n",imgCol,imgRow, toggleCol, toggleRow,daPattern,rgbValue32Bit[0],rgbValue32Bit[1],rgbValue32Bit[2]);
				pixel[imgCol][imgRow] = rgbPixel;
				pixel32Bit[imgCol][imgRow] = rgbPixel32Bit;
			}
			free(pixelArray);
			[pool drain];
	}
	NSLog(@"pixel[][] size=%d\n",sizeof(pixel));
	NSLog(@"pixel32Bit[][] size=%d\n",sizeof(pixel32Bit));
	
	cols=imageWidth;
	rows=imageHeight;
	
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 6\n");

	//if (bitsPerSample ==16){}
	//if (bitsPerSample ==24){}
	//if (bitsPerSample ==32){}
	
	if(bitsPerSample%8==0) //This is for all N*8 pixel (byte)
	{
			int byteSize = bitsPerSample/8; //get count of bytes first, should be 1-4
			NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
			pixelCount = imageWidth*imageHeight;
			k=0;l=0;
			//unsigned char onePixel[3]; //not 3byte, should be 12 bit = 1 1/2 byte
			//unsigned char resetPixel[3];
			imgCol=0; imgRow = 0;
			pixel4Byte = 0;
			color=0;
			
			//CFA Pattern ->try to fill from IFD CFAPttern
			unsigned char pattern[2][2];
			pattern[0][0]=cfaPatternBytes[0]; //=1;
			pattern[1][0]=cfaPatternBytes[1]; //=0;
			pattern[0][1]=cfaPatternBytes[2]; //=2;
			pattern[1][1]=cfaPatternBytes[3]; //=1;
			if(debugBuf2Bytes)NSLog(@"cfaPatternBytes[]={%d,%d,%d,%d}\n", cfaPatternBytes[0],cfaPatternBytes[1],cfaPatternBytes[2],cfaPatternBytes[3]);
			if(debugBuf2Bytes)NSLog(@"cfaPatternBytes + i ={%d,%d,%d,%d}\n", cfaPatternBytes ,cfaPatternBytes +1,cfaPatternBytes + 2,cfaPatternBytes+3);
			
			[imageRawBuffer getBytes:imageBytes length:calcSize]; 
			int *pixelArray = malloc(pixelCount * samplesPerPixel * sizeof(long));
			for(i=0;i<calcSize;i=i+byteSize){
				//pixel4Byte=(int)(imageBytes[i]&0XFF);
				pixel4Byte=0;
				int c=0;
				for(c=i;c<i+byteSize;c++){ //Read in the selected byte plus the next (byteSize-1) ones with bitshifting
					//pixel4Byte+=(int)((imageBytes[c]&0XFF)<<8);
					pixel4Byte = pixel4Byte<<8;
					pixel4Byte+=(int)(imageBytes[c]&0XFF);
					if(debug8Bit &&(i%1000==0))NSLog(@"NEW 8Bit Read in: imageBytes[%d]=%02X / pixel4Byte=%08X", c, imageBytes[c], pixel4Byte);
				}
				
				if(debug && ((l%10000==0) || (i>calcSize-127 && i<calcSize)))NSLog(@"imageBytes[%d]=%02X / imageBytes[%d]=%02X / \n",i, i+1,imageBytes[i],imageBytes[i+1] );
				pixelArray[l]=pixel4Byte;
				l++;
			}
			int pixelCount = imageWidth*imageHeight*samplesPerPixel;

			//for(k=0;k<calcSize;k++){
			for(k=0;k<pixelCount;k++){
				rgbValue[0]=rgbValue[1]=rgbValue[2]=0;
				color=(float)pixelArray[k];
				imgCol = (k/samplesPerPixel)%imageWidth;
				if(k!=0 && (k/samplesPerPixel)%imageWidth==0)	imgRow++;

				rgbBytes rgbPixel;
				int toggleCol=imgCol%2; 
				int toggleRow=imgRow%2;
				int daPattern = pattern[toggleCol][toggleRow];
				
	if(debug8Bit && ((k%100==0) || (i>calcSize-127 && i<calcSize)))NSLog(@"(2) color=%.4f (%08X)/ k=%d / imgCol=%d / imgRow=%d \n",color, color,k, imgCol, imgRow);
				if(samplesPerPixel==1){
					//TO DO: toogle pattern every row

					if(debugColor)NSLog(@"pattern[%d][%d]]=%d\n",toggleCol, toggleRow, daPattern);
					if(debugColor)NSLog(@"COLOR=%lu\n",color);
					
					rgbValue[daPattern]=color;
					rgbPixel.red = rgbValue[0];
					rgbPixel.green = rgbValue[1];
					rgbPixel.blue = rgbValue[2];
					
					//pixel[imgCol][imgRow] = rgbPixel;
				}
				else if(samplesPerPixel==3){
					//causes somehow a NSMallocException (default zone has run out of memory)
					//ERROR in imgRow! Greater than defined! factor 3 (+2): 4097 instead of 1366
					if(daPattern==0){
						rgbPixel.red = (float)pixelArray[k];
						rgbPixel.green = 0.0;
						rgbPixel.blue = 0.0;	
					}
					if(daPattern==1){
						rgbPixel.red = 0.0;
						rgbPixel.green = (float)pixelArray[k+1];
						rgbPixel.blue = 0.0;	
					}
					if(daPattern==2){
						rgbPixel.red = 0.0;
						rgbPixel.green = 0.0;
						rgbPixel.blue = (float)pixelArray[k+2];	
					}
					k=k+2;
					

					int kModulo3 = k%3;
	//NSLog(@"CHECK 2: kModulo3=%d  / imgCol=%d / imgRow=%d /toggleCol=%d / toggleRow=%d / daPattern=%d\n",kModulo3 , imgCol , imgRow, toggleCol, toggleRow, daPattern);
	if(k%100000==0)NSLog(@"CHECK 2: k=%d / kModulo3=%d  / imgCol=%d / imgRow=%d /toggleCol=%d / toggleRow=%d / daPattern=%d\n",k, kModulo3 , imgCol , imgRow, toggleCol, toggleRow, daPattern);
	if(k>calcSize-100)NSLog(@"CHECK 2: k=%d / kModulo3=%d  / imgCol=%d / imgRow=%d /toggleCol=%d / toggleRow=%d / daPattern=%d\n",k, kModulo3 , imgCol , imgRow, toggleCol, toggleRow, daPattern);
					//if(k%3==2)pixel[imgCol][imgRow] = rgbPixel;
	//NSLog(@"CHECK 3\n");

					//if(k+1<pixelCount*samplesPerPixel)rgbPixel.green = pixelArray[++k];
					//if(k+1<pixelCount*samplesPerPixel)rgbPixel.blue = pixelArray[++k];			
				}
				else{
					//check specs for default and extraSamples
					// value could be greater than 3, with m extra components
					rgbPixel.red = (float)pixelArray[k];
					if(k+1<pixelCount*samplesPerPixel)rgbPixel.green = (float)pixelArray[k+1];
					if(k+1<pixelCount*samplesPerPixel)rgbPixel.blue = (float)pixelArray[k+2];
					k=k+(samplesPerPixel-1); //cause will be increased k++ by the for loop
				}
				if(debug8Bit)NSLog(@"pixel[%d][%d] - pattern[%d][%d] - rgbValue[%d] (%.2f/%.2f/%.2f) \n",imgCol,imgRow, toggleCol, toggleRow,daPattern,rgbPixel.red,rgbPixel.green,rgbPixel.blue);
				pixel[imgCol][imgRow] = rgbPixel;
			}
	NSLog(@"READING IMAGE DATA TO ARRAY - DONE - imgCol=%d / imgRow=%d\n",imgCol, imgRow);

			free(pixelArray);
			[pool drain];	
	
	}
	
	//BitsPerSample 10 & 14 (TIFF/EP Specs ignored - too awkward)

	free(imageBytes);
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 7\n");
	
	//dataBuffer = [ImageDebayering writeRgbPixelsToBufferXY:pixel rows:rows cols:cols];
	
	if(debug4)NSLog(@"IMAGE SIZE: Rows=%d / cols=%d\n",rows,cols);
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8\n");
	
	//Testing
	if(debug4)NSLog(@"FUNCTION convertRawToRGB dataBuffer=%@\n",dataBuffer);
	/*
	if(internalBitRes!=8)pixel=pixel32Bit;
	for(i=0;i<cols;i++){
		for(j=0;j<rows;j++){
					//if(debug32Bit)NSLog(@"READING 12BIT ORIGINAL FINISHED: RGB PIX[%i][%i]=(%lu/%lu/%lu)\n",i,j,pixel32Bit[i][j].red,pixel32Bit[i][j].green,pixel32Bit[i][j].blue);
					//if(debug32Bit)NSLog(@"READING 12BIT ORIGINAL FINISHED: RGB PIX[%i][%i]=(%lu/%lu/%lu)\n",i,j,pixel[i][j].red,pixel[i][j].green,pixel[i][j].blue);

		}
	}
	*/
	
	/***********************************************************************/
	//Try Debayering here. Perhaps encapsule later on into a dedicated function
	//altough it's difficult in objective c to pass multidimensional arrays of unknown size to a function and return them 

	//int debayeringMethod=5;
	int debayeringMethod=settings.debayeringMethod;
	//bool doBlur = true;
	//bool doRescale = false;
	
	// 0=straight bayer pattern / 1=bilinear debayering / 2=experimental / 3=random choice / 4=13Pixel / 5=13Pixel random / 6=NxN pattern / 7=NxN Gauss Pattern
	rgbBytes top, bottom, left, right;
	rgbBytes topLeft, topRight, bottomLeft, bottomRight;
	int valCount=0;
	//unsigned long valCount=0;
	//int redVal, greenVal, blueVal =0;
	float redVal, greenVal, blueVal =0.0;
	

	/*************************************************************/
	//			DEBAYERING METHOD 8 (luminosity - b/w)
	/*************************************************************/
	
	
	if(debayeringMethod==9){	
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;
				if(debugDebayering)NSLog(@"DEBAYERING START: pixel[%d][%d] - rgbValue = (%f/%f/%f) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				
				rgbBytes rgbPix32Bit;
				rgbPix32Bit=pixel[i][j];
				rgbValue32Bit[0]=rgbPix32Bit.red;
				rgbValue32Bit[1]=rgbPix32Bit.green;
				rgbValue32Bit[2]=rgbPix32Bit.blue;
				
				float lumVal = rgbPix.red+rgbPix.green+rgbPix.blue;
				rgbBytes rgbPixel;
				rgbPixel.red = lumVal;
				rgbPixel.green = lumVal;
				rgbPixel.blue = lumVal;
/*
				rgbPixel.red = 128.0;
				rgbPixel.green = 128.0;
				rgbPixel.blue = 128.0;
*/
				if(debugDebayering)NSLog(@"DEBAYERING FINISHED: pixel[%d][%d] - rgbValue = (%f/%f/%f) \n",i,j, rgbPixel.red,rgbPixel.green,rgbPixel.blue);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;
//				if(internalBitRes!=8)processedPixel[i][j] = rgbPixel32Bit;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)

		



	/*************************************************************/
	//		EXPERIMENTAL - DEBAYERING METHOD 10 (black and white Bilinear: green to b/w, red and blue calculated b/w)
	/*************************************************************/
	
	
	if(debayeringMethod==10){	
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;
				
				rgbBytes rgbPix32Bit;
				rgbPix32Bit=pixel[i][j];
				rgbValue32Bit[0]=rgbPix32Bit.red;
				rgbValue32Bit[1]=rgbPix32Bit.green;
				rgbValue32Bit[2]=rgbPix32Bit.blue;
				
				
				
//				if(rgbValue[0]==0 && rgbValue[2]==0) //this is a green pixel
				if(rgbValue32Bit[0]==0 && rgbValue32Bit[2]==0) //this is a green pixel
				{	

					rgbBytes rgbPixel;
					//Green value as b/w all channels
					greenVal = rgbValue[1];
					valCount =1;
					rgbValue[0]=greenVal/valCount;
					rgbValue[1]=greenVal/valCount;
					rgbValue[2]=greenVal/valCount;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - GREEN PIXEL\n",i,j);

				}
//				if(rgbValue[1]==0 && rgbValue[2]==0) //this is a red pixel
				if(rgbValue32Bit[1]==0 && rgbValue32Bit[2]==0) //this is a red pixel
				{
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - RED PIXEL\n",i,j);


					//calculate green value

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					//add red channel (self)
					greenVal+=rgbValue[0];valCount++;
					
					rgbValue[0]=greenVal/valCount;
					rgbValue[1]=greenVal/valCount;
					rgbValue[2]=greenVal/valCount;
					rgbValue32Bit[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - RED PIXEL\n",i,j);
					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

				}
//				if(rgbValue[0]==0 && rgbValue[1]==0) //this is a blue pixel
				if(rgbValue32Bit[0]==0 && rgbValue32Bit[1]==0) //this is a blue pixel
				{	
		if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - BLUE PIXEL\n",i,j);
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					greenVal+=rgbValue[2];valCount++;
					
					rgbValue[0]=greenVal/valCount;
					rgbValue[1]=greenVal/valCount;
					rgbValue[2]=greenVal/valCount;
		

				}
				//ATTENTION: do not write back processed pixels to original pixelPattern!
				//otherwised will be directly reused for calculating pixels -> interferrence and false values!
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];

				rgbBytes rgbPixel32Bit;
				rgbPixel32Bit.red = rgbValue32Bit[0];
				rgbPixel32Bit.green = rgbValue32Bit[1];
				rgbPixel32Bit.blue = rgbValue32Bit[2];
				
				if(debugDebayering)NSLog(@"DEBAYERING: pixel[%d][%d] - rgbValue = (%d/%d/%d) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;
//				if(internalBitRes!=8)processedPixel[i][j] = rgbPixel32Bit;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)





	/*************************************************************/
	//			DEBAYERING METHOD 1 (Bilinear)
	/*************************************************************/
	
	
	if(debayeringMethod==1){	
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;
				
				rgbBytes rgbPix32Bit;
				rgbPix32Bit=pixel[i][j];
				rgbValue32Bit[0]=rgbPix32Bit.red;
				rgbValue32Bit[1]=rgbPix32Bit.green;
				rgbValue32Bit[2]=rgbPix32Bit.blue;
				
				
				
//				if(rgbValue[0]==0 && rgbValue[2]==0) //this is a green pixel
				if(rgbValue32Bit[0]==0 && rgbValue32Bit[2]==0) //this is a green pixel
				{	
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - (%lu,%lu,%lu) - GREEN PIXEL\n",i,j,rgbValue[0],rgbValue[1],rgbValue[2]);


//TO DO: Check for alternating red or blue at left/right!!!!

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%d - GREEN PIXEL\n",redVal,valCount);
					if(i%2==0)
					{ //even row: red is left and right
						if(i>0){left=pixel[i-1][j]; redVal+=left.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%d - GREEN PIXEL\n",redVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; redVal+=right.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%d - GREEN PIXEL\n",redVal,valCount);
					}
					else
					{ //odd row: red is top and bottom
						if(j>0){top=pixel[i][j-1]; redVal+=top.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%d - GREEN PIXEL\n",redVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; redVal+=bottom.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%d - GREEN PIXEL\n",redVal,valCount);
					}
					
					
					rgbValue[0]=redVal/valCount;
					rgbValue32Bit[0]=redVal/valCount;
//					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - GREEN PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%d - GREEN PIXEL\n",blueVal,valCount);
					if(i%2!=0) //odd row: blue is left and right
					{
						if(i>0){left=pixel[i-1][j]; blueVal+=left.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%d - GREEN PIXEL\n",blueVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; blueVal+=right.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%d - GREEN PIXEL\n",blueVal,valCount);
					}
					else //even row: blue is top and bottom
					{
						if(j>0){top=pixel[i][j-1]; blueVal+=top.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%d - GREEN PIXEL\n",blueVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; blueVal+=bottom.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%d - GREEN PIXEL\n",blueVal,valCount);
					}
					
					
					rgbValue[2]=blueVal/valCount;
					rgbValue32Bit[2]=blueVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - GREEN PIXEL\n",i,j);



				}
//				if(rgbValue[1]==0 && rgbValue[2]==0) //this is a red pixel
				if(rgbValue32Bit[1]==0 && rgbValue32Bit[2]==0) //this is a red pixel
				{
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - RED PIXEL\n",i,j);


					//calculate green value
//					@try{left=pixel[i-1][j]; greenVal=left.green; valCount++;}@catch(NSException *theException) {}
//					@try{right=pixel[i+1][j]; greenVal=right.green; valCount++;}@catch(NSException *theException) {}
//					@try{top=pixel[i][j-1]; greenVal=top.green; valCount++;}@catch(NSException *theException) {}
//					@try{bottom=pixel[i][j+1]; greenVal=bottom.green; valCount++;}@catch(NSException *theException) {}

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%d - RED PIXEL\n",greenVal,valCount);
					
					
					rgbValue[1]=greenVal/valCount;
					rgbValue32Bit[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - RED PIXEL\n",i,j);
					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%d - RED PIXEL\n",blueVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; blueVal+=topLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%d - RED PIXEL\n",blueVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	blueVal+=topRight.blue; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%d - RED PIXEL\n",blueVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; blueVal+=bottomLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%d - RED PIXEL\n",blueVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; blueVal+=bottomRight.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%d - RED PIXEL\n",blueVal,valCount);


					if(debugDebayering)NSLog(@"DEBUG bottomRight done i=%d / j=%d -  blueVal=%f / valCount=%d - RED PIXEL\n",i,j, blueVal, valCount);
					
					if(debugDebayering)NSLog(@"DEBUG calc blueVal blueVal=%f / valCount=%d - RED PIXEL\n",blueVal,valCount);
					rgbValue[2]=blueVal/valCount;
					rgbValue32Bit[2]=blueVal/valCount;
					//@try{rgbValue[2]=blueVal/valCount;}
					//@catch(NSException *theException) {NSLog(@"Rummsassa!!!");}
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - RED PIXEL\n",i,j);

					
				}
//				if(rgbValue[0]==0 && rgbValue[1]==0) //this is a blue pixel
				if(rgbValue32Bit[0]==0 && rgbValue32Bit[1]==0) //this is a blue pixel
				{	
		if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - BLUE PIXEL\n",i,j);
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%d - BLUE PIXEL\n",greenVal,valCount);
		
					
					rgbValue[1]=greenVal/valCount;
					rgbValue32Bit[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - BLUE PIXEL\n",i,j);


					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%d - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; redVal+=topLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%d - BLUE PIXEL\n",redVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	redVal+=topRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%d - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; redVal+=bottomLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%d - BLUE PIXEL\n",redVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; redVal+=bottomRight.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%d - BLUE PIXEL\n",redVal,valCount);

					
					rgbValue[0]=redVal/valCount;
					rgbValue32Bit[0]=redVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - BLUE PIXEL: rgbValue[0]=redVal/valCount=%ld/%lu=%lu\n",i,j, redVal,valCount, rgbValue[0]);

				}
				//ATTENTION: do not write back processed pixels to original pixelPattern!
				//otherwised will be directly reused for calculating pixels -> interferrence and false values!
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];

				rgbBytes rgbPixel32Bit;
				rgbPixel32Bit.red = rgbValue32Bit[0];
				rgbPixel32Bit.green = rgbValue32Bit[1];
				rgbPixel32Bit.blue = rgbValue32Bit[2];
				
				if(debugDebayering)NSLog(@"DEBAYERING: pixel[%d][%d] - rgbValue = (%d/%d/%d) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;
//				if(internalBitRes!=8)processedPixel[i][j] = rgbPixel32Bit;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)

		

	/*************************************************************/
	//			DEBAYERING METHOD 2 (with direction and gradient)
	/*************************************************************/
	
	//TO DO: MAKE 32Bit READY

	//try debayering pixels within the resolution limit like text 
	
	//Why are the corrected pixels always that PINK??????????????
	if(debayeringMethod==2){	

		float difVal=0;
		float difCount=0;
		float lumValMid = 0;
		float lumValLeft=0;
		float lumValTopLeft=0;
		float lumValBottomLeft=0;
		float lumValRight=0;
		float lumValTopRight=0;
		float lumValBottomRight=0;
		float lumValTop=0;
		float lumValBottom=0;
		float lumValArea=0;
		float lumCount=0;
		float lumValPattern[9];
//		int x=0;
		bool diagonalCorrection = false;
		
		float strength = 0.5; //Effects factor: Should be between 0 and 1: 0=no effect / 1=full effect
		
		
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;
				
				lumValMid = 0; lumValLeft=0;  lumValTopLeft=0;  lumValBottomLeft=0;  lumValRight=0;  lumValTopRight=0;  lumValBottomRight=0;  lumValTop=0;  lumValBottom=0;  lumCount=0;
				lumValArea=0; lumCount=0; difVal=0; difCount=0;

					// Try weight of 50% for each green value
					//try to estimate dark light resolution / orientation 
					lumValMid=rgbValue[0]+rgbValue[1]+rgbValue[2]; lumValPattern[4]=lumValMid; 
					if(i>0){left=pixel[i-1][j]; lumValLeft+=left.red+left.green+left.blue; lumValArea+=lumValLeft; lumValPattern[3]=lumValLeft; lumCount++;}
					if((i+1)<cols){right=pixel[i+1][j]; lumValRight+=right.red+right.green+right.blue;  lumValArea+=lumValRight; lumValPattern[5]=lumValRight; lumCount++;}
					if(j>0){top=pixel[i][j-1]; lumValTop+=top.red+top.green+top.blue; lumValArea+=lumValTop; lumValPattern[1]=lumValTop; lumCount++;}
					if((j+1)<rows){bottom=pixel[i][j+1]; lumValBottom+=bottom.red+bottom.green+bottom.blue; lumValArea+=lumValBottom; lumValPattern[7]=lumValBottom; lumCount++;}
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; lumValTopLeft+=topLeft.red+topLeft.green+topLeft.blue;  lumValArea+=lumValTopLeft; lumValPattern[0]=lumValTopLeft; lumCount++;}
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	lumValTopRight+=topRight.red+topRight.green+topRight.blue; lumValArea+=lumValTopRight; lumValPattern[2]=lumValTopRight; 	lumCount++;}
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; lumValBottomLeft+=bottomLeft.red+bottomLeft.green+bottomLeft.blue; lumValArea+=lumValBottomLeft; lumValPattern[6]=lumValBottomLeft; lumCount++;}
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; lumValBottomRight+=bottomRight.red+bottomRight.green+bottomRight.blue; lumValArea+=lumValBottomRight; lumValPattern[8]=lumValBottomRight; lumCount++;}
					
					//perhaps need of single color maximum brightness, differs 
					/*
					float hor = (float)(lumValLeft+lumValRight)/lumValMid;
					float ver = (float)(lumValTop+lumValBottom)/lumValMid;
					float upDgnl = (float)(lumValBottomLeft+lumValTopRight)/lumValMid;
					float downDgnl = (float)(lumValTopLeft+lumValBottomRight)/lumValMid;
					*/
					float hor = (abs(lumValLeft-lumValMid)+abs(lumValRight-lumValMid))/2; //Wenn diese Abweichung sehr groß ist, sind die Pixel in dieser Richtung sehr unterschiedlich hell
					float ver = (abs(lumValTop-lumValMid)+abs(lumValBottom-lumValMid))/2;
					float upDgnl = (abs(lumValBottomLeft-lumValMid)+abs(lumValTopRight-lumValMid))/2;
					float downDgnl = (abs(lumValTopLeft-lumValMid)+abs(lumValBottomRight-lumValMid))/2;
					if(debugDebayering)NSLog(@"DEBUG debayering luminosity - lumValMid=%lu / lumValLeft=%i / lumValRight=%i / lumValTop=%lu / lumValBottom=%i\n",lumValMid, lumValLeft, lumValRight, lumValTop, lumValBottom);
/*					
					float threshold =25; //defines threshold (min) for variance of 3 pixels in a row  orcol
					float areaThreshold = 0.1; //OK 0.05-0.25 defines difference from overall luminosity to center
					float varianceThreshold = 35; //defines difference max-min in a pattern
*/					//good 20 / 0.20 / 40
					float threshold =30; //defines threshold (min) for variance of 3 pixels in a row  orcol
					float areaThreshold = 0.25; //OK 0.05-0.25 defines difference from overall luminosity to center
					float varianceThreshold = 50; //defines difference max-min in a pattern
					
					if(debugDebayering)	NSLog(@"DEBUG debayering luminosity - hor=%i / ver=%i / upDgnl=%i / downDgnl=%i\n",hor, ver, upDgnl, downDgnl);
					
					//best would be to use some kind of max function for key value pair

					//TO DO: skip for high values (similarity) in all directions->low gradient, homegeneous -> no dif needed  
					if(debugDebayering)NSLog(@"DEBUG debayering area homogeneity - lumValArea=%lu / lumCount=%lu / lumValMid=%lu / (float)lumValArea/lumCount=%.2f\n",lumValArea,lumCount,lumValMid,((float)lumValArea/lumCount)/lumValMid);
					if(debugDebayering)NSLog(@"DEBUG debayering area homogeneity - fabsf(((float)(lumValArea/lumCount)/lumValMid)-1)=%.2f \n",fabsf(((float)(lumValArea/lumCount)/lumValMid)-1));
					
					//if((float)(hor+ver+upDgnl+downDgnl)/4.0 < threshold){
					float spreadMidOverallLum = fabsf(((float)(lumValArea/lumCount)/lumValMid)-1);
					float areaVariance = [ImageDebayering getPatternVariance:lumValPattern];

					if(debugExperimental){
						if(i>1300 && i<1360 && j>620 && j<650){
							NSLog(@"pixel[%d][%d]: hor=%lu / ver=%lu / upDgnl=%lu / downDgnl=%lu / difVal=%lu / spreadMidOverallLum=%.2f / areaVariance=%lu\n",i,j, hor, ver, upDgnl, downDgnl, difVal, spreadMidOverallLum, areaVariance);
							//for(x=0;x<9;x++){NSLog(@"lumValPattern[%d]=%lu\n",x,lumValPattern[x]);}
						}
					}


					//if(fabsf(((float)(lumValArea/lumCount)/lumValMid)-1) > areaThreshold){
					if(spreadMidOverallLum > areaThreshold || areaVariance > varianceThreshold){
					//if(  abs((lumValArea/lumCount)-lumValMid)  > threshold){
						/*
						if(hor>threshold){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
						if(ver>threshold){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
						if(upDgnl>threshold){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
						if(downDgnl>threshold){difVal=(lumValTopLeft+lumValBottomRight)/2;difCount=1;}
						*/
						/*
						if(hor<threshold){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
						if(ver<threshold){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
						if(upDgnl<threshold){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
						if(downDgnl<threshold){difVal=(lumValTopLeft+lumValBottomRight)/2;difCount=1;}
						*/
						/*
						//orthogonal - theoretically correct, but effect is the opposite
						if(hor>threshold){difVal+=(lumValTop+lumValBottom)/2;difCount+=1;}
						if(ver>threshold){difVal+=(lumValLeft+lumValRight)/2;difCount+=1;}
						if(upDgnl>threshold){difVal+=(lumValTopLeft+lumValBottomRight   )/2;difCount+=1;}
						if(downDgnl>threshold){difVal+=(lumValBottomLeft+lumValTopRight)/2;difCount+=1;}
						*/

						//TO DO: Find the maximum gradient max(hor,ver, upDgnl, downDgnl)
						unsigned long max = [ImageDebayering getMaxValue:hor value2:ver value3:upDgnl value4:downDgnl];
						//TO DO: Find also minimum to determine the most probable direction (closest lum vals)
						unsigned long min = [ImageDebayering getMinValue:hor value2:ver value3:upDgnl value4:downDgnl];
						
						//orthogonal - theoretically correct, but effect is the opposite
						if(hor==max && hor>threshold){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
						if(ver==max && ver>threshold){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
						if(diagonalCorrection){
							if(upDgnl==max && upDgnl>threshold){difVal=(lumValTopLeft+lumValBottomRight   )/2;difCount=1;}
							if(downDgnl==max && downDgnl>threshold){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
						}
						/*						
						if(hor==min && hor<threshold){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
						if(ver==min && ver<threshold){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
						if(upDgnl==min && upDgnl<threshold){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
						if(downDgnl==min && downDgnl<threshold){difVal=(lumValTopLeft+lumValBottomRight)/2;difCount=1;}
						*/
						
						//good for defining lines within the resolution limit, but cause bayer pattern on some plain areas
						if(hor==min){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
						if(ver==min){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
						if(diagonalCorrection){
							if(upDgnl==min){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
							if(downDgnl==min){difVal=(lumValTopLeft+lumValBottomRight)/2;difCount=1;}
						}
						
						//somehow stupid, but give it a try
						/*
						if(hor>threshold){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
						if(ver>threshold){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
						if(upDgnl>threshold){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
						if(downDgnl>threshold){difVal=(lumValTopLeft+lumValBottomRight)/2;difCount=1;}
						*/
						/*
						if(debugExperimental){
							if(i>1300 && i<1360 && j>620 && j<650)
								NSLog(@"pixel[%d][%d]: hor=%lu / ver=%lu / upDgnl=%lu / downDgnl=%lu / difVal=%lu / areaVariance=%.2f\n",i,j, hor, ver, upDgnl, downDgnl, difVal,areaVariance);
						}
						*/
						
					}

					/*					
					if(hor>threshold){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
					if(ver>threshold){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
					if(upDgnl>threshold){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
					if(downDgnl>threshold){difVal=(lumValTopLeft+lumValBottomRight)/2;difCount=1;}
*/					
					//the max value shows most similar luminosity direction
					//should ideally be around 2



				
				
				
				if(rgbValue[0]==0 && rgbValue[2]==0) //this is a green pixel
				{	
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - (%d,%d,%d) - GREEN PIXEL\n",i,j,rgbValue[0],rgbValue[1],rgbValue[2]);


					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					if(i%2==0)
					{ //even row: red is left and right
						if(i>0){left=pixel[i-1][j]; redVal+=left.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; redVal+=right.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						
						/*
						//try modifying with orthogonal values (blue) 
						if(j>0){top=pixel[i][j-1]; difVal+=top.blue; difCount++;}
						if((j+1)<rows){bottom=pixel[i][j+1]; difVal+=bottom.blue; difCount++;}
						*/
					}
					else
					{ //odd row: red is top and bottom
						if(j>0){top=pixel[i][j-1]; redVal+=top.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; redVal+=bottom.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);

						/*
						//try modifying with orthogonal values (blue) 
						if(i>0){left=pixel[i-1][j]; difVal+=left.blue; difCount++;}
						if((i+1)<cols){right=pixel[i+1][j]; difVal+=right.blue; difCount++;}
						*/
					}
/*
					if(difCount>0){
						rgbValue[0]=(redVal+difVal)/(valCount+difCount);
					}
*/					
					//rgbValue[0]=(redVal+difVal)/(valCount+difCount);
//					if(difCount>0)rgbValue[0]=((1-strength)*redVal+strength*difVal)/((1-strength)*valCount+strength*difCount);
					if(difCount>0)rgbValue[0]=difVal/difCount;
					else rgbValue[0]=redVal/(float)valCount;
//					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - GREEN PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					if(i%2!=0) //odd row: blue is left and right
					{
						if(i>0){left=pixel[i-1][j]; blueVal+=left.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; blueVal+=right.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						
						/*
						//try modifying with orthogonal values (red) 
						if(j>0){top=pixel[i][j-1]; difVal+=top.red; difCount++;}
						if((j+1)<rows){bottom=pixel[i][j+1]; difVal+=bottom.red; difCount++;}
						*/						
					}
					else //even row: blue is top and bottom
					{
						if(j>0){top=pixel[i][j-1]; blueVal+=top.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; blueVal+=bottom.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);

						/*
						//try modifying with orthogonal values (red) 
						if(i>0){left=pixel[i-1][j]; difVal+=left.red; difCount++;}
						if((i+1)<cols){right=pixel[i+1][j]; difVal+=right.red; difCount++;}
						*/
					}
					
					
					//rgbValue[2]=blueVal/valCount;
					//rgbValue[2]=(blueVal+difVal)/(valCount+difCount);
//					if(difCount>0)rgbValue[2]=((1-strength)*blueVal+strength*difVal)/((1-strength)*valCount+strength*difCount);
//					else rgbValue[2]=blueVal/valCount;
//					if(difCount>0)rgbValue[2]=((1.0-strength)*(float)blueVal+(float)strength*(float)difVal)/((1.0-(float)strength)*(float)valCount+(float)strength*(float)difCount);
					if(difCount>0)rgbValue[2]=difVal/difCount;
					else rgbValue[2]=blueVal/(float)valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - GREEN PIXEL\n",i,j);



				}
				if(rgbValue[1]==0 && rgbValue[2]==0) //this is a red pixel
				{
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - RED PIXEL\n",i,j);


					//calculate green value
//					@try{left=pixel[i-1][j]; greenVal=left.green; valCount++;}@catch(NSException *theException) {}
//					@try{right=pixel[i+1][j]; greenVal=right.green; valCount++;}@catch(NSException *theException) {}
//					@try{top=pixel[i][j-1]; greenVal=top.green; valCount++;}@catch(NSException *theException) {}
//					@try{bottom=pixel[i][j+1]; greenVal=bottom.green; valCount++;}@catch(NSException *theException) {}

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);

					/*
					//try to estimate dark light resolution / orientation 
					lumValMid=rgbValue[0]+rgbValue[1]+rgbValue[2];
					if(i>0){left=pixel[i-1][j]; lumValLeft+=left.red+left.green+left.blue; lumCount++;}
					if((i+1)<cols){right=pixel[i+1][j]; lumValRight+=right.red+right.green+right.blue; lumCount++;}
					if(j>0){top=pixel[i][j-1]; lumValTop+=top.red+top.green+top.blue; lumCount++;}
					if((j+1)<rows){bottom=pixel[i][j+1]; lumValBottom+=bottom.red+bottom.green+bottom.blue; lumCount++;}
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; lumValTopLeft+=topLeft.red+topLeft.green+topLeft.blue; lumCount++;}
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	lumValTopRight+=topRight.red+topRight.green+topRight.blue; 	lumCount++;}
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; lumValBottomLeft+=bottomLeft.red+bottomLeft.green+bottomLeft.blue; lumCount++;}
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; lumValBottomRight+=bottomRight.red+bottomRight.green+bottomRight.blue; lumCount++;}
					
					float hor = (lumValLeft+lumValRight)/lumValMid;
					float ver = (lumValTop+lumValBottom)/lumValMid;
					float upDgnl = (lumValBottomLeft+lumValTopRight)/lumValMid;
					float downDgnl = (lumValTopLeft+lumValBottomRight)/lumValMid;
					float threshold =1.7;
					
					//best would be to use some kind of max function for key value pair
					if(hor>threshold){difVal=(lumValLeft+lumValRight)/2;difCount=1;}
					if(ver>threshold){difVal=(lumValTop+lumValBottom)/2;difCount=1;}
					if(upDgnl>threshold){difVal=(lumValBottomLeft+lumValTopRight)/2;difCount=1;}
					if(downDgnl>threshold){difVal=(lumValTopLeft+lumValBottomRight)/2;difCount=1;}
					
					//the max value shows most similar luminosity direction
					//should ideally be around 2
					
					//if()
					*/
					
					//rgbValue[1]=greenVal/valCount;
					//rgbValue[1]=(greenVal+difVal)/(valCount+difCount);
//					if(difCount>0)rgbValue[1]=((1-strength)*greenVal+strength*difVal)/((1-strength)*valCount+strength*difCount);
//					else rgbValue[1]=greenVal/valCount;
//					if(difCount>0)rgbValue[1]=((1.0-(float)strength)*(float)greenVal+(float)strength*(float)difVal)/((1.0-(float)strength)*(float)valCount+(float)strength*(float)difCount);
					if(difCount>0)rgbValue[1]=difVal/difCount;
					else rgbValue[1]=greenVal/(float)valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - RED PIXEL\n",i,j);
					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; blueVal+=topLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	blueVal+=topRight.blue; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; blueVal+=bottomLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; blueVal+=bottomRight.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);


					if(debugDebayering)NSLog(@"DEBUG bottomRight done i=%d / j=%d -  blueVal=%f / valCount=%d - RED PIXEL\n",i,j, blueVal, valCount);
					
					if(debugDebayering)NSLog(@"DEBUG calc blueVal blueVal=%f / valCount=%ld - RED PIXEL\n",blueVal,valCount);
					//rgbValue[2]=blueVal/valCount;
/*
					@try{rgbValue[2]=blueVal/valCount;}
					@catch(NSException *theException) {NSLog(@"Rummsassa!!!");}
*/					
					//rgbValue[2]=(blueVal+difVal)/(valCount+difCount);
//					if(difCount>0)rgbValue[2]=((1-strength)*blueVal+strength*difVal)/((1-strength)*valCount+strength*difCount);
//					else rgbValue[2]=blueVal/valCount;
//					if(difCount>0)rgbValue[2]=((1.0-(float)strength)*(float)blueVal+(float)strength*(float)difVal)/((1.0-(float)strength)*(float)valCount+(float)strength*(float)difCount);
					if(difCount>0)rgbValue[2]=difVal/difCount;
					else rgbValue[2]=blueVal/(float)valCount;
					
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - RED PIXEL\n",i,j);

					
				}
				if(rgbValue[0]==0 && rgbValue[1]==0) //this is a blue pixel
				{	
		if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - BLUE PIXEL\n",i,j);
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
		
					
					//rgbValue[1]=greenVal/valCount;
					//rgbValue[1]=(greenVal+difVal)/(valCount+difCount);
//					if(difCount>0)rgbValue[1]=((1-strength)*greenVal+strength*difVal)/((1-strength)*valCount+strength*difCount);
//					else rgbValue[1]=greenVal/valCount;
//					if(difCount>0)rgbValue[1]=((1.0-(float)strength)*(float)greenVal+(float)strength*(float)difVal)/((1.0-(float)strength)*(float)valCount+(float)strength*(float)difCount);
					if(difCount>0)rgbValue[1]=difVal/difCount;
					else rgbValue[1]=greenVal/(float)valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - BLUE PIXEL\n",i,j);


					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; redVal+=topLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	redVal+=topRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; redVal+=bottomLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; redVal+=bottomRight.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);

					
					//rgbValue[0]=redVal/valCount;
					//rgbValue[0]=(redVal+difVal)/(valCount+difCount);
//					if(difCount>0)rgbValue[0]=((1-strength)*redVal+strength*difVal)/((1-strength)*valCount+strength*difCount);
//					else rgbValue[0]=redVal/valCount;
//					if(difCount>0)rgbValue[0]=((1.0-(float)strength)*(float)redVal+(float)strength*(float)difVal)/((1.0-(float)strength)*(float)valCount+(float)strength*(float)difCount);
					if(difCount>0)rgbValue[0]=difVal/difCount;
					else rgbValue[0]=redVal/(float)valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - BLUE PIXEL\n",i,j);

				}
				//ATTENTION: do not write back processed pixels to original pixelPattern!
				//otherwised will be directly reused for calculating pixels -> interferrence and false values!
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];
				if(debugDebayering)NSLog(@"DEBAYERING: pixel[%d][%d] - rgbValue = (%d/%d/%d) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)



	/*********************************************************************/
	//			DEBAYERING METHOD 3 (With random choice)
	/*********************************************************************/


	float randPixVal[16];

	if(debayeringMethod==3){	
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;
				
				
				
				
				if(rgbValue[0]==0 && rgbValue[2]==0) //this is a green pixel
				{	
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - (%d,%d,%d) - GREEN PIXEL\n",i,j,rgbValue[0],rgbValue[1],rgbValue[2]);


//TO DO: Check for alternating red or blue at left/right!!!!

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					if(i%2==0)
					{ //even row: red is left and right
						if(i>0){left=pixel[i-1][j]; redVal+=left.red; randPixVal[0]=left.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; redVal+=right.red; randPixVal[1]=right.red;  valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					}
					else
					{ //odd row: red is top and bottom
						if(j>0){top=pixel[i][j-1]; redVal+=top.red; randPixVal[0]=top.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; redVal+=bottom.red; randPixVal[1]=bottom.red; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					}
					
					//if(valCount==0)rgbValue[0]=[ImageDebayering randomRgbVal:rgbValue[1]];else
					//rgbValue[0]=redVal/valCount;
					//rgbValue[0]=((redVal/valCount)+randPixVal[[ImageDebayering randomPixel:2]])/2;
					rgbValue[0]=randPixVal[[ImageDebayering randomPixel:2]];
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127;
//					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - GREEN PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					if(i%2!=0) //odd row: blue is left and right
					{
						if(i>0){left=pixel[i-1][j]; blueVal+=left.blue; randPixVal[0]=left.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; blueVal+=right.blue; randPixVal[1]=right.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					}
					else //even row: blue is top and bottom
					{
						if(j>0){top=pixel[i][j-1]; blueVal+=top.blue; randPixVal[0]=top.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; blueVal+=bottom.blue; randPixVal[1]=bottom.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					}
					
					//if(valCount==0)rgbValue[2]=[ImageDebayering randomRgbVal:rgbValue[1]];else
					//rgbValue[2]=blueVal/valCount;
					//rgbValue[2]=((blueVal/valCount)+randPixVal[[ImageDebayering randomPixel:2]])/2;
					rgbValue[2]=randPixVal[[ImageDebayering randomPixel:2]];
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127;
					
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - GREEN PIXEL\n",i,j);



				}
				if(rgbValue[1]==0 && rgbValue[2]==0) //this is a red pixel
				{
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - RED PIXEL\n",i,j);


					//calculate green value
//					@try{left=pixel[i-1][j]; greenVal=left.green; valCount++;}@catch(NSException *theException) {}
//					@try{right=pixel[i+1][j]; greenVal=right.green; valCount++;}@catch(NSException *theException) {}
//					@try{top=pixel[i][j-1]; greenVal=top.green; valCount++;}@catch(NSException *theException) {}
//					@try{bottom=pixel[i][j+1]; greenVal=bottom.green; valCount++;}@catch(NSException *theException) {}

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; randPixVal[0]=left.green;  valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; randPixVal[1]=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; randPixVal[2]=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; randPixVal[3]=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					
					
					//if(valCount==0)rgbValue[1]=[ImageDebayering randomRgbVal:rgbValue[0]];else
					//rgbValue[1]=((greenVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;
					rgbValue[1]=randPixVal[[ImageDebayering randomPixel:4]];
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127;

					//rgbValue[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - RED PIXEL\n",i,j);
					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; blueVal+=topLeft.blue; randPixVal[0]=topLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	blueVal+=topRight.blue; randPixVal[1]=topRight.blue; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; blueVal+=bottomLeft.blue; randPixVal[2]=bottomLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; blueVal+=bottomRight.blue; randPixVal[3]=bottomRight.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);


					if(debugDebayering)NSLog(@"DEBUG bottomRight done i=%d / j=%d -  blueVal=%f / valCount=%ld - RED PIXEL\n",i,j, blueVal, valCount);
					
					if(debugDebayering)NSLog(@"DEBUG calc blueVal blueVal=%f / valCount=%ld - RED PIXEL\n",blueVal,valCount);
					//if(valCount==0)rgbValue[2]=[ImageDebayering randomRgbVal:rgbValue[0]];else
					//rgbValue[2]=((blueVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;
					rgbValue[2]=randPixVal[[ImageDebayering randomPixel:4]];
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127;


					//rgbValue[2]=blueVal/valCount;
					//@try{rgbValue[2]=blueVal/valCount;}
					//@catch(NSException *theException) {NSLog(@"Rummsassa!!!");}
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - RED PIXEL\n",i,j);

					
				}
				if(rgbValue[0]==0 && rgbValue[1]==0) //this is a blue pixel
				{	
		if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - BLUE PIXEL\n",i,j);
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; randPixVal[0]=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; randPixVal[1]=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; randPixVal[2]=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; randPixVal[3]=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
		
					
					//if(valCount==0){rgbValue[1]=[ImageDebayering randomPixel:4];else
					//int randomPix = [ImageDebayering randomPixel:4];
					//rgbValue[1]=((greenVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;
					rgbValue[1]=randPixVal[[ImageDebayering randomPixel:4]];
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127;
					
//					rgbValue[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - BLUE PIXEL\n",i,j);


					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; redVal+=topLeft.red; randPixVal[0]=topLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	redVal+=topRight.red; randPixVal[1]=topRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; redVal+=bottomLeft.red; randPixVal[2]=bottomLeft.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; redVal+=bottomRight.red; randPixVal[3]=bottomRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);

					
					//if(valCount==0)rgbValue[0]=[ImageDebayering randomRgbVal:rgbValue[2]];else
					//rgbValue[0]=((redVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;
					rgbValue[0]=randPixVal[[ImageDebayering randomPixel:4]];
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127;
					//rgbValue[0]=redVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - BLUE PIXEL\n",i,j);

				}
				//ATTENTION: do not write back processed pixels to original pixelPattern!
				//otherwised will be directly reused for calculating pixels -> interferrence and false values!
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];
				if(debugDebayering)NSLog(@"DEBAYERING: pixel[%d][%d] - rgbValue = (%d/%d/%d) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)

	

	/**********************************************************************/
	//		With more surrounding Pixels
	/**********************************************************************/


	if(debayeringMethod==4){	
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				//debugDebayering=(j>1364)?true:false;
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;
				
				if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - (%d,%d,%d)\n",i,j,rgbValue[0],rgbValue[1],rgbValue[2]);
				
				
				
				if(rgbValue[0]==0 && rgbValue[2]==0) //this is a green pixel
				{	
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - (%d,%d,%d) - GREEN PIXEL\n",i,j,rgbValue[0],rgbValue[1],rgbValue[2]);


//TO DO: Check for alternating red or blue at left/right!!!!

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					if(i%2==0)
					{ //even row: red is left and right
						if(i>0){left=pixel[i-1][j]; redVal+=left.red; valCount++;
							if(j-2>=0 && j+2<rows){ redVal+=((pixel[i-1][j-2]).red+ (pixel[i-1][j+2]).red )/2; valCount++;}
						}
						
						if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; redVal+=right.red; valCount++;
//							if(j-2>=0 && j+2<cols){redVal+=((pixel[i+1][j-2]).red + (pixel[i+1][j+2]).red)/2; valCount++;}
							if(j-2>=0 && j+2<rows){redVal+=((pixel[i+1][j-2]).red + (pixel[i+1][j+2]).red)/2; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					}
					else
					{ //odd row: red is top and bottom
						if(debugDebayering)NSLog(@"DEBUG ## calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if(j>0){top=pixel[i][j-1]; redVal+=top.red; valCount++;
							if(debugDebayering)NSLog(@"DEBUG ### pixel[%d][%d]=(%f/%f/%f)  valCount=%ld - GREEN PIXEL - rows=%d / j=%d\n",i,j-1,top.red,top.green, top.blue,valCount,rows, j);
							if(debugDebayering)NSLog(@"DEBUG #### (pixel[i-2][j-1]).red=%f   /   (pixel[i-2][j+1]).red=%f\n",(pixel[i-2][j-1]).red, (pixel[i-2][j+1]).red);
							if(i>1 && i+2<cols &&j+1<rows){redVal+=((pixel[i-2][j-1]).red + (pixel[i-2][j+1]).red)/2; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - GREEN PIXEL - rows=%d / j=%d\n",redVal,valCount,rows, j);
						if((j+1)<rows){bottom=pixel[i][j+1]; redVal+=bottom.red; valCount++;
							if(i>1 && i+2<cols){redVal+=((pixel[i+2][j-1]).red + (pixel[i+2][j+1]).red)/2; valCount++; }
						}
												
						if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					}
					
					
					rgbValue[0]=redVal/valCount;
//					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - GREEN PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					if(i%2!=0) 
					{ //odd row: blue is left and right
						if(i>0){left=pixel[i-1][j]; blueVal+=left.blue; valCount++;
							if(j-2>=0 && j+2<rows){ blueVal+=((pixel[i-1][j-2]).blue+ (pixel[i-1][j+2]).blue )/2; valCount++;}
						}
						
						if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; blueVal+=right.blue; valCount++;
							if(j-2>=0 && j+2<rows){blueVal+=((pixel[i+1][j-2]).blue + (pixel[i+1][j+2]).blue)/2; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					}
					else
					{ //even row: blue is top and bottom
						if(j>0){top=pixel[i][j-1]; blueVal+=top.blue; valCount++;
							if(i>1 && i+2<cols &&j+1<rows){blueVal+=((pixel[i-2][j-1]).blue + (pixel[i-2][j+1]).blue)/2; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; blueVal+=bottom.blue; valCount++;
							if(i>1 && i+2<cols){blueVal+=((pixel[i+2][j-1]).blue + (pixel[i+2][j+1]).blue)/2; valCount++; }
						}
												
						if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					}

					
					
					rgbValue[2]=blueVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - GREEN PIXEL\n",i,j);



				}
				if(rgbValue[1]==0 && rgbValue[2]==0) //this is a red pixel
				{
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - RED PIXEL\n",i,j);

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					
					
					rgbValue[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - RED PIXEL\n",i,j);
					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; blueVal+=topLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	blueVal+=topRight.blue; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; blueVal+=bottomLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; blueVal+=bottomRight.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);


					if(debugDebayering)NSLog(@"DEBUG bottomRight done i=%d / j=%d -  blueVal=%f / valCount=%ld - RED PIXEL\n",i,j, blueVal, valCount);
					
					if(debugDebayering)NSLog(@"DEBUG calc blueVal blueVal=%f / valCount=%ld - RED PIXEL\n",blueVal,valCount);
					//rgbValue[2]=blueVal/valCount;
					@try{rgbValue[2]=blueVal/valCount;}
					@catch(NSException *theException) {NSLog(@"Rummsassa!!!");}
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - RED PIXEL\n",i,j);

					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;					
					
					//TO DO: calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(i>1){redVal+=(pixel[i-2][j]).red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(i+2<cols){redVal+=(pixel[i+2][j]).red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(j>1){redVal+=(pixel[i][j-2]).red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(j+2<rows){redVal+=(pixel[i][j+2]).red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					//self
					redVal+=rgbValue[0];valCount++;
					if(debugDebayering)NSLog(@"DEBUG 5 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					
					rgbValue[0]=redVal/valCount;
					if(debugDebayering)NSLog(@"DEBUG calc redVal done -  rgbValue[0]=%lu - RED PIXEL\n",rgbValue[0]);
					
				}
				if(rgbValue[0]==0 && rgbValue[1]==0) //this is a blue pixel
				{	
		if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - BLUE PIXEL\n",i,j);
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
		
					
					rgbValue[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - BLUE PIXEL\n",i,j);


					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; redVal+=topLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	redVal+=topRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; redVal+=bottomLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; redVal+=bottomRight.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);

					
					rgbValue[0]=redVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - BLUE PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;					
					
					//TO DO: calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(i>1){blueVal+=(pixel[i-2][j]).blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(i+2<cols){blueVal+=(pixel[i+2][j]).blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(j>1){blueVal+=(pixel[i][j-2]).blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(j+2<rows){blueVal+=(pixel[i][j+2]).blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					//self
					blueVal+=rgbValue[0];valCount++;
					if(debugDebayering)NSLog(@"DEBUG 5 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					
					rgbValue[2]=blueVal/valCount;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal done -  rgbValue[0]=%lu - BLUE PIXEL\n",rgbValue[0]);
						
				}
				//ATTENTION: do not write back processed pixels to original pixelPattern!
				//otherwised will be directly reused for calculating pixels -> interferrence and false values!
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];
				if(debugDebayering)NSLog(@"DEBAYERING: pixel[%d][%d] - rgbValue = (%d/%d/%d) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)




	
	
	/*********************************************************************/
	//			DEBAYERING METHOD 5 (13Pixel Pattern with random choice)
	/*********************************************************************/


	//int randPixVal[4];
	float randomMix = 0.33;
//	float randomMix = 0.75;
	float randomPart = 0;
	int randIts = 3;
	int r=0;

	randomMix=settings.randomMix;
	randIts=settings.randIts;
	
	if(debayeringMethod==5){	
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				//debugDebayering=(j>1363)?true:false;
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;

				rgbBytes rgbPix32Bit;
				rgbPix32Bit=pixel[i][j];
				rgbValue32Bit[0]=rgbPix32Bit.red;
				rgbValue32Bit[1]=rgbPix32Bit.green;
				rgbValue32Bit[2]=rgbPix32Bit.blue;
				
				randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
				
				
				
//				if(rgbValue[0]==0 && rgbValue[2]==0) //this is a green pixel
				if(rgbValue32Bit[0]==0 && rgbValue32Bit[2]==0) //this is a green pixel
				{	
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - (%d,%d,%d) - GREEN PIXEL\n",i,j,rgbValue[0],rgbValue[1],rgbValue[2]);


//TO DO: Check for alternating red or blue at left/right!!!!
/*
					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					if(i%2==0)
					{ //even row: red is left and right
						if(i>0){left=pixel[i-1][j]; redVal+=left.red; valCount++;
							if(j-2>=0 && j+2<rows){ redVal+=((pixel[i-1][j-2]).red+ (pixel[i-1][j+2]).red )/2; valCount++;}
						}
						
						if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; redVal+=right.red; valCount++;
//							if(j-2>=0 && j+2<cols){redVal+=((pixel[i+1][j-2]).red + (pixel[i+1][j+2]).red)/2; valCount++;}
							if(j-2>=0 && j+2<rows){redVal+=((pixel[i+1][j-2]).red + (pixel[i+1][j+2]).red)/2; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					}
*/
					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					if(i%2==0)
					{ //even row: red is left and right

						if(i>0){left=pixel[i-1][j]; redVal+=left.red; randPixVal[0]=left.red; valCount++;
							if(j-2>=0 && j+2<rows){  randPixVal[2]=((pixel[i-1][j-2]).red)/2+ ((pixel[i-1][j+2]).red )/2; redVal+=randPixVal[2]; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; redVal+=right.red; randPixVal[1]=right.red;  valCount++;
							if(debugDebayering)NSLog(@"DEBUG 2 ## calc redVal=%f / randPixVal[1]=%f / randPixVal[2]=%f / randPixVal[3]=%f / valCount=%ld - GREEN PIXEL\n",redVal,randPixVal[1],randPixVal[2],randPixVal[3],valCount);
//							if(j-2>=0 && j+2<rows){randPixVal[3]=((pixel[i+1][j-2]).red)/2 + ((pixel[i+1][j+2]).red)/2; redVal+=randPixVal[3]; valCount++;}
							if(j-2>=0 && j+2<rows){randPixVal[3]=(((pixel[i+1][j-2]).red) + ((pixel[i+1][j+2]).red))/2.0; redVal+=randPixVal[3]; valCount++;}
							if(debugDebayering)NSLog(@"DEBUG 2 ### calc redVal=%f / randPixVal[1]=%f / randPixVal[2]=%f / randPixVal[3]=%f / valCount=%ld - GREEN PIXEL\n",redVal,randPixVal[1],randPixVal[2],randPixVal[3],valCount);
							if(debugDebayering)NSLog(@"DEBUG 2 #### i=%d / j=%d / rows=%d / cols=%d - calc (pixel[i+1][j-2]).red=%f / (pixel[i+1][j+2]).red=%f - GREEN PIXEL\n",i,j,rows,cols,(pixel[i+1][j-2]).red,(pixel[i+1][j+2]).red);
						}
						if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);



					}
					else
					{ //odd row: red is top and bottom

						if(j>0){top=pixel[i][j-1]; redVal+=top.red; randPixVal[0]=top.red; valCount++;
//							if(i>1 && i+2<cols && j+1<rows){randPixVal[2]=((pixel[i-2][j-1]).red + (pixel[i-2][j+1]).red)/2; redVal+=randPixVal[2]; valCount++; }
							if(i>1 && i+2<cols && j+1<rows){randPixVal[2]=((pixel[i-2][j-1]).red)/2 + ((pixel[i-2][j+1]).red)/2; redVal+=randPixVal[2]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; redVal+=bottom.red; randPixVal[1]=bottom.red; valCount++;
//							if(i>1 && i+2<cols){randPixVal[3]=((pixel[i+2][j-1]).red + (pixel[i+2][j+1]).red)/2; redVal+=randPixVal[3]; valCount++; }
							if(i>1 && i+2<cols){randPixVal[3]=((pixel[i+2][j-1]).red)/2 + ((pixel[i+2][j+1]).red)/2; redVal+=randPixVal[3]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);

					}
					
			
					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:4]];
					randomPart=randomPart/randIts;
					rgbValue[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randomPart);
					//rgbValue32Bit[0]=redVal/valCount; //too low in 32Bit
					//rgbValue32Bit[0]=redVal/3; //too low in 32Bit
					//rgbValue32Bit[0]=randomPart; //seems OK in 32Bit
					//rgbValue32Bit[0]=0;
//					int testiVal =[ImageDebayering normalizeTo8Bit:redVal bitsPerSample:32];
					//NSLog(@"GREEN PIXEL: pixel[%d][%d] testiVal=%lu / valCount=%d\n",i,j,testiVal, valCount);
					//NSLog(@"GREEN PIXEL: pixel[%d][%d] redVal=%f  max=%lu\n",i,j,redVal, (unsigned long)0XFFFFFFFF);

					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
//					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - GREEN PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					if(i%2!=0) //odd row: blue is left and right
					{

						if(i>0){left=pixel[i-1][j]; blueVal+=left.blue; randPixVal[0]=left.blue; valCount++;
//							if(j-2>=0 && j+2<rows){ randPixVal[2]=((pixel[i-1][j-2]).blue+ (pixel[i-1][j+2]).blue )/2; blueVal+=randPixVal[2]; valCount++;}
							if(j-2>=0 && j+2<rows){ randPixVal[2]=((pixel[i-1][j-2]).blue)/2+ ((pixel[i-1][j+2]).blue )/2; blueVal+=randPixVal[2]; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; blueVal+=right.blue; randPixVal[1]=right.blue; valCount++;
//							if(j-2>=0 && j+2<rows){randPixVal[3]=((pixel[i+1][j-2]).blue + (pixel[i+1][j+2]).blue)/2; blueVal+=randPixVal[3]; valCount++;}
							if(j-2>=0 && j+2<rows){randPixVal[3]=((pixel[i+1][j-2]).blue)/2 + ((pixel[i+1][j+2]).blue)/2; blueVal+=randPixVal[3]; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);

					}
					else //even row: blue is top and bottom
					{	

						if(j>0){top=pixel[i][j-1]; blueVal+=top.blue; randPixVal[0]=top.blue; valCount++;
//							if(i>1 && i+2<cols  &&j+1<rows){randPixVal[2]=((pixel[i-2][j-1]).blue + (pixel[i-2][j+1]).blue)/2; blueVal+=randPixVal[2]; valCount++; }
							if(i>1 && i+2<cols  &&j+1<rows){randPixVal[2]=((pixel[i-2][j-1]).blue)/2 + ((pixel[i-2][j+1]).blue)/2; blueVal+=randPixVal[2]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; blueVal+=bottom.blue; randPixVal[1]=bottom.blue; valCount++;
//							if(i>1 && i+2<cols){randPixVal[3]=((pixel[i+2][j-1]).blue + (pixel[i+2][j+1]).blue)/2; blueVal+=randPixVal[3]; valCount++; }
							if(i>1 && i+2<cols){randPixVal[3]=((pixel[i+2][j-1]).blue)/2 + ((pixel[i+2][j+1]).blue)/2; blueVal+=randPixVal[3]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);


					}
					

					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:4]];
					randomPart=randomPart/randIts;
					rgbValue[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randomPart);
					//rgbValue32Bit[2]=randomPart; //seems OK in 32Bit
					
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
					
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - GREEN PIXEL\n",i,j);



				}
//				if(rgbValue[1]==0 && rgbValue[2]==0) //this is a red pixel
				if(rgbValue32Bit[1]==0 && rgbValue32Bit[2]==0) //this is a red pixel
				{
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - RED PIXEL\n",i,j);

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; randPixVal[0]=left.green;  valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; randPixVal[1]=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; randPixVal[2]=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; randPixVal[3]=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					

					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:4]];
					randomPart=randomPart/randIts;
					rgbValue[1]=( (1-randomMix)*(greenVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[1]=( (1-randomMix)*(greenVal/valCount)+randomMix*randomPart);
					
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;

					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - RED PIXEL\n",i,j);
					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; blueVal+=topLeft.blue; randPixVal[0]=topLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	blueVal+=topRight.blue; randPixVal[1]=topRight.blue; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; blueVal+=bottomLeft.blue; randPixVal[2]=bottomLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; blueVal+=bottomRight.blue; randPixVal[3]=bottomRight.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);


					if(debugDebayering)NSLog(@"DEBUG bottomRight done i=%d / j=%d -  blueVal=%f / valCount=%ld - RED PIXEL\n",i,j, blueVal, valCount);
					
					if(debugDebayering)NSLog(@"DEBUG calc blueVal blueVal=%f / valCount=%ld - RED PIXEL\n",blueVal,valCount);
					
					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:4]];
					randomPart=randomPart/randIts;					
					rgbValue[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randomPart);

					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;


					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - RED PIXEL\n",i,j);

					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;					
					
					//TO DO: calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					//NSLog(@"0 -pixel[%d][%d] valCount=%d\n",i,j,valCount);
					if(i>1){randPixVal[0]=(pixel[i-2][j]).red; redVal+=randPixVal[0]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					//NSLog(@"1- pixel[%d][%d] valCount=%d\n",i,j,valCount);
					if(i+2<cols){randPixVal[1]=(pixel[i+2][j]).red; redVal+=randPixVal[1];valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					//NSLog(@"2- pixel[%d][%d] valCount=%d\n",i,j,valCount);
					if(j>1){randPixVal[2]=(pixel[i][j-2]).red; redVal+=randPixVal[2]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					//NSLog(@"3- pixel[%d][%d] valCount=%d\n",i,j,valCount);
					if(j+2<rows){randPixVal[3]=(pixel[i][j+2]).red; redVal+=randPixVal[3]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					//NSLog(@"4- pixel[%d][%d] valCount=%d\n",i,j,valCount);
					//self
					randPixVal[4]=rgbValue[0]; //redVal+=randPixVal[4]; valCount++;
					randPixVal[4]=rgbValue32Bit[0];  redVal+=randPixVal[4]; valCount++;
					//NSLog(@"5- pixel[%d][%d] valCount=%d\n",i,j,valCount);
					if(debugDebayering)NSLog(@"DEBUG 5 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					

					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:5]];
					randomPart=randomPart/randIts;				
					rgbValue[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[0]=(unsigned long)( (1-randomMix)*(redVal/valCount)+randomMix*randomPart);
					//rgbValue32Bit[0]=( (1-0)*(redVal/valCount)+0); //too low 32Bit value
					//rgbValue32Bit[0]=redVal/5; //too low 32Bit value
					//NSLog(@"RED PIXEL: pixel[%d][%d] valCount=%d\n",i,j,valCount);
					//rgbValue32Bit[0]=randomPart; //correct 32Bit value
					//rgbValue32Bit[0]=0;
					
					if(debugDebayering)NSLog(@"DEBUG calc redVal done -  rgbValue[0]=%lu - RED PIXEL\n",rgbValue[0]);

					
				}
//				if(rgbValue[0]==0 && rgbValue[1]==0) //this is a blue pixel
				if(rgbValue32Bit[0]==0 && rgbValue32Bit[1]==0) //this is a blue pixel
				{	
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - BLUE PIXEL\n",i,j);
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; randPixVal[0]=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; randPixVal[1]=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; randPixVal[2]=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; randPixVal[3]=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
		
										
					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:4]];
					randomPart=randomPart/randIts;	
					rgbValue[1]=( (1-randomMix)*(greenVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[1]=( (1-randomMix)*(greenVal/valCount)+randomMix*randomPart);
					
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
					
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - BLUE PIXEL\n",i,j);


					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; redVal+=topLeft.red; randPixVal[0]=topLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	redVal+=topRight.red; randPixVal[1]=topRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; redVal+=bottomLeft.red; randPixVal[2]=bottomLeft.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; redVal+=bottomRight.red; randPixVal[3]=bottomRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);

										
					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:4]];
					randomPart=randomPart/randIts;	
					rgbValue[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randomPart);
					if(debugDebayering)NSLog(@"DEBUG 4 ### randomMix=%f / redVAl=%f / valCount=%d / randomPart=%f / rgbValue[0]=%f\n",randomMix, redVal,valCount, randomPart,rgbValue[0]);
					
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - BLUE PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;					
					
					//TO DO: calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(i>1){randPixVal[0]=(pixel[i-2][j]).blue; blueVal+=randPixVal[0]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(i+2<cols){randPixVal[1]=(pixel[i+2][j]).blue; blueVal+=randPixVal[1]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(j>1){randPixVal[2]=(pixel[i][j-2]).blue; blueVal+=randPixVal[2];valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(j+2<rows){randPixVal[3]=(pixel[i][j+2]).blue; blueVal+=randPixVal[3];valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					//self
					randPixVal[4]=rgbValue[0]; //blueVal+=randPixVal[4]; valCount++;
					randPixVal[4]=rgbValue32Bit[0]; blueVal+=randPixVal[4]; valCount++;
					if(debugDebayering)NSLog(@"DEBUG 5 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					
					rgbValue[2]=blueVal/valCount;
					rgbValue32Bit[2]=blueVal/valCount;
					//rgbValue[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:5]]);
					
					//Generate random Part
					randomPart=0;
					for(r=0;r<randIts;r++)randomPart+=randPixVal[[ImageDebayering randomPixel:5]];
					randomPart=randomPart/randIts;	
					rgbValue[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randomPart);
					rgbValue32Bit[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randomPart);
					//NSLog(@"BLUE PIXEL: pixel[%d][%d] valCount=%d\n",i,j,valCount);
					
					if(debugDebayering)NSLog(@"DEBUG calc blueVal done -  rgbValue[0]=%f / rgbValue[1]=%f / rgbValue[2]=%f - BLUE PIXEL\n",rgbValue[0],rgbValue[1],rgbValue[2]);
					
					
					
				}
				//ATTENTION: do not write back processed pixels to original pixelPattern!
				//otherwised will be directly reused for calculating pixels -> interferrence and false values!
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];
				
				if(rgbValue[0]>999999.9)NSLog(@"OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");

				if(debugDebayering)NSLog(@"DEBAYERING: pixel[%d][%d] - rgbValue = (%f/%f/%f) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;
				//if(internalBitRes!=8)processedPixel[i][j] = rgbPixel32Bit;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)

	
	
	



	/*********************************************************************/
	//			DEBAYERING METHOD 6 (NxN Pixel Pattern with random choice)
	/*********************************************************************/
	//Theoretical - not completed yet
	//SUBSTITUTED BY METHOD 7

	//int randPixVal[4];
	//float randomMix = 0.5;
	int n = 5; //kantenlänge Pattern, ggf. erweiterbar auf NxO
//	float weight = 0.5; //ggf. Gauss'sche Glockenkurve o.Ä.

	if(debayeringMethod==6){	
		if(debugDebayering)NSLog(@"DEBUG - debayeringMethod=%d\n",debayeringMethod);
		for(j=0;j<rows;j++){
			for(i=0;i<cols;i++){
				rgbBytes rgbPix;
				rgbPix=pixel[i][j];
				rgbValue[0]=rgbPix.red;
				rgbValue[1]=rgbPix.green;
				rgbValue[2]=rgbPix.blue;
				
				randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
				
				
				
				if(rgbValue[0]==0 && rgbValue[2]==0) //this is a green pixel
				{	
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - (%d,%d,%d) - GREEN PIXEL\n",i,j,rgbValue[0],rgbValue[1],rgbValue[2]);


//TO DO: Check for alternating red or blue at left/right!!!!

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
					if(i%2==0)
					{ //even row: red is left and right

						int a=0;
						//allgemeine formulierung für Pattern Kantenlänge n (x-werte noch durchgehen)
						if(i>0){left=pixel[i-1][j]; redVal+=left.red; randPixVal[0]=left.red; valCount++;
							for(a=2;a<=n/2;a=a+2){
								if(j-a>=0 && j+a<rows){
									randPixVal[a]=((pixel[i-1][j-a]).red+ (pixel[i-1][j+a]).red )/2; redVal+=randPixVal[a]; valCount++; //array index perhaps a/2
								}
							}
						}
						if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; redVal+=right.red; randPixVal[1]=right.red;  valCount++;
							for(a=2;a<=n/2;a=a+2){
								if(j-a>=0 && j+a<rows){
									randPixVal[a-1]=((pixel[i+1][j-a]).red+ (pixel[i+1][j+a]).red )/2; redVal+=randPixVal[a-1]; valCount++; //array index perhaps a/2
								}
							}
						}
						if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);

						
						


					}
					else
					{ //odd row: red is top and bottom

						if(j>0){top=pixel[i][j-1]; redVal+=top.red; randPixVal[0]=top.red; valCount++;
							if(i>1 && i+2<cols){randPixVal[2]=((pixel[i-2][j-1]).red + (pixel[i-2][j+1]).red)/2; redVal+=randPixVal[2]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; redVal+=bottom.red; randPixVal[1]=bottom.red; valCount++;
							if(i>1 && i+2<cols){randPixVal[3]=((pixel[i+2][j-1]).red + (pixel[i+2][j+1]).red)/2; redVal+=randPixVal[3]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - GREEN PIXEL\n",redVal,valCount);

					}
					
					//if(valCount==0)rgbValue[0]=[ImageDebayering randomRgbVal:rgbValue[1]];else
					//rgbValue[0]=redVal/valCount;
					//rgbValue[0]=((redVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;
					
					//rgbValue[0]=randPixVal[[ImageDebayering randomPixel:4]];
					rgbValue[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:4]]);
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
//					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - GREEN PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
					if(i%2!=0) //odd row: blue is left and right
					{

						if(i>0){left=pixel[i-1][j]; blueVal+=left.blue; randPixVal[0]=left.blue; valCount++;
							if(j-2>=0 && j+2<rows){ randPixVal[2]=((pixel[i-1][j-2]).blue+ (pixel[i-1][j+2]).blue )/2; blueVal+=randPixVal[2]; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((i+1)<cols){right=pixel[i+1][j]; blueVal+=right.blue; randPixVal[1]=right.blue; valCount++;
							if(j-2>=0 && j+2<rows){randPixVal[3]=((pixel[i+1][j-2]).blue + (pixel[i+1][j+2]).blue)/2; blueVal+=randPixVal[3]; valCount++;}
						}
						if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);

					}
					else //even row: blue is top and bottom
					{	
						/*
						if(j>0){top=pixel[i][j-1]; blueVal+=top.blue; randPixVal[0]=top.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; blueVal+=bottom.blue; randPixVal[1]=bottom.blue; valCount++;}
						if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						*/

						if(j>0){top=pixel[i][j-1]; blueVal+=top.blue; randPixVal[0]=top.blue; valCount++;
							if(i>1 && i+2<cols){randPixVal[2]=((pixel[i-2][j-1]).blue + (pixel[i-2][j+1]).blue)/2; blueVal+=randPixVal[2]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);
						if((j+1)<rows){bottom=pixel[i][j+1]; blueVal+=bottom.blue; randPixVal[1]=bottom.blue; valCount++;
							if(i>1 && i+2<cols){randPixVal[3]=((pixel[i+2][j-1]).blue + (pixel[i+2][j+1]).blue)/2; blueVal+=randPixVal[3]; valCount++; }
						}
						if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - GREEN PIXEL\n",blueVal,valCount);


					}
					
					//if(valCount==0)rgbValue[2]=[ImageDebayering randomRgbVal:rgbValue[1]];else
					//rgbValue[2]=blueVal/valCount;
					//rgbValue[2]=((blueVal/valCount)+randPixVal[[ImageDebayering randomPixel:2]])/2;
					
					//rgbValue[2]=randPixVal[[ImageDebayering randomPixel:2]];
					rgbValue[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:4]]);
					
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
					
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - GREEN PIXEL\n",i,j);



				}
				if(rgbValue[1]==0 && rgbValue[2]==0) //this is a red pixel
				{
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;
					if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - RED PIXEL\n",i,j);


					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; randPixVal[0]=left.green;  valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; randPixVal[1]=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; randPixVal[2]=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; randPixVal[3]=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - RED PIXEL\n",greenVal,valCount);
					
					
					//if(valCount==0)rgbValue[1]=[ImageDebayering randomRgbVal:rgbValue[0]];else
					//rgbValue[1]=((greenVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;

					//rgbValue[1]=randPixVal[[ImageDebayering randomPixel:4]];
					rgbValue[1]=( (1-randomMix)*(greenVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:4]]);
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;

					//rgbValue[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - RED PIXEL\n",i,j);
					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; blueVal+=topLeft.blue; randPixVal[0]=topLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	blueVal+=topRight.blue; randPixVal[1]=topRight.blue; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; blueVal+=bottomLeft.blue; randPixVal[2]=bottomLeft.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; blueVal+=bottomRight.blue; randPixVal[3]=bottomRight.blue; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - RED PIXEL\n",blueVal,valCount);


					if(debugDebayering)NSLog(@"DEBUG bottomRight done i=%d / j=%d -  blueVal=%f / valCount=%ld - RED PIXEL\n",i,j, blueVal, valCount);
					
					if(debugDebayering)NSLog(@"DEBUG calc blueVal blueVal=%f / valCount=%ld - RED PIXEL\n",blueVal,valCount);
					//if(valCount==0)rgbValue[2]=[ImageDebayering randomRgbVal:rgbValue[0]];else
					//rgbValue[2]=((blueVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;

					//rgbValue[2]=randPixVal[[ImageDebayering randomPixel:4]];
					rgbValue[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:4]]);
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;


					//rgbValue[2]=blueVal/valCount;
					//@try{rgbValue[2]=blueVal/valCount;}
					//@catch(NSException *theException) {NSLog(@"Rummsassa!!!");}
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc blueVal try catch done - RED PIXEL\n",i,j);

					
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;					
					
					//TO DO: calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(i>1){randPixVal[0]=(pixel[i-2][j]).red; redVal+=randPixVal[0]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(i+2<cols){randPixVal[1]=(pixel[i+2][j]).red; redVal+=randPixVal[1];valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(j>1){randPixVal[2]=(pixel[i][j-2]).red; redVal+=randPixVal[2]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					if(j+2<rows){randPixVal[3]=(pixel[i][j+2]).red; redVal+=randPixVal[3]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					//self
					randPixVal[4]=rgbValue[0]; redVal+=randPixVal[4]; valCount++;
					if(debugDebayering)NSLog(@"DEBUG 5 calc redVal=%f valCount=%ld - RED PIXEL\n",redVal,valCount);
					
					//rgbValue[0]=redVal/valCount;
					rgbValue[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:5]]);
					
					if(debugDebayering)NSLog(@"DEBUG calc redVal done -  rgbValue[0]=%lu - RED PIXEL\n",rgbValue[0]);
					
					
				}
				if(rgbValue[0]==0 && rgbValue[1]==0) //this is a blue pixel
				{	
		if(debugDebayering)NSLog(@"DEBUG - pixel[%d][%d] - BLUE PIXEL\n",i,j);
					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate green value
					if(debugDebayering)NSLog(@"DEBUG 0 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(i>0){left=pixel[i-1][j]; greenVal+=left.green; randPixVal[0]=left.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((i+1)<cols){right=pixel[i+1][j]; greenVal+=right.green; randPixVal[1]=right.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if(j>0){top=pixel[i][j-1]; greenVal+=top.green; randPixVal[2]=top.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
					if((j+1)<rows){bottom=pixel[i][j+1]; greenVal+=bottom.green; randPixVal[3]=bottom.green; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc greenVal=%f valCount=%ld - BLUE PIXEL\n",greenVal,valCount);
		
					
					//if(valCount==0){rgbValue[1]=[ImageDebayering randomPixel:4];else
					//int randomPix = [ImageDebayering randomPixel:4];
					//rgbValue[1]=((greenVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;

					//rgbValue[1]=randPixVal[[ImageDebayering randomPixel:4]];
					rgbValue[1]=( (1-randomMix)*(greenVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:4]]);
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
					
//					rgbValue[1]=greenVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc greenVal try catch done - BLUE PIXEL\n",i,j);


					valCount=0;
					redVal=0; greenVal=0; blueVal =0;

					//calculate red value
					if(debugDebayering)NSLog(@"DEBUG 0 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && j>0){topLeft=pixel[i-1][j-1]; redVal+=topLeft.red; randPixVal[0]=topLeft.red; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i+1<cols && (j-1)>=0){topRight=pixel[i+1][j-1]; 	redVal+=topRight.red; randPixVal[1]=topRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if(i>0 && (j+1)<rows){bottomLeft=pixel[i-1][j+1]; redVal+=bottomLeft.red; randPixVal[2]=bottomLeft.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);
					if((i+1)<cols && (j+1)<rows){bottomRight=pixel[i+1][j+1]; redVal+=bottomRight.red; randPixVal[3]=bottomRight.red; 	valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc redVal=%f valCount=%ld - BLUE PIXEL\n",redVal,valCount);

					
					//if(valCount==0)rgbValue[0]=[ImageDebayering randomRgbVal:rgbValue[2]];else
					//rgbValue[0]=((redVal/valCount)+randPixVal[[ImageDebayering randomPixel:4]])/2;

					//rgbValue[0]=randPixVal[[ImageDebayering randomPixel:4]];
					rgbValue[0]=( (1-randomMix)*(redVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:4]]);
					randPixVal[0]=127; randPixVal[1]=127; randPixVal[2]=127; randPixVal[3]=127; randPixVal[4]=127;
					//rgbValue[0]=redVal/valCount;
					valCount=0;
					if(debugDebayering)NSLog(@"DEBUG calc redVal try catch done - BLUE PIXEL\n",i,j);

					valCount=0;
					redVal=0; greenVal=0; blueVal =0;					
					
					//TO DO: calculate blue value
					if(debugDebayering)NSLog(@"DEBUG 0 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(i>1){randPixVal[0]=(pixel[i-2][j]).blue; blueVal+=randPixVal[0]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 1 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(i+2<cols){randPixVal[1]=(pixel[i+2][j]).blue; blueVal+=randPixVal[1]; valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 2 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(j>1){randPixVal[2]=(pixel[i][j-2]).blue; blueVal+=randPixVal[2];valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 3 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					if(j+2<rows){randPixVal[3]=(pixel[i][j+2]).blue; blueVal+=randPixVal[3];valCount++;}
					if(debugDebayering)NSLog(@"DEBUG 4 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					//self
					randPixVal[4]=rgbValue[0]; blueVal+=randPixVal[4]; valCount++;
					if(debugDebayering)NSLog(@"DEBUG 5 calc blueVal=%f valCount=%ld - BLUE PIXEL\n",blueVal,valCount);
					
					rgbValue[2]=blueVal/valCount;
					rgbValue[2]=( (1-randomMix)*(blueVal/valCount)+randomMix*randPixVal[[ImageDebayering randomPixel:5]]);
					if(debugDebayering)NSLog(@"DEBUG calc blueVal done -  rgbValue[0]=%lu - BLUE PIXEL\n",rgbValue[0]);
					
					
					
				}
				//ATTENTION: do not write back processed pixels to original pixelPattern!
				//otherwised will be directly reused for calculating pixels -> interferrence and false values!
				
				rgbBytes rgbPixel;
				rgbPixel.red = rgbValue[0];
				rgbPixel.green = rgbValue[1];
				rgbPixel.blue = rgbValue[2];
				if(debugDebayering)NSLog(@"DEBAYERING: pixel[%d][%d] - rgbValue = (%d/%d/%d) \n",i,j, rgbValue[0],rgbValue[1],rgbValue[2]);
				//pixel[i][j] = rgbPixel;
				processedPixel[i][j] = rgbPixel;

				
			} //END of for(cols)
		} //END of for(rows)
		
		//TO DO: replace pixelArray with processed pixelArray
		//pixel = processedPixel;
	} //END if(debayeringMethod)


	/*********************************************************************/
	//	DEBAYERING METHOD 7 (Experimental NxN Matrix with gaussian weight
	/*********************************************************************/

	randomMix = 0.5;
	randomPart = 0;
	float randomPartRed, randomPartGreen, randomPartBlue=0.0;
	float randomWeightRed, randomWeightGreen, randomWeightBlue=0.0;
	randIts = 3;
	randomMix=settings.randomMix;
	randIts=settings.randIts;
	int shrinkX=2;
	int shrinkY =2; //Amount at each side(left, right, top, bottom) the gaussPattern is shrinked for Random part
	bool gaussianRandom = false; //for generating random Part. if true weigh the random Parts with gaussian variation
	r=0;	
	
	if(debayeringMethod==7){
		bool debugNxN=false;
		bool debugNxN2=true;
		bool keepOriginalPixelColorValue = false;
		int patternSize = 7; //should be odd: center + 2*x +2*y
		patternSize = settings.patternSize;
			//Test, if Array is not correctly initialized each turn
			float randRedVal[patternSize*patternSize];
			float randGreenVal[patternSize*patternSize];
			float randBlueVal[patternSize*patternSize];

			float randRedWeight[patternSize*patternSize];
			float randGreenWeight[patternSize*patternSize];
			float randBlueWeight[patternSize*patternSize];

			
			float radius = 0.2;
			//float sigma = (radius + 1)/(sqrt(2*log(255)));
			float sigma = radius/3.0;
			float variance = powf(sigma,2);
			
			
			
			variance=2.5;
			variance=settings.debayeringVariance;
			//variance 3: 0.0025|0.2231|1.0|0.2231|0.0025
			//variance=2: 0.018|0.367|1.0|0.367|0.018	
			float gaussianMatrix[patternSize][patternSize];


			
			int x,y=0;
			float normalize = 1/(1/(2*M_PI*variance) )*expf( (-1)*(pow(0,2)+pow(0,2))/2*variance );
			//Initialize Gaussian Matrix
			for(y=-patternSize/2;y<patternSize/2+1;y++){
				for(x=-patternSize/2;x<patternSize/2+1;x++){
					float h = normalize*(1/(2*M_PI*variance) )*expf( (-1)*(pow(x,2)+pow(y,2))/2*variance );
					gaussianMatrix[x+patternSize/2][y+patternSize/2]=h;
					NSLog(@"FILLING GAUSSIAN MATRIX: X=%d / Y=%d",x,y);
				}
			}



			if(testLoopFirstPixels){
				int iX,iY=0;
				rgbBytes rgbPix;			
				for(iY=0;iY<5;iY++){
					for(iX=0;iX<5;iX++){
						NSLog(@"TEST LOOP start Deb7 - checking first Pixels... iX=%d / iY=%d",iX,iY);
						rgbPix=pixel[iX][iY];
						NSLog(@"TEST LOOP start Deb7 - checking first Pixels... rgbPix=(%f/%f/%f)" ,rgbPix.red,rgbPix.green,rgbPix.blue);
					}
				}
			}



			//float h = (1/(2*M_PI*variance) )*expf( (-1)*(pow(x,2)+pow(y,2))/2*variance );
			int rX,rY=0;
//			rgbBytes rgbPix;
			float rgbVal[3];
			int xMin,yMin=0;
			int xMax=cols-1;
			int yMax=rows-1;
			int isOriginalPixelGreen = 0; int isOriginalPixelRed = 0; int isOriginalPixelBlue = 0;

			for(y=0;y<rows;y++){
				for(x=0;x<cols;x++){
					if(debug32Bit)NSLog(@"RGB PIX[%i][%i]=(%lu/%lu/%lu)\n",x,y,pixel[x][y].red,pixel[x][y].green,pixel[x][y].blue);
					if(debugNxN)NSLog(@"DEBUG NxN: x=%d / y=%d / cols=%d / rows=%d\n",x,y,cols, rows);
					rgbVal[0]=0;rgbVal[1]=0;rgbVal[2]=0;

					if(keepOriginalPixelColorValue) {
						isOriginalPixelGreen = ((x+1)%2)*((y+1)%2) + (x%2)*(y%2);
						isOriginalPixelRed = (x%2)*((y+1)%2);
						isOriginalPixelBlue = (x+1)%2 * y%2;
					}
					if(isOriginalPixelRed) rgbVal[0]=pixel[x][y].red;
					else if(isOriginalPixelGreen) rgbVal[1]=pixel[x][y].green;
					else if(isOriginalPixelBlue) rgbVal[2]=pixel[x][y].blue;

					
					xMin= (x>patternSize/2)?-patternSize/2:(-1)*x;
					if(debugNxN)NSLog(@"DEBUG NxN: xMin=%d \n",xMin);
					yMin= (y>patternSize/2)?-patternSize/2:(-1)*y;
					if(debugNxN)NSLog(@"DEBUG NxN: yMin=%d \n",yMin);
					xMax= ((cols-x)>patternSize/2)?patternSize/2+1:(cols-x);
					if(debugNxN)NSLog(@"DEBUG NxN: xMax=%d \n",xMax);
					yMax= ((rows-y)>patternSize/2)?patternSize/2+1:(rows-y);	
					if(debugNxN)NSLog(@"DEBUG NxN: yMax=%d \n",yMax);
					
					if(debugNxN)NSLog(@"DEBUG NxN: xMin=%d / xMax=%d / yMin=%d / yMax=%d\n",xMin, xMax,yMin,yMax);
					float blurCounter=0;
					int counterGreen=0;
					int counterRed=0;
					int counterBlue=0;
					float weightGreen=0;
					float weightRed=0;
					float weightBlue=0;
					if(debugNxN)NSLog(@"DEBUG NxN: check 1\n");
					
					for(rY=yMin;rY<yMax;rY++){
						for(rX=xMin;rX<xMax;rX++){
							/*
							int isGreen = ((rX+1)%2)*((rY+1)%2) + (rX%2)*(rY%2);
							int isRed = (rX%2)*((rY+1)%2);
							int isBlue = (rX+1)%2 * rY%2;
							*/

							int isGreen = ((x+rX+1)%2)*((y+rY+1)%2) + ((x+rX)%2)*((y+rY)%2);
							int isRed = ((x+rX)%2)*((y+rY+1)%2);
							int isBlue = (x+rX+1)%2 * (y+rY)%2;

							
							if(debugNxN)NSLog(@"DEBUG NxN: x=%d / y=%d / rX=%d / rY=%d / xMin=%d / xMax=%d / yMin=%d / yMax=%d / isRed=%d, isGreen=%d, isBlue=%d / gauss=%.4f / pixel[%d][%d]=(%d,%d,%d)\n",x,y,rX,rY,xMin,xMax, yMin,yMax,isRed, isGreen, isBlue, (gaussianMatrix[patternSize/2+rX][patternSize/2+rY]), (x+rX),(y+rY), pixel[x+rX][y+rY].red,pixel[x+rX][y+rY].green,pixel[x+rX][y+rY].blue );
/*
							rgbVal[0] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isRed*pixel[x+rX][y+rY].red;
							rgbVal[1] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isGreen*pixel[x+rX][y+rY].green;
							rgbVal[2] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isBlue*pixel[x+rX][y+rY].blue;
*/
							if(keepOriginalPixelColorValue) {
								if(isOriginalPixelRed==0) 	rgbVal[0] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isRed*pixel[x+rX][y+rY].red;
								if(isOriginalPixelGreen==0) rgbVal[1] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isGreen*pixel[x+rX][y+rY].green;
								if(isOriginalPixelBlue==0) 	rgbVal[2] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isBlue*pixel[x+rX][y+rY].blue;
							}
							else {
								rgbVal[0] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isRed*pixel[x+rX][y+rY].red;
								rgbVal[1] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isGreen*pixel[x+rX][y+rY].green;
								rgbVal[2] += gaussianMatrix[patternSize/2+rX][patternSize/2+rY]*isBlue*pixel[x+rX][y+rY].blue;
							}

							if(debug32Bit)NSLog(@"RGB PIX[%i][%i]=(%lu/%lu/%lu)\n",x,y,pixel[x][y].red,pixel[x][y].green,pixel[x][y].blue);

if(debugNxN)NSLog(@"SHRINK: rX=%d / abs(rX)=%d / xMin=%d / shrinkX=%d / xMax=%d\n", rX,abs(rX),xMin,shrinkX,xMax);
if(debugNxN)NSLog(@"SHRINK: rY=%d / abs(rY)=%d / yMin=%d / shrinkY=%d / yMax=%d\n", rY,abs(rY),yMin,shrinkY,yMax);
//							if( (abs(rY)<yMin-shrinkX) && (abs(rX)<xMin-shrinkX) ){
//							if( (rY>=yMin-shrinkX) && (rX>=xMin-shrinkX) && (rY<yMax-shrinkY) && (rX<xMax-shrinkX) ){
							bool addRandom =false;
							if( (rY>=yMin+shrinkY) && (rX>=xMin+shrinkX) && (rY<yMax-shrinkY) && (rX<xMax-shrinkX) ){addRandom = true;}
							if(isRed){
					if(debugNxN)NSLog(@"DEBUG NxN: check 2 counterRed=%d / pixel[%d][%d].red=%lu\n",counterRed,x+rX,y+rY,pixel[x+rX][y+rY].red);
								if(addRandom){
									randRedVal[counterRed]=pixel[x+rX][y+rY].red;
									counterRed++; 
								}
								//weightRed+=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								if(!gaussianRandom) randRedWeight[counterRed]=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								weightRed+=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								//weightRed+=randRedWeight[counterRed];
					if(debugNxN)NSLog(@"DEBUG NxN: check 3 weightRed=%.4f\n",weightRed);
							}
							if(isGreen){
					if(debugNxN)NSLog(@"DEBUG NxN: check 4 counterGreen=%d / pixel[%d][%d].green=%lu\n",counterGreen,x+rX,y+rY,pixel[x+rX][y+rY].green);
								if(addRandom){
									randGreenVal[counterGreen]=pixel[x+rX][y+rY].green;
									counterGreen++; 
								}
								//weightGreen+=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								if(!gaussianRandom) randGreenWeight[counterGreen]=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								weightGreen+=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								//weightGreen+=randGreenWeight[counterGreen];
					if(debugNxN)NSLog(@"DEBUG NxN: check 5 weightGreen=%.4f\n",weightGreen);
							}
							if(isBlue){
					if(debugNxN)NSLog(@"DEBUG NxN: check 6 counterBlue=%d / pixel[%d][%d].blue=%lu\n",counterBlue,x+rX,y+rY,pixel[x+rX][y+rY].blue);
								if(addRandom){
									randBlueVal[counterBlue]=pixel[x+rX][y+rY].blue;
									counterBlue++; 
								}
								//weightBlue+=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								if(!gaussianRandom) randBlueWeight[counterBlue]=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								weightBlue+=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
								//weightBlue+=randBlueWeight[counterBlue];
					if(debugNxN)NSLog(@"DEBUG NxN: check 7 weightBlue=%.4f\n",weightBlue);
							}
							
							//blurCounter++;
							//blurCounter+=gaussianMatrix[patternSize/2+rX][patternSize/2+rY];
							if(debugNxN)NSLog(@"DEBUG NxN: x=%d / y=%d / rX=%d / rY=%d / xMin=%d / xMax=%d / yMin=%d / yMax=%d / isRed=%d, isGreen=%d, isBlue=%d / gauss=%.4f / pixel[%d][%d]=(%d,%d,%d)\n",x,y,rX,rY,xMin,xMax, yMin,yMax,isRed, isGreen, isBlue, (gaussianMatrix[patternSize/2+rX][patternSize/2+rY]), (x+rX),(y+rY), pixel[x+rX][y+rY].red,pixel[x+rX][y+rY].green,pixel[x+rX][y+rY].blue );
							if(debugNxN)NSLog(@"DEBUG NxN: rgbVal=(%d,%d,%d) / pixel[%d][%d]=(%d,%d,%d) / blurCounter=%.2f\n",rgbVal[0],rgbVal[1],rgbVal[2],(x+rX),(y+rY),pixel[x+rX][y+rY].red, pixel[x+rX][y+rY].green, pixel[x+rX][y+rY].blue,blurCounter);
						}
					}	
					if(debugNxN)NSLog(@"DEBUG NxN: check 8\n");
					if(debugNxN)NSLog(@"DEBUG NxN: check 9 weightRed=%.4f / weightGreen=%.4f / weightBlue=%.4f\n",weightRed, weightGreen, weightBlue);
								
					rgbBytes outPix;
					outPix.red=rgbVal[0]/weightRed;
					outPix.green=rgbVal[1]/weightGreen;
					//outPix.green=rgbVal[1]/weightRed; // just testing, because there's always more green (*2) then red and blue pixels in the GRBG Pattern
					outPix.blue=rgbVal[2]/weightBlue;
					processedPixel[x][y]=outPix;
					if(debugNxN)NSLog(@"DEBUG NxN: OUTPUT PIXEL before RANDOM - outPix[%d][%d]=(%lu,%lu,%lu) / counter=(%d,%d,%d) / weightRed=%.2f, weightGreen=%.2f, weightBlue=%.2f / randomMix=%.2f\n",x,y,outPix.red,outPix.green,outPix.blue, counterRed,counterGreen,counterBlue, weightRed,weightGreen,weightBlue, randomMix);


					//Generate random Part
					randomPartRed=0;
					randomPartGreen=0;
					randomPartBlue=0;

					randomWeightRed=0.0;
					randomWeightGreen=0.0;
					randomWeightBlue=0.0;

					if(debugNxN)NSLog(@"DEBUG NxN: check 10\n");

					for(r=0;r<randIts;r++){
						if(debugNxN)NSLog(@"DEBUG NxN: Random Iterations randIts=%d\n",randIts);
						if(!gaussianRandom){
					if(debugNxN)NSLog(@"DEBUG NxN: check 11 counterRed=%d\n",counterRed);
/*							randomPartRed+=randRedVal[[ImageDebayering randomPixel:(counterRed-1)]];
							randomPartGreen+=randGreenVal[[ImageDebayering randomPixel:(counterGreen-1)]];
							randomPartBlue+=randBlueVal[[ImageDebayering randomPixel:(counterBlue-1)]];
*/
							randomPartRed+=randRedVal[[ImageDebayering randomPixel:(counterRed)]];
							randomPartGreen+=randGreenVal[[ImageDebayering randomPixel:(counterGreen)]];
							randomPartBlue+=randBlueVal[[ImageDebayering randomPixel:(counterBlue)]];
					if(debugNxN)NSLog(@"DEBUG NxN: check 12\n");
						}
						else{
					if(debugNxN)NSLog(@"DEBUG NxN: check 13\n");
/*							int randomRedPixNum = [ImageDebayering randomPixel:(counterRed-1)];
							int randomGreenPixNum = [ImageDebayering randomPixel:(counterGreen-1)];
							int randomBluePixNum = [ImageDebayering randomPixel:(counterBlue-1)];
*/
							int randomRedPixNum = [ImageDebayering randomPixel:(counterRed)];
							int randomGreenPixNum = [ImageDebayering randomPixel:(counterGreen)];
							int randomBluePixNum = [ImageDebayering randomPixel:(counterBlue)];
						if(debugNxN)NSLog(@"DEBUG NxN: check 14\n");

							randomWeightRed+=randRedWeight[randomRedPixNum];
							randomWeightGreen+=randGreenWeight[randomGreenPixNum];
							randomWeightBlue+=randBlueWeight[randomBluePixNum];
					if(debugNxN)NSLog(@"DEBUG NxN: check 15\n");

							randomPartRed+=randRedWeight[randomRedPixNum]*randRedVal[randomRedPixNum];
							randomPartGreen+=randGreenWeight[randomGreenPixNum]*randGreenVal[randomGreenPixNum];
							randomPartBlue+=randBlueWeight[randomBluePixNum]*randBlueVal[randomBluePixNum];
					if(debugNxN)NSLog(@"DEBUG NxN: check 16\n");
						}
					}
					if(debugNxN)NSLog(@"DEBUG NxN: check 17\n");
					
					if(!gaussianRandom){
					if(debugNxN)NSLog(@"DEBUG NxN: check 18\n");
						randomPartRed=randomPartRed/randIts;	
						randomPartGreen=randomPartGreen/randIts;	
						randomPartBlue=randomPartBlue/randIts;	
					if(debugNxN)NSLog(@"DEBUG NxN: check 19\n");
					}
					else {
					if(debugNxN)NSLog(@"DEBUG NxN: check 20\n");
						/*
						randomPartRed=randomWeightRed*randomPartRed/randIts;	
						randomPartGreen=randomWeightGreen*randomPartGreen/randIts;	
						randomPartBlue=randomWeightBlue*randomPartBlue/randIts;	
						*/
						//NSLog(@"randomWeightRed=%.16f / randomWeightGreen=%.16f / randomWeightBlue=%.16f", randomWeightRed, randomWeightGreen, randomWeightBlue);

						randomPartRed=randomPartRed/randomWeightRed;	
						randomPartGreen=randomPartGreen/randomWeightGreen;	
						randomPartBlue=randomPartBlue/randomWeightBlue;	
					if(debugNxN)NSLog(@"DEBUG NxN: check 21\n");
						
					}
					if(debugNxN)NSLog(@"DEBUG NxN: check 22\n");
					
					outPix.red=( (1-randomMix)*(rgbVal[0]/weightRed)+randomMix*randomPartRed);
					outPix.green=( (1-randomMix)*(rgbVal[1]/weightGreen)+randomMix*randomPartGreen);
					outPix.blue=( (1-randomMix)*(rgbVal[2]/weightBlue)+randomMix*randomPartBlue);
					
					if(keepOriginalPixelColorValue){
						if(isOriginalPixelRed) outPix.red = rgbVal[0];
						if(isOriginalPixelGreen) outPix.green = rgbVal[1];
						if(isOriginalPixelBlue) outPix.blue = rgbVal[2];
					}

					if(debugNxN)NSLog(@"DEBUG NxN: check 23\n");
					
					if(debugNxN2 && (x%100==0 && y%100==0))NSLog(@"DEBUG NxN: Writing OUTPUT PIXEL - outPix[%d][%d]=(%d,%d,%d) / counter=(%d,%d,%d) / weightRed=%.2f, weightGreen=%.2f, weightBlue=%.2f / randomMix=%.2f\n",x,y,outPix.red,outPix.green,outPix.blue, counterRed,counterGreen,counterBlue, weightRed,weightGreen,weightBlue, randomMix);
					processedPixel[x][y]=outPix;					
					if(debugNxN)NSLog(@"DEBUG NxN: check 24\n");

					
				}
			}
			
//			bool testLoopFirstPixels = true;
			if(testLoopFirstPixels){
				int iX,iY=0;
				rgbBytes rgbPix;			
				for(iY=0;iY<5;iY++){
					for(iX=0;iX<5;iX++){
						NSLog(@"TEST LOOP Deb7 - checking first Pixels... iX=%d / iY=%d",iX,iY);
						rgbPix=processedPixel[iX][iY];
						NSLog(@"TEST LOOP Deb7 - checking first Pixels... rgbPix=(%f/%f/%f)" ,rgbPix.red,rgbPix.green,rgbPix.blue);
					}
				}
			}
			
//			processedPixel=blurredPixel;
	}


	

	if(debug3)NSLog(@"DEBAYERING DONE (or skipped)\n");
	
	/***********************************************************************/
	//					
	//		GAUSSIAN BLUR
	//
	/***********************************************************************/	
	
	//TO DO: Make 32Bit ready
	
	//bool doBlur = true;
	bool doBlur = settings.doBlur;
	bool debugBlur = false;
	float radius = 0.2;
	//float sigma = (radius + 1)/(sqrt(2*log(255)));
	float sigma = radius/3.0;
	float variance = powf(sigma,2);
	variance=3;
	variance=settings.blurVariance;
	//variance 3: 0.0025|0.2231|1.0|0.2231|0.0025
	//variance=2: 0.018|0.367|1.0|0.367|0.018	
	float gaussianMatrix[5][5];
	int x,y=0;
	float normalize = 1/(1/(2*M_PI*variance) )*expf( (-1)*(pow(0,2)+pow(0,2))/2*variance );
	//Initialize Gaussian Matrix
	for(y=-2;y<3;y++){
		for(x=-2;x<3;x++){
			float h = normalize*(1/(2*M_PI*variance) )*expf( (-1)*(pow(x,2)+pow(y,2))/2*variance );
			gaussianMatrix[x+2][y+2]=h;
		}
	}
	//float h = (1/(2*M_PI*variance) )*expf( (-1)*(pow(x,2)+pow(y,2))/2*variance );
	
	
	int rX,rY=0;
//	rgbBytes rgbPix;
	float rgbVal[3];
	if(doBlur){
			for(y=-2;y<3;y++){
				for(x=-2;x<3;x++){
					if(debugBlur)NSLog(@"Gaussian Matrix[%d][%d]=%.4f\n",x, y, gaussianMatrix[x+2][y+2]);
				}
			}
			int xMin,yMin=0;
			int xMax=cols-1;
			int yMax=rows-1;
			for(y=0;y<rows;y++){
				for(x=0;x<cols;x++){
					if(debugBlur)NSLog(@"DEBUG BLUR: x=%d / y=%d / cols=%d / rows=%d\n",x,y,cols, rows);
					rgbVal[0]=0;rgbVal[1]=0;rgbVal[2]=0;
				
					xMin= (x>2)?-2:(-1)*x;
					if(debugBlur)NSLog(@"DEBUG BLUR: xMin=%d \n",xMin);
					yMin= (y>2)?-2:(-1)*y;
					if(debugBlur)NSLog(@"DEBUG BLUR: yMin=%d \n",yMin);
					xMax= ((cols-x)>2)?3:(cols-x);
					if(debugBlur)NSLog(@"DEBUG BLUR: xMax=%d \n",xMax);
					yMax= ((rows-y)>2)?3:(rows-y);	
					if(debugBlur)NSLog(@"DEBUG BLUR: yMax=%d \n",yMax);
					
					if(debugBlur)NSLog(@"DEBUG BLUR: xMin=%d / xMax=%d / yMin=%d / yMax=%d\n",xMin, xMax,yMin,yMax);
					float blurCounter=0;
					for(rY=yMin;rY<yMax;rY++){
						for(rX=xMin;rX<xMax;rX++){
							rgbVal[0] += gaussianMatrix[2+rX][2+rY]*processedPixel[x+rX][y+rY].red;
							rgbVal[1] += gaussianMatrix[2+rX][2+rY]*processedPixel[x+rX][y+rY].green;
							rgbVal[2] += gaussianMatrix[2+rX][2+rY]*processedPixel[x+rX][y+rY].blue;
							//blurCounter++;
							blurCounter+=gaussianMatrix[2+rX][2+rY];
							if(debugBlur)NSLog(@"DEBUG BLUR: rgbVal=(%d,%d,%d) / processedPixel[%d][%d]=(%d,%d,%d) / blurCounter=%.2f\n",rgbVal[0],rgbVal[1],rgbVal[2],x+rX,y+rY,processedPixel[x+rX][y+rY].red, processedPixel[x+rX][y+rY].green, processedPixel[x+rX][y+rY].blue,blurCounter);
						}
					}	
					if(debugBlur)NSLog(@"DEBUG BLUR: blurCounter=%.2f\n",blurCounter);
					if(debugBlur)NSLog(@"DEBUG BLUR: rgbVal=(%d,%d,%d) / blurCounter=%.2f \n",(int)(rgbVal[0]/blurCounter),(int)(rgbVal[1]/blurCounter),(int)(rgbVal[2]/blurCounter), blurCounter);
								
					rgbBytes outPix;
					outPix.red=rgbVal[0]/blurCounter;outPix.green=rgbVal[1]/blurCounter;outPix.blue=rgbVal[2]/blurCounter;
					blurredPixel[x][y]=outPix;
					
				}
			}
			
//			bool testLoopFirstPixels = true;
			if(testLoopFirstPixels){
				int iX,iY=0;
				rgbBytes rgbPix;			
				for(iY=0;iY<5;iY++){
					for(iX=0;iX<5;iX++){
						NSLog(@"TEST LOOP blur - checking first Pixels... iX=%d / iY=%d",iX,iY);
						rgbPix=blurredPixel[iX][iY];
						NSLog(@"TEST LOOP blur - checking first Pixels... rgbPix=(%f/%f/%f)" ,rgbPix.red,rgbPix.green,rgbPix.blue);
					}
				}
			}
			
			processedPixel=blurredPixel;
	}
	



	/***********************************************************************/
	//					
	//		FILM GRAIN
	//
	/***********************************************************************/	
	
	//TO DO: SPEED UP ALGORITHM - random Parts seem to be very slow in total
	bool doGrain = true;
	float mixGrain = 0.33;
	float zufall = 1.0;
//	float randomGrainPixel =0.0;
	int grainPattern = 5;
	//bool doGrain = settings.doGrain;
	bool debugGrain = false;
	float range = 0.1;
	NSLog(@"range=%f",range);
	float rangePercent = 5.0;
//	float minRange = 1.0 - range; 
//	float maxRange = 1.0 + range; 

	//Overwrite with values from settings / command line
	doGrain = settings.doGrain;
	grainPattern = settings.grainPatternSize;
	mixGrain = settings.mixGrain;
	rangePercent = settings.grainDeviation;
	

	if(doGrain){
			int xMin,yMin=0;
			int xMax=cols-1;
			int yMax=rows-1;
			for(y=0;y<rows;y++){
				for(x=0;x<cols;x++){
					if(debugBlur)NSLog(@"DEBUG BLUR: x=%d / y=%d / cols=%d / rows=%d\n",x,y,cols, rows);
					rgbVal[0]=0;rgbVal[1]=0;rgbVal[2]=0;

					xMin= (x>grainPattern)?-grainPattern:(-1)*x;
					if(debugBlur)NSLog(@"DEBUG BLUR: xMin=%d \n",xMin);
					yMin= (y>grainPattern)?-grainPattern:(-1)*y;
					if(debugBlur)NSLog(@"DEBUG BLUR: yMin=%d \n",yMin);
					xMax= ((cols-x)>grainPattern)?grainPattern+1:(cols-x);
					if(debugBlur)NSLog(@"DEBUG BLUR: xMax=%d \n",xMax);
					yMax= ((rows-y)>grainPattern)?grainPattern+1:(rows-y);	
					if(debugBlur)NSLog(@"DEBUG BLUR: yMax=%d \n",yMax);

					if(debugBlur)NSLog(@"DEBUG BLUR: xMin=%d / xMax=%d / yMin=%d / yMax=%d\n",xMin, xMax,yMin,yMax);
					float blurCounter=0;
					for(rY=yMin;rY<yMax;rY++){
						for(rX=xMin;rX<xMax;rX++){
							//add random component to pixel selection
							if([ImageDebayering randomBoolean]){
								rgbVal[0] += processedPixel[x+rX][y+rY].red;
								rgbVal[1] += processedPixel[x+rX][y+rY].green;
								rgbVal[2] += processedPixel[x+rX][y+rY].blue;
								//blurCounter++;
								blurCounter++;
								if(debugBlur)NSLog(@"DEBUG BLUR: rgbVal=(%d,%d,%d) / processedPixel[%d][%d]=(%d,%d,%d) / blurCounter=%.2f\n",rgbVal[0],rgbVal[1],rgbVal[2],x+rX,y+rY,processedPixel[x+rX][y+rY].red, processedPixel[x+rX][y+rY].green, processedPixel[x+rX][y+rY].blue,blurCounter);
							}
						}
					}	
					if(debugBlur)NSLog(@"DEBUG BLUR: blurCounter=%.2f\n",blurCounter);
					if(debugBlur)NSLog(@"DEBUG BLUR: rgbVal=(%d,%d,%d) / blurCounter=%.2f \n",(int)(rgbVal[0]/blurCounter),(int)(rgbVal[1]/blurCounter),(int)(rgbVal[2]/blurCounter), blurCounter);
								
					rgbBytes outPix;
//					zufall = ((float)arc4random() / ARC4RANDOM_MAX * (maxRange - minRange)) + minRange;
					//zufall = (float)[ImageDebayering randomPixel:10]/100;
					
					//randomGrainPixel=[ImageDebayering randomPixelValue:(int)rgbVal[0] bitsPerSample:(int)bitsPerSample range:(int)range];
//	if(debugBlur)NSLog(@"range=%f / minRange=%f / maxRange=%f",range, minRange, maxRange);
//					if(debugBlur)NSLog(@"now calling randomPixelValue / randomPixelDeviation with pixel: %d / bitsPerSample=%d / range=%f / rangePercent=%d", (rgbVal[0]/blurCounter), bitsPerSample, range, rangePercent);
					
					//if(debugBlur)NSLog(@"zufall = %f",zufall);
/*
					[ColorCorrection setMaxVal:bitsPerSample];
					unsigned long maxV = [ColorCorrection getMaxVal];
//					float desc = (float)(rgbVal[0]+rgbVal[1]+rgbVal[2])/(3.0*(float)[ColorCorrection getMaxVal]);
					float desc = (float)((rgbVal[0]+rgbVal[1]+rgbVal[2])/(float)(3.0*(float)[ColorCorrection getMaxVal]) );
					rangePercent = rangePercent*( 2.0-(float)(rgbVal[0]+rgbVal[1]+rgbVal[2])/(3.0*(float)[ColorCorrection getMaxVal]) ); //should be 2*rangePercent for rgb val =0 and 1*rangePercent for max rgb vals
*/
//					NSLog(@"GRAIN: RGB COLOR (%f/%f/%f) / maxV=%u / desc=%f / rangePercent=%f", rgbVal[0], rgbVal[1], rgbVal[2],maxV,desc, rangePercent);
//					NSLog(@"GRAIN: RGB COLOR (%f/%f/%f) / maxV=%f / desc=%u / rangePercent=%f", rgbVal[0], rgbVal[1], rgbVal[2],maxV,desc, rangePercent);
					zufall=[ImageDebayering randomPixelDeviation:(float)((rgbVal[0]+rgbVal[1]+rgbVal[2])/(3.0*blurCounter)) bitsPerSample:(int)bitsPerSample rangePercent:(float)rangePercent];
					outPix.red=mixGrain*((rgbVal[0]/blurCounter)+zufall) + (1-mixGrain)*processedPixel[x][y].red;
					outPix.green=mixGrain*((rgbVal[1]/blurCounter)+zufall) + (1-mixGrain)*processedPixel[x][y].green;
					outPix.blue=mixGrain*((rgbVal[2]/blurCounter)+zufall) + (1-mixGrain)*processedPixel[x][y].blue;

/*
//	if(debugBlur)NSLog(@"range=%f / minRange=%f / maxRange=%f",range, minRange, maxRange);

					if(debugBlur)NSLog(@"now calling randomPixelValue / randomPixelDeviation with pixel: %f / bitsPerSample=%d / range=%f ", (rgbVal[0]/blurCounter), bitsPerSample, range);
					randomGrainPixel=[ImageDebayering randomPixelValue:(rgbVal[0]/blurCounter) bitsPerSample:bitsPerSample pixRange:range];
					if(debugBlur)NSLog(@"returned randomGrainPixel= %f", randomGrainPixel);
					outPix.red=mixGrain*randomGrainPixel + (1-mixGrain)*processedPixel[x][y].red;
					if(debugBlur)NSLog(@"now calling randomPixelValue / randomPixelDeviation with pixel: %f / bitsPerSample=%d / range=%f ", (rgbVal[1]/blurCounter), bitsPerSample, range);
					randomGrainPixel=[ImageDebayering randomPixelValue:(rgbVal[1]/blurCounter) bitsPerSample:bitsPerSample pixRange:range];
					if(debugBlur)NSLog(@"returned randomGrainPixel= %f", randomGrainPixel);
					outPix.green=mixGrain*randomGrainPixel + (1-mixGrain)*processedPixel[x][y].green;
					if(debugBlur)NSLog(@"now calling randomPixelValue / randomPixelDeviation with pixel: %f / bitsPerSample=%d / range=%f ", (rgbVal[2]/blurCounter), bitsPerSample, range);
					randomGrainPixel=[ImageDebayering randomPixelValue:(rgbVal[2]/blurCounter) bitsPerSample:bitsPerSample pixRange:range];
					if(debugBlur)NSLog(@"returned randomGrainPixel= %f", randomGrainPixel);
					outPix.blue=mixGrain*randomGrainPixel + (1-mixGrain)*processedPixel[x][y].blue;
*/


					blurredPixel[x][y]=outPix;
					
				}
			}
			
//			bool testLoopFirstPixels = true;
			if(testLoopFirstPixels){
				int iX,iY=0;
				rgbBytes rgbPix;			
				for(iY=0;iY<5;iY++){
					for(iX=0;iX<5;iX++){
						NSLog(@"TEST LOOP grain - checking first Pixels... iX=%d / iY=%d",iX,iY);
						rgbPix=blurredPixel[iX][iY];
						NSLog(@"TEST LOOP grain - checking first Pixels... rgbPix=(%f/%f/%f)" ,rgbPix.red,rgbPix.green,rgbPix.blue);
					}
				}
			}
			
			processedPixel=blurredPixel;
	}





	/***********************************************************************
	*
	*	COLOR CORRECTION
	*
	************************************************************************/
	colorRedo = settings.colorRedo;
//	colorCorrectionMethod = settings.colorCorrectionMethod;
	bool debugColorRedo = false;
	

	NSLog(@"flag colorRedo is set to ...%d",colorRedo);
	if(colorRedo){
		if(debugColorRedo)NSLog(@"REDOING COLORS...");
		
		//Testing LUT cube transformation
		int m,n,o = 0;
		rgbBytes testPixel, testOutPixel;
		//initialize 
		testPixel.red=testPixel.green=testPixel.blue=0.0;
		testOutPixel.red=testOutPixel.green=testOutPixel.blue=0.0;
		bool testLutCubeTransform = false;
		if(debugColorRedo)NSLog(@"REDOING COLORS... check1");
		if(testLutCubeTransform){
			if(debugColorRedo)NSLog(@"REDOING COLORS... check2");
			for(m=0;m<4096;m+=10){
				for(n=0;n<4096;n+=10){
					for(o=0;o<4096;o+=10){
						testPixel.red=(float)m;
						testPixel.green=(float)n;
						testPixel.blue=(float)o;
						testOutPixel = [ColorCorrection lutCubeTransform:testPixel bitsPerSample:bitsPerSample debug:false];
//						testOutPixel = [ColorCorrection lutCubeTransform:testPixel bitsPerSample:bitsPerSample];
						if(debugColorRedo)NSLog(@"TESTING LUT CUBE TRANSFORM: IN (%f/%f/%f) - OUT (%f/%f/%f)",testPixel.red,testPixel.green,testPixel.blue,testOutPixel.red,testOutPixel.green,testOutPixel.blue);
					}
				}
			}
		}
		if(debugColorRedo)NSLog(@"REDOING COLORS... check3");
	
		int iX,iY=0;
		rgbBytes rgbPix;
//		bool testLoopFirstPixels = true;
		if(testLoopFirstPixels){
			for(iY=0;iY<5;iY++){
				for(iX=0;iX<5;iX++){
					NSLog(@"TEST LOOP colorRedo - checking first Pixels... iX=%d / iY=%d",iX,iY);
					rgbPix=processedPixel[iX][iY];
					NSLog(@"TEST LOOP colorRedo - checking first Pixels... rgbPix=(%f/%f/%f)" ,rgbPix.red,rgbPix.green,rgbPix.blue);
				}
			}
		}
		if(debugColorRedo)NSLog(@"REDOING COLORS... check4");
			for(iY=0;iY<imageHeight;iY++){
				for(iX=0;iX<imageWidth;iX++){
					if(debugColorRedo)NSLog(@"REDOING COLORS... iX=%d / iY=%d",iX,iY);
					rgbPix=processedPixel[iX][iY];
					//if grading
		if(debugColorRedo)NSLog(@"REDOING COLORS... check5 rgbPix=(%f/%f/%f)" ,rgbPix.red,rgbPix.green,rgbPix.blue);
					if(colorCorrectionMethod==0)rgbPix = [ColorCorrection correctColors:rgbPix bitsPerSample:bitsPerSample];
					//if LUT from Cube
		if(debugColorRedo)NSLog(@"REDOING COLORS... check6 iX/iY=%d/%d",iX,iY);
					//if(colorCorrectionMethod==1)	rgbPix = [ColorCorrection lutCubeTransform:rgbPix bitsPerSample:bitsPerSample];
//					if(colorCorrectionMethod==1)	rgbPix = [ColorCorrection lutCubeTransform:rgbPix bitsPerSample:bitsPerSample debug:(iY>1363)?true:false];
					if(colorCorrectionMethod==1)	rgbPix = [ColorCorrection lutCubeTransform:rgbPix bitsPerSample:bitsPerSample debug:false];
		if(debugColorRedo)NSLog(@"REDOING COLORS... check7");
					
					processedPixel[iX][iY]=rgbPix;
		if(debugColorRedo)NSLog(@"REDOING COLORS... check8");
				}
//		NSLog(@"REDOING COLORS... Line %d DONE",iY);
			}
	
	
		NSLog(@"REDOING COLORS... DONE");
//		outPix = [ColorCorrection correctColors:outPix];
	}

	
	
	/***********************************************************************/
	//					
	//		RESCALING
	//
	/***********************************************************************/
	
	//TO DO: Make Rescaling 32Bit Ready
	
	bool debugRescale = false;
	bool doRescale = false;
	doRescale = settings.doRescale;
	resize = settings.resize;
	float rescaleFactor = 0.35;
	//int rescaleMethod=3; //passed as var to func
	rescaleMethod = settings.rescaleMethod;
	//rescaleMethod=3; //passed as var to func
		//1=variable size / 2=halfsize (odd cols and rows) / 3=halfsize (even cols and rows)
	
	
/*
#ifndef resize	
	define float resize = 0.35;
#endif	
*/

	//float resize = 0.35;
	NSLog(@"~~~~~~~~~~RESIZE=%.2f / rescaleMethod=%d\n",resize,rescaleMethod);

	rgbBytes** scaledPixel;

	//if(resize!=1){
	NSLog(@"~~~~~~~~~~settings.resize=%.2f\n",settings.resize);
	if(settings.resize!=1){
		doRescale = true;
		rescaleFactor = resize;
		NSLog(@"~~~~~~~~~~doRescale=%d / rescaleFactor==%.2f / rescaleMethod=%d\n",doRescale,rescaleFactor, rescaleMethod);
	}
	
	int xRescale = imageWidth;
	int yRescale = imageHeight;
	if(doRescale && (rescaleMethod==2 || rescaleMethod==3))rescaleFactor=0.5;
	if(doRescale && (0<rescaleFactor &&rescaleFactor<1)){
		xRescale = imageWidth*rescaleFactor;
		yRescale = imageHeight*rescaleFactor;
	}
	/*
	if(doRescale && (rescaleMethod==2 || rescaleMethod==3)){
			rescaleFactor=0.5;
			xRescale=(int)imageWidth*rescaleFactor;
			yRescale=(int)imageHeight*rescaleFactor;
	
	}
	NSLog(@"~~~~~~~~~~xRescale=%d / yRescale==%d\n",xRescale,yRescale);

	*/
	//rgbBytes** scaledPixel = [ImageDebayering make2DRgbArray:xRescale y:yRescale]; //Initialization only if Rescaling due to memory problems NSMAllocException
	if(doRescale)		scaledPixel = [ImageDebayering make2DRgbArray:xRescale y:yRescale];
	NSLog(@"~~~~~~~~~~doRescale...  make2DRgbArray DONE\n");
	

	//TO DO: solve GRBG pattern error: first G Pixel false
	//TO DO: solve quotient error, all pixels too dark
	//TO DO: solve Repeating Error for factor 0.5 (round?)
	
	
	if(doRescale){
		NSLog(@"+++++++++++++++Rescaling entered\n");
	
		if(rescaleMethod==2){
			NSLog(@"+++++++++++++++Rescaling method=2 entered\n");
			if(debugRescale)NSLog(@"+++++++++++++++Rescaling Method=2 (halfsize, even rows green pixels) entered\n");
			rescaleFactor=0.5;
			xRescale=(int)imageWidth*rescaleFactor;
			yRescale=(int)imageHeight*rescaleFactor;
//			free(scaledPixel);
//			rgbBytes** scaledPixel = [ImageDebayering make2DRgbArray:xRescale y:yRescale];
			
			int iX,iY=0;
			rgbBytes rgbPix;
			
			for(iY=0;iY<yRescale;iY++){
				for(iX=0;iX<xRescale;iX++){
					if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"iX=%d / iY=%d for loop\n",iX,iY);
					if(2*iX<imageWidth && 2*iY<imageHeight){
						if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"if(2*iX<imageWidth && 2*iY<imageHeight) with  / 2*iX=%d / imageWidth=%d / 2*iY=%d / imageHeight=%d\n",(2*iX),imageWidth,(2*iY),imageHeight);
						if(debayeringMethod!=0)rgbPix=processedPixel[2*iX][2*iY];
						else rgbPix=pixel[2*iX][2*iY];
						//if(debayeringMethod!=0)rgbPix=processedPixel[iX][iY];
						//else rgbPix=pixel[iX][iY];
						if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"rgbPix=(%d,%d,%d)\n",rgbPix.red, rgbPix.green, rgbPix.blue);
						scaledPixel[iX][iY] = rgbPix;
						if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"scaledPixel[%d][%d]=rgbPix done\n",iX,iY);
					}
					else{
						if(debugRescale)NSLog(@"SKIPPED\n");
					}
				}
			}
			if(debugRescale)NSLog(@"Rescaling: for loops done\n");
			cols=xRescale;
			rows=yRescale;			
			if(debugRescale)NSLog(@"Rescaling: cols=%d / rows=%d\n",cols,rows);
		}


		if(rescaleMethod==3){
			NSLog(@"+++++++++++++++Rescaling method=3 entered\n");
			if(debugRescale)NSLog(@"+++++++++++++++Rescaling Method=3 (halfsize, even rows red&blue pixels) entered\n");
			rescaleFactor=0.5;
			xRescale=imageWidth*rescaleFactor;
			yRescale=imageHeight*rescaleFactor;
			int iX,iY=0;
			rgbBytes rgbPix;
//			free(scaledPixel);
//			rgbBytes** scaledPixel = [ImageDebayering make2DRgbArray:xRescale y:yRescale];
			
			for(iY=0;iY<yRescale;iY++){
				for(iX=0;iX<xRescale;iX++){
					if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"iY=%d / iX=%d for loop\n",iX,iY);
					if((2*iX+1)<imageWidth && (2*iY+1)<imageHeight){
						if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"2*iY+1=%d / 2*iX+1=%d for loop\n",(2*iX+1),(2*iY+1));
						if(debayeringMethod!=0)rgbPix=processedPixel[2*iX+1][2*iY+1];
						else rgbPix=pixel[2*iX+1][2*iY+1];
						if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"rgbPix=(%d,%d,%d)\n",rgbPix.red, rgbPix.green, rgbPix.blue);
						scaledPixel[iX][iY] = rgbPix;
						if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"scaledPixel[%d][%d]=rgbPix done\n",iX,iY);
					}
					else{
						if(debugRescale && ((iY%100==0 && iX%100==0)|| (iX>xRescale-10 && iY>yRescale-10)) )NSLog(@"SKIPPED\n");
					
					}
				}
			}
			if(debugRescale)NSLog(@"Rescaling: for loops done\n");
			cols=xRescale;
			rows=yRescale;			
			if(debugRescale)NSLog(@"Rescaling: cols=%d / rows=%d\n",cols,rows);
		}
		
		
		
		if(rescaleMethod==1){
			NSLog(@"+++++++++++++++Rescaling method=1 entered\n");
			if(debugRescale)NSLog(@"+++++++++++++++Rescaling entered\n");
			//SCHEMATISCH
			//check, that algorithm is valid for 1/2, 1/3, 1/4,...
			
			//define & init vars
			float xFactor =1;
			float yFactor =1;
			if(debugRescale)NSLog(@"cols=%d / rows=%d / xRescale=%d / yRescale=%d\n",cols, rows, xRescale, yRescale);

			xFactor = (float)((float)cols/(float)xRescale);
			//xFactor = [ImageDebayering roundedFloat:xFactor postDecimals:2];
			yFactor= (float)((float)rows/(float)yRescale);
			//yFactor = [ImageDebayering roundedFloat:yFactor postDecimals:2];
			
			
			//if resize is already given, no need to recalculate
			if(resize!=1){
				xFactor = (float)1/resize;
				//xFactor = [ImageDebayering roundedFloat:xFactor postDecimals:2];
				yFactor= (float)1/resize;
				//yFactor = [ImageDebayering roundedFloat:yFactor postDecimals:2];
			}
			

			if(debugRescale)NSLog(@"xFactor=%.2f / yFactor=%.2f\n", xFactor, yFactor);
			//float xNextPart = 1; 
			//float yNextPart =1;
			int iX, iY, x, y =0;
			
			int xStep=floor(xFactor);
			int xTop=ceil(xFactor);
			float xRest = xFactor-xStep; //part of the last pixel for this output pixel
			//xRest = [ImageDebayering roundedFloat:xRest postDecimals:2];

			//float xNextPart = 1-xRest; //part of the first pixel for this output pixel (Next Round)
			float xNextPart = 1; //part of the first pixel for this output pixel (Next Round)
			int xOffset=0; // int first Pixel for this output pixel
			int xLast=0;
			int yLast=0;

			int yStep=floor(yFactor);
			int yTop=ceil(yFactor);
			float yRest = yFactor-yStep; //part of the last pixel for this output pixel
			bool xStepFlag=false;
			bool yStepFlag = false;
			if(xRest==0.00){
				xStepFlag = true;
				if(debugRescale)NSLog(@"if(xRest==0.00): xRest=%.2f\n", xRest);
			}
			if(yRest==0.00){
				yStepFlag = true;
				if(debugRescale)NSLog(@"if(yRest==0.00): yRest=%.2f\n", yRest);
			}
			//Wert checken und if checken
			
			//yRest = [ImageDebayering roundedFloat:yRest postDecimals:2];
	//		float yRest = yStep-yFactor; //part of the last pixel for this output pixel
	//		float yNextPart = 1.0-yRest; //part of the first pixel for this output pixel
			float yNextPart = 1; //part of the first pixel for this output pixel
			int yOffset=0; // int first Pixel for this output pixel			

			//unsigned int outValue[3];
			float outValue[3];
			rgbBytes rgbPix;
//			rgbBytes outPix;
			
			
			// There's still an error perhaps in the offset, so a Pixel (input) might get skipped totally or part goes to the pixel before, rest skipped and starts with new in the 
			//if xNextPart<1 or yNextPart<1: Rest of THIS Pixel needs to be processed, do not increment!!!
			
			if(debugRescale)NSLog(@"DEBUG Rescaling: variables initialized\n");
			if(debugRescale)NSLog(@"DEBUG Rescaling: cols=%d / rows=%d /xRescale=%d / yRescale=%d / xFactor=%.2f / yFactor=%.2f / xStep=%d / yStep=%d / xTop=%d / yTop=%d / xRest=%.2f / yRest=%.2f / xNextPart=%.2f / yNextPart=%.2f\n",cols,rows,xRescale,yRescale,xFactor,yFactor,xStep,yStep,xTop,yTop,xRest,yRest,xNextPart, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: xStepFlag=%d / yStepFlag=%d\n",xStepFlag, yStepFlag);

			for(iY=0;iY<yRescale;iY++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering outer for loop with iY=%d / yRescale=%d\n", iY, yRescale);
				for(iX=0;iX<xRescale;iX++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering outer for loop with iX=%d / xRescale=%d\n", iX, xRescale);

			//Initialize
			outValue[0]=outValue[1]=outValue[2]=0;
					
					for(y=yOffset;(y<yOffset+yTop)&&(y<rows);y++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering for loop with y=%d / yOffset=%d / yTop=%d / rows=%d\n", y, yOffset, yTop, rows);
						for(x=xOffset;(x<xOffset+xTop)&&(x<cols);x++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering for loop with x=%d / xOffset=%d / xTop=%d / cols=%d\n", x, xOffset, xTop, cols);

			if(debugRescale && (iX%10==0 && iY%10==0))NSLog(@"DEBUG Rescaling: iX=%d / iY=%d\n",iX, iY);
						
							//rgbPix=pixel[x][y];
							if(debayeringMethod!=0)rgbPix=processedPixel[x][y];
							else rgbPix=pixel[x][y];
							
			if(debugRescale)NSLog(@"DEBUG Rescaling: Building outputPixel[%d][%d] - pixel[%d][%d] xOffset=%d / yOffset=%d / xTop=%d / yTop=%d - rgbPix.red=%lu / rgbPix.green=%lu / rgbPix.blue=%lu /\n",iX,iY,x, y, xOffset,yOffset,xTop,yTop, rgbPix.red,rgbPix.green,rgbPix.blue);
			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR BITUEBERLAUF: outputPixel[%d][%d] - pixel[%d][%d]  rgbPix.red=%lu / rgbPix.green=%lu / rgbPix.blue=%lu /\n",iX,iY,x, y,rgbPix.red,rgbPix.green,rgbPix.blue);
			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR BITUEBERLAUF: outputPixel[%d][%d] - pixel[%d][%d]  rgbValue[0]=%lu / rgbValue[1]=%lu / rgbValue[2]=%lu /\n",iX,iY,x, y,rgbValue[0],rgbValue[1],rgbValue[2]);
			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR BITUEBERLAUF: outputPixel[%d][%d] - pixel[%d][%d]  outValue[0]=%lu / outValue[1]=%lu / outValue[2]=%lu /\n",iX,iY,x, y,outValue[0],outValue[1],outValue[2]);
							int c=0;
							rgbValue[0]=rgbPix.red;
							rgbValue[1]=rgbPix.green;
							rgbValue[2]=rgbPix.blue;								

							rgbValue32Bit[0]=rgbPix.red;
							rgbValue32Bit[1]=rgbPix.green;
							rgbValue32Bit[2]=rgbPix.blue;								
							
			if(debugRescale)NSLog(@"DEBUG Rescaling: outValue initialize (new iteration): outputPixel[%d][%d] - pixel[%d][%d]  outValue[0]=%lu / outValue[1]=%lu / outValue[2]=%lu /\n",iX,iY,x, y,outValue[0],outValue[1],outValue[2]);
						
			if(debugRescale)NSLog(@"DEBUG Rescaling: check1\n");
						
							//rgbPix=pixel[x][y];
						
							if(y==yOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check2 y=%d / yOffset=%d\n",y, yOffset);
								if(x==xOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check3 x=%d / xOffset=%d\n",x,xOffset);
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(xNextPart*yNextPart*rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(xNextPart*yNextPart*rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check4 c=%d, xNextPart=%.2f / yNextPart=%.2f \n", c,xNextPart, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check4.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									
									//scaledPixel[iX][iY]+=xNextPart*yNextPart*pixel[x][y];
									//write to array in the last step after iterATING OVER X AND Y
								}
								else if(x==(xOffset+xTop-1)){//letzter teil, könnte man auch hinter diese for schleife legen
			if(debugRescale)NSLog(@"DEBUG Rescaling: check5\n");
									if(xRest==0.0)
										//if(internalBitRes==8)
										for(c=0;c<3;c++){outValue[c]+=(yNextPart*rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(yNextPart*rgbValue32Bit[c]);}
									else
										//if(internalBitRes==8)
										for(c=0;c<3;c++){outValue[c]+=(xRest*yNextPart*rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(xRest*yNextPart*rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check6 c=%d / xRest=%.2f / yNextPart=%.2f\n",c, xRest, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check6.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);

									//scaledPixel[iX][iY]+=xRest*yNextPart*pixel[x][y];
								}
								else {
			if(debugRescale)NSLog(@"DEBUG Rescaling: check7\n");
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(yNextPart*rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(yNextPart*rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check8 c=%d / yNextPart=%.2f\n", c, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check8.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
								
									//scaledPixel[iX][iY]+=yNextPart*pixel[x][y];
								}
							}
							else if(y==(yOffset+yTop-1)){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check9 y=%d / yOffset=%d / yTop=%d\n",y,yOffset, yTop);
								if(x==xOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check10 x=%d / xOffset=%d\n",x, xOffset);
									if(yRest!=0.0)
										//if(internalBitRes==8)
										for(c=0;c<3;c++){outValue[c]+=(xNextPart*yRest*rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(xNextPart*yRest*rgbValue32Bit[c]);}
									else
										//if(internalBitRes)
										for(c=0;c<3;c++){outValue[c]+=(xNextPart*rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(xNextPart*rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check11 / c=%d, xNextPart=%.2f, yRest=%.2f\n", c, xNextPart, yRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check11.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xNextPart*yRest*pixel[x][y];
								}
								else if(x==(xOffset+xTop-1)){//letzter teil, könnte man auch hinter diese for schleife legen
			if(debugRescale)NSLog(@"DEBUG Rescaling: check12 / x=%d, xOffset=%d, xTop=%d\n",x, xOffset, xTop);
								if(xRest!=0.0 && yRest!=0.0)
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(xRest*yRest*rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(xRest*yRest*rgbValue32Bit[c]);}
								else if(xRest==0.0 && yRest==0.0)
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(rgbValue32Bit[c]);}
								else if(xRest==0.0 && yRest!=0.0)
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(yRest*rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(yRest*rgbValue32Bit[c]);}
								else if(xRest!=0.0 && yRest==0.0)
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(xRest*rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(xRest*rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check1, xRest=%.2f ,yRest=%.2f\n",xRest,yRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check12.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xRest*yRest*pixel[x][y];
								}
								else {
			if(debugRescale)NSLog(@"DEBUG Rescaling: check13\n");
									if(yRest!=0.0)
										//if(internalBitRes==8)
										for(c=0;c<3;c++){outValue[c]+=(yRest*rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(yRest*rgbValue32Bit[c]);}
									else
										//if(internalBitRes==8)
										for(c=0;c<3;c++){outValue[c]+=(rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check14 / yRest=%.2f\n",yRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check14.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=yRest*pixel[x][y];
									
								}
							}
							else{
			if(debugRescale)NSLog(@"DEBUG Rescaling: check15\n");
								if(x==xOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check16 x=%d, xOffset=%d\n");
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(xNextPart*rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(xNextPart*rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check17 xNextPart=%.2f\n",xNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check17.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xNextPart*pixel[x][y];
								}
								else if(x==(xOffset+xTop-1)){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check18 x=%d, xOffset=%d, xTop=%d\n",x, xOffset, xTop);
								//letzter teil, könnte man auch hinter diese for schleife legen
									if(xRest==0.0)
										//if(internalBitRes==8)
										for(c=0;c<3;c++){outValue[c]+=(rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(rgbValue32Bit[c]);}
									else
										//if(internalBitRes==8)
										for(c=0;c<3;c++){outValue[c]+=(xRest*rgbValue[c]);}
										//else for(c=0;c<3;c++){outValue[c]+=(xRest*rgbValue32Bit[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check19 xRest=%.2f\n",xRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check19.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xRest*pixel[x][y];
								}
								else {
			if(debugRescale)NSLog(@"DEBUG Rescaling: check20\n");
									//if(internalBitRes==8)
									for(c=0;c<3;c++){outValue[c]+=(rgbValue[c]);}
									//else for(c=0;c<3;c++){outValue[c]+=(rgbValue32Bit[c]);}
									//scaledPixel[iX][iY]+=pixel[x][y];
			if(debugRescale)NSLog(@"DEBUG Rescaling: check21 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									
								}
							}
							xLast=x;
							
						} //END for loop x input
						
						yLast=y;
					} //END for loop y input
			if(debugRescale)NSLog(@"DEBUG Rescaling: input values for X settings for next iteration: xOffset=%d / xTop=%d / xRest=%.8f / xFactor=%.8f\n", xOffset, xTop, xRest, xFactor);
							//Set X values for the next iteration
							//xOffset = xOffset + xTop;
							xOffset = xOffset + xStep;
							//xOffset=xLast+1;
							xNextPart = 1-xRest; //part of the first pixel for THIS output pixel (Next Round)
							//xNextPart = [ImageDebayering roundedFloat:xNextPart postDecimals:2];
							/*
							xRest = xFactor-xNextPart-xStep; //something wrong here
							if(xRest<0) {
								xRest=xRest+xStep;
								//correction for xOffset here
								xOffset++;
							}
							*/
							//xRest = fabsf(xFactor-xNextPart-xStep);




							xNextPart = 1-xRest; //part of the first pixel for THIS output pixel (Next Round)
							float xRestOld=xRest;
							xRest = fmodf((xFactor-xNextPart),1.00);
							if(xFactor-xNextPart == 1.0)xRest=1;
							xTop=floor(xFactor-xNextPart);
							if(xRest>0 && xRest<1)xTop++;
							if(fmodf(xNextPart,1.00)>0.00)xTop++;
							if(xNextPart==1.00)xTop++;
							xOffset=xLast;
							//if(xRest==0)xOffset++;
							if(xRestOld==0.0 || xRestOld==1.0)xOffset++;
							
	if(debugRescale)NSLog(@"DEBUG Rescaling: (new) xRest=%.4f / (new)xTop=%d / (new) xNextPart=%.4f / xRestOld=%.4f\n", xRest, xTop, xNextPart,xRestOld);

							if(fmodf(xNextPart, 1.00)==0.00){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xNextPart==1 / xRest=%.8f is recalculated to xRest=%.8f\n", xRest, (xFactor-xStep));
								xNextPart = 1;
								//if(!xStepFlag)xOffset++; //causes repeating problem for factor 0.5?
							}							
							if(xOffset>=cols)xOffset=0;							
							if(iX+1==xRescale)xOffset=0;


							
							/*
	//-(float)roundedFloat:(float)orig postDecimals:(int)postDec{

							//if(xNextPart==1.00){
							//if(xNextPart==1.00 || xNextPart==0.00){ //modulo 1 ? %1
							if(fmodf(xNextPart, 1.00)==0.00){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xNextPart==1 / xRest=%.8f is recalculated to xRest=%.8f\n", xRest, (xFactor-xStep));
								xNextPart = 1;
								if(!xStepFlag)xOffset++; //causes repeating problem for factor 0.5?
								//xOffset=xLast;
								xRest = xFactor-xStep;
							}

							
							
							if(xOffset>=cols){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xOffset>=cols\n");
								xOffset = 0;
								xRest = xFactor-xStep;
							}
							if(iX+1==xRescale){
	if(debugRescale)NSLog(@"DEBUG Rescaling: iX+1==xRescale\n");
								xOffset = 0;
								xRest = xFactor-xStep;
							}
							//xRest = [ImageDebayering roundedFloat:xRest postDecimals:2];
							*/

			if(debugRescale)NSLog(@"DEBUG Rescaling: X settings for next iteration: xOffset=%d / xNextPart=%.8f / xRest=%.8f\n", xOffset, xNextPart,xRest);
			if(debugRescale && ((xRest<0)||(xRest>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR xRest=%.8f\n", xRest);
			if(debugRescale && ((yRest<0)||(yRest>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR yRest=%.8f\n", yRest);
			if(debugRescale && ((xNextPart<0)||(xNextPart>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR xNextPart=%.8f\n", xNextPart);
			if(debugRescale && ((yNextPart<0)||(yNextPart>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR yNextPart=%.8f\n", yNextPart);
			

			if(debugRescale)NSLog(@"DEBUG Rescaling: inner for loops done - start settings for next iteration\n");

					// Start settings for the next iteration
					/*
					xOffset = xOffset + xTop;
					xNextPart = 1-xRest; //part of the first pixel for this output pixel (Next Round)
					xRest = xFactor-xNextPart-xStep;
					yOffset = yOffset + yTop;
					yNextPart = 1-yRest; //part of the first pixel for this output pixel
					yRest = yFactor-yNextPart-yStep;
					*/

			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR ERRORS: outValue[]=(%d,%d,%d) to scaledPixel[%d][%d] / xFactor*yFactor=%.2f\n",outValue[0],outValue[1],outValue[2],iX,iY, (xFactor*yFactor));
					
					rgbBytes outputPixel;

					outputPixel.red = outValue[0];
					outputPixel.green = outValue[1];
					outputPixel.blue = outValue[2];


					/*
					//still too dark - doppelt gemoppelt?
					outputPixel.red = outValue[0]*rescaleFactor;
					outputPixel.green = outValue[1]*rescaleFactor;
					outputPixel.blue = outValue[2]*rescaleFactor;
					*/
					
					//too dark! Gets darker the more rescaled -> square false?
					outputPixel.red = outValue[0]/(xFactor*yFactor);
					outputPixel.green = outValue[1]/(xFactor*yFactor);
					outputPixel.blue = outValue[2]/(xFactor*yFactor);
					
					//TEST FOR ERRORS
					//outputPixel.blue = 255;
					
	if(debugRescale)NSLog(@"DEBUG Rescaling: inner for loops done - settings for next iteration DONE\n");
			
					
			
			
					scaledPixel[iX][iY] = outputPixel;
			if(debugRescale)NSLog(@"DEBUG Rescaling: added outputPixel (%d,%d,%d) to scaledPixel[%d][%d]\n",outputPixel.red,outputPixel.green,outputPixel.blue,iX,iY);

				}//END outer iX loop
						//Set Y values for the next iteration
			if(debugRescale)NSLog(@"DEBUG Rescaling: input values for Y settings for next iteration: yOffset=%d / yTop=%d / yRest=%.2f / yFactor=%.2f\n", yOffset, yTop, yRest, yFactor);
						//yOffset = yOffset + yTop;
						yOffset = yOffset + yStep;
						//yOffset=yLast+1;
						yNextPart = 1-yRest; //part of the first pixel for this output pixel
						//yNextPart = [ImageDebayering roundedFloat:yNextPart postDecimals:2];
						/*
						yRest = yFactor-yNextPart-yStep;
						if(yRest<0) {
							yRest=yRest+yStep;
							//correction for yOffset here
							yOffset++;
						}					
						*/
						//yRest = fabsf(yFactor-yNextPart-yStep); //COLOR VALUES CORRECT, wrong image part

						
						
							yNextPart = 1-yRest; //part of the first pixel for this output pixel
							float yRestOld=yRest;
							yRest = fmodf((yFactor-yNextPart),1.00);
							if(yFactor-yNextPart == 1.0)yRest=1;
							yTop=floor(yFactor-yNextPart);
							if(yRest>0 && yRest<1)yTop++;
							if(fmodf(yNextPart,1.00)>0.00)yTop++;
							if(yNextPart==1.00)yTop++;
							yOffset=yLast;
							//if(yRest==0)yOffset++;
							if(yRestOld==0.0 || yRestOld==1.0)yOffset++;


							
							if(fmodf(yNextPart, 1.00)==0.00){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xNextPart==1 / xRest=%.8f is recalculated to xRest=%.8f\n", xRest, (xFactor-xStep));
								yNextPart = 1;
								//if(!xStepFlag)xOffset++; //causes repeating problem for factor 0.5?
							}							
							if(yOffset>=rows)yOffset=0;							
							if(iY+1==yRescale)yOffset=0;						
						
						
						
						/*
						//if(yNextPart==1.00){
						//if(yNextPart==1.00 || yNextPart==0.00){ //modulo 1 ? %1
						if(fmodf(yNextPart, 1.00)==0.00){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xNextPart==1 / xRest=%.2f is recalculated to xRest=%.2f\n", xRest, (xFactor-xStep));
							yNextPart = 1;
							if(!yStepFlag)yOffset++; //causes repeating problem for factor 0.5
							//yOffset=yLast;
							yRest = yFactor-yStep;
						}
						if(yOffset>=rows){
							yOffset = 0;
							yRest = yFactor-yStep;
						}
						if(iY+1==yRescale){
							yOffset = 0;
							yRest = yFactor-yStep;
						}
						//yRest = [ImageDebayering roundedFloat:yRest postDecimals:2];
						//Reset outValues here
						outValue[0]=outValue[1]=outValue[2]=0;
						*/
			if(debugRescale)NSLog(@"DEBUG Rescaling: Y settings for next iteration: yOffset=%d / yNextPart=%.2f / yRest=%.2f\n", yOffset, yNextPart,yRest);
				
			}//END outer iY loop
			if(debugRescale)NSLog(@"DEBUG Rescaling: outer loops done\n");

			cols=xRescale;
			rows=yRescale;

			if(debugRescale)NSLog(@"DEBUG Rescaling: new dimensionsions: cols=%d / rows=%d\n",cols,rows);
			
			/*
			//USE DEFAULT OUTPUT BYTE 2 BUFFER LOOP WITH NEW COLS AND ROWS
			//downscale image and write out pixels
			for(j=0;j<rows;j++){
				if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.1\n");
				for(i=0;i<cols;i++){
					//Image Processing here
					// transform cols -> xRescaled
					// transform rows -> yRescaled
					//interpolate pixels
					//easy if output size is 1/2, 1/3, 1/4,... of original size
					
					
					//Write pixels to buffer
				}
			}	
			//how to return buffer size or pass rescale values from main func?
			*/
		}




		
/********************************************************************/

		if(rescaleMethod==4){
			NSLog(@"+++++++++++++++Rescaling method=42 entered\n");
			if(debugRescale)NSLog(@"+++++++++++++++Rescaling entered\n");
			//SCHEMATISCH
			//check, that algorithm is valid for 1/2, 1/3, 1/4,...
			
			//define & init vars
			float xFactor =1;
			float yFactor =1;
			if(debugRescale)NSLog(@"cols=%d / rows=%d / xRescale=%d / yRescale=%d\n",cols, rows, xRescale, yRescale);

			xFactor = (float)((float)cols/(float)xRescale);
			//xFactor = [ImageDebayering roundedFloat:xFactor postDecimals:2];
			yFactor= (float)((float)rows/(float)yRescale);
			//yFactor = [ImageDebayering roundedFloat:yFactor postDecimals:2];
			
			
			//if resize is already given, no need to recalculate
			if(resize!=1){
				xFactor = (float)1/resize;
				//xFactor = [ImageDebayering roundedFloat:xFactor postDecimals:2];
				yFactor= (float)1/resize;
				//yFactor = [ImageDebayering roundedFloat:yFactor postDecimals:2];
			}
			

			if(debugRescale)NSLog(@"xFactor=%.2f / yFactor=%.2f\n", xFactor, yFactor);
			//float xNextPart = 1; 
			//float yNextPart =1;
			int iX, iY, x, y =0;
			
			int xStep=floor(xFactor);
			//int xStep=ceil(xFactor);
			int xTop=ceil(xFactor);
			float xRest = xFactor-xStep; //part of the last pixel for this output pixel
			xStep=xTop; //initial
			//xRest = [ImageDebayering roundedFloat:xRest postDecimals:2];

			//float xNextPart = 1-xRest; //part of the first pixel for this output pixel (Next Round)
			float xNextPart = 1; //part of the first pixel for this output pixel (Next Round)
			int xOffset=0; // int first Pixel for this output pixel
			int xLast=0;
			int yLast=0;

			int yStep=floor(yFactor);
			//int yStep=ceil(yFactor);
			int yTop=ceil(yFactor);
			float yRest = yFactor-yStep; //part of the last pixel for this output pixel
			yStep=yTop;
			bool xStepFlag=false;
			bool yStepFlag = false;
			if(xRest==0.00){
				xStepFlag = true;
				if(debugRescale)NSLog(@"if(xRest==0.00): xRest=%.2f\n", xRest);
			}
			if(yRest==0.00){
				yStepFlag = true;
				if(debugRescale)NSLog(@"if(yRest==0.00): yRest=%.2f\n", yRest);
			}
			//Wert checken und if checken
			
			//yRest = [ImageDebayering roundedFloat:yRest postDecimals:2];
	//		float yRest = yStep-yFactor; //part of the last pixel for this output pixel
	//		float yNextPart = 1.0-yRest; //part of the first pixel for this output pixel
			float yNextPart = 1; //part of the first pixel for this output pixel
			int yOffset=0; // int first Pixel for this output pixel			

			//unsigned int outValue[3];
			float outValue[3];
			rgbBytes rgbPix;
//			rgbBytes outPix;
			
			
			// There's still an error perhaps in the offset, so a Pixel (input) might get skipped totally or part goes to the pixel before, rest skipped and starts with new in the 
			//if xNextPart<1 or yNextPart<1: Rest of THIS Pixel needs to be processed, do not increment!!!
			
			if(debugRescale)NSLog(@"DEBUG Rescaling: variables initialized\n");
			if(debugRescale)NSLog(@"DEBUG Rescaling: cols=%d / rows=%d /xRescale=%d / yRescale=%d / xFactor=%.2f / yFactor=%.2f / xStep=%d / yStep=%d / xTop=%d / yTop=%d / xRest=%.2f / yRest=%.2f / xNextPart=%.2f / yNextPart=%.2f\n",cols,rows,xRescale,yRescale,xFactor,yFactor,xStep,yStep,xTop,yTop,xRest,yRest,xNextPart, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: xStepFlag=%d / yStepFlag=%d\n",xStepFlag, yStepFlag);

			for(iY=0;iY<yRescale;iY++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering outer for loop with iY=%d / yRescale=%d\n", iY, yRescale);
				for(iX=0;iX<xRescale;iX++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering outer for loop with iX=%d / xRescale=%d\n", iX, xRescale);

				outValue[0]=outValue[1]=outValue[2]=0;
					
					//for(y=yOffset;(y<yOffset+yTop)&&(y<rows);y++){
					for(y=yOffset;(y<yOffset+yStep)&&(y<rows);y++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering for loop with y=%d / yOffset=%d / yTop=%d / rows=%d\n", y, yOffset, yTop, rows);
						//for(x=xOffset;(x<xOffset+xTop)&&(x<cols);x++){
						for(x=xOffset;(x<xOffset+xStep)&&(x<cols);x++){
			if(debugRescale)NSLog(@"DEBUG Rescaling: Entering for loop with x=%d / xOffset=%d / xTop=%d / cols=%d\n", x, xOffset, xTop, cols);

			if(debugRescale && (iX%10==0 && iY%10==0))NSLog(@"DEBUG Rescaling: iX=%d / iY=%d\n",iX, iY);
						
							//rgbPix=pixel[x][y];
							if(debayeringMethod!=0)rgbPix=processedPixel[x][y];
							else rgbPix=pixel[x][y];
							
			if(debugRescale)NSLog(@"DEBUG Rescaling: Building outputPixel[%d][%d] - pixel[%d][%d] xOffset=%d / yOffset=%d / xTop=%d / yTop=%d - rgbPix.red=%lu / rgbPix.green=%lu / rgbPix.blue=%lu /\n",iX,iY,x, y, xOffset,yOffset,xTop,yTop, rgbPix.red,rgbPix.green,rgbPix.blue);
			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR BITUEBERLAUF: outputPixel[%d][%d] - pixel[%d][%d]  rgbPix.red=%lu / rgbPix.green=%lu / rgbPix.blue=%lu /\n",iX,iY,x, y,rgbPix.red,rgbPix.green,rgbPix.blue);
			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR BITUEBERLAUF: outputPixel[%d][%d] - pixel[%d][%d]  rgbValue[0]=%lu / rgbValue[1]=%lu / rgbValue[2]=%lu /\n",iX,iY,x, y,rgbValue[0],rgbValue[1],rgbValue[2]);
			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR BITUEBERLAUF: outputPixel[%d][%d] - pixel[%d][%d]  outValue[0]=%lu / outValue[1]=%lu / outValue[2]=%lu /\n",iX,iY,x, y,outValue[0],outValue[1],outValue[2]);
							int c=0;
							/*
							outValue[0]=rgbValue[0]=rgbPix.red;
							outValue[1]=rgbValue[1]=rgbPix.green;
							outValue[2]=rgbValue[2]=rgbPix.blue;					
							*/
							rgbValue[0]=rgbPix.red;
							rgbValue[1]=rgbPix.green;
							rgbValue[2]=rgbPix.blue;								
							if(debugRescale)NSLog(@"DEBUG Rescaling: outValue initialize (new iteration): outputPixel[%d][%d] - pixel[%d][%d]  outValue[0]=%lu / outValue[1]=%lu / outValue[2]=%lu /\n",iX,iY,x, y,outValue[0],outValue[1],outValue[2]);
						
			if(debugRescale)NSLog(@"DEBUG Rescaling: check1\n");
						
							//rgbPix=pixel[x][y];
						
							if(y==yOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check2 y=%d / yOffset=%d\n",y, yOffset);
								if(x==xOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check3 x=%d / xOffset=%d\n",x,xOffset);

									for(c=0;c<3;c++){outValue[c]+=(xNextPart*yNextPart*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check4 c=%d, xNextPart=%.2f / yNextPart=%.2f \n", c,xNextPart, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check4.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									
									//scaledPixel[iX][iY]+=xNextPart*yNextPart*pixel[x][y];
									//write to array in the last step after iterATING OVER X AND Y
								}
								else if(x==(xOffset+xTop-1)){//letzter teil, könnte man auch hinter diese for schleife legen
			if(debugRescale)NSLog(@"DEBUG Rescaling: check5\n");

									for(c=0;c<3;c++){outValue[c]+=(xRest*yNextPart*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check6 c=%d / xRest=%.2f / yNextPart=%.2f\n",c, xRest, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check6.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);

									//scaledPixel[iX][iY]+=xRest*yNextPart*pixel[x][y];
								}
								else {
			if(debugRescale)NSLog(@"DEBUG Rescaling: check7\n");
									for(c=0;c<3;c++){outValue[c]+=(yNextPart*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check8 c=%d / yNextPart=%.2f\n", c, yNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check8.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
								
									//scaledPixel[iX][iY]+=yNextPart*pixel[x][y];
								}
							}
							else if(y==(yOffset+yTop-1)){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check9 y=%d / yOffset=%d / yTop=%d\n",y,yOffset, yTop);
								if(x==xOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check10 x=%d / xOffset=%d\n",x, xOffset);
									for(c=0;c<3;c++){outValue[c]+=(xNextPart*yRest*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check11 / c=%d, xNextPart=%.2f, yRest=%.2f\n", c, xNextPart, yRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check11.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xNextPart*yRest*pixel[x][y];
								}
								else if(x==(xOffset+xTop-1)){//letzter teil, könnte man auch hinter diese for schleife legen
			if(debugRescale)NSLog(@"DEBUG Rescaling: check12 / x=%d, xOffset=%d, xTop=%d\n",x, xOffset, xTop);
									for(c=0;c<3;c++){outValue[c]+=(xRest*yRest*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check1, xRest=%.2f ,yRest=%.2f\n",xRest,yRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check12.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xRest*yRest*pixel[x][y];
								}
								else {
			if(debugRescale)NSLog(@"DEBUG Rescaling: check13\n");
									for(c=0;c<3;c++){outValue[c]+=(yRest*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check14 / yRest=%.2f\n",yRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check14.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=yRest*pixel[x][y];
									
								}
							}
							else{
			if(debugRescale)NSLog(@"DEBUG Rescaling: check15\n");
								if(x==xOffset){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check16 x=%d, xOffset=%d\n");
									for(c=0;c<3;c++){outValue[c]+=(xNextPart*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check17 xNextPart=%.2f\n",xNextPart);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check17.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xNextPart*pixel[x][y];
								}
								else if(x==(xOffset+xTop-1)){
			if(debugRescale)NSLog(@"DEBUG Rescaling: check18 x=%d, xOffset=%d, xTop=%d\n",x, xOffset, xTop);
								//letzter teil, könnte man auch hinter diese for schleife legen
									for(c=0;c<3;c++){outValue[c]+=(xRest*rgbValue[c]);}
			if(debugRescale)NSLog(@"DEBUG Rescaling: check19 xRest=%.2f\n",xRest);
			if(debugRescale)NSLog(@"DEBUG Rescaling: check19.1 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									//scaledPixel[iX][iY]+=xRest*pixel[x][y];
								}
								else {
			if(debugRescale)NSLog(@"DEBUG Rescaling: check20\n");
									for(c=0;c<3;c++){outValue[c]+=(rgbValue[c]);}
									//scaledPixel[iX][iY]+=pixel[x][y];
			if(debugRescale)NSLog(@"DEBUG Rescaling: check21 - outValue[]=(%d,%d,%d)\n",outValue[0],outValue[1],outValue[2]);
									
								}
							}
							if(x>xLast)xLast=x;
							
						} //END for loop x input
						
						if(y>yLast)yLast=y;
					} //END for loop y input
			if(debugRescale)NSLog(@"DEBUG Rescaling: input values for X settings for next iteration: xOffset=%d / xTop=%d / xRest=%.8f / xFactor=%.8f\n", xOffset, xTop, xRest, xFactor);
							//Set X values for the next iteration
							
							xNextPart = 1 -xRest;
							xRest = xFactor - xNextPart;
							xStep=ceil(xRest);
							int xDif=floor(xRest);
							xRest=xRest-xDif;
							
							if(0<xRest && xRest<1) xOffset=xLast;
							else if (fmodf(xRest, 1.00)==0.00) xOffset=xOffset+floor(xFactor);
		
							if(yOffset>=rows || iY+1==yRescale){
								yOffset=0;
								yRest = yFactor-floor(yFactor);
							}
					
							//if(0<xRest && xRest<1) xOffset=xLast%cols;
							//else if (fmodf(xRest, 1.00)==0.00) xOffset=(int)(xOffset+floor(xFactor))%cols;
							
							
							
							
							/*
							xOffset = xOffset + xStep;
							xNextPart = 1-xRest; //part of the first pixel for THIS output pixel (Next Round)

							xRest = fabsf(xFactor-xNextPart-xStep);

							if(fmodf(xNextPart, 1.00)==0.00){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xNextPart==1 / xRest=%.8f is recalculated to xRest=%.8f\n", xRest, (xFactor-xStep));
								xNextPart = 1;
								if(!xStepFlag)xOffset++; //causes repeating problem for factor 0.5?
								//xOffset=xLast;
								xRest = xFactor-xStep;
							}

							
							
							if(xOffset>=cols){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xOffset>=cols\n");
								xOffset = 0;
								xRest = xFactor-xStep;
							}
							if(iX+1==xRescale){
	if(debugRescale)NSLog(@"DEBUG Rescaling: iX+1==xRescale\n");
								xOffset = 0;
								xRest = xFactor-xStep;
							}
							*/

			if(debugRescale)NSLog(@"DEBUG Rescaling: X settings for next iteration: xOffset=%d / xNextPart=%.8f / xRest=%.8f\n", xOffset, xNextPart,xRest);
			if(debugRescale && ((xRest<0)||(xRest>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR xRest=%.8f\n", xRest);
			if(debugRescale && ((yRest<0)||(yRest>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR yRest=%.8f\n", yRest);
			if(debugRescale && ((xNextPart<0)||(xNextPart>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR xNextPart=%.8f\n", xNextPart);
			if(debugRescale && ((yNextPart<0)||(yNextPart>1)))NSLog(@"DEBUG Rescaling: ########## WARNING! ##########: OUT OF RANGE ERROR yNextPart=%.8f\n", yNextPart);
			

			if(debugRescale)NSLog(@"DEBUG Rescaling: inner for loops done - start settings for next iteration\n");

					// Start settings for the next iteration


			if(debugRescale)NSLog(@"DEBUG Rescaling: COLOR ERRORS: outValue[]=(%d,%d,%d) to scaledPixel[%d][%d] / xFactor*yFactor=%.2f\n",outValue[0],outValue[1],outValue[2],iX,iY, (xFactor*yFactor));
					
					rgbBytes outputPixel;

					outputPixel.red = outValue[0];
					outputPixel.green = outValue[1];
					outputPixel.blue = outValue[2];



					//TEST FOR ERRORS
					//outputPixel.blue = 255;
					
	if(debugRescale)NSLog(@"DEBUG Rescaling: inner for loops done - settings for next iteration DONE\n");
			
					
			
			
					scaledPixel[iX][iY] = outputPixel;
			if(debugRescale)NSLog(@"DEBUG Rescaling: added outputPixel (%d,%d,%d) to scaledPixel[%d][%d]\n",outputPixel.red,outputPixel.green,outputPixel.blue,iX,iY);

				}//END outer iX loop
				//Set Y values for the next iteration
			if(debugRescale)NSLog(@"DEBUG Rescaling: input values for Y settings for next iteration: yOffset=%d / yTop=%d / yRest=%.2f / yFactor=%.2f\n", yOffset, yTop, yRest, yFactor);

				yNextPart = 1 -yRest;
				yRest = yFactor - yNextPart;
				yStep=ceil(yRest);
				int yDif=floor(yRest);
				yRest=yRest-yDif;
							
				if(0<yRest && yRest<1) yOffset=yLast;
				else if (fmodf(yRest, 1.00)==0.00) yOffset=yOffset+floor(yFactor);
				if(yOffset>=rows || iY+1==yRescale){
					yOffset=0;
					yRest = yFactor-floor(yFactor);
				}

							
				//if(0<yRest && yRest<1) yOffset=yLast%rows;
				//else if (fmodf(yRest, 1.00)==0.00) yOffset=(int)(yOffset+(int)floor(yFactor))%rows;

				
						/*
						yOffset = yOffset + yStep;
						yNextPart = 1-yRest; //part of the first pixel for this output pixel

						yRest = fabsf(yFactor-yNextPart-yStep); //COLOR VALUES CORRECT, wrong image part

						if(fmodf(yNextPart, 1.00)==0.00){
	if(debugRescale)NSLog(@"DEBUG Rescaling: xNextPart==1 / xRest=%.2f is recalculated to xRest=%.2f\n", xRest, (xFactor-xStep));
							yNextPart = 1;
							if(!yStepFlag)yOffset++; //causes repeating problem for factor 0.5
							yRest = yFactor-yStep;
						}
						if(yOffset>=rows){
							yOffset = 0;
							yRest = yFactor-yStep;
						}
						if(iY+1==yRescale){
							yOffset = 0;
							yRest = yFactor-yStep;
						}
						*/
						
						outValue[0]=outValue[1]=outValue[2]=0;
			if(debugRescale)NSLog(@"DEBUG Rescaling: Y settings for next iteration: yOffset=%d / yNextPart=%.2f / yRest=%.2f\n", yOffset, yNextPart,yRest);
				
			}//END outer iY loop
			if(debugRescale)NSLog(@"DEBUG Rescaling: outer loops done\n");

			cols=xRescale;
			rows=yRescale;

			if(debugRescale)NSLog(@"DEBUG Rescaling: new dimensionsions: cols=%d / rows=%d\n",cols,rows);
			

		} //END if(rescaleMethod==4)


		
		
		


			if(debugRescale)NSLog(@"Rescaling completed!\n");

		
	}// END if (doRescale)

	/****************************************/
	//Rescale finished

	if(debug3)NSLog(@"START writing output buffer\n");
	
	for(j=0;j<rows;j++){
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.1\n");
		for(i=0;i<cols;i++){
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.2\n");
			rgbBytes rgbPix;
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.3\n");
	if(debug3)NSLog(@"i=%d, cols=%d, j=%d, rows=%d, debayeringMethod=%d, doRescale=%d\n",i,cols,j,rows,debayeringMethod,doRescale);
	
			rgbPix=pixel[i][j];
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.3.1\n");
			if(debayeringMethod!=0)rgbPix=processedPixel[i][j];
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.3.2\n");
			if(doRescale)rgbPix=scaledPixel[i][j];
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.3.3\n");
			//else rgbPix=pixel[i][j];
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.4\n");

			/*
			rgbValue[0]=rgbPix.red;
			rgbValue[1]=rgbPix.green;
			rgbValue[2]=rgbPix.blue;
			*/
						
			if(bitsPerSample==8){
				outputValue[0]=rgbPix.red;
				outputValue[1]=rgbPix.green;
				outputValue[2]=rgbPix.blue;
			}
			else{
				outputValue[0]=[ImageDebayering normalizeFloatTo8Bit:rgbPix.red bitsPerSample:bitsPerSample];
				outputValue[1]=[ImageDebayering normalizeFloatTo8Bit:rgbPix.green bitsPerSample:bitsPerSample];
				outputValue[2]=[ImageDebayering normalizeFloatTo8Bit:rgbPix.blue bitsPerSample:bitsPerSample];
			}
				/*
				outputValue[0]=rgbPix.red;
				outputValue[1]=0;
				outputValue[2]=0;
				*/
				/*
			}
			else{
				outputValue[0]=[ImageDebayering normalizeTo8Bit:rgbPix.red bitsPerSample:internalBitRes];
				outputValue[1]=[ImageDebayering normalizeTo8Bit:rgbPix.green bitsPerSample:internalBitRes];
				outputValue[2]=[ImageDebayering normalizeTo8Bit:rgbPix.blue bitsPerSample:internalBitRes];
			}
			*/
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.5\n");
			if(debug32Bit)NSLog(@"RGB PIX[%i][%i]=(%i/%i/%i)\n",i,j,rgbPix.red,rgbPix.green,rgbPix.blue);
			if(debug4 && (0<=i) && (i<3))NSLog(@"RGB PIX[%i][%i]=(%i/%i/%i) - (%d/%d/%d)\n",i,j,rgbPix.red,rgbPix.green,rgbPix.blue, rgbValue[0], rgbValue[1], rgbValue[2]);
			/*[dataBuffer appendBytes:rgbPix.red length:1];
			[dataBuffer appendBytes:rgbPix.green length:1];
			[dataBuffer appendBytes:rgbPix.blue length:1];
			*/
			[dataBuffer appendBytes:outputValue length:3];
	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 8.6\n");
//			if(debug)NSLog(@"dataBuffer=%@",dataBuffer);
			
		}
	}
	if(debug3)NSLog(@"END writing output buffer\n");
	
	
	
	
	

	if(debug3)NSLog(@"FUNCTION convertRawToRGB DEBUG 9\n");
	unsigned char dummy[32];
	[dataBuffer getBytes:dummy length:32];
	for(i=0;i<32;i++)NSLog(@"byte[%d]=%02X\n",i,dummy[i]);
	[testBuffer appendBytes:dummy length:32];
	if(debug4)NSLog(@"FUNCTION convertRawToRGB testBuffer=%@\n",testBuffer);
	NSLog(@"LINUX DEBUG: testBuffer appendBytes:  - done");


/*
[pixel release];
[pixel32Bit release];
[processedPixel release];
[blurredPixel release];
[scaledPixel release];
*/
	free(pixel);
	NSLog(@"LINUX DEBUG: free(pixel)  - done");
	free(pixel32Bit);
	NSLog(@"LINUX DEBUG: free(pixel32Bit)  - done");
	free(processedPixel);
	NSLog(@"LINUX DEBUG: free(processedPixel)  - done");
	free(blurredPixel);
	NSLog(@"LINUX DEBUG: free(blurredPixel)  - done");
	if(doRescale)free(scaledPixel);
	NSLog(@"LINUX DEBUG: free(scaledPixel)  - done");
	
	//FREE ADDITIONAL MEMORY
/*
	[imageBytes release];
[imageData release];
[testBuffer release];
*/
//	free(imageBytes);
//	free(imageData);
	//free(dataBuffer);
//	free(testBuffer);
	
	
	/*
	processedImageData dataBlock;
	dataBlock.buffer=dataBuffer;
	dataBlock.cols=cols;
	dataBlock.rows=rows;
	return dataBlock;
	*/
	//drain
    [pool drain];
	
	return dataBuffer;
	
} // END of function convertRawToRgb

-(NSMutableData *)bufferTest{
	NSMutableData *testi = [NSMutableData data];
	[testi appendBytes:"\x12" "\x34" "\x56" length:3];
	return testi;

}

-(float)roundedFloat:(float)orig postDecimals:(int)postDec{
	int factor = pow(10,postDec);
	float rounded = (roundf (orig * factor)) / factor;
	return rounded;
}

@end