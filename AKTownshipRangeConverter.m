//
//  AKTownshipRangeConverter.m
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

#import "AKTownshipRangeConverter.h"

@implementation AKTownshipRangeConverter

static NSString * const townshipGeocoderURL = @"http://www.geocommunicator.gov/TownshipGeocoder/TownshipGeocoder.asmx";
static NSString * const getLatLonPath       = @"GetLatLon"   ;
static NSString * const getTRSPath          = @"GetTRS"      ;
static NSString * const getStateListPath    = @"GetStateList";
static NSString * const getPMListPath       = @"GetPMList"   ;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Perform custom initialization.
    }
    return self;
}

+ (AKTownshipRangeConverter *)sharedConverter
{
    static AKTownshipRangeConverter *sharedConverter = nil;
    if (!sharedConverter) sharedConverter = [[super allocWithZone:nil]init];
    return sharedConverter;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedConverter];
}

#pragma mark - XML Parsing

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    xmlLatLon = [NSMutableDictionary dictionary];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElementName = qName;
    currentDictionary = [NSMutableDictionary dictionary];
    outstring = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!currentElementName) return;
    [outstring appendFormat:@"%@", string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *value = [outstring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // The TownshipGeocoder Web Service returns XML data.
    // Within the XML, a block of GeoRSS XML is contained with the <Data> tag.
    // So, there are two XML parsers being used here:
    // one for the overall result, and one for the <Data> tag.
    
    // Parser for the overall XML:
    if (parser == townshipGeocoderResultParser)
    {
        if ([qName isEqualToString:@"CompletionStatus"])
        {
            if ([value isEqualToString:@"true"]) _completionStatus = true;  // Valid request
            else                                 _completionStatus = false; // Invalid request
        }
        else if ([qName isEqualToString:@"Message"]) _message = value; // "Ok" or error message
        else if ([qName isEqualToString:@"Data"])    _data    = value; // GeoRSS
    }
    
    // Parser for the GeoRSS XML in the <Data> tag:
    else if (parser == dataParser)
    {
        // Save the title of the current section of XML:
        if ([qName isEqualToString:@"title"]) currentTitle = value;
        
        // Parse the coordinate:
        else if ([qName isEqualToString:@"georss:point"])
        {
            NSArray *coordinates = [value componentsSeparatedByString:@" "];
            // TO DO: CONVERT COORDINATE FROM WGS84 TO NAD83.
            double lat = [[coordinates objectAtIndex:1] doubleValue];
            double lon = [[coordinates objectAtIndex:0] doubleValue];
            _location = nil;
            _location = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
        }
        
        // Parse township, range, section, etc.:
        else if ([qName isEqualToString:@"description"] &&
                 ([currentTitle isEqualToString:@"Township Range Section"]))
        {
            NSArray *trsComponents = [value componentsSeparatedByString:@","];
            
            _townshipRange = nil;
            _townshipRange = [[AKTownshipRange alloc]init];
            
            _townshipRange.stateAbbreviation     = [ trsComponents objectAtIndex:0];
            _townshipRange.principalMeridianCode = (int) [[trsComponents objectAtIndex:1] integerValue];

            _townshipRange.townshipNumber        = (int) [[trsComponents objectAtIndex:2] integerValue];
            _townshipRange.townshipFraction      = (int) [[trsComponents objectAtIndex:3] integerValue];
            NSString *townshipDirectionString    = [ trsComponents objectAtIndex:4];
            
            _townshipRange.rangeNumber           = (int) [[trsComponents objectAtIndex:5] integerValue];
            _townshipRange.townshipFraction      = (int) [[trsComponents objectAtIndex:6] integerValue];
            NSString *rangeDirectionString       = [ trsComponents objectAtIndex:7];
            
            _townshipRange.section               = (int) [[trsComponents objectAtIndex:8] integerValue];
            _townshipRange.sectionDivision       = [ trsComponents objectAtIndex:9];
            _townshipRange.townshipDuplicateCode = [ trsComponents objectAtIndex:10];
            
            if      ([townshipDirectionString isEqualToString:@"N"]) _townshipRange.townshipDirection = townshipDirectionNorth;
            else if ([townshipDirectionString isEqualToString:@"S"]) _townshipRange.townshipDirection = townshipDirectionSouth;
            
            if      ([rangeDirectionString    isEqualToString:@"E"]) _townshipRange.rangeDirection    = rangeDirectionEast;
            else if ([rangeDirectionString    isEqualToString:@"W"]) _townshipRange.rangeDirection    = rangeDirectionWest;
        }
        
        // Parse polygon coordinates:
        else if ([qName isEqualToString:@"georss:polygon"])
        {
            NSArray *polygonStrings = [value componentsSeparatedByString:@","];
            _polygon = nil;
            _polygon = [[NSMutableArray alloc]init];
            
            for (int i=0; i<[polygonStrings count]; i+=2)
            {
                double lat = [[polygonStrings objectAtIndex:i  ] doubleValue];
                double lon = [[polygonStrings objectAtIndex:i+1] doubleValue];
                CLLocation *coordinate = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
                [_polygon addObject:coordinate];
            }
        }
    }
}

#pragma mark - Data Retrieval

- (void)getDataWithURL:(NSString*)urlString
            completion:(void (^)(void))completion
               failure:(void (^)(NSString *failureDescription))failure
{    
    // Send request:
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parse response:
        townshipGeocoderResultParser = (NSXMLParser *)responseObject;
        townshipGeocoderResultParser.shouldProcessNamespaces = YES;
        townshipGeocoderResultParser.delegate = self;
        if ([townshipGeocoderResultParser parse])
        {
            if (_completionStatus)
            {                
                if ([_data rangeOfString:@"georss"].location != NSNotFound)
                {
                    // Parse the GeoRSS XML within the response:
                    dataParser = [[NSXMLParser alloc]initWithData:[_data dataUsingEncoding:NSUTF8StringEncoding]];
                    dataParser.shouldProcessNamespaces = YES;
                    dataParser.delegate = self;
                    if ([dataParser parse]) completion();
                    else failure([[dataParser parserError] localizedDescription]);
                }
                else if ([_data rangeOfString:@" - "].location != NSNotFound)
                {
                    // Parse meridian list:
                    NSArray *meridians = [_data componentsSeparatedByString:@","];
                    
                    _meridians = nil;
                    _meridians = [[NSMutableDictionary alloc]init];
                    
                    for (NSString *meridianString in meridians)
                    {
                        NSArray *meridianComponents = [meridianString componentsSeparatedByString:@" - "];
                        int meridianNumber = [[meridianComponents objectAtIndex:0] intValue];
                        [_meridians setObject:[meridianComponents objectAtIndex:1] forKey:[NSNumber numberWithInt:meridianNumber]];
                    }
                    completion();
                }
                else
                {
                    // Parse state list.
                    // TO DO.
                }
            }
            else failure(_message);
        }
        else failure([[townshipGeocoderResultParser parserError] localizedDescription]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure([error localizedDescription]);
    }];
    
    [operation start];
}

