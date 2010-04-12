//
//  SBPunyCode.h
//  LoopiaDNS
//
//  Created by Simon Blommegård and Tomas Franzén on 2010-03-03.
//

#import <Foundation/Foundation.h>

@interface NSString (SBPunyCode)

- (NSString *)stringFromIDN;

- (NSString *)stringToIDN;

@end
