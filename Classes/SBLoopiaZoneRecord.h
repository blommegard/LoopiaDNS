//
//  SBLoopiaZoneRecord.h
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-01.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark ZoneRecordObject

#define SBLoopiaZoneRecordTypeKey @"type"
#define SBLoopiaZoneRecordTTLKey @"ttl"
#define SBLoopiaZoneRecordPriorityKey @"priority"
#define SBLoopiaZoneRecordRDataKey @"rdata"
#define SBLoopiaZoneRecordRecordIDKey @"record_id"

#define SBLoopiaZoneRecordTypes [NSArray arrayWithObjects:@"A", @"AAAA", @"CNAME", @"HINFO", @"MX", @"SRV", @"TXT", @"NS", nil]

#pragma mark -

@interface SBLoopiaZoneRecord : NSObject {
	NSString *type;
	NSInteger TTL;
	NSInteger priority;
	NSString *data;
	NSInteger ID;
	
	BOOL dirty;
}

@property (copy) NSString *type;
@property () NSInteger TTL;
@property () NSInteger priority;
@property (copy) NSString *data;
@property () NSInteger ID;
@property () BOOL dirty;

#pragma mark -

+ (SBLoopiaZoneRecord *)loopiaZoneRecordsFromDictionary:(NSDictionary *)zoneRecord;

+ (NSArray *)loopiaZoneRecordsFromDictionaries:(NSArray *)zoneRecords;

#pragma mark -

- (id)initWithType:(NSString *)t TTL:(NSInteger)tt priority:(NSInteger)p data:(NSString *)d ID:(NSInteger)i;

- (id)initWithDictionary:(NSDictionary *)dict;

#pragma mark -

- (NSUInteger)typeIndex;

@end
