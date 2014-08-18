//
//  AKTownshipRange.m
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

#import "AKTownshipRange.h"

@implementation AKTownshipRange

@synthesize statusString = _statusString;

#define stateStringKey           @"townshipRangeKeyStateString"
#define principalMeridianCodeKey @"townshipRangeKeyPrincipalMeridianCode"
#define principalMeridianNameKey @"townshipRangeKeyPrincipalMeridianName"
#define townshipNumberKey        @"townshipRangeKeyTownshipNumber"
#define townshipFractionKey      @"townshipRangeKeyTownshipFraction"
#define townshipDirectionKey     @"townshipRangeKeyTownshipDirection"
#define rangeNumberKey           @"townshipRangeKeyRangeNumber"
#define rangeFractionKey         @"townshipRangeKeyRangeFraction"
#define rangeDirectionKey        @"townshipRangeKeyRangeDirection"
#define sectionNumberKey         @"townshipRangeKeySectionNumber"
#define sectionDivisionKey       @"townshipRangeKeySectionDivision"
#define townshipDuplicateCodeKey @"townshipRangeKeyTownshipDuplicateCode"
#define isValidKey               @"townshipRangeKeyIsValid"
#define statusStringKey          @"townshipRangeKeyStatusString"

-(id)init
{
    self = [super init];
    if (self)
    {
        _sectionDivision = @"";
        _townshipDuplicateCode = @"";
        _isValid = false;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self)
    {
        self.stateAbbreviation     = [aDecoder decodeObjectForKey:stateStringKey          ];
        self.principalMeridianCode = [aDecoder decodeIntForKey   :principalMeridianCodeKey];
        self.principalMeridianName = [aDecoder decodeObjectForKey:principalMeridianNameKey];
        self.townshipNumber        = [aDecoder decodeIntForKey   :townshipNumberKey       ];
        self.townshipFraction      = [aDecoder decodeIntForKey   :townshipFractionKey     ];
        self.townshipDirection     = [aDecoder decodeIntForKey   :townshipDirectionKey    ];
        self.rangeNumber           = [aDecoder decodeIntForKey   :rangeNumberKey          ];
        self.rangeFraction         = [aDecoder decodeIntForKey   :rangeFractionKey        ];
        self.rangeDirection        = [aDecoder decodeIntForKey   :rangeDirectionKey       ];
        self.section               = [aDecoder decodeIntForKey   :sectionNumberKey        ];
        self.sectionDivision       = [aDecoder decodeObjectForKey:sectionDivisionKey      ];
        self.townshipDuplicateCode = [aDecoder decodeObjectForKey:townshipDuplicateCodeKey];
        self.isValid               = [aDecoder decodeBoolForKey  :isValidKey              ];
        self.statusString          = [aDecoder decodeObjectForKey:statusStringKey         ];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.stateAbbreviation     forKey:stateStringKey          ];
    [aCoder encodeInt   :self.principalMeridianCode forKey:principalMeridianCodeKey];
    [aCoder encodeObject:self.principalMeridianName forKey:principalMeridianNameKey];
    [aCoder encodeInt   :self.townshipNumber        forKey:townshipNumberKey       ];
    [aCoder encodeInt   :self.townshipFraction      forKey:townshipFractionKey     ];
    [aCoder encodeInt   :self.townshipDirection     forKey:townshipDirectionKey    ];
    [aCoder encodeInt   :self.rangeNumber           forKey:rangeNumberKey          ];
    [aCoder encodeInt   :self.rangeFraction         forKey:rangeFractionKey        ];
    [aCoder encodeInt   :self.rangeDirection        forKey:rangeDirectionKey       ];
    [aCoder encodeInt   :self.section               forKey:sectionNumberKey        ];
    [aCoder encodeObject:self.sectionDivision       forKey:sectionDivisionKey      ];
    [aCoder encodeObject:self.townshipDuplicateCode forKey:townshipDuplicateCodeKey];
    [aCoder encodeBool  :self.isValid               forKey:isValidKey              ];
    [aCoder encodeObject:self.statusString          forKey:statusStringKey         ];
}

#pragma mark - Township Direction

-(void) setTownshipDirection:(townshipDirection)townshipDirection
{
    _townshipDirection = townshipDirection;
    
    if (townshipDirection == townshipDirectionNorth)      _townshipDirectionString = @"N";
    else if (townshipDirection == townshipDirectionSouth) _townshipDirectionString = @"S";
}

-(townshipDirection)townshipDirection { return _townshipDirection;       }

-(NSString*)townshipDirectionString   { return _townshipDirectionString; }

#pragma mark - Range Direction

-(void) setRangeDirection:(rangeDirection)rangeDirection
{
    _rangeDirection = rangeDirection;
    
    if (rangeDirection == rangeDirectionEast)      _rangeDirectionString = @"E";
    else if (rangeDirection == rangeDirectionWest) _rangeDirectionString = @"W";
}

-(rangeDirection)rangeDirection  { return _rangeDirection;       }

-(NSString*)rangeDirectionString { return _rangeDirectionString; }

-(void)setStatusString:(NSString *)statusString
{
    _statusString = statusString;
}

-(NSString*)statusString
{
    return _statusString;
}

@end