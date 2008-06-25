//
//  EnvVariable.m
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "EnvVariable.h"
#import "SasString.h"


@implementation EnvVariable

- (id)initWithString: (NSString *)string {
    [ super init ];

	key = [[ NSString alloc ] init ];
	value = [[ NSString alloc ] init ];

    NS_DURING
	[ self parseString: string ];
    NS_HANDLER
	NSLog( @"Error parsing line: %@", string );
    NS_ENDHANDLER

	return self;
}

- (void)dealloc {
	[ key release ];
	[ value release ];
}

+ (id)envVariableWithEnvVariable: (id)anEnv {
    id env = [[ EnvVariable alloc ] init];
	[ env setKey: [ anEnv key ]];
    [ env setValue: [ anEnv value ]];
    return [ env autorelease ];
}

+ (id)envVariableWithString: (NSString *)string {
    return [[[ EnvVariable alloc ] initWithString: string ] autorelease ];
}

+ (id)envVariableWithValue: (NSString *)aValue forKey: (NSString *)aKey {
	id env = [[ EnvVariable alloc ] init];
	[ env setKey: aKey ];
	[ env setValue: aValue ];
	return [ env autorelease ];
}

+ (BOOL)isContainedInString: (NSString *)string {
  if ( [ string startsWithStringIgnoringWhitespace: @"#" ] ) return NO;
  id parts = [ string componentsSeparatedByString: @"=" ];
  if ( [ parts count] != 2 ) return NO;
  id lhs = [ parts objectAtIndex: 0 ];
	int words = [ lhs fieldCountSeperatedBy: [ NSCharacterSet whitespaceCharacterSet ]];
  if ( words > 1 ) {
    return NO;
  } else {
    return YES;
  }
}

- (NSString *)key { return key; }
- (NSString *)value { return value; }

- (void) setValue: (id)aValue {
	if ( aValue != value ) {
		[ value release ];
		value = [ aValue copy ];
	}
}

- (void) setKey: (id)aKey {
	if ( aKey != key ) {
		[ key release ];
		key   = [ aKey copy ];
	}
}

- (void)parseString: (NSString *)string {
	NSScanner *scanner = [ NSScanner scannerWithString: string ];
	NSString *aKey;
	NSString *aValue;
	[ scanner scanUpToString: @"=" intoString: &aKey ];
	[ scanner scanString: @"=" intoString: nil ];
	aValue = [ string substringFromIndex: [ scanner scanLocation ]];
	aKey = [ aKey stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]];
	aValue = [ aValue stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]];
	[ self setKey: aKey ];
	[ self setValue: aValue ];
}


- (NSData *)data {
    NSMutableData *envData = [ NSMutableData data ];
	NSString *item = [ NSString stringWithFormat: @"%@ = %@", [ self key ], [ self value ]];
	[ envData appendData: [ item dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
    
    return envData;
}

- (NSString *)description {
	return [ NSString stringWithFormat: @"%@ = %@", [ self key ], [ self value ]];
}


@end
