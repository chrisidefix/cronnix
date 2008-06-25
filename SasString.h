//
//  SasString.h
//  CronniX
//
//  Created by Sven A. Schmidt on Sat Jan 04 2003.
//  Copyright (c) 2003 Koch und Schmidt Systemtechnik GbR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString( SasString )

- (BOOL)startsWithNumber;
- (int)fieldCountSeperatedBy: (NSCharacterSet *)charSet;
- (BOOL)startsWithStringIgnoringWhitespace: (NSString *)string;
- (BOOL)startsWithString: (NSString *)string;
- (NSString *)stringByTrimmingWhitespaceAndNewline;

@end