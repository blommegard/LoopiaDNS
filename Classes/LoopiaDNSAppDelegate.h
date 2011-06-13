//
//  LoopiaDNSAppDelegate.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-02-25.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//
//  Modified by Björn Dahlgren 2011-06-13
//  Added support for multiple users
//

#import <Cocoa/Cocoa.h>

#import "SBLoopiaAPI.h"
#import "SBAddSubdomainWindowController.h"
#import "SBPreferencesWindowController.h"

@class SBDomainInfoWindowController;

@interface LoopiaDNSAppDelegate : NSObject <NSApplicationDelegate, SBLoopiaAPIDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource, SBAddSubdomainWindowControllerDelegate, SBPreferencesWindowControllerDelegate, NSTableViewDelegate, NSTableViewDataSource, NSUserInterfaceValidations> {
    NSWindow *window;
	
	NSMutableDictionary *userRPCs;
	NSMutableDictionary *domainRPCs;
	
	NSUndoManager *undoManager;
	
	NSMutableArray *domains;
	NSMutableDictionary *subdomains;
	NSMutableDictionary *selectedSubdomain;
	
	NSMutableArray *zoneRecords;
	
	NSString *externalIP;
	NSString *title;
	
	BOOL justAdded;
	NSString *justAddedSubdomain;
		
	IBOutlet NSOutlineView *domainOutlineView;
	IBOutlet NSButton *reloadDomainButton;
	IBOutlet NSButton *addDomainButton;
	IBOutlet NSButton *removeDomainButton;
	IBOutlet NSMenuItem *addDomainMenuItem;
	
	IBOutlet NSProgressIndicator *domainsProgressIndicator;
	
	IBOutlet NSTableView *zoneRecordTableView;
	IBOutlet NSCell *zoneRecordTableViewCellData;
	IBOutlet NSButton *reloadZoneRecordButton;
	IBOutlet NSButton *addZoneRecordButton;
	IBOutlet NSButton *removeZoneRecordButton;
	
	IBOutlet NSProgressIndicator *zoneRecordProgressIndicator;
	
	IBOutlet NSArrayController *zoneRecordArrayController;
	
	IBOutlet SBDomainInfoWindowController *domainInfoWindowController;
	
	//Add a Domain Sheet
	IBOutlet NSImageView *freeDomainImageView;
	IBOutlet NSProgressIndicator *freeDomainProgressIndicator;
	IBOutlet NSPopUpButton *freeDomainUserList;
	IBOutlet NSTextField *freeDomainTextField;
	IBOutlet NSButton *freeDomainBuyCheckBox;
	IBOutlet NSButton *freeDomainAddButton;
	IBOutlet NSButton *freeDomainCloseButton;
}

@property (assign) IBOutlet NSWindow *window;
@property (copy) NSMutableArray *zoneRecords;

#pragma mark -

- (void)addedUser:(NSString*)username password:(NSString*)password;
- (void)removedUsers:(NSArray*)users;

#pragma mark -

- (IBAction)showPreferences:(id)sender;

#pragma mark -

- (IBAction)checkAvailability:(id)sender;

- (IBAction)reloadDomain:(id)sender;

- (IBAction)addSubdomain:(id)sender;

- (IBAction)removeSubdomain:(id)sender;

- (IBAction)reloadZoneRecord:(id)sender;

- (IBAction)addZoneRecord:(id)sender;

- (IBAction)removeZoneRecord:(id)sender;

#pragma mark -

- (void)shouldSelectDomainItem:(id)item;

@end
