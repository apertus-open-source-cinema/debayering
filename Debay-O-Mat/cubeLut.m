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


#import "cubeLut.h"
#import "imageDebayering.h"
#import "memoryManagement.h"
#import "cubePixel.h"
#include<math.h>
#include <stdlib.h>
#include <Foundation/Foundation.h>  
#include <stdio.h>

/*
 * Define the CubeLut class and the class methods.
 */
@implementation CubeLut
bool debugCube = false;
bool debugReadCube = false;
//CubePixel *c0,*c1,*c2,*c3,*c4,*c5,*c6,*c7;
	rgbBytes c0,c1,c2,c3,c4,c5,c6,c7;
/*
	CubePixel *c000;
	CubePixel *c001;
	CubePixel *c010;
	CubePixel *c011;
	CubePixel *c100;
	CubePixel *c101;
	CubePixel *c110;
	CubePixel *c111;
*/


-(void)checkFile:(NSString *)file{
	if(debugCube)NSLog(@"checkFile(): NOW OPENING CUBE FILE: %@", file);
}

-(void)readCube:(NSString *)fileName{
	if(debugCube)NSLog(@"readCube(): NOW OPENING CUBE FILE: %@", fileName);

	//DECLARE VARIABLES WITH PERHAPS HIGH MEMORY CONSUPTION
	NSMutableData *data = nil;
	NSMutableData *testData  = nil;
	NSData *outputBuffer = nil;
	NSString *appendString = nil;
	//NSData *commentData = nil;
	rgbBytes *pixels = nil;	

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
	

	//get file size in bytes
	NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:fileName];
	int fileSize = [fileHandle seekToEndOfFile];
    if(debugCube)NSLog(@"~~~~~~~~~~~~~myFile Size =%i" , fileSize) ;	
	if(fileSize==0 | fileSize==nil) {
		if(debugCube)NSLog(@"FILE SIZE = 0, might be empty or directory - ABORTING\n");
	return;}
	//rewind fileHandle
	[fileHandle seekToFileOffset:0];

	//Read in entire Cube file, the separate by line breaks
	
    NSString*    input;
    NSArray*      lines;
    int          i;
	int cubeDimensions = 0;
	rgbBytes cubePixel;
	cubePixel.red = cubePixel.green = cubePixel.blue = 0.0;
//	NSMutableArray * lutCube = nil;
	int x,y,z =0;
	int r,g,b = 0;
	int lineNumber = 0;
	

    input = [[NSString alloc] initWithData: [fileHandle availableData] encoding: NSUTF8StringEncoding];
    [input autorelease];
    lines = [input componentsSeparatedByString: @"\n"];
	if(debugCube)NSLog(@"CUBE: cubeDimensions=%d / counting line: %d",cubeDimensions,[lines count]);
	
    for (i = 0; i < [lines count]; i++)
    {	
		NSString *line = [lines objectAtIndex:i];
//		if(debugCube)NSLog(@"CUBE: cubeDimensions=%d / LINE = %@ ",cubeDimensions,line);
		//skip comments starting with #
		if ([line hasPrefix:@"#"]) continue;
		//skip empty lines
		if ([line length]==0) continue;
		if(cubeDimensions==0){

			if ([line rangeOfString:@"LUT_3D_SIZE"].location == NSNotFound) {
//				if(debugReadCube)NSLog(@"string does not contain LUT_3D_SIZE");
				continue; //makes no sense if Dimensions of the cube not determined
			} else {
			  NSLog(@"string contains LUT_3D_SIZE at line %d",i);
			  NSArray* lineParts = [line componentsSeparatedByString: @" "];
			  NSLog(@"Count Pars: %d",[lineParts count]);
			  NSString *cubeDimensionsString = [lineParts objectAtIndex:1]; //as in cube lut specs
			  cubeDimensions = (int)[cubeDimensionsString intValue];
			  [CubeLut setCubeSize:cubeDimensions];
			  NSLog(@"CUBE DIMENSIONS: LUT_3D_SIZE=%d",cubeDimensions);
			}		
		}
		else{ //CubeDimensions determined
			// if LutCube Array not yet initialized: do so
//if(debugReadCube)NSLog(@"CUBE reading lines... check1");
			//if(lutCube==nil)lutCube=[CubeLut cubeOfSize:cubeDimensions];
			//if(lutCubeArray==nil)lutCubeArray = [CubeLut make3DRgbArray:cubeDimensions y:cubeDimensions z:cubeDimensions];
			if(lutCube==nil){
				lutCube=[CubeLut createCubeArray:cubeDimensions];
				//initialize x/y/z coordinates
				NSLog(@"INITIALIZING coordinates");
				x=y=z = 0;
				lineNumber = 0;
			}
//if(debugReadCube)NSLog(@"CUBE reading lines... check2");
			
			//rest of the lines should contain cube data
			NSArray* lineParts = [line componentsSeparatedByString: @" "];
			// index 0 = red / index 1 = green / index 2 = blue
//if(debugReadCube)NSLog(@"CUBE reading lines... check3");
			cubePixel.red = [[lineParts objectAtIndex:0] floatValue];
			cubePixel.green = [[lineParts objectAtIndex:1] floatValue];
			cubePixel.blue = [[lineParts objectAtIndex:2] floatValue];
//if(debugReadCube)NSLog(@"cubePixel.red=%f / cubePixel.green=%f / cubePixel.blue=%f /",cubePixel.red,cubePixel.green,cubePixel.blue);			

			//determine actual x,y,z coordinates from lineCount modulo size
/*
			z=lineNumber%cubeDimensions;
			y=(lineNumber/cubeDimensions)%cubeDimensions;
			x=(lineNumber/(int)pow(cubeDimensions,2))%cubeDimensions;
*/			
			//somethings swapped here - perhaps change and test - all wrong! ???
			x=lineNumber%cubeDimensions;
			y=(lineNumber/cubeDimensions)%cubeDimensions;
			z=(lineNumber/(int)pow(cubeDimensions,2))%cubeDimensions;


			if(debugReadCube)NSLog(@"PREPARING CALL OF setCubePixel: x=%d y=%d z=%d / lineNumber=%d",x,y,z,lineNumber);			
			[CubeLut setCubePixel:cubePixel x:x y:y z:z];
			lineNumber++;
			
			
			//Use the make3DArray func instead and access coordinates with lutCube[x][y][z]
			//lutCubeArray[x][y][z] = cubePixel;
			
		}
//if(debugReadCube)NSLog(@"EXIT function readCube()");			

	}
	
	//Reading in LUT finished - output for test reasons
	if(debugCube){
		rgbBytes *testPixel;
		CubePixel *testCubePixel;
		float rgbArray[3];
		NSLog(@"NOW READ OUT CUBE LUT for test reasons...");
		for(x=0;x<cubeDimensions;x++){
			for(y=0;y<cubeDimensions;y++){
				for(z=0;z<cubeDimensions;z++){
	//				testPixel=(rgbBytes*)[CubeLut getCubePixel:x y:y z:z];
		NSLog(@"NOW READ OUT CUBE LUT... check1");
					testCubePixel=[CubeLut readCubePixel:x y:y z:z];
					NSLog(@"OUTPUT LUT CUBE at coordinates(%d/%d/%d): (%f/%f/%f)",x,y,z,testCubePixel.red,testCubePixel.green,testCubePixel.blue);
				}
			}
		}
	}
