//
//  TaskObjectTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sat Mar 23 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "TaskObjectTest.h"


NSString *taskString = @"Min Hour Mday Month Wday My \"Command\"";
NSString *systemTaskString = @"Min Hour Mday Month Wday User My \"Command\"";
NSString *infoString = @"Task info";
NSString *inactiveTaskString = @"#CronniX Min Hour Mday Month Wday My \"Command\"";
NSString *inactiveTaskString2 = @"#CronniX\tMin Hour Mday Month Wday My \"Command\"";

@implementation TaskObjectTest

- (void)setUp {
	task = [[ TaskObject alloc ] initWithString: taskString ];
	systemTask = [[ TaskObject alloc ] initWithString: systemTaskString forSystem: YES ];
}

- (void)tearDown {
	[ task release ];
	[ systemTask release ];
}


- (void)testMultilineInfoData {
	task = [[ TaskObject alloc ] initWithString: taskString ];
	NSString *infoString =
		@"#CrInfo info 1\n"
		@"#CrInfo\tinfo 2\n"
		@"#CrInfo info 3\n";
	NSString *expectedString =
		@"#CrInfo info 1\n"
		@"#CrInfo info 2\n"
		@"#CrInfo info 3\n"
		@"Min\tHour\tMday\tMonth\tWday\tMy \"Command\"";
	[ task setInfo: infoString ];
	[ self assert: [ task description ] equals: expectedString ];
}


- (void)testMultilineInfo {
	task = [[ TaskObject alloc ] initWithString: taskString ];
	NSString *infoString =
		@"#CrInfo info 1\n"
		@"#CrInfo\tinfo 2\n"
		@"#CrInfo info 3\n";
	NSString *expectedInfo =
		@"info 1\n"
		@"info 2\n"
		@"info 3";
	[ task setInfo: infoString ];
	[ self assert: [ task info ] equals: expectedInfo ];
}


- (void)testSetInfo {
	[ task setInfo: @"#CrInfo another test...\n" ];
	[ self assert: [ task info ] equals: @"another test..." ];
}


- (void)testInitWithStringForInactive2 {
	id aTask = [[ TaskObject alloc ] initWithString: inactiveTaskString2 ];
	[ self assertFalse: [ aTask isActive ]];
	[ self assert: [ aTask minute ] equals: @"Min" ];
	[ self assert: [ aTask hour ] equals: @"Hour" ];
	[ self assert: [ aTask month ] equals: @"Month" ];
	[ self assert: [ aTask mday ] equals: @"Mday" ];
	[ self assert: [ aTask wday ] equals: @"Wday" ];
	[ self assert: [ aTask command ] equals: @"My \"Command\"" ];	
}

- (void)testInitWithStringForInactive {
	id aTask = [[ TaskObject alloc ] initWithString: inactiveTaskString ];
	[ self assertFalse: [ aTask isActive ]];
	[ self assert: [ aTask minute ] equals: @"Min" ];
	[ self assert: [ aTask hour ] equals: @"Hour" ];
	[ self assert: [ aTask month ] equals: @"Month" ];
	[ self assert: [ aTask mday ] equals: @"Mday" ];
	[ self assert: [ aTask wday ] equals: @"Wday" ];
	[ self assert: [ aTask command ] equals: @"My \"Command\"" ];	
}


- (void)testInitWithStringForSystem {
	id aTask = [[ TaskObject alloc ] initWithString: systemTaskString forSystem: YES ];
	[ self assertTrue: [ aTask isActive ]];
	[ self assert: [ aTask minute ] equals: @"Min" ];
	[ self assert: [ aTask hour ] equals: @"Hour" ];
	[ self assert: [ aTask month ] equals: @"Month" ];
	[ self assert: [ aTask mday ] equals: @"Mday" ];
	[ self assert: [ aTask wday ] equals: @"Wday" ];
	[ self assert: [ aTask user ] equals: @"User" ];
	[ self assert: [ aTask command ] equals: @"My \"Command\"" ];	
}

- (void)testInitWithString {
	id aTask = [[ TaskObject alloc ] initWithString: taskString ];
	[ self assertTrue: [ aTask isActive ]];
	[ self assert: [ aTask minute ] equals: @"Min" ];
	[ self assert: [ aTask hour ] equals: @"Hour" ];
	[ self assert: [ aTask month ] equals: @"Month" ];
	[ self assert: [ aTask mday ] equals: @"Mday" ];
	[ self assert: [ aTask wday ] equals: @"Wday" ];
	[ self assert: [ aTask command ] equals: @"My \"Command\"" ];	
}


- (void)testDataForInactiveTask2 {
	id aTask = [[ TaskObject alloc ] initWithString: inactiveTaskString2 ];
	id string = [[ NSString alloc ] initWithData: [ aTask data ] 
										encoding: [ NSString defaultCStringEncoding]];
	[ self assert: string equals: @"#CronniX Min\tHour\tMday\tMonth\tWday\tMy \"Command\"" ];
}

