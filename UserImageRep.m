//
//  UserImage.m
//  CronniX
//
//  Created by sas on Sun Jun 10 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "UserImageRep.h"


@implementation UserImageRep

- (id)initWithUserName: (NSString *)username {
    [ self setUser: username ];
    return [ self init ];
}

- (id)init {
    return [ self initWithDrawSelector: @selector(draw) delegate: self ];
}

- (id)initWithDrawSelector: (SEL)method delegate: (id)object {
    if ( self = [ super initWithDrawSelector: method delegate: object ] ) {
    }
    return self;
}

- (void)dealloc {
    [ user release ];
}

- (void) setUser: (NSString *)name {
    [ user autorelease ];
    if ( name )
        user = [ name copy ];
    else
        user = [ [ NSString alloc ] initWithString: @"" ];
}

- (NSString *)user {
    return user;
}


- (BOOL)draw {
    NSMutableDictionary *attrs = [ NSMutableDictionary dictionary ];
    [ attrs setObject: [ NSFont systemFontOfSize: 10 ] forKey: NSFontAttributeName ];
    [ @"Crontab for user:" drawAtPoint: NSMakePoint( 5, 15 ) withAttributes: attrs ];
    [ attrs setObject: [ NSColor blueColor ] forKey: NSForegroundColorAttributeName ];
    [ [ self user ] drawAtPoint: NSMakePoint( 5, 5 ) withAttributes: attrs ];
    return YES;
}

@end