/*	
	NSData * buffer = nil;
	//Prepare buffer for imageData
	NSData *imageData = nil;

	NSLog(@"NOW READING IN BYTES"); //Output bytes
	//ONLY READ FIRST 8 BYTES
	int headerLength = 8;
	(buffer = [fileHandle readDataOfLength:headerLength]);
	NSLog(@"TIFF HEADER (%d bytes):%@", headerLength, buffer); //Output bytes  
*/
}

/*
+ (NSMutableArray *) cubeOfSize:(NSInteger)size{
	NSLog(@"ENTERED FUNC cubeOfSize with size=%d",size);
   //return [[[self alloc] initWithDimensions:size] autorelease];
   //return [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
   return [[self createCubeOfSize:size] autorelease];
}

+ (NSMutableArray *) createCubeOfSize:(NSInteger)size{
//	NSLog(@"ENTERED FUNC cubeOfSize with size=%d",size);
   //return [[[self alloc] initWithDimensions:size] autorelease];
//   return [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
//	NSLog(@"ENTERED FUNC createCubeOfSize");
	int x,y,z = 0;
   if((self = [[NSMutableArray alloc] initWithCapacity:size])) {
//	NSLog(@"FUNC createCubeOfSize check1");
      for(z = 0; z < size; z++) {
//	NSLog(@"FUNC createCubeOfSize check2");
         NSMutableArray *yArray = [[NSMutableArray alloc] initWithCapacity:size];
		  for(y = 0; y < size; y++) {
//	NSLog(@"FUNC createCubeOfSize check3");
			 NSMutableArray *xArray = [[NSMutableArray alloc] initWithCapacity:size];
			 for(x = 0; x < size; x++)
//	NSLog(@"FUNC createCubeOfSize check4 - x=%d / y=%d / z=%d",x,y,z);
				[xArray addObject:[NSNull null]];
			 [yArray addObject:xArray];
			 [xArray release];
		  }
		[self addObject:yArray];
        [yArray release];
      }
   }
	NSLog(@"DONE - FUNC createCubeOfSize");
   return self;
}
*/
/*
+ (id) initWithDimensions:(NSInteger)size {
//- (id) initWithCapacity:(NSInteger)size {
	NSLog(@"ENTERED FUNC initWithCapacity");
	int x,y,z = 0;
   if((self = [self initWithCapacity:size])) {
	NSLog(@"FUNC initWithCapacity check1");
      for(z = 0; z < size; z++) {
	NSLog(@"FUNC initWithCapacity check2");
         NSMutableArray *yArray = [[NSMutableArray alloc] initWithCapacity:size];
		  for(y = 0; y < size; y++) {
	NSLog(@"FUNC initWithCapacity check3");
			 NSMutableArray *xArray = [[NSMutableArray alloc] initWithCapacity:size];
			 for(x = 0; x < size; x++)
	NSLog(@"FUNC initWithCapacity check4");
//				rgbBytes dummyBytes = nil;
				[xArray addObject:[NSNull null]];
//				[xArray addObject:dummyBytes];
			 [yArray addObject:xArray];
			 [xArray release];
		  }
		[self addObject:yArray];
        [yArray release];
      }
   }
   return self;
}
*/

-(NSMutableArray*)createCubeArray:(int)size{

	NSMutableArray *array3D = [[NSMutableArray alloc] initWithCapacity:size];
	int i,j,k=0;
	for (i = 0; i < size; ++i)
	{
		NSMutableArray *array2D = [[NSMutableArray alloc] initWithCapacity:size];
		for (j = 0; j < size; ++j)
		{
			NSMutableArray *justAnArray = [[NSMutableArray alloc] initWithCapacity:size];
				
				//makes no difference
				NSLog(@"FILLING LUT CUBE WITH PIXELS (0/0/0)");
				for (k = 0; k < size; ++k)
				{
					CubePixel *myPix = [[CubePixel alloc] init];
					myPix.red = 0.0;
					myPix.green = 0.0;
					myPix.blue = 0.0;
					[justAnArray addObject:myPix];
				}
				
			[array2D addObject:justAnArray];
			[justAnArray release];
		}
		[array3D addObject:array2D];
		[array2D release];
	}
	return array3D;

}


