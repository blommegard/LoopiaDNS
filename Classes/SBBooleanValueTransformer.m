//
//  SBBooleanValueTransformer.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-04-06.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBBooleanValueTransformer.h"


@implementation SBBooleanValueTransformer

- (NSString *)transformedValue:(NSNumber *)value {
    return ([value boolValue]) ? @"Yes" : @"No";
}

@end
