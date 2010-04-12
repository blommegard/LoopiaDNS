//
//  SBPunyCodeValueTransformer.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-04-07.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBPunyCodeValueTransformer.h"

#import <SBPunyCode/SBPunyCode.h>

@implementation SBPunyCodeValueTransformer

- (NSString *)transformedValue:(NSString *)value {
	return [value stringFromIDN];
}

@end
