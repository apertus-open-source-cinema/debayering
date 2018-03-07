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



#include <stdio.h>
#include<math.h>
#include <stdlib.h>





/* 
 * The next #include line is generally present in all Objective-C
 * source files that use GNUstep.  The Foundation.h header file
 * includes all the other standard header files you need.
 */
#include <Foundation/Foundation.h>  
#include <stdio.h>
#import "imageDebayering.h"
#import "memoryManagement.h"
#import "colorCorrection.h"
#import "cubeLut.h";
#define deeebug = true;

const bool debug = false;

/*
 * Declare the Test class that implements the class method (classStringValue).
 */
@interface Test
+ (const char *) classStringValue;
@end

/*
 * Define the Test class and the class method (classStringValue).
 */
@implementation Test
+ (const char *) classStringValue;
{
  return "This is the string value of the Test class";
}

- (void)openFile:(NSString *)str{
	NSLog(@"NOW OPENING FILE: %@", str);
}

- (void)test{
	NSLog(@"TEST FUNC CALLED");
}

@end

@interface FileHandling
+ (const char *) classStringValue;
@end
/*
 * Define the Test class and the class method (classStringValue).
 */
@implementation FileHandling
+ (const char *) classStringValue;
{
  return "This is the string value of the Test class";
}


//-(void)writeDataToFile:(NSData *)buffer outputFile:(NSString *)fileName{
-(void)writeDataToFile:(NSData *)buffer currentPath:(NSString *)currentPath outputFile:(NSString *)fileName{
	NSLog(@"FUNCTION writeDataToFile entered...\n");

#ifdef WIN32
#include <winconf.h>
	NSLog(@"SYSTEM IS WINDOWS");
#endif

#ifdef __unix__
#include <unixconf.h>
	NSLog(@"SYSTEM IS UNIX");
#endif

// Substitute hard coded basePath with current exe dir
basePath = currentPath;

	NSLog(@"FUNCTION writeDataToFile - basePath = %@\n",basePath);

//	NSString *basePath= @"C:/pidi/dev/objective-c/test/myMovie/CONTENTS/IMAGE/0002CD/output/";  // just for testing purpose
//	NSString *outputPath = [NSString stringWithFormat:@"%@%@", basePath, "output/"];
	NSString *outputPath = [NSString stringWithFormat:@"%@%@%@%@%@", basePath, movieProjectName, dirName, clipName, outputDir];
	NSLog(@"FUNCTION writeDataToFile - outputPath = %@\n",outputPath);

//	NSString *basePath= @"C:/pidi/dev/objective-c/test/myMovie/CONTENTS/IMAGE/0002CD-FILM/output/";  // just for testing purpose
	NSString *fileExtension = @"-modified.TIF"; 
	
	NSArray *split1 = [fileName componentsSeparatedByString:@"/"];
	NSString *last = [split1 lastObject];
	NSLog(@"writeDataToFile - stripped fileName: %@\n",last);
	/*
	//NSArray *split2 = [last componentsSeparatedByString:@"."];
	NSArray *listItems = [last componentsSeparatedByString:@"."];
	NSLog(@"Number of objects in Array: %@\n",[listItems count]);
	NSString *fName = [listItems firstObject];
	NSLog(@"writeDataToFile - fileName without file extension: %@\n",fName);
	*/
	NSString *absPath = [NSString stringWithFormat:@"%@%@%@", outputPath, last, fileExtension];	
	NSLog(@"NOW WRITING TO OUTPUT FILE: %@\n",absPath);
	[buffer writeToFile:absPath atomically:YES];

}




//- (void)openFile:(NSString *)fileName{
//- (void)openFile:(NSString *)fileName params:(inputParams)settings{
- (void)openFile:(NSString *)fileName currentPath:currentPath params:(inputParams)settings{
	NSLog(@"NOW OPENING FILE: %@", fileName);

//DECLARE VARIABLES WITH PERHAPS HIGH MEMORY CONSUPTION
NSMutableData *data = nil;
NSMutableData *testData  = nil;
NSData *outputBuffer = nil;
NSString *appendString = nil;
//NSData *commentData = nil;
rgbBytes *pixels = nil;	

NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	
	//Get file size first
/*    NSFileManager *filemgr;
    NSDictionary *fileAttributes = [filemgr attributesOfItemAtPath: fileName error: NULL];

NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
long long fileSize = [fileSizeNumber longLongValue];
	NSLog(@"~~~~~~~~~~~~FILE SIZE: %d", fileSize);
	if(fileSize==0) return;
	if(fileSize==nil) return;
*/	
	
	//Standard TIFF Header First 8 Bytes 0-7 is header info
	/*
	TIFF: Bytes 0&1: 
	Legal values:
	4949,H for little endian (least significant to most significant byte)
	4D4D,H for big endian (most significant to least significant byte)
	
	*/
	/* TIFF Bytes 2-7 perhaps irrelevant for the camera project. RWA Data should be uncompressed */
	

	//get file size in bytes
	NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:fileName];
	int fileSize = [fileHandle seekToEndOfFile];
    NSLog(@"~~~~~~~~~~~~~myFile Size =%i" , fileSize) ;	
	if(fileSize==0 | fileSize==nil) {
		NSLog(@"FILE SIZE = 0, might be empty or directory - ABORTING\n");
	return;}
	//rewind fileHandle
	[fileHandle seekToFileOffset:0];

	//Read in TIFF header
	NSData * buffer = nil;
	//Prepare buffer for imageData
	NSData *imageData = nil;

	NSLog(@"NOW READING IN BYTES"); //Output bytes
	//ONLY READ FIRST 8 BYTES
	int headerLength = 8;
	(buffer = [fileHandle readDataOfLength:headerLength]);
	NSLog(@"TIFF HEADER (%d bytes):%@", headerLength, buffer); //Output bytes  

	// TO DO: check for legal TIFF header bytes 0&1
	
	unsigned char headerBytes[8];
	[buffer getBytes:headerBytes length:8];
	unsigned char ifdOffset = headerBytes[4];
	NSLog(@"HEADER BYTE 0: %02X", headerBytes[0]);
	NSLog(@"HEADER BYTE 1: %02X", headerBytes[1]);
	NSLog(@"HEADER BYTE 2: %02X", headerBytes[2]);
	NSLog(@"HEADER BYTE 3: %02X", headerBytes[3]);
	NSLog(@"HEADER BYTE 4: %02X", headerBytes[4]);
	NSLog(@"HEADER BYTE 5: %02X", headerBytes[5]);
	NSLog(@"HEADER BYTE 6: %02X", headerBytes[6]);
	NSLog(@"HEADER BYTE 7: %02X", headerBytes[7]);
	
	//Set fileHandle to 1st IFD
	[fileHandle seekToFileOffset:ifdOffset];

	//is fileHandle still at byte 8? Test: read another 8 bytes
	//otherwise set fileHandle to position with [fileHandle seekToFileOffset: x]
	(buffer = [fileHandle readDataOfLength:headerLength]);
	NSLog(@"+++++++++++ NEXT 8 BYTES:%@", buffer); //Output bytes  


	// calculate offset to imageWidth & imageHeight (+)
	// TO DO: get offset at byte 4 (+ more bytes)
	//if little endian (4949) offset needs to be [7][6][5][4] -> bit operation?
	
	bool littleEndian = true;
	if((headerBytes[0] == 0X49)&&(headerBytes[1] == 0X49)){
		//little endian
		littleEndian = true;
	}
	else if((headerBytes[0] == 0X4D)&&(headerBytes[1] == 0X4D)){
		//big endian
		littleEndian = false;
	}
	
	
	int i = 0;
	long offset = 0X0;
	if(littleEndian){
		for(i=7; i>3; i--){
			offset = offset << 8;
			offset = offset | headerBytes[i];
			NSLog(@"\n+++++++++++ littleEndian - offset:%08X\n", offset); //Output bytes  
		}
	}
	else{
		for(i=4; i<8; i++){
			offset = offset << 8;
			offset = offset | headerBytes[i];
			NSLog(@"\n+++++++++++ bigEndian - offset:%08X\n", offset); //Output bytes  
		}
	}