/*
-(rgbBytes**)make3DRgbArray:(int)arraySizeX y:(int)arraySizeY z:(int)arraySizeZ {  
	NSLog(@"function make3DRgbArray arraySizeX=%d / arraySizeY=%d / arraySizeZ=%d\n",arraySizeX,arraySizeY,arraySizeZ);
	rgbBytes** theArray;  
	NSLog(@"Rums1");
	theArray = (rgbBytes**) malloc(arraySizeX*arraySizeY*sizeof(rgbBytes*));  
	//theArray = (rgbBytes**)[MemoryManagement memBlock:(arraySizeX*arraySizeY*sizeof(rgbBytes*))];
	NSLog(@"Rums2");
	int x,y,z=0;
	for (x = 0; x < arraySizeX; x++)  {
	   //theArray[y] = (rgbBytes*) malloc(arraySizeY*sizeof(rgbBytes));  
		for (y = 0; y < arraySizeY; y++)  {
		   theArray[y] = (rgbBytes*) malloc(arraySizeZ*sizeof(rgbBytes));  
		//   theArray[y] = (rgbBytes*)[MemoryManagement memBlock:(arraySizeZ*sizeof(rgbBytes))];
		}
	}
	NSLog(@"Rums3");
   return theArray;  
}  
*/
//call: rgbBytes** lutCube = [CubeLut make3DRgbArray:x y:y z:z];

-(void)setCubePixel:(rgbBytes)inputPixel x:(int)x y:(int)y z:(int)z{
	bool debugSetCubePixel = false;
	if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check1");
	if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check2");

	rgbBytes test = inputPixel;
	CubePixel *myPix = [[CubePixel alloc] init];
	myPix.red = inputPixel.red;
	myPix.green = inputPixel.green;
	myPix.blue = inputPixel.blue;
	if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check3");
	NSMutableArray *xArray = [lutCube objectAtIndex:(NSUInteger)x];
	NSMutableArray *yArray = [xArray objectAtIndex:(NSUInteger)y];
//	NSMutableArray *zArray = [lutCube objectAtIndex:(NSUInteger)z];
//	NSMutableArray *yArray = [zArray objectAtIndex:(NSUInteger)y];
	if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL (%f/%f/%f) at (%d/%d/%d) ",test.red,test.green,test.blue,x,y,z);
	@try{
		if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check5");
		[yArray setObject:myPix atIndexedSubscript:(NSUInteger)z]; 
//		[yArray setObject:myPix atIndexedSubscript:(NSUInteger)x]; 
		if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check6");
	}
	@catch(NSException * e){
		if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check7");
		[yArray insertObject:myPix atIndex:(NSUInteger)z]; 
//		[yArray insertObject:myPix atIndex:(NSUInteger)x]; 
		if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check8 check size: %d",[yArray count]);
	}
	if(debugSetCubePixel)NSLog(@"SET CUBE PIXEL ...check9");
	if(debugReadCube){
		//rgbBytes *test = [CubeLut getCubePixel:x y:y z:z];
		CubePixel *test = [CubeLut readCubePixel:x y:y z:z];
		NSLog(@"READ CUBE PIXEL: (%f/%f/%f)",test.red,test.green,test.blue);
	}
}

-(int)getCubeSize{
	return cubeSize;
}

-(void)setCubeSize:(int)size{
	cubeSize=size;
}

