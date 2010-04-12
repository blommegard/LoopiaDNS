//
//  LHURLAccess.h
//  Data Access
//
//  Created by Tomas Franzén on 2010-01-11.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	LHURLAccessTypeData,
	LHURLAccessTypeString,
	LHURLAccessTypeImage,
	LHURLAccessTypeXML,
	LHURLAccessTypeHTML,
	LHURLAccessTypeJSON
} LHURLAccessType;


@interface LHURLAccess : NSObject {
	void(^block)(id data, NSURLResponse *response, NSError *error);
	LHURLAccessType type;
	
	NSConnection *connection;
	NSURLResponse *response;
	NSMutableData *incomingData;
}

+ (void)fetchURL:(NSURL*)URL withType:(LHURLAccessType)type onCompletion:(void(^)(id data, NSURLResponse *response, NSError *error))block;

@end