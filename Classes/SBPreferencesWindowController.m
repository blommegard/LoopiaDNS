//
//  SBPreferencesWindowController.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-24.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//
//  Modified by Björn Dahlgren 2011-06-13
//  Added support for multiple users
//

#import "SBPreferencesWindowController.h"

@implementation SBPreferencesWindowController

@synthesize delegate, userArrayController, usersTableView;

- (id)init {
	[super initWithWindowNibName:@"SBPreferencesWindow"];
	return self;
}

#pragma mark User actions

- (IBAction)addUser:(id)sender {
    SBAuthWindowController *authWindowController = [[SBAuthWindowController alloc] init];
	[authWindowController setDelegate:self];
	[authWindowController showSheetWithParent:self.window];
}

- (IBAction)removeUsers:(id)sender {
	NSMutableArray *users = [NSMutableArray arrayWithCapacity:10];
	NSIndexSet *selectedIndexes = [usersTableView selectedRowIndexes];
	
	[selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[users addObject:[[userArrayController arrangedObjects] objectAtIndex:idx]];
	}];
		
	[userArrayController removeObjectsAtArrangedObjectIndexes:selectedIndexes];
	
    [delegate removedUsers:users];
}

#pragma mark SBAuthWindowControllerDelegate

- (void)authWindowController:(SBAuthWindowController *)authWindowController didAuthenticatewithUsername:(NSString *)username password:(NSString *)password {
	[userArrayController addObject:username];
	
	[delegate addedUser:username password:password];
}

@end
