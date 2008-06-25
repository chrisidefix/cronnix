//
//  TaskObject.h
//  CronniX
//
//  Created by Sven A. Schmidt on Mon Dec 31 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrontabLine.h"

static NSString *DisableTag __attribute__ ((unused)) = @"#CronniX";

@interface TaskObject : NSObject <CrontabLine> {
	NSMutableDictionary *task;
	BOOL isSystemCrontabTask;
}

- (id)init;
- (id)initWithString:(NSString *)string forSystem: (BOOL)isSystemCrontab;
- (id)initWithString:(NSString *)string;
- (id)initWithTask:(id)aTask;

+ (id)taskWithString:(NSString *)string;
+ (id)taskWithTask:(id)task;

+ (BOOL)isContainedInString: (NSString *)line;

- (void)parseString: (NSString *)string;

- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;

- (void)setActive: (BOOL)value;

- (BOOL)isActive;

- (void)setInfo: (NSString *)value;

- (NSString *)info;

- (void)setMinute: (NSString *)value;

- (NSString *)minute;

- (void)setHour: (NSString *)value;

- (NSString *)hour;

- (void)setMday: (NSString *)value;

- (NSString *)mday;

- (void)setMonth: (NSString *)value;

- (NSString *)month;

- (void)setWday: (NSString *)value;

- (NSString *)wday;

- (void)setCommand: (NSString *)value;

- (NSString *)command;

- (void)setUser: (NSString *)value;

- (NSString *)user;

- (NSData *)data;

// accessors

//- (NSMutableDictionary *)task;

//- (void)setTask:(id)value;

- (void)setDictionary:(NSDictionary *)value;

- (BOOL)isSystemCrontabTask;

- (void)setIsSystemCrontabTask: (BOOL)aVal;


@end
