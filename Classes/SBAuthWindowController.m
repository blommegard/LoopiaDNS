//
//  SBAuthWindowController.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-04.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBAuthWindowController.h"
#import "EMKeychainItem.h"

@implementation SBAuthWindowController

@synthesize delegate;

#pragma mark -

- (id)init {
	[super initWithWindowNibName:@"SBAuthWindow"];
	return self;
}

- (void)loadWindow {
	[super loadWindow];
}
		 
#pragma mark -

- (IBAction)authenticate:(id)sender {
	EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"LoopiaDNS" withUsername:[APIUserTextField stringValue]];
	if (!keychainItem) {
		//Add to keychain..
		[EMGenericKeychainItem addGenericKeychainItemForService:@"LoopiaDNS" withUsername:[APIUserTextField stringValue] password:[APIPasswordTextField stringValue]];
		
	} else {
		//Update keychain..
		[keychainItem setUsername:[APIUserTextField stringValue]];
		[keychainItem setPassword:[APIPasswordTextField stringValue]];
	}
	
	//Disappear..
	[NSApp endSheet:[self window]];
	[[self window] orderOut:nil];
	
	//Message delegate..
    if ([self.delegate respondsToSelector:@selector(authWindowController:didAuthenticatewithUsername:password:)])
        [[self delegate] authWindowController:self didAuthenticatewithUsername:[APIUserTextField stringValue] password:[APIPasswordTextField stringValue]];
}
- (IBAction)cancel:(id)sender {	
	//Disappear..
	[NSApp endSheet:[self window]];
	[[self window] orderOut:nil];
	
	//Message delegate..
    if ([self.delegate respondsToSelector:@selector(authWindowControllerDidCancel:)])
        [[self delegate] authWindowControllerDidCancel:self];
}

#pragma mark -

- (void)showSheetWithParent:(NSWindow *)window {
	[NSApp beginSheet:[self window] modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
