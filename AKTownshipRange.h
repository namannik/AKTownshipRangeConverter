//
//  AKTownshipRange.h
//
//  Created by Alan Kinnaman on 5/11/14.
//  Copyright (c) 2014 AlanKinnaman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

typedef enum
{
    fractionalTownshipRangeNone          = 0,
    fractionalTownshipRangeOneQuarter    = 1,
    fractionalTownshipRangeOneHalf       = 2,
    fractionalTownshipRangeThreeQuarters = 3
} fractionalTownshipRange;

typedef enum
{
    townshipDirectionNorth,
    townshipDirectionSouth,
} townshipDirection;

typedef enum
{
    rangeDirectionEast,
    rangeDirectionWest,
} rangeDirection;

@interface AKTownshipRange : NSObject <NSCoding>

{
    townshipDirection _townshipDirection;
    NSString *_townshipDirectionString;
    
    rangeDirection _rangeDirection;
    NSString *_rangeDirectionString;
}

@property (nonatomic, strong) NSString *stateAbbreviation;
@property (nonatomic, strong) NSString *stateName;
@property int principalMeridianCode;
@property (nonatomic, strong) NSString *principalMeridianName;

@property int townshipNumber;
@property fractionalTownshipRange townshipFraction;
@property townshipDirection townshipDirection;
@property (readonly) NSString *townshipDirectionString;

@property int rangeNumber;
@property fractionalTownshipRange rangeFraction;
@property rangeDirection rangeDirection;
@property (readonly) NSString *rangeDirectionString;

@property int section; // 1 to 36
@property NSString *sectionDivision;
@property NSString *townshipDuplicateCode;

@end
