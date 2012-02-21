//
//  SBAddSubdomainWindowController.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-04.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBAddSubdomainWindowController.h"
#import <SBPunyCode/SBPunyCode.h>

@implementation SBAddSubdomainWindowController

@synthesize delegate;

#pragma mark -

- (id)initWithDomain:(NSString *)domain {
	[super initWithWindowNibName:@"SBAddSubdomainWindow"];
	domainString = [domain copy];
	return self;
}

- (void)loadWindow {
	[super loadWindow];
	[domainTextField setStringValue:[NSString stringWithFormat:@".%@", [domainString stringFromIDN]]];
}

#pragma mark -

- (IBAction)addSubdomain:(id)sender {
	//Disappear..
	[NSApp endSheet:[self window]];
	[[self window] orderOut:nil];
	
	//Message delegate..
    if ([self.delegate respondsToSelector:@selector(addSubdomainWindowController:didAddSubdomain:toDomain:)])
        [[self delegate] addSubdomainWindowController:self didAddSubdomain:[[subdomainTextField stringValue] stringToIDN] toDomain:domainString];
}
- (IBAction)cancel:(id)sender {	
	//Disappear..
	[NSApp endSheet:[self window]];
	[[self window] orderOut:nil];
	
	//Message delegate..
    if ([self.delegate respondsToSelector:@selector(addSubdomainWindowControllerDidCancel:)])
        [[self delegate] addSubdomainWindowControllerDidCancel:self];
}

#pragma mark -

- (void)showSheetWithParent:(NSWindow *)window {
	[NSApp beginSheet:[self window] modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
