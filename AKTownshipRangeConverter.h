//
//  AKTownshipRangeConverter.h
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

// This Objective-C class is a wrapper around the Township Geocoder web service,
// which provided by the United States Bureau of Land Management GeoCommunicator.
//
// This class was not developed, nor is it maintained by, the United States Bureau of Land Management.
//
// Township Geocoder Home Page:
//   http://www.geocommunicator.gov/GeoComm/lsis_home/townshipdecoder/index.htm
//
// Township Geocoder Formatting Guide:
//   http://www.geocommunicator.gov/GeoComm/reference/GeoCommunicator_Web_Services_TGC_Formats.pdf
//
// Township Geocoder Web Service URL:
//    http://www.geocommunicator.gov/TownshipGeocoder/TownshipGeocoder.asmx
//
// BLM GeoCommunicator Data Disclaimer:
//    http://www.geocommunicator.gov/GeoComm/GC_disclaimer.htm
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import "AKTownshipRange.h"

@interface AKTownshipRangeConverter : NSObject <NSXMLParserDelegate>

{
    NSMutableDictionary *currentDictionary;
    NSMutableDictionary *xmlLatLon;
    NSString *currentElementName;
    NSString *currentTitle;
    NSMutableString *outstring;
    
    NSXMLParser *townshipGeocoderResultParser;
    NSXMLParser *dataParser;
    
    BOOL _completionStatus;
    NSString *_message;
    NSString *_data;

    CLLocation *_location;
    AKTownshipRange *_townshipRange;
    NSMutableArray *_polygon;
    NSMutableDictionary *_meridians;
}

+ (AKTownshipRangeConverter *)sharedConverter;

// Convert township/range to a coordinate.
- (void)coordinateForTownshipRange:(AKTownshipRange*)townshipRange
                        completion:(void (^)(CLLocation *location, NSArray *polygon))completion
                           failure:(void (^)(NSString *failureDescription))failure;

// Convert a coordinate to a township/range.
- (void)townshipRangeForLocation:(CLLocation*)location
                      completion:(void (^)(AKTownshipRange *townshipRange, NSArray *polygon))completion
                         failure:(void (^)(NSString *failureDescription))failure;

// Get the name of the meridian for the specified code and state abbreviation.
- (void)meridianNameForCode:(int)code
          stateAbbreviation:(NSString*)stateAbbreviation
                 completion:(void (^)(NSString *meridianName))completion
                    failure:(void (^)(NSString *failureDescription))failure;

// Get the meridians for the specified state abbreviation.
// The dictionary returned in the completion block uses the meridian code as an NSNumber for the key.
- (void)meridiansForState:(NSString*)stateAbbreviation
               completion:(void (^)(NSDictionary *meridians))completion
                  failure:(void (^)(NSString *failureDescription))failure;

@end
