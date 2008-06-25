//
//  CrontabTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sat Mar 23 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "CrontabTest.h"
#import "CommentLine.h"

NSString *testString =
@"ENV1= value\n"
@"ENV2= value +more\n"
@"ENV3=value\n"
@"ENV4=value +more\n"
@"ENV5 = value\n"
@"ENV6 = value +more\n"
@"ENV7 =value\n"
@"ENV8 =value +more\n"
@"@reboot atRebootCommand\n"
@"#CrInfo another test...\n"
@" 1      2       3       4       *       echo \"Happy New Year!\"\n"
@"# comment 1\n"
@"  # comment 2\n"
@"\t# comment 3\n"
@" 1      2       3       4       *       second Task\n"
@"ENV9 = value\n"
@"#CrInfo third Task\n"
@" 30\t5\t \t6       4       *       third Task\n"
@"#CrInfo inactive Task\n"
@"#CronniX 30\t5\t \t6       4       *       inactive Task\n";

NSString *normalizedTestString =
@"ENV1 = value\n"
@"ENV2 = value +more\n"
@"ENV3 = value\n"
@"ENV4 = value +more\n"
@"ENV5 = value\n"
@"ENV6 = value +more\n"
@"ENV7 = value\n"
@"ENV8 = value +more\n"
@"@reboot atRebootCommand\n"
@"#CrInfo another test...\n"
@"1\t2\t3\t4\t*\techo \"Happy New Year!\"\n"
@"# comment 1\n"
@"  # comment 2\n"
@"\t# comment 3\n"
@"1\t2\t3\t4\t*\tsecond Task\n"
@"ENV9 = value\n"
@"#CrInfo third Task\n"
@"30\t5\t6\t4\t*\tthird Task\n"
@"#CrInfo inactive Task\n"
@"#CronniX 30\t5\t6\t4\t*\tinactive Task\n";

NSString *identicalTasks =
@"A = a\n"
@"#CronniX */5    *       *       *       *       0\n"
@"#CrInfo 1.1\n"
@"#CrInfo 1.2\n"
@"0       0       1       1       *       1\n"
@"B = b\n"
@"C = c\n"
@"D = d\n"
@"#CrInfo 2.1\n"
@"0       0       1       1       *       2\n"
@"#CrInfo 3.1\n"
@"#CrInfo 3.2\n"
@"#CrInfo 3.3\n"
@"0       0       1       1       *       2\n";


@implementation CrontabTest


- (void)testBugReport_reidEllis_20050112 {
  NSString * s = @"0 1 2 3 4 test\n"
  @"@reboot 1 2 3 4 5\n";
  id ct = [[ Crontab alloc ] initWithString: s ];
  [ self assertInt: [ ct taskCount ] equals: 1 ];
}

- (void)test_dataForSystemCrontab {
  NSString * s = @"15 3 * * * root periodic daily\n";
  id ct = [[Crontab alloc] initWithString: s forUser: @"system"];
  id outString = [[NSString alloc] initWithData: [ct data] encoding: [NSString defaultCStringEncoding]];
  [self assert: outString equals: @"15	3	*	*	*	root	periodic daily\n"];
  
}


- (void)testBugReport_andreasZys_20041015 {
  NSString * s = @"15      3       *       *       *       root    periodic daily\n";
  id ct = [[ Crontab alloc ] initWithString: s forUser: @"system" ];
  [ self assertInt: [ ct taskCount ] equals: 1 ];
  id task = [ ct taskAtIndex: 0 ];
  [ self assert: [ task command ] equals: @"periodic daily" ];
}


- (void)testBugReport_NoelJackson_20041014 {
  NSString * s = 
  @"  23     5       *       *       3,7     /Library/MySQL/bin/mysqldump --user=noel --password=blank --port=3360 --all-databases --host=127.0.0.1 > ~/Sites/MySQLDump.sql\n";
  id ct = [[ Crontab alloc ] initWithString: s ];
  [ self assertInt: [ ct taskCount ] equals: 1 ];
}


