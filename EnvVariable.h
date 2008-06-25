//
//  EnvVariable.h
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 abstracture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrontabLine.h"

@interface EnvVariable : NSObject <CrontabLine> {
	NSString *key;
	NSString *value;
}

- (id)initWithString: (NSString *)string;
+ (id)envVariableWithEnvVariable: (id)anEnv;
+ (id)envVariableWithString: (NSString *)string;
+ (id)envVariableWithValue: (NSString *)aValue forKey: (NSString *)aKey;

+ (BOOL)isContainedInString: (NSString *)string;

- (NSString *)key;
- (NSString *)value;
- (void) setKey: (id)aKey;
- (void) setValue: (id)aValue;

- (void)parseString: (NSString *)string;

- (NSData *)data;

@end