//input Pixel normalized to value between 0.0 and 1.0
-(rgbBytes)transformByLut:(rgbBytes)inputPix{
	bool debugLutTransform = false;
	bool testMem =true;
	rgbBytes outPix;
//	float x,y,z;
//	float distanceX,distanceY,distanceZ;
//	int xLow,yLow,zLow,xHigh,yHigh,zHigh;
	//input Pixel normalized to value between 0.0 and 1.0
	int size = [CubeLut getCubeSize]-1; //demo dimensions=17, array index from 0 to 16

	

	//TO DO: get coordinates inputPix.red*size
	float x = inputPix.red*(float)size;
	float y = inputPix.green*(float)size;
	float z = inputPix.blue*(float)size;
	if(debugLutTransform)NSLog(@"FUNC transformByLut: (x,y,z)=(%f,%f,%f)",x,y,z);
	//TO DO: floor / ceil -> get next edges of mini cube
/*
	int xLow = floor(x);
	int yLow = floor(y);
	int zLow = floor(z);
*/
	int xLow = (int)x;
	int yLow = (int)y;
	int zLow = (int)z;
	
//	NSLog(@"FUNC transformByLut: ?????? (xLow,yLow,zLow)=(%d,%d,%d)",xLow,yLow,zLow);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: (xLow,yLow,zLow)=(%f,%f,%f)",xLow,yLow,zLow);
/*
	int xHigh = ceil(x);
	int yHigh = ceil(y);
	int zHigh = ceil(z);
*/
	int xHigh = xLow+1;
	int yHigh = yLow+1;
	int zHigh = zLow+1;

	if(debugLutTransform)NSLog(@"FUNC transformByLut: ??????(xHigh,yHigh,zHigh)=(%d,%d,%d)",xHigh,yHigh,zHigh);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: (xHigh,yHigh,zHigh)=(%f,%f,%f)",xHigh,yHigh,zHigh);
	
	//TO DO: distance to High / Low
	
	float distanceX = x-(float)xLow;
	float distanceY = y-(float)yLow;
	float distanceZ = z-(float)zLow;
	
	//TO DO: get Values for High / Low each RGB
	//TO DO: More complicated: calculated value depends on ALL edge point values!

	CubePixel *c000;
	CubePixel *c001;
	CubePixel *c010;
	CubePixel *c011;
	CubePixel *c100;
	CubePixel *c101;
	CubePixel *c110;
	CubePixel *c111;
	
	//No mem leaks so far
	//cXYZ schema
	
	c000 = [CubeLut readCubePixel:xLow y:yLow z:zLow];
	c001 = [CubeLut readCubePixel:xLow y:yLow z:zHigh];
	c010 = [CubeLut readCubePixel:xLow y:yHigh z:zLow];
	c011 = [CubeLut readCubePixel:xLow y:yHigh z:zHigh];
	c100 = [CubeLut readCubePixel:xHigh y:yLow z:zLow];
	c101 = [CubeLut readCubePixel:xHigh y:yLow z:zHigh];
	c110 = [CubeLut readCubePixel:xHigh y:yHigh z:zLow];
	c111 = [CubeLut readCubePixel:xHigh y:yHigh z:zHigh];

	if(debugLutTransform)NSLog(@"FUNC transformByLut: c000=(%f/%f/%f)",c000.red,c000.green,c000.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c001=(%f/%f/%f)",c001.red,c001.green,c001.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c010=(%f/%f/%f)",c010.red,c010.green,c010.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c011=(%f/%f/%f)",c011.red,c011.green,c011.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c100=(%f/%f/%f)",c100.red,c100.green,c100.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c101=(%f/%f/%f)",c101.red,c101.green,c101.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c110=(%f/%f/%f)",c110.red,c110.green,c110.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c111=(%f/%f/%f)",c111.red,c111.green,c111.blue);
/*
		//original code
	float distC000 = pow( pow(x-xLow, 2) + pow(y-yLow, 2) + pow(z-zLow, 2), 1/2);
	float distC001 = pow( pow(x-xLow, 2) + pow(y-yLow, 2) + pow(z-zHigh, 2), 1/2);
	float distC010 = pow( pow(x-xLow, 2) + pow(y-yHigh, 2) + pow(z-zLow, 2), 1/2);
	float distC011 = pow( pow(x-xLow, 2) + pow(y-yHigh, 2) + pow(z-zHigh, 2), 1/2);
	float distC100 = pow( pow(x-xHigh, 2) + pow(y-yLow, 2) + pow(z-zLow, 2), 1/2);
	float distC101 = pow( pow(x-xHigh, 2) + pow(y-yLow, 2) + pow(z-zHigh, 2), 1/2);
	float distC110 = pow( pow(x-xHigh, 2) + pow(y-yHigh, 2) + pow(z-zLow, 2), 1/2);
	float distC111 = pow( pow(x-xHigh, 2) + pow(y-yHigh, 2) + pow(z-zHigh, 2), 1/2);
*/
	//no mem leaks so far
	float distC000 = sqrtf( powf(x-xLow, 2.0) + powf(y-yLow, 2.0) + powf(z-zLow, 2.0));
	float distC001 = sqrtf( powf(x-xLow, 2.0) + powf(y-yLow, 2.0) + powf(z-zHigh, 2.0));
	float distC010 = sqrtf( powf(x-xLow, 2.0) + powf(y-yHigh, 2.0) + powf(z-zLow, 2.0));
	float distC011 = sqrtf( powf(x-xLow, 2.0) + powf(y-yHigh, 2.0) + powf(z-zHigh, 2.0));
	float distC100 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yLow, 2.0) + powf(z-zLow, 2.0));
	float distC101 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yLow, 2.0) + powf(z-zHigh, 2.0));
	float distC110 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yHigh, 2.0) + powf(z-zLow, 2.0));
	float distC111 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yHigh, 2.0) + powf(z-zHigh, 2.0));

	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST powf(x-xLow, 2.0)=%f / powf(y-yLow, 2.0)=%f / powf(z-zLow, 2.0)=%f",powf(x-xLow, 2.0),powf(y-yLow, 2.0),powf(z-zLow, 2.0));
	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0)=%f",powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0));
	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST sqrtf(powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0))=%f",sqrtf(powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0)));
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC000=%f",distC000);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC001=%f",distC001);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC010=%f",distC010);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC011=%f",distC011);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC100=%f",distC100);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC101=%f",distC101);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC110=%f",distC110);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC111=%f",distC111);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST powf(x-xHigh, 2.0)=%f / powf(y-yHigh, 2.0)=%f / powf(z-zHigh, 2.0)=%f",powf(x-xHigh, 2.0),powf(y-yHigh, 2.0),powf(z-zHigh, 2.0));
	//somethings wrong here - output (normalized) should not be greater than 1
	
	float redOut = c000.red*distC000+c001.red*distC001+c010.red*distC010+c011.red*distC011+c100.red*distC100+c101.red*distC101+c110.red*distC110+c111.red*distC111;
	float greenOut = c000.green*distC000+c001.green*distC001+c010.green*distC010+c011.green*distC011+c100.green*distC100+c101.green*distC101+c110.green*distC110+c111.green*distC111;
	float blueOut = c000.blue*distC000+c001.blue*distC001+c010.blue*distC010+c011.blue*distC011+c100.blue*distC100+c101.blue*distC101+c110.blue*distC110+c111.blue*distC111;

	if(debugLutTransform)NSLog(@"FUNC transformByLut: outPix=(%f,%f,%f)",redOut,greenOut,blueOut);
