//
//  SBAddSubdomainWindowController.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-04.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBAddSubdomainWindowController;

@protocol SBAddSubdomainWindowControllerDelegate <NSObject>

@optional

- (void)addSubdomainWindowController:(SBAddSubdomainWindowController *)addSubdomainWindowController didAddSubdomain:(NSString *)subdomain toDomain:(NSString *)domain;

- (void)addSubdomainWindowControllerDidCancel:(SBAddSubdomainWindowController *)addSubdomainWindowController;

@end

#pragma mark -

@interface SBAddSubdomainWindowController : NSWindowController {
	IBOutlet NSTextField *domainTextField;
	IBOutlet NSTextField *subdomainTextField;
	
	NSString *domainString;
	
	id <SBAddSubdomainWindowControllerDelegate> delegate;
}

@property (nonatomic, assign) id <SBAddSubdomainWindowControllerDelegate> delegate;

#pragma mark -

- (IBAction)addSubdomain:(id)sender;
- (IBAction)cancel:(id)sender;

#pragma mark -
- (id)initWithDomain:(NSString *)domain;
- (void)showSheetWithParent:(NSWindow *)window;

@end
