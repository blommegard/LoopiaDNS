//
//  SBDomainInfoWindowController.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-04-04.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SBDomainInfoWindowController : NSWindowController {
	NSDictionary *domainInfo;
}

@property(retain) NSDictionary *domainInfo;

@end