#pragma mark - Conversions

- (void)coordinateForTownshipRange:(AKTownshipRange*)townshipRange
                        completion:(void (^)(CLLocation *location, NSArray *polygon))completion
                           failure:(void (^)(NSString *failureDescription))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?TRS=%@,%i,%i,%i,%@,%i,%i,%@,%i,%@,%@",
                           townshipGeocoderURL,
                           getLatLonPath,
                           townshipRange.stateAbbreviation,
                           townshipRange.principalMeridianCode,
                           
                           townshipRange.townshipNumber,
                           townshipRange.townshipFraction,
                           townshipRange.townshipDirectionString,
                           
                           townshipRange.rangeNumber,
                           townshipRange.rangeFraction,
                           townshipRange.rangeDirectionString,
                           
                           townshipRange.section,
                           townshipRange.sectionDivision,
                           townshipRange.townshipDuplicateCode];
    
    [self getDataWithURL:urlString
              completion:^{
                  
                  completion(_location, _polygon);
                  
              } failure:^(NSString *failureDescription) {
                  failure(failureDescription);
              }];
}

- (void)townshipRangeForLocation:(CLLocation*)location
                      completion:(void (^)(AKTownshipRange *townshipRange, NSArray *polygon))completion
                         failure:(void (^)(NSString *failureDescription))failure
{
    // TO DO: CONVERT COORDINATE FROM NAD83 TO WGS84.
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?Lat=%f&Lon=%f&Units=eDD&Datum=NAD83",
                           townshipGeocoderURL,
                           getTRSPath,
                           location.coordinate.latitude,
                           location.coordinate.longitude];
    
    [self getDataWithURL:urlString
              completion:^{
                  
                  [self meridianNameForCode:_townshipRange.principalMeridianCode
                          stateAbbreviation:_townshipRange.stateAbbreviation
                                 completion:^(NSString *meridianName) {
                                     
                                     _townshipRange.principalMeridianName = meridianName;
                                     completion(_townshipRange, _polygon);
                                    
                                 } failure:^(NSString *failureDescription) {
                                     failure(failureDescription);
                                 }];
                  
              } failure:^(NSString *failureDescription) {
                  failure(failureDescription);
              }];
}

# pragma mark - Principal Meridian Retrieval

- (void)meridianNameForCode:(int)code
          stateAbbreviation:(NSString*)stateAbbreviation
                 completion:(void (^)(NSString *meridianName))completion
                    failure:(void (^)(NSString *failureDescription))failure
{
    [self meridiansForState:stateAbbreviation
                 completion:^(NSDictionary *meridians) {
                     
                     completion( [meridians objectForKey:[NSNumber numberWithInt:code]] );
                     
                 } failure:^(NSString *failureDescription) {
                     failure(failureDescription);
                 }];
}

- (void)meridiansForState:(NSString*)stateAbbreviation
               completion:(void (^)(NSDictionary *meridians))completion
                  failure:(void (^)(NSString *failureDescription))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?StateAbbrev=%@",
                           townshipGeocoderURL,
                           getPMListPath,
                           stateAbbreviation];
    
    [self getDataWithURL:urlString
              completion:^{
                  
                  completion(_meridians);
                  
              } failure:^(NSString *failureDescription) {
                  failure(failureDescription);
              }];
}

@end
