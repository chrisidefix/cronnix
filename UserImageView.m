//
//  userImageView.m
//  CronniX
//
//  Created by sas on Sun Jun 10 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "UserImageView.h"


@implementation UserImageView

- (id)init {
    return [ self initWithFrame: NSMakeRect( 0, 0, 32, 32 ) ];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [ self setUser: @"" ];
        title = [ [ NSString alloc ] initWithString: NSLocalizedString( @"Crontab for user:", @"string in status toolbar item" ) ];
        attributes = [ [ NSMutableDictionary alloc ] init ];
        [ attributes setObject: [ NSFont systemFontOfSize: 10 ] forKey: NSFontAttributeName ];
    }
    return self;
}

- (void)dealloc {
    [ user release ];
    [ title release ];
    [ attributes release ];
}

- (void) setUser: (NSString *)name {
    [ user autorelease ];
    if ( name )
        user = [ name copy ];
    else
        user = [ [ NSString alloc ] initWithString: @"" ];
    [ self setFrameSize: [ self size ] ];
}

- (NSString *)user {
    return user;
}

- (NSString *)title {
    return title;
}

- (NSMutableDictionary *)attributes {
    return attributes;
}

- (NSSize)size {
    NSSize tsize = [ title sizeWithAttributes: [ self attributes ] ];
    NSSize usize = [ user sizeWithAttributes: [ self attributes ] ];
    return NSMakeSize( ( tsize.width > usize.width ? tsize.width : usize.width ) +10, 32 );
}

- (void)drawRect:(NSRect)rect {
    int w;
    int tot_width = [ self size ].width;
    [ [ self attributes ] setObject: [ NSColor blackColor ] forKey: NSForegroundColorAttributeName ];
    w = [ title sizeWithAttributes: [ self attributes ] ].width;
    [ [ self title ] drawAtPoint: NSMakePoint( (tot_width - w)/2, 15 ) withAttributes: [ self attributes ] ];
    [ [ self attributes ] setObject: [ NSColor blueColor ] forKey: NSForegroundColorAttributeName ];
    w = [ user sizeWithAttributes: [ self attributes ] ].width;
    [ [ self user ] drawAtPoint: NSMakePoint( (tot_width - w)/2, 2 ) withAttributes: [ self attributes ] ];
}



@end
