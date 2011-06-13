//
//  LoopiaDNSAppDelegate.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-02-25.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//
//  Modified by Björn Dahlgren 2011-06-13
//  Added support for multiple users
//

#import <BWToolkitFramework/BWToolkitFramework.h>
#import <SBPunyCode/SBPunyCode.h>

#import "LoopiaDNSAppDelegate.h"
#import "SBLoopiaZoneRecord.h"
#import "EMKeychainItem.h"
#import "LHURLAccess.h"
#import "SBZoneRecordDataFormatter.h"
#import "SBDomainInfoWindowController.h"

@implementation LoopiaDNSAppDelegate

@synthesize window, zoneRecords;

#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	//UI Setup..
	[freeDomainAddButton setEnabled:NO];
	[addDomainButton setEnabled:NO];
	[removeDomainButton setEnabled:NO];
	
	[addZoneRecordButton setEnabled:NO];
	[removeZoneRecordButton setEnabled:NO];
	[reloadZoneRecordButton setEnabled:NO];
	
	//Get title
	title = [window title];
	
	//Get external IP
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"http://simonb.se/ip/" forKey:@"SBLoopiaAPIIPLookupDomain"]];
	[LHURLAccess fetchURL:[NSURL URLWithString:[defaults valueForKey:@"SBLoopiaAPIIPLookupDomain"]] withType:LHURLAccessTypeString onCompletion:^(id data, NSURLResponse *response, NSError *error) {
		externalIP = data;
	}];
	
	subdomains = [NSMutableDictionary dictionary];
	justAdded = NO;
	
	//The array we use for our Array Controller, adding KVO..
	[self addObserver:self forKeyPath:@"zoneRecords" options:NSKeyValueObservingOptionOld context:nil];
	
	//Set the data-formatter..
	SBZoneRecordDataFormatter *zoneRecordDataFormatter = [[SBZoneRecordDataFormatter alloc] init];
	[zoneRecordTableViewCellData setFormatter:zoneRecordDataFormatter];
	[zoneRecordDataFormatter bind:@"type" toObject:zoneRecordArrayController withKeyPath:@"selection.typeIndex" options:nil];
	
	domains = [[NSMutableArray alloc] init];
	userRPCs = [[NSMutableDictionary alloc] init];
	domainRPCs = [[NSMutableDictionary alloc] init];
	NSArray *users = [defaults arrayForKey:@"SBLoopiaAPIUsers"];
	
	if (users == nil || [users count] == 0) {
		[self showPreferences:nil];
	}
		
	for (NSString* user in users) {
		// Get key for user
		EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"LoopiaDNS" withUsername:user];
		
		// If key is valid
		if ([keychainItem username] && [keychainItem password]) {
			// Create new RPC
			SBLoopiaAPI *rpc = [[SBLoopiaAPI alloc] initWithAPIUser:[keychainItem username] password:[keychainItem password]];
			[rpc setDelegate:self];
			
			// Add it in the user dictionary
			[userRPCs setValue:rpc forKey:user];
			
			[reloadDomainButton setEnabled:NO];
			[domainsProgressIndicator startAnimation:nil];
			[rpc getDomains];
		}
	}
}



- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	[window makeKeyAndOrderFront:nil];
	return YES;
}

#pragma mark IBActions

- (IBAction)showPreferences:(id)sender {
    SBPreferencesWindowController *preferencesWindowController = [[SBPreferencesWindowController alloc] init];
    [preferencesWindowController setDelegate:self];
    [preferencesWindowController.window makeKeyAndOrderFront:self];
}

- (IBAction)checkAvailability:(id)sender {
	[freeDomainImageView setImage:nil];
	[freeDomainProgressIndicator startAnimation:nil];
	[[userRPCs objectForKey:[freeDomainUserList titleOfSelectedItem]] domainIsFree:[freeDomainTextField stringValue]];
}

