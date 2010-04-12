//
//  SBDomainInfoWindowController.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-04-04.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBDomainInfoWindowController.h"


@implementation SBDomainInfoWindowController

@synthesize domainInfo;

- (id)init {
	[super initWithWindowNibName:@"SBDomainInfoWindow"];
	return self;
}

@end
