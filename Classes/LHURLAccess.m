//
//  LHURLAccess.m
//  Data Access
//
//  Created by Tomas Franzén on 2010-01-11.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import "LHURLAccess.h"


@implementation LHURLAccess

- (id)initWithURL:(NSURL*)URL withType:(LHURLAccessType)t onCompletion:(void(^)(id data, NSURLResponse *response, NSError *error))b {
	[super init];
	NSURLRequest *req = [NSURLRequest requestWithURL:URL];
	connection = [[NSURLConnection connectionWithRequest:req delegate:self] retain];
	
	type = t;
	block = [b copy];
	return self;
}

- (void)dealloc {
	[response release];
	[incomingData release];
	[connection release];
	[block release];
	[super dealloc];
}

- (void)invalidate {
	[[NSGarbageCollector defaultCollector] enableCollectorForPointer:self];
	[self release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)r {
	response = [r retain];
	incomingData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[incomingData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	block(nil, nil, error);
	[self invalidate];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	id object = nil;
	NSError *error = nil;
	
	if(type == LHURLAccessTypeData)
		object = incomingData;
	else if(type == LHURLAccessTypeString)
		object = [[[NSString alloc] initWithData:incomingData encoding:NSUTF8StringEncoding] autorelease]; // Shouldn't just assume UTF-8. Fix.
	else if(type == LHURLAccessTypeImage)
		object = [[[NSImage alloc] initWithData:incomingData] autorelease];
	else if(type == LHURLAccessTypeXML)
		object = [[[NSXMLDocument alloc] initWithData:incomingData options:0 error:&error] autorelease];
	else if(type == LHURLAccessTypeHTML)
		object = [[[NSXMLDocument alloc] initWithData:incomingData options:NSXMLDocumentTidyHTML error:&error] autorelease];
	else if(type == LHURLAccessTypeJSON)
		object = nil; // TBI
	
	block(object, response, error);	
	[self invalidate];
}

+ (void)fetchURL:(NSURL*)URL withType:(LHURLAccessType)type onCompletion:(void(^)(id data, NSURLResponse *response, NSError *error))block {
	LHURLAccess *obj = [[self alloc] initWithURL:URL withType:type onCompletion:block];
	[[NSGarbageCollector defaultCollector] disableCollectorForPointer:obj]; // keep object around in GC
}

@end