- (void)testRemoveTaskWithIdenticals {
	id ct = [[ Crontab alloc ] initWithString: identicalTasks ];
	id task2 = [ ct taskAtIndex: 2 ];
	id task3 = [ ct taskAtIndex: 3 ];
	[ ct removeTask: task2 ];
	[ self assertInt: [ ct taskCount ] equals: 3 ];
	[ self assert: [ ct taskAtIndex: 2 ] equals: task3 ];
}


- (void)testAddEnvToEmptyCrontab {
	id ct = [[ Crontab alloc ] init ];
	id env = [ EnvVariable envVariableWithString: @"newKey=testvalue" ];
	[ ct addEnvVariable: env ];
	[ self assertInt: [ ct envVariableCount ] equals: 1 ];
	[ self assert: [ ct envVariableAtIndex: 0 ] equals: env ];
	[ ct release ];
}


- (void)testIdenticalTasks {
	id ct = [[ Crontab alloc ] initWithString: identicalTasks ];
	[ self assertInt: [ ct taskCount ] equals: 4 ];
	[ self assertInt: [ ct envVariableCount ] equals: 4 ];
	id task2 = [ ct taskAtIndex: 2 ];
	[ self assert: [ task2 info ] equals: @"2.1" ];
	id task3 = [ ct taskAtIndex: 3 ];
	[ self assert: [ task3 info ] equals: @"3.1\n3.2\n3.3" ];
	[ ct release ];
}


- (void)testMultilineInfo {
	NSString *tab =
	    @"#CrInfo info 1\n"
		@"#CrInfo\tinfo 2\n"
		@"#CrInfo info 3\n"
		@"1 2 3 4 * a task\n";
	NSString *expectedInfo =
		@"info 1\n"
		@"info 2\n"
		@"info 3";
	id ct = [[ Crontab alloc ] initWithString: tab ];
	id task = [ ct taskAtIndex: 0 ];
	[ self assert: [ task info ] equals: expectedInfo ];
}

- (void)testIsContainedInString {
	[ self assertTrue: [ Crontab isContainedInString: testString ]];
	[ self assertTrue: [ Crontab isContainedInString: normalizedTestString ]];
	[ self assertTrue: [ Crontab isContainedInString: @"1 2 3 4 * new task" ]];
}

- (void)testAddTask {
	id aTask = [ TaskObject taskWithString: @"1 2 3 4 * new task" ];
	[ crontab addTask: aTask ];
    [ self assertInt: [ crontab taskCount ] equals: 5 message: @"wrong task count" ];
    [ self assert: [[ crontab taskAtIndex: 0 ] command ] equals: @"echo \"Happy New Year!\""
		  message: @"wrong task at index 0" ];
    [ self assert: [[ crontab taskAtIndex: 1 ] command ] equals: @"second Task"
		  message: @"wrong task at index 1" ];
    [ self assert: [[ crontab taskAtIndex: 2 ] command ] equals: @"third Task"
		  message: @"wrong task at index 2" ];
    [ self assert: [[ crontab taskAtIndex: 3 ] command ] equals: @"inactive Task"
		  message: @"wrong task at index 3" ];
    [ self assert: [[ crontab taskAtIndex: 4 ] command ] equals: @"new task"
		  message: @"wrong task at index 4" ];
}

- (void)testData {
	id data = [ crontab data ];
	id string = [[ NSString alloc ] initWithData: data encoding: [ NSString defaultCStringEncoding]];
	id expectedLines = [ normalizedTestString componentsSeparatedByString: @"\n" ];
	id outputLines = [ string componentsSeparatedByString: @"\n" ];
	[ self assertInt: [ outputLines count ] equals: [ expectedLines count ]];
	
	{
		int i = 0;
		for ( i = 0; i < [ expectedLines count ]; i++ ) {
			[ self assert: [ outputLines objectAtIndex: i ] equals: [ expectedLines objectAtIndex: i ]];
		}
	}
}


