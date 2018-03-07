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


#import "memoryManagement.h"
#include<math.h>
#include <stdlib.h>

/*
 * Define the MemoryManagement class and the class methods.
 */
@implementation MemoryManagement

NSPointerArray *memoryBlockPointers;


-(void)initializeMemory{
//Initialize Memory 

		NSPointerFunctionsOptions options=(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality);
		memBlockPointers=[NSPointerArray pointerArrayWithOptions: options];

//		memBlockPointers=[NSPointerArray strongObjectsPointerArray];
}

-(void)initializeMemoryBlock{
	//Initialize new Memory Block
	NSPointerFunctionsOptions options=(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality);
	memoryBlockPointers=[NSPointerArray pointerArrayWithOptions: options];
}

-(void *)addToMemoryBlock:(long *)size{
//-(void *)memBlock:(long *)size{
	void * p;
	p = malloc(size);
	[memoryBlockPointers addPointer:p];
//	NSLog(@"addToMemoryBlock ...DONE\n");
	return p;
}

-(void)freeMemoryBlock{
	@try{
		int i=0;
		[memoryBlockPointers compact]; //Removes NULL values
		int total = memoryBlockPointers.count;
		//This iteration breaks, might be of freeing memory parts first, that store more memory parts -> try LIFO
		for (i=total-1; i>=0; i--) {
			void *seg = [memoryBlockPointers pointerAtIndex:i];
			free(seg);
			[memoryBlockPointers removePointerAtIndex:i];
		}
	}
	@catch (NSException *e){
		NSLog(@"Something went wrong while freeing memory\n");
	}
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
		for (i=total-1; i>0; i--) {
			void *seg = [memBlockPointers pointerAtIndex:i];
			//NSLog(@"free memory...i=%d / total=%d / seg=%p\n",i, total, seg);
			free(seg);
//			[seg release];
//			seg = nil;
			[memBlockPointers removePointerAtIndex:i];
		}
	}
	@catch (NSException *e){
		NSLog(@"Something went wrong while freeing memory\n");
	}
	NSLog(@"free memory - DONE\n");
//	memBlockPointers=nil;
//	[MemoryManagement initializeMemory];
//	[memBlockPointers release];
}
