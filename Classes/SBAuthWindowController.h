//
//  SBAuthWindowController.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-04.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBAuthWindowController;

@protocol SBAuthWindowControllerDelegate <NSObject>

@optional

- (void)authWindowController:(SBAuthWindowController *)authWindowController didAuthenticatewithUsername:(NSString *)username password:(NSString *)password;

- (void)authWindowControllerDidCancel:(SBAuthWindowController *)authWindowController;

@end

#pragma mark -

@interface SBAuthWindowController : NSWindowController {
	IBOutlet NSTextField *APIUserTextField;
	IBOutlet NSTextField *APIPasswordTextField;
	
	id <SBAuthWindowControllerDelegate> delegate;
}

@property (nonatomic, assign) id <SBAuthWindowControllerDelegate> delegate;

#pragma mark -

- (IBAction)authenticate:(id)sender;
- (IBAction)cancel:(id)sender;

#pragma mark -

- (void)showSheetWithParent:(NSWindow *)window;

@end