/*
	CubePixel *c0;
	CubePixel *c1;
	CubePixel *c2;
	CubePixel *c3;
	CubePixel *c4;
	CubePixel *c5;
	CubePixel *c6;
	CubePixel *c7;
*/

	//no mem leaks so far
	//if(testMem) return inputPix;

	//this block causes mem leak of around one GB of allocated and not released memory
	CubePixel *c0 = [[CubePixel alloc] init];
	CubePixel *c1 = [[CubePixel alloc] init];
	CubePixel *c2 = [[CubePixel alloc] init];
	CubePixel *c3 = [[CubePixel alloc] init];
	CubePixel *c4 = [[CubePixel alloc] init];
	CubePixel *c5 = [[CubePixel alloc] init];
	CubePixel *c6 = [[CubePixel alloc] init];
	CubePixel *c7 = [[CubePixel alloc] init];
//	CubePixel *c8 = [(CubePixel*)[MemoryManagement addToMemoryBlock:(sizeof(CubePixel))] init];
	

	//if(testMem) return inputPix;

	//TO DO: initialize only once & Reuse allocated CubePixel for processing each pixel of one image
	// TO DO: Check if the use of CubePixel is mandatory (Memory Allocation) or if simple rgbBytes would be sufficient
//	rgbBytes c0,c1,c2,c3,c4,c5,c6,c7; //this works, definition on top outside the function - Memory under control, speed seems better than with allocating CubePixels


	/*	
	c0=c000;
	c1=c100-c000;
	c2=c010-c000;
	c3=c001-c000;
	c4=c110-c010-c100+c000;
	c5=c101-c001-c100+c000;
	c6=c011 -c001 -c010 +c000;
	c7=c111 -c011 -c101 -c110 +c100 +c001 +c010 -c000;
*/

// MEM LEAK - Up to 1GB of memory allocated and not released after processing!
	//if(testMem)return inputPix;
	

	c0.red=c000.red;
	c1.red=c100.red-c000.red;
	c2.red=c010.red-c000.red;
	c3.red=c001.red-c000.red;
	c4.red=c110.red-c010.red-c100.red+c000.red;
	c5.red=c101.red-c001.red-c100.red+c000.red;
	c6.red=c011.red-c001.red-c010.red+c000.red;
	c7.red=c111.red-c011.red-c101.red-c110.red+c100.red+c001.red+c010.red-c000.red;

	c0.green=c000.green;
	c1.green=c100.green-c000.green;
	c2.green=c010.green-c000.green;
	c3.green=c001.green-c000.green;
	c4.green=c110.green-c010.green-c100.green+c000.green;
	c5.green=c101.green-c001.green-c100.green+c000.green;
	c6.green=c011.green-c001.green-c010.green+c000.green;
	c7.green=c111.green-c011.green-c101.green-c110.green+c100.green+c001.green+c010.green-c000.green;

	c0.blue=c000.blue;
	c1.blue=c100.blue-c000.blue;
	c2.blue=c010.blue-c000.blue;
	c3.blue=c001.blue-c000.blue;
	c4.blue=c110.blue-c010.blue-c100.blue+c000.blue;
	c5.blue=c101.blue-c001.blue-c100.blue+c000.blue;
	c6.blue=c011.blue-c001.blue-c010.blue+c000.blue;
	c7.blue=c111.blue-c011.blue-c101.blue-c110.blue+c100.blue+c001.blue+c010.blue-c000.blue;
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c0.red=%f / c1.red=%f / c2.red=%f / c3.red=%f / c4.red=%f / c5.red=%f / c6.red=%f / c7.red=%f ",c0.red,c1.red,c2.red,c3.red,c4.red,c5.red,c6.red,c7.red);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c0.green=%f / c1.green=%f / c2.green=%f / c3.green=%f / c4.green=%f / c5.green=%f / c6.green=%f / c7.green=%f ",c0.green,c1.green,c2.green,c3.green,c4.green,c5.green,c6.green,c7.green);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c0.blue=%f / c1.blue=%f / c2.blue=%f / c3.blue=%f / c4.blue=%f / c5.blue=%f / c6.blue=%f / c7.blue=%f ",c0.blue,c1.blue,c2.blue,c3.blue,c4.blue,c5.blue,c6.blue,c7.blue);
	
	float dx=(x-xLow)/(xHigh-xLow);
	float dy=(y-yLow)/(yHigh-yLow);
	float dz=(z-zLow)/(zHigh-zLow);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: NEW FORMULA (dx,dy,dz)=(%f,%f,%f)",dx,dy,dz);
	
	//f(p)=c0+c1*dx+c2*dy+c3*dz+c4*dx*dy+c5*dx*dz+c6*dy*dz+c7*dx*dy*dz;
	float lutRed, lutGreen, lutBlue;
	lutRed=c0.red+c1.red*dx+c2.red*dy+c3.red*dz+c4.red*dx*dy+c5.red*dx*dz+c6.red*dy*dz+c7.red*dx*dy*dz;
	lutGreen=c0.green+c1.green*dx+c2.green*dy+c3.green*dz+c4.green*dx*dy+c5.green*dx*dz+c6.green*dy*dz+c7.green*dx*dy*dz;
	lutBlue=c0.blue+c1.blue*dx+c2.blue*dy+c3.blue*dz+c4.blue*dx*dy+c5.blue*dx*dz+c6.blue*dy*dz+c7.blue*dx*dy*dz;
	
	if(debugLutTransform)NSLog(@"FUNC transformByLut: NEW FORMULA outPix=(%f,%f,%f)",lutRed,lutGreen,lutBlue);
	
