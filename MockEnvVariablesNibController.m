//
//  MockEnvVariablesNibController.m
//  CronniX
//
//  Created by Sven A. Schmidt on Mon Jan 20 2003.
//  Copyright (c) 2003 Koch und Schmidt Systemtechnik GbR. All rights reserved.
//

#import "MockEnvVariablesNibController.h"

static id sharedInstance = nil;


@implementation envVariablesNibController


+ (id)sharedInstance {
    return sharedInstance ? sharedInstance : [[self alloc] init];
}

- (void)clear { }

- (void)setCrontab: (id)aCrontab { }

@end
