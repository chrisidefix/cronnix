//
//  SwitchFormatter.m
//  CronniX
//
//  Created by sas on Sat Sep 15 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "SwitchFormatter.h"


@implementation SwitchFormatter

- (NSString *)stringForObjectValue: (id)obj {
    //NSLog( @"inside SwitchFormatter:stringForObjectValue: %@", [ obj description ] );
    if ( ! [ obj isKindOfClass: [ NSButtonCell class ] ] ) {
        return [ obj description ];
    }
    return [ obj stringValue ];
}


/*- (BOOL)getObjectValue: (id *)obj
    forString: (NSString *)string
    errorDescription: (NSString **)error { */
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error {

    BOOL retval = NO;
    NSString *err = nil;

    NSLog( @"inside SwitchFormatter:getObjectValue" );

    if (obj) {
        if ( [ string isEqualTo: @"1" ] ) {
            [ *obj setState: 1 ];
        } else {
            [ *obj setState: 0 ];
        }
        retval = YES;
    } else {
            err = NSLocalizedString(@"Couldn't convert value", @"Error converting");
    }
    
    if (error) {
        *error = err;
    }
    return retval;
    
}

- (NSAttributedString *)attributedStringForObjectValue: (id)obj
    withDefaultAttributes: (NSDictionary *)attr {
    return [ [ [ NSAttributedString alloc ] initWithString: [ self stringForObjectValue: obj ] ] autorelease ];
}


@end
