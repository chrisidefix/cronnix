//
//  SimpleLine.h
//  CronniX
//
//  Created by Sven A. Schmidt on Thu Apr 08 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrontabLine.h"


@interface SimpleLine : NSObject <CrontabLine> {
	
	NSString *line;
	
}

- (id)initWithString: (NSString *)aString;
- (void)dealloc;
- (NSData *)data;
+ (BOOL)isContainedInString: (NSString *)aString;

@end