- (void)testDataLineCount {
	id data = [ crontab data ];
	id string = [[ NSString alloc ] initWithData: data encoding: [ NSString defaultCStringEncoding]];
	[ self assertInt: [[ string componentsSeparatedByString: @"\n" ] count ] 
			  equals: [[ normalizedTestString componentsSeparatedByString: @"\n" ] count ]];
}


- (void)testTaskInfo {
    id task = [ crontab taskAtIndex: 0 ];
    [ self assert: [ task info ] equals: @"another test..." ];
}


- (void)testCommentLine {
    [ self assertInt: [ crontab objectCountForClass: [ CommentLine class ]] equals: 3 ];
}


- (void)testAddEnvVariable {
    id env = [ EnvVariable envVariableWithString: @"newKey=testvalue" ];
	[ crontab addEnvVariable: env ];
	id string = [ crontab description ];
	id lines = [ string componentsSeparatedByString: @"\n" ];
	[ self assert: [ lines objectAtIndex: 7 ] equals: @"ENV8 = value +more" ];
	[ self assert: [ lines objectAtIndex: 8 ] equals: @"@reboot atRebootCommand" ];
	[ self assert: [ lines objectAtIndex: 15 ] equals: @"ENV9 = value" ];
	[ self assert: [ lines objectAtIndex: 16 ] equals: @"newKey = testvalue" ];
	[ self assert: [ lines objectAtIndex: 17 ] equals: @"#CrInfo third Task" ];
}

- (void)testInsertEnvVariable {
  id env = [ EnvVariable envVariableWithString: @"newKey=testvalue" ];
  [ crontab insertEnvVariable: env atIndex: 3 ];
  [ self assertInt: [ crontab envVariableCount ] equals: 10 message: @"wrong env variable count" ];
  [ self assert: [[ crontab envVariableAtIndex: 2 ] key ] equals: @"ENV3" message: @"wrong env at index 2" ];
  [ self assert: [[ crontab envVariableAtIndex: 3 ] key ] equals: @"newKey" message: @"wrong env at index 3" ];
  [ self assert: [[ crontab envVariableAtIndex: 4 ] key ] equals: @"ENV4" message: @"wrong env at index 4" ];
	id string = [ crontab description ];
	id lines = [ string componentsSeparatedByString: @"\n" ];
	[ self assert: [ lines objectAtIndex: 2 ] equals: @"ENV3 = value" ];
	[ self assert: [ lines objectAtIndex: 3 ] equals: @"newKey = testvalue" ];
	[ self assert: [ lines objectAtIndex: 4 ] equals: @"ENV4 = value +more" ];
}


- (void)testInsertEnvVariable2 {
  id env = [ EnvVariable envVariableWithString: @"newKey=testvalue" ];
  [ crontab insertEnvVariable: env atIndex: 8 ];
  [ self assertInt: [ crontab envVariableCount ] equals: 10 message: @"wrong env variable count" ];
  [ self assert: [[ crontab envVariableAtIndex: 7 ] key ] equals: @"ENV8" message: @"wrong env at index 7" ];
  [ self assert: [[ crontab envVariableAtIndex: 8 ] key ] equals: @"newKey" message: @"wrong env at index 8" ];
  [ self assert: [[ crontab envVariableAtIndex: 9 ] key ] equals: @"ENV9" message: @"wrong env at index 9" ];
	id string = [ crontab description ];
	id lines = [ string componentsSeparatedByString: @"\n" ];
	[ self assert: [ lines objectAtIndex: 14 ] equals: @"1	2	3	4	*	second Task" ];
	[ self assert: [ lines objectAtIndex: 15 ] equals: @"newKey = testvalue" ];
	[ self assert: [ lines objectAtIndex: 16 ] equals: @"ENV9 = value" ];
}