/*	
	outPix.red = redOut;
	outPix.green = greenOut;
	outPix.blue = blueOut;
*/	
	outPix.red = lutRed;
	outPix.green = lutGreen;
	outPix.blue = lutBlue;
	
//	NSLog(@"FUNC transformByLut: size=%d",size);	

	return outPix;
}

/*******************************************************
*
*	Quick & Lean Version of FUNC transformByLut
*
*******************************************************/
	rgbBytes c000, c001,c010,c011,c100,c101,c110,c111;
	float distC000,distC001, distC010, distC011, distC100, distC101, distC110, distC111;


//input Pixel normalized to value between 0.0 and 1.0
-(rgbBytes)transformByLutSmallMem:(rgbBytes)inputPix{
	bool debugLutTransform = false;
	bool testMem =true;
	rgbBytes outPix;
//	float x,y,z;
//	float distanceX,distanceY,distanceZ;
//	int xLow,yLow,zLow,xHigh,yHigh,zHigh;
	//input Pixel normalized to value between 0.0 and 1.0
	int size = [CubeLut getCubeSize]-1; //demo dimensions=17, array index from 0 to 16

	

	//TO DO: get coordinates inputPix.red*size
	float x = inputPix.red*(float)size;
	float y = inputPix.green*(float)size;
	float z = inputPix.blue*(float)size;
	if(debugLutTransform)NSLog(@"FUNC transformByLut: (x,y,z)=(%f,%f,%f)",x,y,z);
	//TO DO: floor / ceil -> get next edges of mini cube
	int xLow, yLow, zLow;
	int xHigh, yHigh, zHigh;
	
	xLow = (int)x;
	yLow = (int)y;
	zLow = (int)z;
	
//	NSLog(@"FUNC transformByLut: ?????? (xLow,yLow,zLow)=(%d,%d,%d)",xLow,yLow,zLow);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: (xLow,yLow,zLow)=(%f,%f,%f)",xLow,yLow,zLow);

	xHigh = xLow+1;
	yHigh = yLow+1;
	zHigh = zLow+1;

	if(debugLutTransform)NSLog(@"FUNC transformByLut: ??????(xHigh,yHigh,zHigh)=(%d,%d,%d)",xHigh,yHigh,zHigh);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: (xHigh,yHigh,zHigh)=(%f,%f,%f)",xHigh,yHigh,zHigh);
	
	//TO DO: distance to High / Low
/*	
	float distanceX = x-(float)xLow;
	float distanceY = y-(float)yLow;
	float distanceZ = z-(float)zLow;
*/	
	//TO DO: get Values for High / Low each RGB
	//TO DO: More complicated: calculated value depends on ALL edge point values!

	//No mem leaks so far
	//cXYZ schema
/*	
	c000 = [CubeLut readCubePixel:xLow y:yLow z:zLow];
	c001 = [CubeLut readCubePixel:xLow y:yLow z:zHigh];
	c010 = [CubeLut readCubePixel:xLow y:yHigh z:zLow];
	c011 = [CubeLut readCubePixel:xLow y:yHigh z:zHigh];
	c100 = [CubeLut readCubePixel:xHigh y:yLow z:zLow];
	c101 = [CubeLut readCubePixel:xHigh y:yLow z:zHigh];
	c110 = [CubeLut readCubePixel:xHigh y:yHigh z:zLow];
	c111 = [CubeLut readCubePixel:xHigh y:yHigh z:zHigh];
*/

//	rgbBytes c000, c001,c010,c011,c100,c101,c110,c111;
//	c000.red=c001.red=c010.red=c011.red=c100.red=c101.red=c110.red=c111.red=0.0;
//	c000.green=c001.green=c010.green=c011.green=c100.green=c101.green=c110.green=c111.green=0.0;
//	c000.blue=c001.blue=c010.blue=c011.blue=c100.blue=c101.blue=c110.blue=c111.blue=0.0;

	//c000 = [CubeLut cubePixel2RgbBytes:[CubeLut readCubePixel:xLow y:yLow z:zLow]];
	c000 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xLow y:yLow z:zLow] rgbPix:c000];
	c001 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xLow y:yLow z:zHigh] rgbPix:c001];
	c010 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xLow y:yHigh z:zLow] rgbPix:c010];
	c011 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xLow y:yHigh z:zHigh] rgbPix:c011];
	c100 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xHigh y:yLow z:zLow] rgbPix:c100];
	c101 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xHigh y:yLow z:zHigh] rgbPix:c101];
	c110 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xHigh y:yHigh z:zLow] rgbPix:c110];
	c111 = [CubeLut cubeToRgbBytes:[CubeLut readCubePixel:xHigh y:yHigh z:zHigh] rgbPix:c111];


	if(debugLutTransform)NSLog(@"FUNC transformByLut: c000=(%f/%f/%f)",c000.red,c000.green,c000.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c001=(%f/%f/%f)",c001.red,c001.green,c001.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c010=(%f/%f/%f)",c010.red,c010.green,c010.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c011=(%f/%f/%f)",c011.red,c011.green,c011.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c100=(%f/%f/%f)",c100.red,c100.green,c100.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c101=(%f/%f/%f)",c101.red,c101.green,c101.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c110=(%f/%f/%f)",c110.red,c110.green,c110.blue);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c111=(%f/%f/%f)",c111.red,c111.green,c111.blue);

	//no mem leaks so far