//		NSLog(@"\n+++++++++++ offset:%i\n", offset); //Output bytes  
	[fileHandle seekToFileOffset: offset];
	buffer = [fileHandle readDataOfLength: 2];
	int numOfDirEntries = buffer;
    NSLog(@"buffer:%i", buffer); //Output bytes  
    NSLog(@"numOfDirEntries:%@", numOfDirEntries); //Output bytes  
	unsigned char entriesBytes[2];
	[buffer getBytes:entriesBytes length:2];
	int bufSize=2;
	
	
	if(littleEndian){
		int bigBytes = [FileHandling toBigEndian:buffer byteSize:bufSize];
		NSLog(@"toBigEndian test= %08X  \n", bigBytes);
	numOfDirEntries = bigBytes;
		NSLog(@"toBigEndian numOfDirEntries= %08X (int: %i) \n", numOfDirEntries, numOfDirEntries);

	long lsb = 0Xff00 & numOfDirEntries;
		int msb = 0Xff & numOfDirEntries;
		NSLog(@"msb:%02X / lsb:%02X", msb, lsb); //Output bytes  

//		numOfDirEntries = numOfDirEntries >> 8;
    //NSLog(@"numOfDirEntries:%@", numOfDirEntries); //Output bytes  
	}
	else{ //bigEndian
		int firstIFD = 0X00;
		for(i=0; i<sizeof(entriesBytes); i++){
			firstIFD=firstIFD <<8;
			firstIFD = firstIFD|entriesBytes[i];
		}
		numOfDirEntries=firstIFD;
	}
	
    //NSLog(@"numOfDirEntries:%@", numOfDirEntries); //Output bytes  

	bool deebug=true;
	if(deebug){}
	if(debug){ }
	
	//Read in all IFDs
	NSData *buf[numOfDirEntries];
	int counter = numOfDirEntries;
	int j=0;
	unsigned char ifdBytes[numOfDirEntries][12];
	unsigned char offsetBytes[4];
	unsigned long offsetToNextIfd = 0;
	unsigned long offsetEntryPosition = offset+2+numOfDirEntries*12;
	NSLog(@"OFFSET ENTRY POSITION: %d",offsetEntryPosition);
	
	while(counter>0){
		buf[counter] = buffer = [fileHandle readDataOfLength: 12];
		[buffer getBytes:ifdBytes[counter] length:12];
		if(debug) NSLog(@"buf[%i]:%@", counter, buf[counter]); //Output bytes  
		counter--;	
	}
	for(i=1;i<numOfDirEntries; i++){
		for(j=0;j<12;j++){
			if(debug) NSLog(@"ifdBytes[%d][%d]=%02X",i, j, ifdBytes[i][j]);
		}
	}
	
	//Get Offset Bytes if Thumbnail
	//Set fileHandle to 1st IFD
	[fileHandle seekToFileOffset:offsetEntryPosition];
	buffer = [fileHandle readDataOfLength: 4];
	[buffer getBytes:offsetBytes length:4];
	for(i=0;i<4;i++){
		NSLog(@"~~~~~~~~~~~~ OFFSET BYTE[%d]=%02X",i,offsetBytes[i]);
	}
	
	offsetToNextIfd = [FileHandling getLongFrom4Bytes:offsetBytes isLittleEndian:littleEndian];

	[FileHandling getIFDs:buf entries:numOfDirEntries];


	//For standard TIFF, the image width is tagged 0100 H
	//For standard TIFF the imageLength is tagged 0101 H
	
	//[FileHandling getImageWidth:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	//[FileHandling getImageHeight:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	long newSubfileType = [FileHandling getNewSubfileType:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	long imageHeight = [FileHandling getImageHeight:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	long imageWidth = [FileHandling getImageWidth:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	
	long stripOffsets = [FileHandling getStripOffsets:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	[FileHandling getSubIfdPointer:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	long bitsPerSample = [FileHandling getBitsPerSample:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	int compression = [FileHandling getCompression:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	long samplesPerPixel = [FileHandling getSamplesPerPixel:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	long rowsPerStrip = [FileHandling getRowsPerStrip:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	long stripByteCounts = [FileHandling getStripByteCounts:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian];
	int photometricInterpretation = [FileHandling getPhotometricInterpretation:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian]; //if =2 then it's a RGB Image with default 8 bits per color per pixel. Sample DNG has BitsPerSample C (hex) = 12 (integer)
	long cfaPattern = [FileHandling getCfaPattern:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian]; //if =2 then it's a RGB Image with default 8 bits per color per pixel. Sample DNG has BitsPerSample C (hex) = 12 (integer)
	long cfaRepeatPatternDim = [FileHandling getCfaRepeatPatternDim:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian]; //if =2 then it's a RGB Image with default 8 bits per color per pixel. Sample DNG has BitsPerSample C (hex) = 12 (integer)
	int xResolution = [FileHandling getXResolution:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian]; 
	int yResolution = [FileHandling getYResolution:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian]; 
	int resolutionUnit = [FileHandling getResolutionUnit:ifdBytes entries:numOfDirEntries isLittleEndian:littleEndian]; 
	
	long calculatedBytes = 0;
	int bitsPerByte = 8;
	//Correction for false values in TIFF Header tagged 102,H - Default is 8 Bits Per Sample
	if((0>bitsPerSample) | (bitsPerSample>32)){ //valid values are 8, 10, 12, 16, 24, 32
		bitsPerSample = 8;
	}
	calculatedBytes = (imageWidth*samplesPerPixel*bitsPerSample/bitsPerByte)*rowsPerStrip;

	NSLog(@"PhotometricInterpretation=%d    -   (%08x)\n",photometricInterpretation,photometricInterpretation);
	NSLog(@"cfaPattern=%d    -   (%08x)\n",cfaPattern,cfaPattern);
	NSLog(@"cfaRepeatPatternDim=%d    -   (%08x)\n",cfaRepeatPatternDim,cfaRepeatPatternDim);
	//If photometricInterpretation == 32803 (CFA), the CFAPettern tags shall be present
	unsigned char *cfaPatternBytes[4];
	//Set default values for CFAPattern
	cfaPatternBytes[0]=1; cfaPatternBytes[1]=0;	cfaPatternBytes[2]=2; cfaPatternBytes[3]=1;	
	if(photometricInterpretation == 32803){
		for(i=3;i>=0;i--){
			cfaPatternBytes[i]=cfaPattern & 0XFF;
			cfaPattern = cfaPattern >> 8;
			NSLog(@"cfaPatternBytes[%d]=%i\n",i, cfaPatternBytes[i]);
		}
	}
	NSLog(@"CHECK AFTER WRITING BYTES: cfaPatternBytes[]={%i, %i, %i, %i}\n",cfaPatternBytes[0], cfaPatternBytes[1], cfaPatternBytes[2], cfaPatternBytes[3]);
	
	NSLog(@"Image data newSubfileType=%d!\n",newSubfileType);
	NSLog(@"Image data offsetToNextIfd=%d!\n",offsetToNextIfd);
	NSLog(@"Image data stripByteCounts=%d!\n",stripByteCounts);
	NSLog(@"Image data rowsPerStrip=%d!\n",rowsPerStrip);
	NSLog(@"Image data stripOffsets=%d!\n",stripOffsets);
	//NSLog(@"Image data rowsPerStrip*stripByteCounts=%d!\n",(rowsPerStrip*stripByteCounts));
	NSLog(@"Image data in bytes (calculated)=%d!\n",calculatedBytes);
	
	//check if newSubfileType indicates thumbnail (=10001.H) or full resolution raw Image (=0). 
	//If thumbnail, the next IFD has to be searched (4-byte Offset of the next IFD after last IFD entry)
	if(newSubfileType==1){
		NSLog(@"+++++++++++++++ This IFD is for a THUMBNAIL +++++++++++++++");
	}
	
	
//	if(imageHeight == rowsPerStrip){
	if(imageHeight > 0){
		//Image data is stored in one strip
		NSLog(@"Image data is stored in one strip!\n");
		[fileHandle seekToFileOffset:stripOffsets];
		imageData = [fileHandle readDataOfLength:stripByteCounts];
/*
		unsigned char imageBytes[32];
		[imageData getBytes:imageBytes length:32];
		for(i=0;i<32;i++){
			NSLog(@"imageBytes[%d]=%02X\n", i, imageBytes[i]);
		}

		//allocate memory on stack first
		unsigned char *imageBytesMemory = malloc(stripByteCounts);
		if(imageBytesMemory == NULL){
			NSLog(@"ERROR IN ALLOCATING MEMORY FOR LARGE ARRAY of size[%l]!\n",stripByteCounts);
		}
		[imageData getBytes:imageBytesMemory length:stripByteCounts]; 
		for(i=0;i<128;i++){
			NSLog(@"imageBytesMemory[%d]=%02X\n", i, imageBytesMemory[i]);
		}	

		
		free(imageBytesMemory);	
*/
		//allocate memory on stack first
		unsigned char *imageBytes = malloc(stripByteCounts);
		if(imageBytes == NULL){
			NSLog(@"ERROR IN ALLOCATING MEMORY FOR LARGE ARRAY of size[%l]!\n",stripByteCounts);
		}
		[imageData getBytes:imageBytes length:stripByteCounts]; 
		for(i=0;i<128;i++){
			if(debug) NSLog(@"imageBytes[%d]=%02X\n", i, imageBytes[i]);
		}		

		data = [NSMutableData data];
		testData = [NSMutableData data];
		outputBuffer = [NSMutableData data];		
		appendString = nil;
		//rgbBytes *pixels;
		//returning a multidimensional array from function not yet solved, so returning NSMutableData bytes block

		
//		[data appendBytes:"\x4D" "\x4D" "\x00" "\x2A" "\x00" "\x00" "\x00" "\x08" length:8];
		[data appendBytes:"\x4D" "\x4D" "\x00" "\x2A" length:4];
		NSLog(@"(1)HEADER BYTES FOR OUTPUT FILE: %@\n",data);




	//just for testing - why is image distorted after processing?
	//imageWidth--;
	//the image is displayed in the right angle, but lacks one pixel in width compared to original size
	//still a stripe of confused pixels running from top right in a one pixel (less) per row pattern
		

	//just for testing - why is image distorted after processing?
	//imageWidth++;

			NSLog(@"CHECK BEFORE PASSING TO FUNC: cfaPatternBytes[]={%i, %i, %i, %i}\n",cfaPatternBytes[0], cfaPatternBytes[1], cfaPatternBytes[2], cfaPatternBytes[3]);
			NSLog(@"cfaPatternBytes[%d]=%i\n",i, cfaPatternBytes[i]);
//		int *testArray[4];
//		testArray[0]=11;testArray[1]=22;testArray[2]=33;testArray[3]=44;
		bool doRescale = false;
		float resize = 0.129;
		resize = 1.0; // this deactivates Rescaling entirely
		int debayeringMethod=5;
		bool doBlur = true;
		float randomMix = 0.33; // only for debyeringMethod = 3, 5, 7
		//float randomPart = 0;
		int randIts = 3;		// only for debyeringMethod = 3, 5, 7
		float debayeringVariance=2.5;		//only for debyeringMethod == 7
		float blurVariance=2.5;		
		bool doGrain = false;
		int grainPatternSize = 5;
		float mixGrain = 0.33;
		float grainDeviation = 5.0;


		int rescaleMethod=1;	
		//1=variable size / 2=halfsize (odd cols and rows) / 3=halfsize (even cols and rows)		
		
		int xRescale = imageWidth;
		int yRescale = imageHeight;
		resize = settings.resize;
		doRescale = settings.doRescale;
		if(doRescale){
			if(rescaleMethod==2 || rescaleMethod==3)resize=0.5;
			if((0<resize &&resize<1)){
				xRescale = imageWidth*resize;
				yRescale = imageHeight*resize;
			}	
		}
		
		NSLog(@"xRescale=%d / yRescale=%d / resize=%.2f\n", xRescale, yRescale, resize);
		//Try to get dataBuffer and Rescaled Dimensions from function
//		memPointers=[NSMutableArray new];
		
//		NSPointerFunctionsOptions options=(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality);
//		memBlockPointers=[NSPointerArray pointerArrayWithOptions: options];

		//memBlockPointers=[NSPointerArray weakObjectsPointerArray];
		NSLog(@"CHECK: memBlockPointers done... now calling convertRawToRGB");
//DEFINITION FROM .h
//+ (NSMutableData *)convertRawToRGB:(NSData *)imageRawBuffer imageWidth:(long)imageWidth imageHeight:(long)imageHeight bitsPerSample:(int)bitsPerSample samplesPerPixel:(int)samplesPerPixel cfaPattern:(int *)cfaPatternBytes scaleFactor:(float)resize rescaleMethod:(int)rescaleMethod params:(inputParams)settings;
		
		outputBuffer = [ImageDebayering convertRawToRGB:imageData imageWidth:imageWidth imageHeight:imageHeight bitsPerSample:bitsPerSample samplesPerPixel:samplesPerPixel cfaPattern:cfaPatternBytes scaleFactor:(float)resize rescaleMethod:rescaleMethod params:settings];

		//[outputBuffer appendBytes:[@"adstgasdtsdg" cStringUsingEncoding:NSASCIIStringEncoding] length:1];
		//NSLog(@"OUTPUT BUFFER - RGB-PIXELs as data block: %@\n", outputBuffer);
		NSLog(@"OUTPUT BUFFER - SIZE: %d\n", [outputBuffer length]);
		NSLog(@"~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+* COUNTING MEMORY OBJECTS:  - COUNT: %d\n", [MemoryManagement countMemObjects]);
		[MemoryManagement freeAllMemObjects];
		NSLog(@"~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+*~+* MEMORY RELEASED:  - COUNT: %d\n", [MemoryManagement countMemObjects]);

	//just for testing - why is image distorted after processing?
	//imageWidth--;
		
		
		//OFFSET FOR IFDs
		long imgByteSize = [outputBuffer length];
		long newOffset = imgByteSize + 8;
		//long newOffset = stripByteCounts + 8;
		NSLog(@"StripByteCounts= %08X / imgByteSize=%08X / newOffset=%08X \n",(stripByteCounts),imgByteSize,newOffset);
		[FileHandling appendLongToBuffer:data longValue:newOffset];
		NSLog(@"(2)HEADER BYTES FOR OUTPUT FILE: %@\n",data);

		
		//Append image data bytes
		//[data appendBytes:imageBytes length:stripByteCounts]; //this is appending the original image bytes - unprocessed!
		[data appendData:outputBuffer];
		
		//Append IFD

		//Required tags for DNG file format:
		//258 BitsPerSample	0X0102
		//259 Compression	0X0103
		//257 ImageLength 	0X0101
		//256 ImageWidth 	0X0100
		//254 NewSubFileType	0X00FE
		//274 Orientation	0X0112
		//262 PhotometricInterpretation	0X0106
		//284 PlanarConfiguration
		//278 RowsPerStrip	0X0116
		//277 SamplesPerPixel
		//279 StripByteCounts
		//273 StripOffsets	0X0111
		//325 TileByteCounts
		//323 TileLength
		//324 TileOffsets
		//322 TileWidth
		
		//Required tags for TIFF file format:
		//256 ImageWidth 				0X0100
		//257 ImageLength 				0X0101
		//258 BitsPerSample				0X0102
		//259 Compression				0X0103
		//262 PhotometricInterpretation	0X0106
		//273 StripOffsets				0X0111
		//277 SamplesPerPixel			0X0115
		//278 RowsPerStrip				0X0116
		//279 StripByteCounts			0X0117
		//282 XResolution				0X011A
		//283 YResolution				0X011B
		//296 ResolutionUnit			0X0128

		//254 NewSubFileType	0X00FE
		//274 Orientation	0X0112
		//284 PlanarConfiguration
		//322 TileWidth

		//Append IFD
		[testData appendBytes:"\x00" "\x0C" length:2]; //Number of directory entries c = 11 entries (wrong! use 13(0X0D) instead)
		NSLog(@"APPEND BYTES FOR OUTPUT FILE: byteSize=%i\n",[testData length]);
		[testData appendBytes:"\x00" "\xfe" "\x00" "\x04" "\x00" "\x00" "\x00" "\x01" "\x00" "\x00" "\x00" "\x00" length:12];

		//256 ImageWidth 				0X0100
		[testData appendBytes:"\x01""\x00" "\x00" "\x04" "\x00" "\x00" "\x00" "\x01" length:8];
		if(resize!=1)imageWidth=xRescale;
		[FileHandling appendLongToBuffer:testData longValue:imageWidth];

		// 257 - 0X0101 - ImageLength
		[testData appendBytes:"\x01""\x01" "\x00" "\x04" "\x00" "\x00" "\x00" "\x01" length:8];
		if(resize!=1)imageHeight=yRescale;
		[FileHandling appendLongToBuffer:testData longValue:imageHeight];

		// 258 - 0X0102 - BitsPerSample
		[testData appendBytes:"\x01""\x02" "\x00" "\x03" "\x00" "\x00" "\x00" "\x01" length:8];
//		[FileHandling appendIntToBuffer:testData intValue:bitsPerSample];
		//if processed use default 8 bit
		[FileHandling appendIntToBuffer:testData intValue:8];
		
		// 259 - 0X0103 - Compression
		[testData appendBytes:"\x01""\x03" "\x00" "\x03" "\x00" "\x00" "\x00" "\x01" length:8];
		[FileHandling appendIntToBuffer:testData intValue:compression];

		//262 PhotometricInterpretation	0X0106
		[testData appendBytes:"\x01""\x06" "\x00" "\x03" "\x00" "\x00" "\x00" "\x01" length:8];
//		[FileHandling appendIntToBuffer:testData intValue:photometricInterpretation]; //wrong if processed RGB Tiff
		[FileHandling appendIntToBuffer:testData intValue:2];

		//273 StripOffsets				0X0111
		[testData appendBytes:"\x01""\x11" "\x00" "\x04" "\x00" "\x00" "\x00" "\x01" length:8];
		//[FileHandling appendLongToBuffer:testData longValue:stripOffsets]; //Must be recalculated, when writing data to file
		[FileHandling appendLongToBuffer:testData longValue:8]; //this is correct offset if image data bytes follow the tiff header (8bytes)
		
		//277 SamplesPerPixel			0X0115
//		[testData appendBytes:"\x01""\x15" "\x00" "\x03" "\x00" "\x00" "\x00" "\x01" length:8];
		[testData appendBytes:"\x01""\x15" "\x00" "\x03" "\x00" "\x00" "\x00" "\x01" length:8];
		[FileHandling appendIntToBuffer:testData intValue:3];

		//278 RowsPerStrip				0X0116
		[testData appendBytes:"\x01""\x16" "\x00" "\x04" "\x00" "\x00" "\x00" "\x01" length:8];
		[FileHandling appendLongToBuffer:testData longValue:rowsPerStrip];
		//279 StripByteCounts			0X0117
		[testData appendBytes:"\x01""\x17" "\x00" "\x04" "\x00" "\x00" "\x00" "\x01" length:8];
		//[FileHandling appendLongToBuffer:testData longValue:stripByteCounts];
		[FileHandling appendLongToBuffer:testData longValue:imgByteSize]; //recalculated after processing
		
		//282 XResolution				0X011A
		[testData appendBytes:"\x01""\x1A" "\x00" "\x05" "\x00" "\x00" "\x00" "\x01" length:8];
		if(xResolution != -1)
		[FileHandling appendLongToBuffer:testData longValue:xResolution];
		else 
		[FileHandling appendLongToBuffer:testData longValue:1];

		//283 YResolution				0X011B
		[testData appendBytes:"\x01""\x1B" "\x00" "\x05" "\x00" "\x00" "\x00" "\x01" length:8];
		if(yResolution != -1)
		[FileHandling appendLongToBuffer:testData longValue:yResolution];
		else 
		[FileHandling appendLongToBuffer:testData longValue:1];
/*		
		//296 ResolutionUnit			0X0128
		[testData appendBytes:"\x01""\x28" "\x00" "\x05" "\x00" "\x00" "\x00" "\x01" length:8];
		if(resolutionUnit != -1)
		[FileHandling appendLongToBuffer:testData longValue:resolutionUnit];
		else 
		[FileHandling appendLongToBuffer:testData longValue:1];
*/		
		//Next IFD offset (none)
		[testData appendBytes:"\x00" "\x00" "\x00" "\x00" length:4];
		
		//Write finishing pattern retrieved in different TIFF files
		[testData appendBytes:"\x08" "\x00" "\x08" "\x00" "\x08" "\x00" length:6];
		
		//Write comment to buffer
		NSString *comment = @"This is just a test!";
		NSData *commentData = [comment dataUsingEncoding:NSUTF8StringEncoding];
		[testData appendData:commentData];
		
		//Write EOF pattern
		[testData appendBytes:"\x00" "\x00" "\x00" "\x48" "\x00" "\x00" "\x00" "\x01" "\x00" "\x00" "\x00" "\x48" "\x00" "\x00" "\x00" "\x01"  length:16];
		
		
		
		
		NSLog(@"TEST IFD BYTES FOR OUTPUT FILE: %@ (byteSize)=%i\n",testData, [testData length]);
//		[data appendBytes:testData length:[testData length]]; // writes false bytes to data
		[data appendData:testData];
//		[FileHandling writeDataToFile:data outputFile:fileName];
		[FileHandling writeDataToFile:data currentPath:currentPath outputFile:fileName];

		
		
//		free(byteMem);
		free(imageBytes);			
		
	}
	else if(imageHeight != rowsPerStrip){
		//Image data is spread in different strip -> collect them all and put image data back together
	}
	
//	NSLog(@"ImageHeight=%04X (hex) = %d (integer) / ImageWidth=%04X (hex) = %d (integer)", imageHeight, imageHeight, imageWidth, imageWidth);
	
	

	


// FREE all (explicitly or implicitly) allocated memory
/*
free(buffer);
free(imageData);
//free(buf);
free(data);
free(testData);
//free(outputBuffer);
free(appendString);
//free(commentData);
//free(pixels);
*/
  


	

[pool drain];
} //end of function openFile







typedef struct
{
   unsigned char array[4];
} longBytes;

/*
-(longBytes)getLongBytes:(long)longValue{
	longBytes returnBytes;
	int i=0;
	for(i=0;i<4;i++){
		returnBytes.array[i] = 0X00|longValue;
		longValue = longValue >> 8;
		NSLog(@"returnBytes.array[%i]=%02X",i,returnBytes.array[i]);
	}
	//returnBytes.array[0] = 0XFF; //testing byteorder
	return returnBytes;
}
*/

+(NSString*)intToHexString:(NSInteger)value
{
return [[NSString alloc] initWithFormat:@"%lX", value];
}



-(unsigned char *)appendLongToBuffer:byteBuffer longValue:(long)longValue{
		unsigned char offsetByte[4];
		int i=0;
		for(i=3;i>=0;i--){
			offsetByte[i] = longValue & 0Xff;
			longValue = longValue >> 8;
			//NSLog(@"offsetByte[%d]=%02X\n", i, offsetByte[i]);
			//offsetByte[0] = 0XFF; testing byte order
		}
		unsigned char *byteMem;
		byteMem = malloc(4); //allocate memory for 4 bytes of IFD offset
		byteMem = offsetByte;
		[byteBuffer appendBytes:byteMem length:4];
		free(byteMem);
}

-(void)appendIntToBuffer:byteBuffer intValue:(int)intValue{
		unsigned char offsetByte[4];
		int i=0;
		for(i=1;i>=0;i--){
			offsetByte[i] = intValue & 0Xff;
			intValue = intValue >> 8;
			//NSLog(@"offsetByte[%d]=%02X\n", i, offsetByte[i]);
			offsetByte[3] = offsetByte[2] = 0X00; 
		}
		unsigned char *byteMem;
		byteMem = malloc(4); //allocate memory for 4 bytes of IFD offset
		byteMem = offsetByte;
		[byteBuffer appendBytes:byteMem length:4];
		free(byteMem);
}


-(unsigned char *)long2Bytes:(long)longValue{
	unsigned char returnBytes[4];
	int i=0;
	for(i=3;i>=0;i--){
		returnBytes[i] = 0X00|longValue;
		longValue = longValue >> 8;
		NSLog(@"returnBytes[%i]=%02X",i,returnBytes[i]);
	}
	return returnBytes;
}

-(void)getIFDs:(NSData *)buf entries:(int)num{
	NSLog(@"FUNCTION getIFDs called with  num=%i\n", num);
	if(num==0 | num==NULL) return;
	int i=1;
	int flag[2];
	for(i=1; i<num; i++){
		NSLog(@"buffer[%i]: %@\n", i, buf[i]);
		//const char *bytes = [buf bytes];
		//NSString *result = [[NSString alloc] initWithData:buf[i] encoding:NSUTF8StringEncoding];
		//NSLog(@"+bytes=%08X\n",bytes);
		
	}
}


		//Required tags for TIFF file format:
		//256 ImageWidth 				0X0100
		//257 ImageLength 				0X0101
		//258 BitsPerSample				0X0102
		//259 Compression				0X0103
		//262 PhotometricInterpretation	0X0106
		//273 StripOffsets				0X0111
		//277 SamplesPerPixel			0X0115
		//278 RowsPerStrip				0X0116
		//279 StripByteCounts			0X0117
		//282 XResolution				0X011A
		//283 YResolution				0X011B
		//296 ResolutionUnit			0X0128

-(int)getNewSubfileType:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X00FE;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}		
		
-(int)getImageWidth:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0100;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getImageHeight:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0101;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getBitsPerSample:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0102;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}
-(int)getCompression:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0103;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getPhotometricInterpretation:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0106;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(long)getCfaPattern:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X828E;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(long)getCfaRepeatPatternDim:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X828D;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}


-(int)getStripOffsets:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0111;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getSamplesPerPixel:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0115;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getRowsPerStrip:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0116;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getStripByteCounts:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0117;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getXResolution:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X011A;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getYResolution:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X011B;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getResolutionUnit:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X0128;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(int)getSubIfdPointer:(unsigned char[][12])ifdArray entries:(int)count isLittleEndian:littleEndian{
	int searchFlag = 0X014A;
	return [FileHandling getIfdEntry:ifdArray entries:count isLittleEndian:littleEndian searchForFlag:searchFlag];
}

-(long)getLongFrom4Bytes:(unsigned char[4])offsetBytes isLittleEndian:littleEndian{
	long value=0;
	int i=0;
	
			if(littleEndian == true){
				for(i=3;i>=0;i--){
					value = value << 8;
					value = value|offsetBytes[i];
				}
			}
			else{
				for(i=0;i<4;i++){
					value = value << 8;
					value = value|offsetBytes[i];
				}
			}		
	
	return value;
}

-(int)getIfdEntry:(unsigned char[][12])ifdArray entries:(int)numOfDirEntries isLittleEndian:littleEndian searchForFlag:searchFlag{
	//ifdArray is of size x<=ifdEntries and y=12 (bytes)
	if(debug)NSLog(@"###size of Array: %d / searchFlag=%d (%04X)\n", numOfDirEntries,searchFlag,searchFlag);
	long flag = 0X00;
	long fieldType = 0X00;
	long count = 0X00;
	long value = 0X00;
	int i,j=0;
	for(i=1;i<=numOfDirEntries; i++){
		flag = 0X00;
		//check for littleEndian
		if(littleEndian == true){
			flag = flag|ifdArray[i][1];
			flag = flag << 8;
			flag = flag|ifdArray[i][0];
		}
		else{
			flag = flag|ifdArray[i][0];
			flag = flag << 8;
			flag = flag|ifdArray[i][1];
		}
		fieldType = 0X00;
		//check for littleEndian
		if(littleEndian == true){
			fieldType = fieldType|ifdArray[i][3];
			fieldType = fieldType << 8;
			fieldType = fieldType|ifdArray[i][2];
		}
		else{
			fieldType = fieldType|ifdArray[i][2];
			fieldType = fieldType << 8;
			fieldType = fieldType|ifdArray[i][3];
		}
		count = 0X00;
		//check for littleEndian
		if(littleEndian == true){
			for(j=7;j>=4;j--){
				count = count<<8;
				count = count|ifdArray[i][j];
			}
		}
		else{
			for(j=4;j<8;j++){
				count = count<<8;
				count = count|ifdArray[i][j];
			}
		}		
		if(debug) NSLog(@"ifdArray[%d]=%02X%02X / flag=%04X / fieldType=%04X / count=%08X",i, ifdArray[i][0],ifdArray[i][1],flag,fieldType,count);
		int numBytes=0;
		switch(fieldType){
			case 1:
				if(debug) NSLog(@"fieldType=%04X - BYTE - 8-Bit unsigned integer",fieldType);
				numBytes = 1;
				if(0<count && count<=4) numBytes = count;
				break;
			case 2: //Very special case: count filed is often > 4 but irrelevant for current use case
				if(debug) NSLog(@"fieldType=%04X - ASCII - 8-Bit byte with 7-Bit ASCII code",fieldType);
				numBytes = 1;
				break;
			case 3:
				if(debug) NSLog(@"fieldType=%04X - SHORT - 16-Bit (2 Byte) unsigned integer",fieldType);
				numBytes = 2;
				//if(count==2) numBytes=4; 
				//not yet correctly solved! Default 2 bytes, to return entire 8 Bit evaluated as SINGLE Value (perhaps leftbound)
				//if count fields states "2", then 8 Bits of Value contain 2 shorts 0001 0001
				//if count states "1", depending 
				break;
			case 4:
				if(debug) NSLog(@"fieldType=%04X - LONG - 32-Bit (4 Byte) unsigned integer",fieldType);
				numBytes = 4;
				break;
			case 5:
				if(debug) NSLog(@"fieldType=%04X - RATIONAL - Two Longs",fieldType);
				break;
			
		}
		int bound=8+(numBytes); //8 bytes = bytes 0-1:header, bytes 2-3: fieldType, bytes 4-7:number of values
		if(flag==searchFlag){
			NSLog(@"FLAG %04X found!!!!!!!!!\n",searchFlag);
			if(littleEndian == true){
//				for(j=11;j>7;j--){
				for(j=bound-1;j>7;j--){
					value = value << 8;
					value = value|ifdArray[i][j];
				}
			}
			else{
//				for(j=8;j<12;j++){
				for(j=8;j<bound;j++){
					value = value << 8;
					value = value|ifdArray[i][j];
				}
			}			
			NSLog(@"RETURN VALUE= %04X HEX = %d INTEGER\n",value,value);
			//return value seems to be a hex value! might need conversion
			if(value!=0 && value!=nil) return value;
			else if (value==0) return 0;
		}
	}
	return -1;
}



//changes byte order from little endian to big endian. Can handle up to 4 bytes (sizeof long)
- (long)toBigEndian:(NSData *)buf byteSize:(int)sz{
	unsigned char  byteArray[sz];
	[buf getBytes:byteArray length:sz];
	int i=0;
	long output = 0X0;
	long temp = 0X0;
	for(i=0; i <sz; i++){
		NSLog(@":toBigEndian: i=%i / byteArray[]=%02X\n", i, byteArray[i]);
	}


	for(i=sz-1; i >= 0; i--){
		output << 8;
		output = output | byteArray[i];	
		NSLog(@":toBigEndian: i=%i / byteArray[]=%02X / output=%08X \n", i, byteArray[i], output);
	}
	return output;
}

/*
//- (long)changeBytesToBigEndian:(int[])byteArray{
- (long)changeBytesToBigEndian:(unsigned char[])byteArray{
	int i=0;
	int max = sizeof(byteArray);
	NSLog(@"::: changeBytesToBigEndian: sizeof byteArray=%i \n", max);
	long output = 0X0;
	long temp = 0X0;
	for (i=max-1; i>=0; i--){
		NSLog(@":changeBytesToBigEndian: i=%i / byteArray[]=%02X / output=%08X \n", i, byteArray[i], output);
		output << 8;
		output = output || byteArray[i];
	}
	return output;
}
*/

- (void)getDirectoryListing:(NSString *)path{
	
}
/*
- (NSData *)bufTestFunc{
	NSData *driss;
	[driss appendBytes:"\xFF" "\x12" length:2];
	return driss;
}
*/
- (int *)testFunc{
  static int  r[10];
  int i;

  /* set the seed */
  srand( (unsigned)time( NULL ) );
  for ( i = 0; i < 10; ++i)
  {
     r[i] = rand();
     NSLog( @"r[%d] = %d\n", i, r[i]);

  }
  return r;
}

-(rgbBytes *)testFunc2D{
	rgbBytes pixels[10][10];
	rgbBytes point;
	int i,j =0;
	for(i=0;i<10;i++){
		for(j=0;j<10;j++){
			point.red= rand();
			point.green= rand();
			point.blue= rand();
			pixels[i][j]=point;
//			NSLog(@"# pixels[%d][%d]=(%d / %d / %d)\n",i,j,point.red,point.green,point.blue);
		}
	}

	for(i=0;i<10;i++){
		for(j=0;j<10;j++){
			point=pixels[i][j];
			NSLog(@"# pixels[%d][%d]=(%d / %d / %d)\n",i,j,point.red,point.green,point.blue);
		}
	}
	return pixels;
}

- (void)test{
	NSLog(@"TEST FUNC CALLED");
}

-(void)printGaussVariance{

	float variance =0.1;
	float gaussianMatrix[7][7];
	
	int c,x,y=0;
	//DEBUG STUFF: Print out a list of Gauss Patterns for different Variances
	for(variance=0.1;variance<5.0;variance=variance+0.1){
		//variance=variance+(c/10.0);
		float normalize = 1/(1/(2*M_PI*variance) )*expf( (-1)*(pow(0,2)+pow(0,2))/2*variance );
		NSLog(@"Variance=%.2f\n|", variance);
		for(y=-3;y<4;y++){
			for(x=-3;x<4;x++){
				float h = normalize*(1/(2*M_PI*variance) )*expf( (-1)*(pow(x,2)+pow(y,2))/2*variance );
				//float h = (1/(2*M_PI*variance) )*expf( (-1)*(pow(x,2)+pow(y,2))/2*variance );
				gaussianMatrix[x+3][y+3]=h;
				if(y==0)NSLog(@"%.4f|",h);
			}
		}
//		NSLog(@"normalize=%.16f\n",  normalize);
		//NSLog(@"Variance=%.2f\n|", variance);
		for(y=-3;y<4;y++){
				//NSLog(@"%.4f|",gaussianMatrix[x+2][0]);
		}
		NSLog(@"\n");
	}	

}

-(void)testArrays{

		unsigned char testArrayChar[3];
		testArrayChar[0]=7;
		testArrayChar[1]=8;
		testArrayChar[2]=9;
		
		unsigned char testArrayULong[3];
		testArrayULong[0]=7;
		testArrayULong[1]=8;
		testArrayULong[2]=9;
		
		int i=0;
		for(i=0;i<3;i++){
			NSLog(@"testArrayChar[%d]=%d / testArrayULong[%d]=%d \n", i, testArrayChar[i], i, testArrayULong[i]);
		}
}

@end

/* Global variables */
bool littleEndian = false;
NSMutableArray *memPointers;
NSPointerArray *memBlockPointers;
NSMutableArray *memBlockArray;
int memCounter;
float gradationSlope;
float gradationOffset;
float gradationPower;
bool colorRedo;
NSMutableArray * lutCube;
rgbBytes** lutCubeArray;
int cubeSize;
int colorCorrectionMethod = 0; //0=gradient 1=LUT
bool testLoopFirstPixels = true;
CubePixel* coefficientsArray[8];
NSMutableArray *coefs;





/*
 * The main() function: pass a message to the Test class
 * and print the returned string.
 *pass debayering method as argument to main()
 *	1= "", 2= "", 3= "" (or even better: define an arary with matches)
 *	and so on... 
 */

//int main(void)
int main(int argc, const char * argv[])
{
#ifdef WIN32
#include <winconf.h>
#endif

#ifdef __unix__
#include <unixconf.h>
#endif

#ifdef WIN32
NSLog(@"SYSTEM IS WINDOWS");
#endif

#ifdef __unix__
NSLog(@"SYSTEM IS LINUX");
#endif

NSLog( @"CURRENT APPLICATION PATH IS: %@" , [[NSBundle mainBundle] bundlePath] );
NSLog( @"CURRENT EXECUTABLE PATH IS: %@" , [[NSBundle mainBundle] executablePath] );
NSString *currentExePath = [[NSBundle mainBundle] executablePath];
NSRange split = [currentExePath rangeOfString:@"/" options:NSBackwardsSearch];
NSUInteger pos = split.location +1;
NSLog( @"last occurence of delimiter is at pos %d",split);
NSLog( @"Turn into NSUInteger %d",pos);
//NSString *currentPath = [currentExePath substringWithRange:split];
//NSString *currentPath = [currentExePath substringWithRange:NSMakeRange(0,43)];
NSString *currentPath = [currentExePath substringToIndex:pos];
NSLog( @"CURRENT PATH (DIR) IS %@",currentPath);



//TO DO: Add colorRedo & colorCorrectionMethod to settings struct
colorRedo=true;
colorCorrectionMethod = 1;
[ColorCorrection initializeGradation];
//memCounter = 0;
//[FileHandling printGaussVariance];

//Initialize Memory 
/*
		NSPointerFunctionsOptions options=(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality);
		memBlockPointers=[NSPointerArray pointerArrayWithOptions: options];
*/
//		memBlockPointers=[NSPointerArray strongObjectsPointerArray];

[MemoryManagement initializeMemory];		

//Read 3D LUT Cube
//[CubeLut get3dCube];
[CubeLut get3dCube:currentPath];
[CubeLut initCoefficientsNSArray];



NSLog(@"Passed variable argv[0]=%s / argv[1]=%s to main() func\n",argv[0],argv[1]);	

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



int a=0;
for(a=0;a<argc;a++)
{
	NSLog(@"Passed variable argv[%d]=%s\n",a,argv[a]);	
	//char *utf8String = /* Assume this exists. */ ;
	NSString *stringFromConstChar = [[NSString alloc] initWithUTF8String:argv[a]];
	NSArray *keyValuePairs = [stringFromConstChar componentsSeparatedByString:@"="];
	NSLog(@"stringFromConstChar=%@ / Sizeof keyValuePairs=%d",stringFromConstChar,[keyValuePairs count]);
	//NSString *key = keyValuePairs[0];
	//NSString *value = keyValuePairs[1];
	if([keyValuePairs count]==2){
		NSString *key = [keyValuePairs objectAtIndex:0];
		NSString *value = [keyValuePairs objectAtIndex:1];
		//if(keyValuePairs[0]== @"var1")NSLog(@"FOUND MATCH");
		NSLog(@"Split key-value pairs: key=%@ / value=%@\n",key,value);	
		//NSLog( @"Value of %s = %d",(#key), key);
		if([key isEqualToString:@"doRescale"]){NSLog(@"Match found: %@", key); settings.doRescale=[value boolValue]; NSLog(@"CHECK SET VALUE: %s", settings.doRescale?"true":"false");}
		if([key isEqualToString:@"resize"]){NSLog(@"Match found: %@", key); settings.resize=[value floatValue]; NSLog(@"CHECK SET VALUE: %.2f", settings.resize);}
		if([key isEqualToString:@"rescaleMethod"]){NSLog(@"Match found: %@", key); settings.rescaleMethod=[value integerValue]; NSLog(@"CHECK SET VALUE: %.d", settings.rescaleMethod);}
		if([key isEqualToString:@"debayeringMethod"]){NSLog(@"Match found: %@", key); settings.debayeringMethod=[value integerValue]; NSLog(@"CHECK SET VALUE: %d", settings.debayeringMethod);}
		if([key isEqualToString:@"doBlur"]){NSLog(@"Match found: %@", key); settings.doBlur=[value boolValue]; NSLog(@"CHECK SET VALUE: %s", settings.doBlur?"true":"false");}
		if([key isEqualToString:@"patternSize"]){NSLog(@"Match found: %@", key); settings.patternSize=[value floatValue]; NSLog(@"CHECK SET VALUE: %.2f", settings.patternSize);}
		if([key isEqualToString:@"randomMix"]){NSLog(@"Match found: %@", key); settings.randomMix=[value floatValue]; NSLog(@"CHECK SET VALUE: %.2f", settings.randomMix);}
		if([key isEqualToString:@"randIts"]){NSLog(@"Match found: %@", key); settings.randIts=[value integerValue]; NSLog(@"CHECK SET VALUE: %d", settings.randIts);}
		if([key isEqualToString:@"debayeringVariance"]){NSLog(@"Match found: %@", key); settings.debayeringVariance=[value floatValue]; NSLog(@"CHECK SET VALUE: %.2f", settings.debayeringVariance); }
		if([key isEqualToString:@"blurVariance"]){NSLog(@"Match found: %@", key); settings.blurVariance=[value floatValue]; NSLog(@"CHECK SET VALUE: %.2f", settings.blurVariance);}
		//if([key isEqualToString:@"debayeringMethod"]){NSLog(@"Match found: %@", key); settings.#key=[value floatValue];}
		
		if([key isEqualToString:@"doGrain"]){NSLog(@"Match found: %@", key); settings.doGrain=[value boolValue]; NSLog(@"CHECK SET VALUE: %s", settings.doGrain?"true":"false");}
		if([key isEqualToString:@"grainPatternSize"]){NSLog(@"Match found: %@", key); settings.grainPatternSize=[value floatValue]; NSLog(@"CHECK SET VALUE: %.2f", settings.grainPatternSize);}
		if([key isEqualToString:@"mixGrain"]){NSLog(@"Match found: %@", key); settings.mixGrain=[value floatValue]; NSLog(@"CHECK SET VALUE: %.2f", settings.mixGrain);}
		if([key isEqualToString:@"grainDeviation"]){NSLog(@"Match found: %@", key); settings.grainDeviation=[value floatValue]; NSLog(@"CHECK SET VALUE: %d", settings.grainDeviation);}

		if([key isEqualToString:@"colorRedo"]){NSLog(@"Match found: %@", key); settings.colorRedo=[value boolValue]; NSLog(@"CHECK SET VALUE: %d", settings.colorRedo?"true":"false");}
		if([key isEqualToString:@"colorCorrectionMethod"]){NSLog(@"Match found: %@", key); settings.colorCorrectionMethod=[value integerValue]; NSLog(@"CHECK SET VALUE: %d", settings.colorCorrectionMethod);}
		/*
		settings.resize = 1.0; // ==1.0  deactivates Rescaling entirely
		settings.rescaleMethod=0;
		settings.debayeringMethod=7;
		settings.doBlur = false;
		settings.patternSize = 7;
		settings.randomMix = 0.33; // only for debyeringMethod = 3, 5, 7
		settings.randIts = 3;		// only for debyeringMethod = 3, 5, 7
		settings.debayeringVariance=2.5;		//only for debyeringMethod == 7
		settings.blurVariance=2.5;				
		*/
	}
}
//NSLog(@"Passed variable argv[0]=%s (count argc=%d) to main() func\n",argc, argv[0]);	
int debayeringMethod=0;
if(argv[1]!=nil) debayeringMethod=argv[1];

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  printf("%s\n", [Test classStringValue]);
/*
//PERHAPS TO DO: Get single Image from RAW data stream  
NSString *basePath= @"C:/pidi/dev/objective-c/test/";  // perhaps needs a path relative to program dir
NSString *movieProjectName = @"myMovie"; // needs perhaps dynamically selectable var name
NSString *dirName = @"/CONTENTS/IMAGE/"; //Reference Structure from Specs
//NSString *clipName = @"0002CD"; //needs to be changed to a passed variable
NSString *clipName = @"0002CD-FILM"; //needs to be changed to a passed variable
*/

//TO DO: substitute hard coded basePath with current execution path
basePath = currentPath;


NSLog(@"BASE PATH: %@", basePath);
NSString *absPath = [NSString stringWithFormat:@"%@%@%@%@", basePath, movieProjectName, dirName, clipName];
NSLog(@"Now checking path: %@", absPath);
// check listing of dir. Read dir contents (filtered) to array

[FileHandling testArrays];

//	NSString *bundleRoot = [[NSBundle mainBundle] absPath];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray* files = [fm directoryContentsAtPath:absPath];
//	NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absPath error:NULL];	
//	NSArray* files = [fm directoryContentsAtPath:bundleRoot];
NSLog(@"NUMBER OF FILES FOUND: %d", [files count]);

BOOL isDir;
BOOL exists = [fm fileExistsAtPath:absPath isDirectory:&isDir];
if (exists) {
NSLog(@"FILE EXISTS");
    /* file exists */
    if (isDir) {
NSLog(@"DIR EXISTS");
        /* file is a directory */
    }
 }


		for(NSString *file in files) {
			NSString *filePath = [absPath stringByAppendingPathComponent:file];
			NSLog(@"##########FILE FOUND%@", file);
			NSLog(@"##########PATH   %@", filePath);
			//Klappt
//			[FileHandling openFile:filePath];
//			[FileHandling openFile:filePath params:settings];
			[FileHandling openFile:filePath currentPath:currentPath params:settings];
			[Test test];
		}

  
/*check if file exists */  
  NSFileManager *filemgr;
  NSData *databuffer;
//  NSString *fileName = @"C:/pidi/dev/objective-c/test/img/test1.jpg";
  NSString *fileName = @"C:/pidi/dev/objective-c/test/img/test.txt";
  
  
  filemgr = [NSFileManager defaultManager];
  if ([filemgr fileExistsAtPath: fileName ] == YES){
        NSLog (@"File exists");
		databuffer = [filemgr contentsAtPath: fileName ];
        NSLog(@"%@", databuffer); /*just output file content for debugging reason*/
		// TO DO:  Get XY Dimensions of image
		
		//TO DO: get single lines of RAW image data and split them at linebreak
		
		// TO DO: Read RAW image data to XY array
		
		// TO DO: get border of image -> different processing
		
		// TO DO: process inner pixels in double foreach (X & Y) or different 
		
			// DEBAYERING HERE
			// TO DO: process single pixels (needs info about surrounding pixels)

		}
  else
        NSLog (@"File not found");  
/* open file and read to buf */


	[ImageDebayering test];
	
	int i=0;
	for(i=0;i<100;i++){
		NSLog(@"Random binary = %d\n",[ImageDebayering randomBoolean]);
		//NSLog(@"Random binary = %d\n",arc4random());
//		NSLog(@"rand() - Random number = %d\n",rand()%2);
	}
	
	NSLog(@"rand() - Random number = %d\n",rand());
	
	
//		NSLog(@"BUF TEST FUNC liefert: %@\n",[FileHandling bufTestFunc]);
  [pool drain];
  return 0;
} // End of main()