- (void)testInsertEnvVariable3 {
  id env = [ EnvVariable envVariableWithString: @"newKey=testvalue" ];
  [ crontab insertEnvVariable: env atIndex: 9 ];
  [ self assertInt: [ crontab envVariableCount ] equals: 10 message: @"wrong env variable count" ];
  [ self assert: [[ crontab envVariableAtIndex: 7 ] key ] 
         equals: @"ENV8" message: @"wrong env at index 7" ];
  [ self assert: [[ crontab envVariableAtIndex: 8 ] key ] 
         equals: @"ENV9" message: @"wrong env at index 8" ];
  [ self assert: [[ crontab envVariableAtIndex: 9 ] key ] 
         equals: @"newKey" message: @"wrong env at index 9" ];
	id string = [ crontab description ];
	id lines = [ string componentsSeparatedByString: @"\n" ];
	[ self assert: [ lines objectAtIndex: 14 ] equals: @"1	2	3	4	*	second Task" ];
	[ self assert: [ lines objectAtIndex: 15 ] equals: @"ENV9 = value" ];
	[ self assert: [ lines objectAtIndex: 16 ] equals: @"newKey = testvalue" ];
}


- (void)testRemoveAllEnvVariables {
    [ crontab removeAllEnvVariables ];
    [ self assertInt: [ crontab envVariableCount ] equals: 0 ];
}

- (void)testRemoveEnvVariableAtIndex {
    [ crontab removeEnvVariableAtIndex: 2 ];
    [ self assertInt: [ crontab envVariableCount ] equals: 8 message: @"wrong env variable count" ];
    [ self assert: [[ crontab envVariableAtIndex: 0 ] key ] equals: @"ENV1" message: @"wrong env at index 0" ];
    [ self assert: [[ crontab envVariableAtIndex: 1 ] key ] equals: @"ENV2" message: @"wrong env at index 1" ];
    [ self assert: [[ crontab envVariableAtIndex: 2 ] key ] equals: @"ENV4" message: @"wrong env at index 2" ];
}



- (void)testRemoveEnvVariable {
    id env = [ crontab envVariableAtIndex: 1 ];
    [ crontab removeEnvVariable: env ];
    [ self assertInt: [ crontab envVariableCount ] equals: 8 message: @"wrong env variable count" ];
    [ self assert: [[ crontab envVariableAtIndex: 0 ] key ] equals: @"ENV1" message: @"wrong env at index 0" ];
    [ self assert: [[ crontab envVariableAtIndex: 1 ] key ] equals: @"ENV3" message: @"wrong env at index 1" ];
    [ self assert: [[ crontab envVariableAtIndex: 2 ] key ] equals: @"ENV4" message: @"wrong env at index 2" ];
}


- (void)testRemoveEnvVariableWithKey {
    [ crontab removeEnvVariableWithKey: @"ENV6" ];
    [ self assertInt: [ crontab envVariableCount ] equals: 8 message: @"wrong env variable count" ];
    [ self assert: [[ crontab envVariableAtIndex: 4 ] key ] equals: @"ENV5" message: @"wrong env at index 4" ];
    [ self assert: [[ crontab envVariableAtIndex: 5 ] key ] equals: @"ENV7" message: @"wrong env at index 5" ];
    [ self assert: [[ crontab envVariableAtIndex: 6 ] key ] equals: @"ENV8" message: @"wrong env at index 6" ];
}

- (void)testRemoveEnvVariableWithNonexistingKey {
    [ crontab removeEnvVariableWithKey: @"ENV10" ];
    [ self assertInt: [ crontab envVariableCount ] equals: 9 message: @"wrong env variable count" ];
}

- (void)testReplaceTaskAtIndex {
    id aTask = [ TaskObject taskWithString: @"1 2 3 4 * new task" ];
    [ crontab replaceTaskAtIndex: 1 withTask: aTask ];
    [ self assertInt: [ crontab taskCount ] equals: 4 message: @"wrong task count" ];
    [ self assert: [[ crontab taskAtIndex: 0 ] command ] equals: @"echo \"Happy New Year!\""
	  message: @"wrong task at index 0" ];
    [ self assert: [[ crontab taskAtIndex: 1 ] command ] equals: @"new task"
	  message: @"wrong task at index 1" ];
    [ self assert: [[ crontab taskAtIndex: 2 ] command ] equals: @"third Task"
	  message: @"wrong task at index 2" ];
}



