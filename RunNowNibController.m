#import "RunNowNibController.h"

@implementation RunNowNibController


static RunNowNibController *sharedInstance = nil;


+ (RunNowNibController *)sharedInstance {
    return sharedInstance ? sharedInstance : [[self alloc] init];
}

/*
+ (void)showWindow {
    [ [ self sharedInstance ] showWindow ];
}

+ (void)hideWindow {
    [ [ self sharedInstance ] hideWindow ];
}
*/


- (id)init {
    if (sharedInstance) {
        [self dealloc];
    } else {
        //NSLog( @"RunNowNibController init" );
        [super init];
        sharedInstance = self;
        // load bundle at this point in order to have the text field ready when text is written to it.
        [NSBundle loadNibNamed:@"runNowPanel" owner:self];
    }
    return sharedInstance;
}

- (void)dealloc {
    [ window close ];
    [ super dealloc ];
}



// accessors

- (NSPanel *)window{
    return window;
}

- (NSTextView *)outputTextField {
    return outputTextField;
}


// workers

- (void)showWindow {
    //NSLog( @"show" );
    if ( ! [ self window ] ) {
        if (![NSBundle loadNibNamed:@"runNowPanel" owner:self])  {
            NSLog(@"Failed to load runNowPanel.nib");
            NSBeep();
            return;
        }
    }
	[ [ self window ] setMenu:nil];
    [ [ self window ] setFrameUsingName: @"runNowPanel" ];
    [ [ self window ] setFrameAutosaveName: @"runNowPanel" ];
    [ [ self window ] makeKeyAndOrderFront:nil];
}


-(void)hideWindow {
    // "window" is an NSPanel, so closing does not dispose
    //NSLog( @"hide" );
    [ [ self window ] close ];
}


@end