- (IBAction)reloadDomain:(id)sender {
	[reloadDomainButton setEnabled:NO];
	[domainsProgressIndicator startAnimation:nil];
	
	// Clear all domain data
	[domains removeAllObjects];
	[domainRPCs removeAllObjects];
	
	for (SBLoopiaAPI *rpc in [userRPCs allValues])
		[rpc getDomains];
}

- (IBAction)addSubdomain:(id)sender {
	
	//Works even with a subdomain selected thanks to the "domain"-key in our dicrionary..
	int row = [domainOutlineView selectedRow];
	NSDictionary *domain = [domainOutlineView itemAtRow:row];
	
	SBAddSubdomainWindowController *addSubdomainWindowController = [[SBAddSubdomainWindowController alloc] initWithDomain:[domain objectForKey:SBLoopiaDomainDomainKey]];
	[addSubdomainWindowController setDelegate:self];
	[addSubdomainWindowController showSheetWithParent:window];
}

- (IBAction)removeSubdomain:(id)sender {
	NSInteger row = [domainOutlineView selectedRow];
	NSDictionary *subdomain = [domainOutlineView itemAtRow:row];
	
	//Create an alert sheet..
	NSAlert *alert = [NSAlert alertWithMessageText:@"Remove Subdomain" defaultButton:@"Remove" alternateButton:@"Cancel" otherButton:nil 
						 informativeTextWithFormat:[NSString stringWithFormat:@"Do you really want to remove the subdomain: %@.%@", [[subdomain objectForKey:@"subdomain"] stringFromIDN], [[subdomain objectForKey:@"domain"] stringFromIDN]]];
	[alert setAlertStyle:NSCriticalAlertStyle];
	
	//Show the sheet..
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:(void *)CFRetain(subdomain)];
}

- (IBAction)reloadZoneRecord:(id)sender {
	[reloadZoneRecordButton setEnabled:NO];
	[zoneRecordProgressIndicator startAnimation:nil];
	
	NSString *domain = [selectedSubdomain objectForKey:@"domain"];
	[[domainRPCs objectForKey:domain] getZoneRecordsForDomain:domain subdomain:[selectedSubdomain objectForKey:@"subdomain"]];
}

- (IBAction)addZoneRecord:(id)sender {	
	//End any editing that is taking place..
	BOOL editingEnabled = [window makeFirstResponder:window];
	if (!editingEnabled) return;
	
	//Create, add and rearrange..
	SBLoopiaZoneRecord *loopiaZoneRecord = [[SBLoopiaZoneRecord alloc] init];
	
	//Custom IP?
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults valueForKey:@"SBLoopiaAPIDefaultZoneDataType"] == [NSNumber numberWithInt:1])
		[loopiaZoneRecord setData:[defaults valueForKey:@"SBLoopiaAPIDefaultZoneDataCustomIP"]];
	else
		[loopiaZoneRecord setData:externalIP];

	[zoneRecordArrayController addObject:loopiaZoneRecord];
	[zoneRecordArrayController rearrangeObjects];
	
	//Get the new object, mark it dirty and begin editing it..
	NSArray *a = [zoneRecordArrayController arrangedObjects];
	int row = [a indexOfObjectIdenticalTo:loopiaZoneRecord];
	
	[window setDocumentEdited:YES];
	
	[zoneRecordTableView editColumn:3 row:row withEvent:nil select:YES];
	
}

- (IBAction)removeZoneRecord:(id)sender {
	//End any editing that is taking place..
	BOOL editingEnabled = [window makeFirstResponder:window];
	if (!editingEnabled) return;
	
	[zoneRecordArrayController remove:nil];
}

#pragma mark NSAlertDelegate

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSDictionary *)contextInfo {
	CFRelease(contextInfo);

	//Remove..
	if (returnCode == NSAlertDefaultReturn) {
		[domainsProgressIndicator startAnimation:nil];
		NSString *domain = [contextInfo objectForKey:@"domain"];
		[[domainRPCs objectForKey:domain] removeSubdomain:[contextInfo objectForKey:@"subdomain"] forDomain:domain];
	}
}	 

