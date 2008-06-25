//
//  crControllerTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sun Mar 24 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "crControllerTest.h"

NSString *crontabString =
@"ENV1= value\n"
@"ENV2= value +more\n"
@"ENV3=value\n"
@"ENV4=value +more\n"
@"ENV5 = value\n"
@"ENV6 = value +more\n"
@"ENV7 =value\n"
@"ENV8 =value +more\n"
@"#CrInfo another test...\n"
@" 1      2       3       4       *       task 0\n"
@"#CrInfo another test...\n"
@" 1      2       3       4       *       task 1\n"
@"#CrInfo another test...\n"
@" 1      2       3       4       *       task 2\n";


@implementation crControllerTest


- (void)setUp {
	controller = [[ crController alloc ] init ];
	[ controller initDataSource ];
	cronData = [[ crontabString dataUsingEncoding: [ NSString defaultCStringEncoding ]] retain ];
	[ controller parseCrontab: cronData ];
}

- (void)tearDown {
	[ controller release ];
	[ cronData release ];
}


// ---- tests ----


- (void)test_addTaskToSystemCrontab {
	[controller openSystemCrontab];
  [controller newLine];
  id data = [[controller currentCrontab] data];
  id s = [[NSString alloc] initWithData: data encoding: [NSString defaultCStringEncoding]];
  id lines = [s componentsSeparatedByString: @"\n"];
  id lastLine = [lines objectAtIndex: [lines count]-2];
  [self assert: lastLine equals: @"0	0	1	1	*	root	echo \"Happy New Year!\""];
}


- (void)testDuplicateTwoLines {
	id list = [ NSMutableArray array ];
	[ list addObject: [ NSNumber numberWithInt: 0 ]];
	[ list addObject: [ NSNumber numberWithInt: 2 ]];
	[ controller duplicateLinesInList: [ list objectEnumerator ]];
	id ct = [ controller currentCrontab ];
	[ self assertInt: [ ct taskCount ] equals: 5 ];
	[ self assert: [[ ct taskAtIndex: 0 ] command ] equals: @"task 0" ];
	[ self assert: [[ ct taskAtIndex: 1 ] command ] equals: @"task 1" ];
	[ self assert: [[ ct taskAtIndex: 2 ] command ] equals: @"task 2" ];
	[ self assert: [[ ct taskAtIndex: 3 ] command ] equals: @"task 0" ];
	[ self assert: [[ ct taskAtIndex: 4 ] command ] equals: @"task 2" ];
}

- (void)testDuplicateLastLine {
	id i = [ NSNumber numberWithInt: 2 ];
	id list = [ NSArray arrayWithObject: i ];
	[ controller duplicateLinesInList: [ list objectEnumerator ]];
	id ct = [ controller currentCrontab ];
	[ self assertInt: [ ct taskCount ] equals: 4 ];
	[ self assert: [[ ct taskAtIndex: 0 ] command ] equals: @"task 0" ];
	[ self assert: [[ ct taskAtIndex: 1 ] command ] equals: @"task 1" ];
	[ self assert: [[ ct taskAtIndex: 2 ] command ] equals: @"task 2" ];
	[ self assert: [[ ct taskAtIndex: 3 ] command ] equals: @"task 2" ];
}


- (void)testParseCrontab {
	id ctr = [[ crController alloc ] init ];
	[ ctr parseCrontab: cronData ];
	[ self assertNotNil: [ controller currentCrontab ]];
}


- (void)testOpenSystemCrontab {
	[ controller openSystemCrontab ];
	[ self assertNotNil: [ controller currentCrontab ]];	
}

@end