//	float distC000,distC001, distC010, distC011, distC100, distC101, distC110, distC111;

	distC000 = sqrtf( powf(x-xLow, 2.0) + powf(y-yLow, 2.0) + powf(z-zLow, 2.0));
	distC001 = sqrtf( powf(x-xLow, 2.0) + powf(y-yLow, 2.0) + powf(z-zHigh, 2.0));
	distC010 = sqrtf( powf(x-xLow, 2.0) + powf(y-yHigh, 2.0) + powf(z-zLow, 2.0));
	distC011 = sqrtf( powf(x-xLow, 2.0) + powf(y-yHigh, 2.0) + powf(z-zHigh, 2.0));
	distC100 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yLow, 2.0) + powf(z-zLow, 2.0));
	distC101 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yLow, 2.0) + powf(z-zHigh, 2.0));
	distC110 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yHigh, 2.0) + powf(z-zLow, 2.0));
	distC111 = sqrtf( powf(x-xHigh, 2.0) + powf(y-yHigh, 2.0) + powf(z-zHigh, 2.0));
	
	
	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST powf(x-xLow, 2.0)=%f / powf(y-yLow, 2.0)=%f / powf(z-zLow, 2.0)=%f",powf(x-xLow, 2.0),powf(y-yLow, 2.0),powf(z-zLow, 2.0));
	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0)=%f",powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0));
	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST sqrtf(powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0))=%f",sqrtf(powf(x-xLow, 2.0)+powf(y-yLow, 2.0)+powf(z-zLow, 2.0)));
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC000=%f",distC000);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC001=%f",distC001);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC010=%f",distC010);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC011=%f",distC011);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC100=%f",distC100);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC101=%f",distC101);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC110=%f",distC110);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: distC111=%f",distC111);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: TEST powf(x-xHigh, 2.0)=%f / powf(y-yHigh, 2.0)=%f / powf(z-zHigh, 2.0)=%f",powf(x-xHigh, 2.0),powf(y-yHigh, 2.0),powf(z-zHigh, 2.0));
	//somethings wrong here - output (normalized) should not be greater than 1
	
	float redOut = c000.red*distC000+c001.red*distC001+c010.red*distC010+c011.red*distC011+c100.red*distC100+c101.red*distC101+c110.red*distC110+c111.red*distC111;
	float greenOut = c000.green*distC000+c001.green*distC001+c010.green*distC010+c011.green*distC011+c100.green*distC100+c101.green*distC101+c110.green*distC110+c111.green*distC111;
	float blueOut = c000.blue*distC000+c001.blue*distC001+c010.blue*distC010+c011.blue*distC011+c100.blue*distC100+c101.blue*distC101+c110.blue*distC110+c111.blue*distC111;

	if(debugLutTransform)NSLog(@"FUNC transformByLut: outPix=(%f,%f,%f)",redOut,greenOut,blueOut);

	//no mem leaks so far
	//if(testMem) return inputPix;

		//NSLog(@"COUNT COEFFICIENTS: %d",coefficients.count);
//		float col = coefficients[0].red;
//		CubePixel c01 = coefficients[0];

	

	//TO DO: initialize only once & Reuse allocated CubePixel for processing each pixel of one image
	// TO DO: Check if the use of CubePixel is mandatory (Memory Allocation) or if simple rgbBytes would be sufficient
//	rgbBytes c0,c1,c2,c3,c4,c5,c6,c7; //this works, definition on top outside the function - Memory under control, speed seems better than with allocating CubePixels

	

// MEM LEAK - Up to 1GB of memory allocated and not released after processing!
	//if(testMem)return inputPix;
	

	c0.red=c000.red;
	c1.red=c100.red-c000.red;
	c2.red=c010.red-c000.red;
	c3.red=c001.red-c000.red;
	c4.red=c110.red-c010.red-c100.red+c000.red;
	c5.red=c101.red-c001.red-c100.red+c000.red;
	c6.red=c011.red-c001.red-c010.red+c000.red;
	c7.red=c111.red-c011.red-c101.red-c110.red+c100.red+c001.red+c010.red-c000.red;

	c0.green=c000.green;
	c1.green=c100.green-c000.green;
	c2.green=c010.green-c000.green;
	c3.green=c001.green-c000.green;
	c4.green=c110.green-c010.green-c100.green+c000.green;
	c5.green=c101.green-c001.green-c100.green+c000.green;
	c6.green=c011.green-c001.green-c010.green+c000.green;
	c7.green=c111.green-c011.green-c101.green-c110.green+c100.green+c001.green+c010.green-c000.green;

	c0.blue=c000.blue;
	c1.blue=c100.blue-c000.blue;
	c2.blue=c010.blue-c000.blue;
	c3.blue=c001.blue-c000.blue;
	c4.blue=c110.blue-c010.blue-c100.blue+c000.blue;
	c5.blue=c101.blue-c001.blue-c100.blue+c000.blue;
	c6.blue=c011.blue-c001.blue-c010.blue+c000.blue;
	c7.blue=c111.blue-c011.blue-c101.blue-c110.blue+c100.blue+c001.blue+c010.blue-c000.blue;
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c0.red=%f / c1.red=%f / c2.red=%f / c3.red=%f / c4.red=%f / c5.red=%f / c6.red=%f / c7.red=%f ",c0.red,c1.red,c2.red,c3.red,c4.red,c5.red,c6.red,c7.red);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c0.green=%f / c1.green=%f / c2.green=%f / c3.green=%f / c4.green=%f / c5.green=%f / c6.green=%f / c7.green=%f ",c0.green,c1.green,c2.green,c3.green,c4.green,c5.green,c6.green,c7.green);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: c0.blue=%f / c1.blue=%f / c2.blue=%f / c3.blue=%f / c4.blue=%f / c5.blue=%f / c6.blue=%f / c7.blue=%f ",c0.blue,c1.blue,c2.blue,c3.blue,c4.blue,c5.blue,c6.blue,c7.blue);
	
	float dx=(x-xLow)/(xHigh-xLow);
	float dy=(y-yLow)/(yHigh-yLow);
	float dz=(z-zLow)/(zHigh-zLow);
	if(debugLutTransform)NSLog(@"FUNC transformByLut: NEW FORMULA (dx,dy,dz)=(%f,%f,%f)",dx,dy,dz);
	
	//f(p)=c0+c1*dx+c2*dy+c3*dz+c4*dx*dy+c5*dx*dz+c6*dy*dz+c7*dx*dy*dz;
	float lutRed, lutGreen, lutBlue;
	lutRed=c0.red+c1.red*dx+c2.red*dy+c3.red*dz+c4.red*dx*dy+c5.red*dx*dz+c6.red*dy*dz+c7.red*dx*dy*dz;
	lutGreen=c0.green+c1.green*dx+c2.green*dy+c3.green*dz+c4.green*dx*dy+c5.green*dx*dz+c6.green*dy*dz+c7.green*dx*dy*dz;
	lutBlue=c0.blue+c1.blue*dx+c2.blue*dy+c3.blue*dz+c4.blue*dx*dy+c5.blue*dx*dz+c6.blue*dy*dz+c7.blue*dx*dy*dz;
	
	if(debugLutTransform)NSLog(@"FUNC transformByLut: NEW FORMULA outPix=(%f,%f,%f)",lutRed,lutGreen,lutBlue);
	
	outPix.red = lutRed;
	outPix.green = lutGreen;
	outPix.blue = lutBlue;
	
