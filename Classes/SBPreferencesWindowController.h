//
//  SBPreferencesWindowController.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-24.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//
//  Modified by Björn Dahlgren 2011-06-13
//  Added support for multiple users
//

#import <Cocoa/Cocoa.h>

#import "SBAuthWindowController.h"

@class SBPreferencesWindowController;

@protocol SBPreferencesWindowControllerDelegate <NSObject>

@optional

- (void)addedUser:(NSString*)username password:(NSString*)password;
- (void)removedUsers:(NSArray*)users;

@end

@interface SBPreferencesWindowController : NSWindowController <SBAuthWindowControllerDelegate> {
    IBOutlet NSArrayController *userArrayController;
	IBOutlet NSTableView *usersTableView;
    
    id <SBPreferencesWindowControllerDelegate> delegate;
}

@property (nonatomic, assign) id <SBPreferencesWindowControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet NSArrayController *userArrayController;
@property (retain, nonatomic) IBOutlet NSTableView *usersTableView;

- (IBAction)addUser:(id)sender;
- (IBAction)removeUsers:(id)sender;

@end
