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


#import "cubePixel.h"
#include<math.h>
#include <stdlib.h>
#include <Foundation/Foundation.h>  
#include <stdio.h>

@implementation CubePixel
@synthesize red = _red;
@synthesize green = _green;
@synthesize blue = _blue;


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Add init here
		self.red=0.0;
		self.green=0.0;
		self.blue=0.0;
    }
    return self;
}

- (id)zeros
{
NSLog(@"entered zeros");
    if (self != nil)
    {
        // Add init here
		self.red=0.0;
		self.green=0.0;
		self.blue=0.0;
    }
NSLog(@"zeros DONE");
    return self;
}

- (void)dealloc
{
    self.red = 0.0;
    self.green = 0.0;
    self.blue = 0.0;
	self=nil;
    [super dealloc];
}



@end