//
//  SBZoneRecordDataFormatter.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-16.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBZoneRecordDataFormatter.h"

@implementation SBZoneRecordDataFormatter

@synthesize type;

- (NSString *)stringForObjectValue:(id)anObject {
	return [anObject description];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	*anObject = string;
	return YES;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
	return [[[NSAttributedString alloc] initWithString:[self stringForObjectValue:[anObject description]] attributes:attributes] autorelease];
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error {
	switch (type) {
		case SBZoneRecordDataFormatterTypeA: {
			*newString = nil;
			NSArray *parts = [partialString componentsSeparatedByString:@"."];
			
			if ([parts count] > 4) return NO;
			
			NSCharacterSet *validCharacters = [NSCharacterSet characterSetWithRange:NSMakeRange('0', 10)];
			
			for(NSString *part in parts) {
				if ([[part stringByTrimmingCharactersInSet:validCharacters] length]) return NO;
				if ([part intValue] > 255) return NO;
			}
			
			break;
		}
		case SBZoneRecordDataFormatterTypeAAAA: {
			*newString = nil;
			NSArray *parts = [partialString componentsSeparatedByString:@":"];
			
			NSCharacterSet *validCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef:"];
			
			for(NSString *part in parts) {
				if ([[part stringByTrimmingCharactersInSet:validCharacters] length]) return NO;
			}
			
			break;
		}
		default:
			break;
	}

	return YES;
}

- (void)setNilValueForKey:(NSString *)key {
	if([key isEqualToString:@"type"]) {
		type = 0;
	}
}

@end