//	NSLog(@"FUNC transformByLut: size=%d",size);	


	return outPix;
}

-(rgbBytes)cubeToRgbBytes:(CubePixel*)cubePix rgbPix:(rgbBytes)rgbPix{
	rgbPix.red = cubePix.red;
	rgbPix.green = cubePix.green;
	rgbPix.blue = cubePix.blue;
	return rgbPix;
}

-(rgbBytes)cubePixel2RgbBytes:(CubePixel*)cubePix{
	rgbBytes rgbPix;
	rgbPix.red = cubePix.red;
	rgbPix.green = cubePix.green;
	rgbPix.blue = cubePix.blue;
	return rgbPix;
}


-(CubePixel*)readCubePixel:(int)x y:(int)y z:(int)z{
	return [[[lutCube objectAtIndex:(NSUInteger)x] objectAtIndex:(NSUInteger)y] objectAtIndex:(NSUInteger)z]; 
//	return [[[lutCube objectAtIndex:(NSUInteger)z] objectAtIndex:(NSUInteger)y] objectAtIndex:(NSUInteger)x]; 
}

-(rgbBytes*)getCubePixel:(int)x y:(int)y z:(int)z{
	return [[[lutCube objectAtIndex:(NSUInteger)x] objectAtIndex:(NSUInteger)y] objectAtIndex:(NSUInteger)z]; 
}

-(void)initCoefficients{
	//global var
	int i=0;
	for(i=0;i<8;i++){
//		CubePixel *c = (CubePixel*)[MemoryManagement memBlock:(sizeof(CubePixel))];

		coefficientsArray[i]= (CubePixel*)[MemoryManagement memBlock:(sizeof(CubePixel))];
		//		CubePixel *c7 = (CubePixel*)[MemoryManagement memBlock:(sizeof(CubePixel))];

	
	} 
	

}

-(void)initCoefficientsNSArray{
	//global var
	int i=0;
	if(coefs==nil){
//	NSLog(@"initializing Coefficients: count=%d",[coefs count]);

		for(i=0;i<8;i++){
			CubePixel *c = (CubePixel*)[MemoryManagement memBlock:(sizeof(CubePixel))];
			[coefs addObject:c];
			coefficientsArray[i]= (CubePixel*)[MemoryManagement memBlock:(sizeof(CubePixel))];
		} 
	}
}



-(CubePixel*)getCoefficients{
	return *coefficientsArray;
}

-(NSMutableArray*)getCoefficientsNSArray{
	return coefs;
}




//-(void)get3dCube{
-(void)get3dCube:(NSString *)currentPath{

#ifdef WIN32
#include <winconf.h>
	NSLog(@"SYSTEM IS WINDOWS");
#endif

#ifdef __unix__
#include <unixconf.h>
	NSLog(@"SYSTEM IS UNIX");
#endif


//	NSString *cubeFileName = @"simpletest2-lut.cube"; //simple test cube with N=2
	NSString *cubeFileName = @"lut.cube"; //Original ARRI LUT cube
//	NSString *cubeFileName = @"AlexaV3_EI0800_LogC2Video_DCIP3D65_LE_aftereffects3d.cube"; //Original ARRI LUT cube

//Substitue hard coded basePath with current exe dir path
basePath = currentPath;
	NSString *absPath = [NSString stringWithFormat:@"%@%@%@", basePath, lutDirName, cubeFileName];
	if(debugCube)NSLog(@"FUNCTION get3dCube() now opening file at:  %@", absPath); //Output bytes  
	//absPath = @"lut.cube";
	[CubeLut checkFile:absPath];
	//TO DO: Break / throw Error if file not found!
	[CubeLut readCube:absPath];
}


@end