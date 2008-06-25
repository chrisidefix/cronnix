//
//  SasStringTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SasStringTest.h"
#import "SasString.h"

@implementation SasStringTest

- (void)testStringByTrimmingWhitespaceAndNewline {
	[ self assert: [ @"\nbla test " stringByTrimmingWhitespaceAndNewline]
		   equals: @"bla test" ];
	[ self assert: [ @" bla test\n" stringByTrimmingWhitespaceAndNewline]
		   equals: @"bla test" ];
}

- (void)testStartsWithString {
    [ self assertTrue: [ @"blabla" startsWithString: @"bla" ] message: @"positive test failed" ];
    [ self assertFalse: [ @"ba" startsWithString: @"bla" ] message: @"negative test failed" ];
}

- (void)testStartsWithStringIgnoringWhitespace {
    [ self assertTrue: [ @"  bla" startsWithStringIgnoringWhitespace: @"bla" ]];
    [ self assertTrue: [ @"\tbla" startsWithStringIgnoringWhitespace: @"bla" ]];
    [ self assertFalse: [ @"ba" startsWithStringIgnoringWhitespace: @"bla" ]];
}

- (void)testFieldCount {
    NSCharacterSet *ws = [ NSCharacterSet whitespaceCharacterSet ];
    id line = @" 30\t5\t \t6       4       *       third Task\n";
    int fieldCount = [ line fieldCountSeperatedBy: ws ];
    [ self assertInt: fieldCount equals: 7 ];
}

- (void)testStartsWithNumer {
    id s = @"test";
    [ self assertFalse: [ s startsWithNumber ]];
}

@end
