//
//  LoopiaDNSAppDelegate.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-02-25.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SBLoopiaAPI.h"
#import "SBAuthWindowController.h"
#import "SBAddSubdomainWindowController.h"

@class SBDomainInfoWindowController;

@interface LoopiaDNSAppDelegate : NSObject <NSApplicationDelegate, SBLoopiaAPIDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource, SBAuthWindowControllerDelegate, SBAddSubdomainWindowControllerDelegate, NSTableViewDelegate, NSTableViewDataSource, NSUserInterfaceValidations> {
    NSWindow *window;
	
	SBLoopiaAPI *RPC;
	
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
	IBOutlet NSTextField *freeDomainTextField;
	IBOutlet NSButton *freeDomainBuyCheckBox;
	IBOutlet NSButton *freeDomainAddButton;
	IBOutlet NSButton *freeDomainCloseButton;
}

@property (assign) IBOutlet NSWindow *window;
@property (copy) NSMutableArray *zoneRecords;

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
