//
//  Crontab.h
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Jan 16 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskObject.h"
#import "EnvVariable.h"
#import "CrontabLine.h"

// __attribute__ ((unused)) suppresses compiler warnings
static NSString *NewCrontabParsedNotification __attribute__ ((unused)) = @"NewCrontabParsed";
static NSString *systemCrontabUser __attribute__ ((unused)) = @"system";

static NSString *EnvVariableAddedNotification __attribute__ ((unused)) = @"EnvVariableAdded";
static NSString *EnvVariableEditedNotification __attribute__ ((unused)) = @"EnvVariableEdited";
static NSString *EnvVariableDeletedNotification __attribute__ ((unused)) = @"EnvVariableDeleted";


/*!
	@class Crontab
	@abstract 
	@discussion 
*/
@interface Crontab : NSObject <CrontabLine> {
	NSMutableArray *objects;
	NSString *user;
}

+ (BOOL)isContainedInString: (NSString *)string;

- (id)initWithString: (NSString *)string;
- (id)initWithString: (NSString *)data forUser: (NSString *)aUser;
- (id)initWithData: (NSData *)data forUser: (NSString *)aUser;
- (id)initWithContentsOfFile: (NSString *)path forUser: (NSString *)aUser;

// workers

- (void)clear;

- (void)parseString: (NSString *)string;

- (BOOL)isSystemCrontab;

- (BOOL)writeAtPath: (NSString *)path;

// accessors

- (NSEnumerator *)tasks;
- (NSEnumerator *)reverseTasks;

- (int)taskCount;

//- (void)setTasks: (NSMutableArray *)aVal;

- (NSString *)user;

- (void)setUser: (NSString *)aVal;

- (NSEnumerator *)envVariables;
- (NSEnumerator *)reverseEnvVariables;
- (int)envVariableCount;
- (EnvVariable *)envVariableAtIndex: (int)index;

- (int)objectCountForClass: (Class)aClass;
- (int)objectIndexOfTaskAtIndex: (int)index;
- (int)objectIndexOfEnvVariableAtIndex: (int)index;
- (int)objectIndexOfLastEnvVariable;

- (void)addEnvVariable: (EnvVariable *)env;
- (void)addEnvVariableWithValue: (NSString *)aValue forKey: (NSString *)aKey;
- (void)removeEnvVariable: (EnvVariable *)env;
- (void)removeEnvVariableWithKey: (NSString *)key;
- (void)removeEnvVariableAtIndex: (int)index;
- (void)removeAllEnvVariables;
- (void)insertEnvVariable: (id)env atIndex: (int)index;

- (void)addTask: (TaskObject *)task;
- (void)addTaskWithString: (NSString *)string;
- (void)removeTaskAtIndex: (int)index;
- (void)removeTask: (TaskObject *)task;
- (void)insertTask: (TaskObject *)aTask atIndex: (int)index;
- (void)replaceTaskAtIndex: (int)index withTask: (TaskObject *)aTask;

- (NSData *)data;

- (TaskObject *)taskAtIndex: (int)index;
- (int)indexOfTask: (id)aTask;


@end
