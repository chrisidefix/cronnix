//
//  CrInfoCommentLine.m
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Apr 07 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "CrInfoCommentLine.h"
#import "SasString.h"

@implementation CrInfoCommentLine


+ (BOOL)isContainedInString: (NSString *)aString {
    if ( [ aString startsWithStringIgnoringWhitespace: CrInfoComment ] ) {
		return YES;
    } else {
		return NO;
    }
}


@end
