//
//  CrInfoCommentLine.h
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Apr 07 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleLine.h"

static NSString *CrInfoComment __attribute__ ((unused)) = @"#CrInfo";


@interface CrInfoCommentLine : SimpleLine {
}

+ (BOOL)isContainedInString: (NSString *)aString;

@end
