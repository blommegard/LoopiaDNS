//
//  SBXMLRPC.m
//  LoopiaAPI
//
//  Created by Simon Blommegård on 2010-02-25.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBLoopiaAPI.h"
#import "SBLoopiaZoneRecord.h"

@implementation SBLoopiaAPI

@synthesize APIUser, APIPassword;
@synthesize delegate;

#pragma mark -

- (id)initWithAPIUser:(NSString *)user password:(NSString *)password {
	[super init];
	
	[self setAPIUser: user];
	[self setAPIPassword: password];
	
	APIURL = [[NSURL URLWithString: @"https://api.loopia.se/RPCSERV"] retain];
	
	return self;
}

#pragma mark -
#pragma mark Loopia API Methods - Other

- (void)domainIsFree:(NSString *)domain {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"domainIsFree" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

- (void)payInvoice:(NSString *)invoice {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"payInvoiceUsingCredits" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, invoice, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

#pragma mark Loopia API Methods - Get

- (void)getDomain:(NSString *)domain {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"getDomain" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

- (void)getDomains {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"getDomains" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

- (void)getSubdomainsForDomain:(NSString *)domain {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"getSubdomains" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

- (void)getZoneRecordsForDomain:(NSString *)domain subdomain:(NSString *)subdomain {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"getZoneRecords" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, subdomain, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

#pragma mark Loopia API Methods - Add

- (void)addDomain:(NSString *)domain buy:(BOOL)buy {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"addDomainToAccount" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, [NSNumber numberWithBool:buy], nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

- (void)addSubdomain:(NSString *)subdomain toDomain:(NSString *)domain {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"addSubdomain" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, subdomain, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

- (void)addZoneRecord:(SBLoopiaZoneRecord *)record toDomain:(NSString *)domain subdomain:(NSString *)subdomain {
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[record type], [NSNumber numberWithInteger:[record TTL]], [NSNumber numberWithInteger:[record priority]], [record data], nil]
													 forKeys:[NSArray arrayWithObjects:SBLoopiaZoneRecordTypeKey, SBLoopiaZoneRecordTTLKey, SBLoopiaZoneRecordPriorityKey, SBLoopiaZoneRecordRDataKey, nil]];
	
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"addZoneRecord" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, subdomain, dict, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

#pragma mark Loopia API Methods - Remove

- (void)removeSubdomain:(NSString *)subdomain forDomain:(NSString *)domain {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"removeSubdomain" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, subdomain, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

- (void)removeZoneRecord:(NSInteger)recordID forDomain:(NSString *)domain subdomain:(NSString *)subdomain {
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"removeZoneRecord" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, subdomain, [NSNumber numberWithInteger:recordID], nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

#pragma mark Loopia API Methods - Update

- (void)updateZoneRecord:(SBLoopiaZoneRecord *)record forDomain:(NSString *)domain subdomain:(NSString *)subdomain {
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[record type], [NSNumber numberWithInteger:[record TTL]], [NSNumber numberWithInteger:[record priority]], [record data], [NSNumber numberWithInteger:[record ID]], nil]
													 forKeys:[NSArray arrayWithObjects:SBLoopiaZoneRecordTypeKey, SBLoopiaZoneRecordTTLKey, SBLoopiaZoneRecordPriorityKey, SBLoopiaZoneRecordRDataKey, SBLoopiaZoneRecordRecordIDKey, nil]];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: APIURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [request setMethod: @"updateZoneRecord" withParameters: [NSArray arrayWithObjects:APIUser, APIPassword, domain, subdomain, dict, nil]];
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
	[request release];
}

#pragma mark XMLRPCConnectionDelegate Methods

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	if ([response isFault]) {
//		NSLog(@"Fault code: %@", [response faultCode]);
//		NSLog(@"Fault string: %@", [response faultString]);
		
		//Call delegate
		[[self delegate] loopiaAPI:self failedWithFaultCode:[response faultCode] faultString:[response faultString]];
	} else {
//		NSLog(@"Parsed response: %@", [response object]);
	
		//Call the delegates
		if (([[response object] isKindOfClass:[NSString class]] && [[response object] isEqualToString:SBLoopiaStatusRateLimited]) ||
			([[response object] isKindOfClass:[NSArray class]] && [[response object] count] && [[[response object] objectAtIndex:0] isKindOfClass:[NSString class]] && [[[response object] objectAtIndex:0] isEqualToString:SBLoopiaStatusRateLimited])) {
			[[self delegate] loopiaAPI:self failedRateLimited:SBLoopiaStatusRateLimited];
			
		} else if (([[response object] isKindOfClass:[NSString class]] && [[response object] isEqualToString:SBLoopiaStatusAuthError]) ||
			([[response object] isKindOfClass:[NSArray class]] && [[response object] count] && [[[response object] objectAtIndex:0] isKindOfClass:[NSString class]] && [[[response object] objectAtIndex:0] isEqualToString:SBLoopiaStatusAuthError])) {
			[[self delegate] loopiaAPI:self failedAuthenticateWithUsername:[[request parameters] objectAtIndex:0] password:[[request parameters] objectAtIndex:1]];

		} else if ([[request method] isEqualToString:@"domainIsFree"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self domain:[[request parameters] objectAtIndex:2] isFreeDidFinishWithString:[response object]];

		} else if ([[request method] isEqualToString:@"payInvoiceUsingCredits"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self payInvoiceDidFinishWithString:[response object]];
			
		} else if ([[request method] isEqualToString:@"getDomain"] && [[response object] isKindOfClass:[NSDictionary class]]) {
			[[self delegate] loopiaAPI:self getDomain:[[request parameters] objectAtIndex:2] didFinishWithDictionary:[response object]];

		} else if ([[request method] isEqualToString:@"getDomains"] && [[response object] isKindOfClass:[NSArray class]]) {
			[[self delegate] loopiaAPI:self getDomainsDidFinishWithArray:[response object]];

		} else if ([[request method] isEqualToString:@"getSubdomains"] && [[response object] isKindOfClass:[NSArray class]]) {
			[[self delegate] loopiaAPI:self getSubdomainsForDomain:[[request parameters] objectAtIndex:2] didFinishWithArray:[response object]];
			
		} else if ([[request method] isEqualToString:@"getZoneRecords"] && [[response object] isKindOfClass:[NSArray class]]) {
			NSArray *loopiaZoneRecords = [SBLoopiaZoneRecord loopiaZoneRecordsFromDictionaries:[response object]];
			[[self delegate] loopiaAPI:self getZoneRecordsForDomain:[[request parameters] objectAtIndex:2] subdomain:[[request parameters] objectAtIndex:3] didFinishWithArray:loopiaZoneRecords];
			
		} else if ([[request method] isEqualToString:@"addDomainToAccount"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self addDomain:[[request parameters] objectAtIndex:2] buy:[[[request parameters] objectAtIndex:3] boolValue] didFinishWithString:[response object]];
			
		} else if ([[request method] isEqualToString:@"addSubdomain"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self addSubdomain:[[request parameters] objectAtIndex:3] toDomain:[[request parameters] objectAtIndex:2] didFinishWithString:[response object]];
			
		} else if ([[request method] isEqualToString:@"addZoneRecord"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self addZoneRecord:[[request parameters] objectAtIndex:4] toDomain:[[request parameters] objectAtIndex:2] subdomain:[[request parameters] objectAtIndex:3] didFinishWithString:[response object]];
			
		} else if ([[request method] isEqualToString:@"removeSubdomain"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self removeSubdomain:[[request parameters] objectAtIndex:3] forDomain:[[request parameters] objectAtIndex:2] didFinishWithString:[response object]];

		} else if ([[request method] isEqualToString:@"removeZoneRecord"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self removeZoneRecord:[[[request parameters] objectAtIndex:4] integerValue] forDomain:[[request parameters] objectAtIndex:2] subdomain:[[request parameters] objectAtIndex:3] didFinishWithString:[response object]];
			
		} else if ([[request method] isEqualToString:@"updateZoneRecord"] && [[response object] isKindOfClass:[NSString class]]) {
			[[self delegate] loopiaAPI:self updateZoneRecord:[[request parameters] objectAtIndex:4] toDomain:[[request parameters] objectAtIndex:2] subdomain:[[request parameters] objectAtIndex:3] didFinishWithString:[response object]];
		}
	}
}


- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {}

#pragma mark -

- (void)dealloc {
	[APIUser release];
	[APIPassword release];
	[APIURL release];
	[super dealloc];
}

@end
