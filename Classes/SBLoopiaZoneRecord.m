//
//  SBLoopiaZoneRecord.m
//  LoopiaDNS
//
//  Created by Simon Blommegård on 2010-03-01.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import "SBLoopiaZoneRecord.h"

@implementation SBLoopiaZoneRecord

@synthesize type, TTL, priority, data, ID, dirty;

#pragma mark -

+ (SBLoopiaZoneRecord *)loopiaZoneRecordsFromDictionary:(NSDictionary *)zoneRecord {
	SBLoopiaZoneRecord *loopiaZoneRecord = [[[SBLoopiaZoneRecord alloc] initWithDictionary:zoneRecord] autorelease];
	
	return loopiaZoneRecord;
}

+ (NSArray *)loopiaZoneRecordsFromDictionaries:(NSArray *)zoneRecords {
	NSMutableArray *loopiaZoneRecords = [NSMutableArray array];
	
	for(NSDictionary *zoneRecord in zoneRecords) {
		SBLoopiaZoneRecord *loopiaZoneRecord = [[[SBLoopiaZoneRecord alloc] initWithDictionary:zoneRecord] autorelease];
		[loopiaZoneRecords addObject:loopiaZoneRecord];
	}
	
	return loopiaZoneRecords;
}

#pragma mark -

- (id)init {
	[super init];
	[self setType: @"A"];
	[self setTTL: 3600];
	[self setPriority: 0];
	[self setData: @"127.0.0.1"];
	[self setID: 0];
	
	[self setDirty: YES];
	
	return self;
}

- (id)initWithType:(NSString *)t TTL:(NSInteger)tt priority:(NSInteger)p data:(NSString *)d ID:(NSInteger)i {
	[super init];
	[self setType: t];
	[self setTTL: tt];
	[self setPriority: p];
	[self setData: d];
	[self setID: i];
	
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
	[super init];
	[self setType: [dict objectForKey:SBLoopiaZoneRecordTypeKey]];
	[self setTTL: [[dict objectForKey:SBLoopiaZoneRecordTTLKey] integerValue]];
	[self setPriority: [[dict objectForKey:SBLoopiaZoneRecordPriorityKey] integerValue]];
	[self setData: [dict objectForKey:SBLoopiaZoneRecordRDataKey]];
	[self setID: [[dict objectForKey:SBLoopiaZoneRecordRecordIDKey] integerValue]];
	
	return self;
}

#pragma mark -

- (NSUInteger)typeIndex {
	return [SBLoopiaZoneRecordTypes indexOfObject:[self type]];
}

- (void)setTypeIndex:(NSUInteger)index {
	[self setType:[SBLoopiaZoneRecordTypes objectAtIndex:index]];
}

#pragma mark -

- (void)dealloc {
	[type release];
	[data release];
	[super dealloc];
}

@end
