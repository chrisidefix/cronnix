//
//  EnvVariableTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Thu Mar 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "EnvVariableTest.h"

NSString *envType1 = @"ENV1= value\n";
NSString *envType2 = @"ENV2= value +more\n";
NSString *envType3 = @"ENV3=value\n";
NSString *envType4 = @"ENV4=value +more\n";
NSString *envType5 = @"ENV5 = value";
NSString *envType6 = @"ENV6 = value +more";
NSString *envType7 = @"ENV7 =value";
NSString *envType8 = @"ENV8 =value +more";


@implementation EnvVariableTest

- (void)testBugReport_NoelJackson_20041014 {
  NSString * s = 
  @"  23     5       *       *       3,7     /Library/MySQL/bin/mysqldump --user=noel --password=blank --port=3360 --all-databases --host=127.0.0.1 > ~/Sites/MySQLDump.sql\n";
  [ self assertTrue: ! [ EnvVariable isContainedInString: s ] ];
}


- (void)testDescription {
	id env = [ EnvVariable envVariableWithString: envType1 ];
	[ self assert: [ env description ] equals: @"ENV1 = value" ];
}

- (void)testData {
	id env = [ EnvVariable envVariableWithString: envType1 ];
	id string = [[ NSString alloc ] initWithData: [ env data ] encoding: [ NSString defaultCStringEncoding]];
	[ self assert: string equals: @"ENV1 = value" ];
}

- (void)testInitWithStringType1 {
	id env = [ EnvVariable envVariableWithString: envType1 ];
	[ self assert: [ env key ] equals: @"ENV1" ];
	[ self assert: [ env value ] equals: @"value" ];
}

- (void)testInitWithStringType2 {
	id env = [ EnvVariable envVariableWithString: envType2 ];
	[ self assert: [ env key ] equals: @"ENV2" ];
	[ self assert: [ env value ] equals: @"value +more" ];
}

- (void)testInitWithStringType3 {
	id env = [ EnvVariable envVariableWithString: envType3 ];
	[ self assert: [ env key ] equals: @"ENV3" ];
	[ self assert: [ env value ] equals: @"value" ];
}

- (void)testInitWithStringType4 {
	id env = [ EnvVariable envVariableWithString: envType4 ];
	[ self assert: [ env key ] equals: @"ENV4" ];
	[ self assert: [ env value ] equals: @"value +more" ];
}

- (void)testInitWithStringType5 {
	id env = [ EnvVariable envVariableWithString: envType5 ];
	[ self assert: [ env key ] equals: @"ENV5" ];
	[ self assert: [ env value ] equals: @"value" ];
}

- (void)testInitWithStringType6 {
	id env = [ EnvVariable envVariableWithString: envType6 ];
	[ self assert: [ env key ] equals: @"ENV6" ];
	[ self assert: [ env value ] equals: @"value +more" ];
}

- (void)testInitWithStringType7 {
	id env = [ EnvVariable envVariableWithString: envType7 ];
	[ self assert: [ env key ] equals: @"ENV7" ];
	[ self assert: [ env value ] equals: @"value" ];
}

- (void)testInitWithStringType8 {
	id env = [ EnvVariable envVariableWithString: envType8 ];
	[ self assert: [ env key ] equals: @"ENV8" ];
	[ self assert: [ env value ] equals: @"value +more" ];
}

@end
