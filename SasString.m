//
//  SasString.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sat Jan 04 2003.
//  Copyright (c) 2003 Koch und Schmidt Systemtechnik GbR. All rights reserved.
//

#import "SasString.h"


@implementation NSString( SasString )

- (BOOL)startsWithNumber {
	if ( [ self length ] < 1 ) return NO;
	
	unichar firstChar;
	[ self getCharacters: &firstChar range: NSMakeRange( 0, 1 ) ];

	id numberSet = [ NSCharacterSet decimalDigitCharacterSet ];

	return [ numberSet characterIsMember: firstChar ];
}

- (int)fieldCountSeperatedBy: (NSCharacterSet *)charSet  {
    NSScanner *scanner = [ NSScanner scannerWithString: self ];
    NSString *dummy;
    int fieldCount = 0;
    while ( [ scanner scanUpToCharactersFromSet: charSet intoString: &dummy ] ) {
	fieldCount++;
    }
    return fieldCount;
}

- (BOOL)startsWithStringIgnoringWhitespace: (NSString *)string {
    id trimmedString = [ self stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceCharacterSet ]];
    id pattern = [ NSString stringWithFormat: @"%@*", string ];
    return [ trimmedString isLike: pattern ];
}


- (BOOL)startsWithString: (NSString *)string {
    id pattern = [ NSString stringWithFormat: @"%@*", string ];
    return [ self isLike: pattern ];
}


- (NSString *)stringByTrimmingWhitespaceAndNewline {
	return [ self stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]];
}


@end