- (void)testDataForInactiveTask {
	id aTask = [[ TaskObject alloc ] initWithString: inactiveTaskString ];
	id string = [[ NSString alloc ] initWithData: [ aTask data ] 
										encoding: [ NSString defaultCStringEncoding]];
	[ self assert: string equals: @"#CronniX Min\tHour\tMday\tMonth\tWday\tMy \"Command\"" ];
}


- (void)testDataForSystemTask {
	id string = [[ NSString alloc ] initWithData: [ systemTask data ] 
										encoding: [ NSString defaultCStringEncoding]];
	[ self assert: string equals: @"Min\tHour\tMday\tMonth\tWday\tUser\tMy \"Command\"" ];
}


- (void)testData {
	id string = [[ NSString alloc ] initWithData: [ task data ] encoding: [ NSString defaultCStringEncoding]];
	[ self assert: string equals: @"Min\tHour\tMday\tMonth\tWday\tMy \"Command\"" ];
}


- (void)testIsContainedInStringPositives {
	[ self assertTrue: [ TaskObject isContainedInString: taskString ]];
	[ self assertTrue: [ TaskObject isContainedInString: systemTaskString ]];
	[ self assertTrue: [ TaskObject isContainedInString: inactiveTaskString ]];
	[ self assertTrue: [ TaskObject isContainedInString: inactiveTaskString2 ]];
}

- (void)testIsContainedInStringNegatives {
	[ self assertFalse: [ TaskObject isContainedInString: @"test test" ]];
	[ self assertFalse: [ TaskObject isContainedInString: @"# test" ]];
	[ self assertFalse: [ TaskObject isContainedInString: @"1 2 3 4 5" ]];
	[ self assertFalse: [ TaskObject isContainedInString: @"@reboot 1 2 3 4 5" ]];
}

- (void)testMinute {
	[ self assert: [ task minute ] equals: @"Min" ];
}

- (void)testHour {
	[ self assert: [ task hour ] equals: @"Hour" ];
}

- (void)testMonth {
	[ self assert: [ task month ] equals: @"Month" ];
}

- (void)testMday {
	[ self assert: [ task mday ] equals: @"Mday" ];
}

- (void)testWday {
	[ self assert: [ task wday ] equals: @"Wday" ];
}

- (void)testCommand {
	[ self assert: [ task command ] equals: @"My \"Command\"" ];
}

- (void)testInfo {
	NSString *s = [ infoString copy ];
	[ task setInfo: s ];
	[ self assert: [ task info ] equals: infoString ];
	[ s release ];
	[ self assert: [ task info ] equals: infoString ];
	[ task setInfo: [ task info ] ];
	[ self assert: [ task info ] equals: infoString ];
}

- (void)testSystemTask {
	[ self assert: [ systemTask minute ] equals: @"Min" ];
	[ self assert: [ systemTask hour ] equals: @"Hour" ];
	[ self assert: [ systemTask month ] equals: @"Month" ];
	[ self assert: [ systemTask mday ] equals: @"Mday" ];
	[ self assert: [ systemTask wday ] equals: @"Wday" ];
	[ self assert: [ systemTask user ] equals: @"User" ];
	[ self assert: [ systemTask command ] equals: @"My \"Command\"" ];
}

- (void)testTaskWithTask {
	TaskObject *newtask = [ TaskObject taskWithTask: task ];
	[ task setMinute:  @"1" ];
	[ task setHour:    @"1" ];
	[ task setMonth:   @"1" ];
	[ task setMday:    @"1" ];
	[ task setWday:    @"1" ];
	[ task setUser:    @"testUser" ];
	[ task setCommand: @"testCommand" ];
	[ self assert: [ newtask minute ] equals: @"Min" ];
	[ self assert: [ newtask month ] equals: @"Month" ];
	[ self assert: [ newtask command ] equals: @"My \"Command\"" ];
}

- (void)testDictionary {
	NSMutableDictionary *copy;
	NSMutableDictionary *orig = [ NSMutableDictionary dictionary ];
	[ orig setObject: @"Hans Dampf" forKey: @"Name" ];
	copy = [ NSMutableDictionary dictionaryWithDictionary: orig ];
	[ orig setObject: @"Donni Lotti" forKey: @"Name" ];
	[ self assertFalse: [[ orig objectForKey: @"Name" ] isEqual: [ copy objectForKey: @"Name" ]]];
}

- (void)testDictionary2 {
	NSMutableDictionary *copy;
	NSMutableDictionary *orig = [ NSMutableDictionary dictionary ];
	[ orig setObject: @"Hans Dampf" forKey: @"Name" ];
	copy = [[ NSMutableDictionary alloc ] initWithDictionary: orig ];
	[ orig setObject: @"Donni Lotti" forKey: @"Name" ];
	[ self assertFalse: [[ orig objectForKey: @"Name" ] isEqual: [ copy objectForKey: @"Name" ]]];
}


@end
