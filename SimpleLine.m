//
//  SimpleLine.m
//  CronniX
//
//  Created by Sven A. Schmidt on Thu Apr 08 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SimpleLine.h"


@implementation SimpleLine

- (id)initWithString: (NSString *)aString {
    [ super init ];
	line = [ aString copy ];
    return self;
}

- (void)dealloc {
	[ line release ];
}


+ (BOOL)isContainedInString: (NSString *)aString {
	return YES;
}


- (NSData *)data {
	return [ line dataUsingEncoding: [ NSString defaultCStringEncoding ]];
}

@end