#pragma mark BWSheetControllerDelegate

- (BOOL)shouldCloseSheet:(id)sender {
	if ([sender isEqualTo:freeDomainAddButton]) {
		SBLoopiaAPI *rpc = [userRPCs objectForKey:[freeDomainUserList titleOfSelectedItem]];
		NSString *domain = [freeDomainTextField stringValue];
		[domainsProgressIndicator startAnimation:nil];

		//Buy..
		if ([freeDomainBuyCheckBox state] == NSOnState) {
			[rpc addDomain:domain buy:YES];
		//..or just add it..
		} else {
			[rpc addDomain:domain buy:NO];
		}
	}
	
	//Clear the Sheet - option?
	[freeDomainTextField setStringValue:@""];
	[freeDomainImageView setImage:nil];
	
	return YES;
}

#pragma mark SBPreferencesWindowController

- (void)addedUser:(NSString*)username password:(NSString*)password {
	SBLoopiaAPI *rpc = [[SBLoopiaAPI alloc] initWithAPIUser:username password:password];
	[rpc setDelegate:self];
	[userRPCs setValue:rpc forKey:username];
	
	[reloadDomainButton setEnabled:NO];
	[domainsProgressIndicator startAnimation:nil];
	[rpc getDomains];
}

- (void)removedUsers:(NSArray*)users {
    for (NSString *user in users)
        [userRPCs removeObjectForKey:user];
    
    [self reloadDomain:nil];
}

#pragma mark SBAddSubdomainWindowControllerDomain

- (void)addSubdomainWindowController:(SBAddSubdomainWindowController *)addSubdomainWindowController didAddSubdomain:(NSString *)subdomain toDomain:(NSString *)domain {	
	
	[domainsProgressIndicator startAnimation:nil];
	[[domainRPCs objectForKey:domain] addSubdomain:subdomain toDomain:domain];
}

- (void)addSubdomainWindowControllerDidCancel:(SBAddSubdomainWindowController *)addSubdomainWindowController {}

#pragma mark KVO (ZoneRecords)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	switch ([[change objectForKey:@"kind"] integerValue]) {
		case NSKeyValueChangeSetting:
			break;
		case NSKeyValueChangeInsertion:
			break;
		case NSKeyValueChangeRemoval:
			//Remove the selected records from loopia..
			[zoneRecordProgressIndicator startAnimation:nil];
			for (SBLoopiaZoneRecord *zr in [change objectForKey:@"old"]) {
				//..but not if they are new..
				if (![zr ID]) {
					[window setDocumentEdited:NO];
					[zoneRecordProgressIndicator stopAnimation:nil];
					continue;
				}
					
				NSString *domain = [selectedSubdomain objectForKey:@"domain"];
				[[domainRPCs objectForKey:domain] removeZoneRecord:[zr ID] forDomain:domain subdomain:[selectedSubdomain objectForKey:@"subdomain"]];
			}
			break;
		case NSKeyValueChangeReplacement:
			break;
		default:
			break;
	}
}

#pragma mark NSTableViewDelegate

- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
	if ([tableView selectedRow] == -1) return proposedSelectionIndexes;
	
	SBLoopiaZoneRecord *loopiaZoneRecord = [zoneRecords objectAtIndex: [tableView selectedRow]];

	if (![loopiaZoneRecord dirty]) return proposedSelectionIndexes;
	
	[[zoneRecords objectAtIndex:[tableView selectedRow]] setDirty:NO];
	
	NSString *domain = [selectedSubdomain objectForKey:@"domain"];
	
	if ([loopiaZoneRecord ID]) {
		//Update the record..
		[zoneRecordProgressIndicator startAnimation:nil];
		[[domainRPCs objectForKey:domain] updateZoneRecord:loopiaZoneRecord forDomain:domain subdomain:[selectedSubdomain objectForKey:@"subdomain"]];
	} else {
		//Add the record..
		[zoneRecordProgressIndicator startAnimation:nil];
		[[domainRPCs objectForKey:domain] addZoneRecord:loopiaZoneRecord toDomain:domain subdomain:[selectedSubdomain objectForKey:@"subdomain"]];
	}
	
	return proposedSelectionIndexes;
}

