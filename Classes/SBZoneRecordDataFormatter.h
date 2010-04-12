//
//  SBZoneRecordDataFormatter.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-16.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	SBZoneRecordDataFormatterTypeA,
	SBZoneRecordDataFormatterTypeAAAA
} SBZoneRecordDataFormatterType;


@interface SBZoneRecordDataFormatter : NSFormatter {
	SBZoneRecordDataFormatterType type;
}

@property () SBZoneRecordDataFormatterType type;

@end