- (void)testInsertTaskAtIndex {
    id aTask = [ TaskObject taskWithString: @"1 2 3 4 * new task" ];
    [ crontab insertTask: aTask atIndex: 1 ];
    [ self assertInt: [ crontab taskCount ] equals: 5 message: @"wrong task count" ];
    [ self assert: [[ crontab taskAtIndex: 0 ] command ] equals: @"echo \"Happy New Year!\""
	  message: @"wrong task at index 0" ];
    [ self assert: [[ crontab taskAtIndex: 1 ] command ] equals: @"new task"
	  message: @"wrong task at index 1" ];
    [ self assert: [[ crontab taskAtIndex: 2 ] command ] equals: @"second Task"
	  message: @"wrong task at index 2" ];
    [ self assert: [[ crontab taskAtIndex: 3 ] command ] equals: @"third Task"
	  message: @"wrong task at index 3" ];
}


- (void)testRemoveTaskAtIndex {
    [ crontab removeTaskAtIndex: 1 ];
    [ self assertInt: [ crontab taskCount ] equals: 3 message: @"wrong task count" ];
    [ self assert: [[ crontab taskAtIndex: 0 ] command ] equals: @"echo \"Happy New Year!\""
	  message: @"wrong task at index 0" ];
    [ self assert: [[ crontab taskAtIndex: 1 ] command ] equals: @"third Task"
	  message: @"wrong task at index 1" ];
}


- (void)testWhiteSpaceTask {
    id task = [ crontab taskAtIndex: 2 ];
    [ self assert: [ task minute ] equals: @"30" ];
    [ self assert: [ task hour ] equals: @"5" ];
    [ self assert: [ task mday ] equals: @"6" ];
    [ self assert: [ task command ] equals: @"third Task" ];
}


- (void)testTaskCount {
    [ self assertInt: [ crontab taskCount ] equals: 4 ];
}

- (void)testTask {
    [ self assertNotNil: [ crontab taskAtIndex: 0 ] ];
}

- (void)testTaskMinute {
    id task = [ crontab taskAtIndex: 0 ];
    [ self assert: [ task minute ] equals: @"1" ];
}

- (void)testTaskHour {
    id task = [ crontab taskAtIndex: 0 ];
    [ self assert: [ task hour ] equals: @"2" ];
}

- (void)testTaskMonth {
    id task = [ crontab taskAtIndex: 0 ];
    [ self assert: [ task month ] equals: @"4" ];
}

- (void)testTaskMday {
    id task = [ crontab taskAtIndex: 0 ];
    [ self assert: [ task mday ] equals: @"3" ];
}

- (void)testTaskWday {
    id task = [ crontab taskAtIndex: 0 ];
    [ self assert: [ task wday ] equals: @"*" ];
}

- (void)testTaskCommand {
    id task = [ crontab taskAtIndex: 0 ];
    [ self assert: [ task command ] equals: @"echo \"Happy New Year!\"" ];
}

- (void)testEnvironmentVariablesCount {
    [ self assertInt: [ crontab envVariableCount ] equals: 9 ];
}

- (void)testEnvironmentVariableContent {
    id env = [ crontab envVariableAtIndex: 0 ];
    [ self assert: [ env key ] equals: @"ENV1" ];
    [ self assert: [ env value ] equals: @"value" ];
}

- (void)testTaskAtIndex {
    [ self assertNotNil: [ crontab taskAtIndex: 0 ]];
}


- (void)setUp {
    crontab = [[ Crontab alloc ] initWithString: testString ];
}

- (void)tearDown {
    [ crontab release ];
}



@end