#pragma mark NSTableViewDataSource

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	//dirty..
	[[zoneRecords objectAtIndex:rowIndex] setDirty:YES];
	[window setDocumentEdited:YES];
}

#pragma mark NSOutlineViewDataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (!item) {
		return [domains objectAtIndex:index];
	} else {
		return [[subdomains objectForKey:[item objectForKey:SBLoopiaDomainDomainKey]] objectAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if ([[item objectForKey:@"type"] isEqualTo:@"subdomain"]) {
		return NO;
	} else {
		return YES;
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (!item) {
		return [domains count];
	} else {
		return [[subdomains objectForKey:[item objectForKey:SBLoopiaDomainDomainKey]] count];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([[item objectForKey:@"type"] isEqualTo:@"subdomain"]) {
		return [[item objectForKey:@"subdomain"] stringFromIDN];
	} else {
		NSString *domain = [item objectForKey:SBLoopiaDomainDomainKey];
		return [domain stringFromIDN];
	}
}

#pragma mark NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	if ([[item objectForKey:@"type"] isEqualTo:@"subdomain"]) {
		return NO;
	} else {
		return YES;
	}	
}

- (void)outlineViewItemWillExpand:(NSNotification *)notification {
	[domainsProgressIndicator startAnimation:nil];
	NSString *domain = [[[notification userInfo] objectForKey:@"NSObject"] objectForKey:SBLoopiaDomainDomainKey];
	[[domainRPCs objectForKey:domain] getSubdomainsForDomain:domain];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	[self shouldSelectDomainItem:item];
	return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	if(justAdded) {
		justAdded = NO;
	}
	
	//No row selected..
	if ([[notification object] selectedRow] == -1) {
		[addDomainButton setEnabled:NO];
		[removeDomainButton setEnabled:NO];
		
		[addZoneRecordButton setEnabled:NO];
		[removeZoneRecordButton setEnabled:NO];
		[reloadZoneRecordButton setEnabled:NO];
	}
}

- (void)shouldSelectDomainItem:(id)item {
	//Enable buttons..
	[addDomainButton setEnabled:YES];
	//..if subdomain..
	if ([[item objectForKey:@"type"] isEqualTo:@"subdomain"]) {
		[removeDomainButton setEnabled:YES];
		[addZoneRecordButton setEnabled:YES];
		[removeZoneRecordButton setEnabled:YES];
		[reloadZoneRecordButton setEnabled:YES];
		
		selectedSubdomain = item;
		
		//Set title..
		[window setTitle:[NSString stringWithFormat:@"%@.%@ - %@", [[item objectForKey:@"subdomain"] stringFromIDN], [[item objectForKey:@"domain"] stringFromIDN], title]];
		
		//"pre-update" our KVO array..
		[self willChangeValueForKey:@"zoneRecords"];
		zoneRecords = [item objectForKey:@"zoneRecords"];
		[self didChangeValueForKey:@"zoneRecords"];
		
		//Update our KVO array for real..
		[zoneRecordProgressIndicator startAnimation:nil];
		NSString *domain = [item objectForKey:@"domain"];
		[[domainRPCs objectForKey:domain] getZoneRecordsForDomain:domain subdomain:[item objectForKey:@"subdomain"]];
	//..else if domain..
	} else {
		[removeDomainButton setEnabled:NO];
		
		//Set the correct domainfor the info window..
		[domainInfoWindowController setDomainInfo:item];
	}
}

#pragma mark NSUserInterfaceValidations

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem {
	//Our domain info menu item..
	if ([anItem action] == @selector(domainInfo:)) {
		
		int row = [domainOutlineView selectedRow];
		NSDictionary *item = [domainOutlineView itemAtRow:row];
		
		//Ugly hack for finding out if the selected item is a domain..
		if ([item objectForKey:SBLoopiaDomainReferenceNoKey]) {
			return YES;
		} else {
			return NO;
		}
	}

	return YES;
}

#pragma mark SBLoopiaXMLRPCDelegate

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI getDomainsDidFinishWithArray:(NSArray *)array {
	[domains addObjectsFromArray:array];
	
	[domains sortUsingComparator:^(id a, id b) { 
		return [[[a objectForKey:@"domain"] stringFromIDN] compare:[[b objectForKey:@"domain"] stringFromIDN]];
	}];
	
	for (NSDictionary *domainInfo in array)
		[domainRPCs setValue:loopiaAPI forKey:[domainInfo valueForKey:@"domain"]];
		
	[domainsProgressIndicator stopAnimation:nil];
	[domainOutlineView reloadData];
	[reloadDomainButton setEnabled:YES];
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI getSubdomainsForDomain:(NSString *)domain didFinishWithArray:(NSArray *)array {
	
	NSMutableArray *subdomainsArray = [NSMutableArray array];
	
	//In case we just added a new subdomain..
	NSDictionary *newSubdomain;

	for(NSString *subdomain in array) {
		NSMutableDictionary *subdomainDictionary = [NSMutableDictionary dictionary];
		[subdomainDictionary setObject:@"subdomain" forKey:@"type"];
		[subdomainDictionary setObject:domain forKey:@"domain"];
		[subdomainDictionary setObject:subdomain forKey:@"subdomain"];
		[subdomainDictionary setObject:[NSMutableArray array] forKey:@"zoneRecords"];
		
		//..create an reference to it..
		if(justAdded && [subdomain isEqualToString:justAddedSubdomain]) {
			newSubdomain = subdomainDictionary;
		}
		
		[subdomainsArray addObject:subdomainDictionary];
	}
	
	[subdomains setObject:subdomainsArray forKey:domain];

	[domainsProgressIndicator stopAnimation:nil];
	[domainOutlineView reloadData];
	
	//..and select it..
	if(justAdded) {
		justAdded = NO;

		int row = [domainOutlineView rowForItem:newSubdomain];
		[domainOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		[self shouldSelectDomainItem:newSubdomain];
	}
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI domain:(NSString *)domain isFreeDidFinishWithString:(NSString *)string {
	if ([string isEqualToString:SBLoopiaStatusDomainOccupied]) {
		[freeDomainImageView setImage:[NSImage imageNamed:@"Cross.png"]];
		[freeDomainAddButton setEnabled:YES];
	} else if ([string isEqualToString:SBLoopiaStatusBadIndata]) {
		[freeDomainImageView setImage:[NSImage imageNamed:@"Cross.png"]];
		[freeDomainAddButton setEnabled:NO];
	} else{
		[freeDomainImageView setImage:[NSImage imageNamed:@"Checkmark.png"]];
		[freeDomainAddButton setEnabled:YES];
	}
	[freeDomainProgressIndicator stopAnimation:nil];
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI removeSubdomain:(NSString *)subdomain forDomain:(NSString *)domain didFinishWithString:(NSString *)string {
	if (![string isEqualToString:SBLoopiaStatusOK]) {
		[[domainRPCs objectForKey:domain] getSubdomainsForDomain:domain];
	} else {
		//Remove from our model..
		for	(NSDictionary *subdomainDict in [[subdomains objectForKey:domain] copy]) {
			if ([[subdomainDict valueForKey:@"subdomain"] isEqualToString:subdomain]) {
				[[subdomains objectForKey:domain] removeObject:subdomainDict];
				break;
			}
		}
		
		[domainOutlineView reloadData];
		
		//.. and select a new row for real..
		int row = [domainOutlineView selectedRow];
		[self shouldSelectDomainItem:[domainOutlineView itemAtRow:row]];
		[domainsProgressIndicator stopAnimation:nil];
	}
}

#pragma mark TODO
- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI failedAuthenticateWithUsername:(NSString *)username password:(NSString *)password {
	//Create an alert sheet..
	NSAlert *alert = [NSAlert alertWithMessageText:@"Authentication failed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Login with user %@ failed.", username]];
	[alert setAlertStyle:NSCriticalAlertStyle];
	
	//Show the sheet..
	[alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	
	[alert release];
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI addSubdomain:(NSString *)subdomain toDomain:(NSString *)domain didFinishWithString:(NSString *)string {	
	//We have just added a new subdomain..
	justAdded = YES;
	justAddedSubdomain = subdomain;
	[[domainRPCs objectForKey:domain] getSubdomainsForDomain:domain];
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI getZoneRecordsForDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithArray:(NSArray *)array {
	[selectedSubdomain setObject:array forKey:@"zoneRecords"];
	
	[self willChangeValueForKey:@"zoneRecords"];
	zoneRecords = [selectedSubdomain objectForKey:@"zoneRecords"];
	[self didChangeValueForKey:@"zoneRecords"];
	
	[reloadZoneRecordButton setEnabled:YES];
	[zoneRecordProgressIndicator stopAnimation:nil];
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI removeZoneRecord:(NSInteger)recordID forDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithString:(NSString *)string {
	if (![string isEqualToString:SBLoopiaStatusOK]) {
		[[domainRPCs objectForKey:domain] getZoneRecordsForDomain:domain subdomain:subdomain];
	} else {
		[zoneRecordProgressIndicator stopAnimation:nil];
	}
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI updateZoneRecord:(SBLoopiaZoneRecord *)loopiaZoneRecord toDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithString:(NSString *)string {
	[window setDocumentEdited:NO];
	if (![string isEqualToString:SBLoopiaStatusOK]) {
		[[domainRPCs objectForKey:domain] getZoneRecordsForDomain:domain subdomain:subdomain];
	} else {
		[zoneRecordProgressIndicator stopAnimation:nil];		
	}
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI addZoneRecord:(SBLoopiaZoneRecord *)loopiaZoneRecord toDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithString:(NSString *)string {
	[window setDocumentEdited:NO];
	//Call every time to get the new ID..
	[[domainRPCs objectForKey:domain] getZoneRecordsForDomain:domain subdomain:subdomain];
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI failedRateLimited:(NSString *)string {
	//Stop indicators..
	[domainsProgressIndicator stopAnimation:nil];
	[zoneRecordProgressIndicator stopAnimation:nil];
	
	//Create an alert sheet..
	NSAlert *alert = [NSAlert alertWithMessageText:@"Rate Limitation Reached" defaultButton:@"Kjell Out" alternateButton:nil otherButton:nil 
						 informativeTextWithFormat:@"You have exceeded the maximum allowed requests (15) to Loopia per minute, just kjell out for a minute."];
	[alert setAlertStyle:NSCriticalAlertStyle];
	
	//Show the sheet..
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI addDomain:(NSString *)domain buy:(BOOL)buy didFinishWithString:(NSString *)string {
	// Stop indicator
	[domainsProgressIndicator stopAnimation:nil];
	
	// If successful, reload our list of domains..
	if ([string isEqualToString:SBLoopiaStatusOK]) {
		[domainRPCs setValue:loopiaAPI forKey:domain];
		[loopiaAPI getDomains];
	} else if ([string isEqualToString:SBLoopiaStatusDomainOccupied]) {
		//Create an alert sheet..
		NSAlert *alert = [NSAlert alertWithMessageText:@"Domain Occupied" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Try another domain"];
		[alert setAlertStyle:NSCriticalAlertStyle];
		
		//Show the sheet..
		[alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
		
		[alert release];
	}
}

@end
