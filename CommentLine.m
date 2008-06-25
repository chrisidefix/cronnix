//
//  Comment.m
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "CommentLine.h"
#import "SasString.h"
#import "TaskObject.h"

@implementation CommentLine

+ (BOOL)isContainedInString: (NSString *)string {
    if ( [ string startsWithStringIgnoringWhitespace: @"#" ] 
		 && ! [ string startsWithStringIgnoringWhitespace: DisableTag ] ) {
		return YES;
    } else {
		return NO;
    }
}

@end
