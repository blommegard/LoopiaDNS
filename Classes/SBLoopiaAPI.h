//
//  SBXMLRPC.h
//  LoopiaAPI
//
//  Created by Simon Blommegård on 2010-02-25.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XMLRPC/XMLRPC.h>

@class SBLoopiaAPI;
@class SBLoopiaZoneRecord;

#pragma mark DomainObject

#define SBLoopiaDomainDomainKey @"domain"
#define SBLoopiaDomainPaidKey @"paid"
#define SBLoopiaDomainRegisteredKey @"registered"
#define SBLoopiaDomainReferenceNoKey @"reference_no"
#define SBLoopiaDomainUnpaidAmountKey @"unpaid_amount"

#pragma mark StatusObject

#define SBLoopiaStatusOK @"OK"
#define SBLoopiaStatusAuthError @"AUTH_ERROR"
#define SBLoopiaStatusDomainOccupied @"DOMAIN_OCCUPIED"
#define SBLoopiaStatusRateLimited @"RATE_LIMITED"
#define SBLoopiaStatusBadIndata @"BAD_INDATA"
#define SBLoopiaStatusUnknownError @"UNKNOWN_ERROR"

#pragma mark -

@protocol SBLoopiaAPIDelegate <NSObject>

@optional

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI failedRateLimited:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI failedAuthenticateWithUsername:(NSString *)username password:(NSString *)password;

#pragma mark -

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI failedWithFaultCode:(NSNumber *)code faultString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI domain:(NSString *)domain isFreeDidFinishWithString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI payInvoiceDidFinishWithString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI getDomain:(NSString *)domain didFinishWithDictionary:(NSDictionary *)dictionary;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI getDomainsDidFinishWithArray:(NSArray *)array;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI getSubdomainsForDomain:(NSString *)domain didFinishWithArray:(NSArray *)array;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI getZoneRecordsForDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithArray:(NSArray *)array;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI addDomain:(NSString *)domain buy:(BOOL)buy didFinishWithString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI addSubdomain:(NSString *)subdomain toDomain:(NSString *)domain didFinishWithString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI addZoneRecord:(SBLoopiaZoneRecord *)loopiaZoneRecord toDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI removeSubdomain:(NSString *)subdomain forDomain:(NSString *)domain didFinishWithString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI removeZoneRecord:(NSInteger)recordID forDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithString:(NSString *)string;

- (void)loopiaAPI:(SBLoopiaAPI *)loopiaAPI updateZoneRecord:(SBLoopiaZoneRecord *)loopiaZoneRecord toDomain:(NSString *)domain subdomain:(NSString *)subdomain didFinishWithString:(NSString *)string;

@end

#pragma mark -

@interface SBLoopiaAPI : NSObject <XMLRPCConnectionDelegate>{
	NSString *APIUser;
	NSString *APIPassword;
	
	NSURL *APIURL;
	
	id <SBLoopiaAPIDelegate> delegate;
}

@property (copy) NSString *APIUser;
@property (copy) NSString *APIPassword;
@property (nonatomic, assign) id <SBLoopiaAPIDelegate> delegate;

#pragma mark -

- (id)initWithAPIUser:(NSString *)user password:(NSString *)password;

#pragma mark -

- (void)domainIsFree:(NSString *)domain;

- (void)payInvoice:(NSString *)invoice;

- (void)getDomain:(NSString *)domain;

- (void)getDomains;

- (void)getSubdomainsForDomain:(NSString *)domain;

- (void)getZoneRecordsForDomain:(NSString *)domain subdomain:(NSString *)subdomain;

- (void)addDomain:(NSString *)domain buy:(BOOL)buy;

- (void)addSubdomain:(NSString *)subdomain toDomain:(NSString *)domain;

- (void)addZoneRecord:(SBLoopiaZoneRecord *)record toDomain:(NSString *)domain subdomain:(NSString *)subdomain;

- (void)removeSubdomain:(NSString *)subdomain forDomain:(NSString *)domain;

- (void)removeZoneRecord:(NSInteger)recordID forDomain:(NSString *)domain subdomain:(NSString *)subdomain;

- (void)updateZoneRecord:(SBLoopiaZoneRecord *)record forDomain:(NSString *)domain subdomain:(NSString *)subdomain;

@end
