#import "loadCrontabController.h"

NSString *locUserSelectedNotification = @"UserSelected";


@implementation loadCrontabController

static loadCrontabController *sharedInstance = nil;

// class methods

+ (loadCrontabController *)sharedInstance {
    return sharedInstance ? sharedInstance : [[self alloc] init];
}

//

- (id)init {
    if (sharedInstance) {
	[self dealloc];
    } else {
        //NSLog( @"init" );
        [super init];
        sharedInstance = self;
    }
    return sharedInstance;
}

- (void)dealloc {
    [ [ self window ] close ];
    if ( username ) [ username release ];
    [ super dealloc ];
}

- (NSPanel *)window {
    return window;
}

- (NSString *)username {
    return username;
}

- (int)returnCode {
    return returnCode;
}

-(void)hideWindow {
    // "window" is an NSPanel, so closing does not dispose
    //NSLog( @"hide" );
    [ NSApp stopModal ];
    [ window close ];
}


- (void)showModalDialog {
    //NSLog( @"show" );
    if ( ! window ) {
        if (![NSBundle loadNibNamed:@"LoadCrontabWindow" owner:self])  {
            NSLog(@"Failed to load LoadCrontabWindow.nib");
            NSBeep();
            return;
        }
	[ window setMenu:nil];
    }
    [ NSApp runModalForWindow: [ self window ] ];
}


- (void)beginSheetForWindow: (NSWindow *)parent {
    if ( ! window ) {
        if (![NSBundle loadNibNamed:@"LoadCrontabWindow" owner:self])  {
            NSLog(@"Failed to load LoadCrontabWindow.nib");
            NSBeep();
            return;
        }
	[ window setMenu:nil];
    }
    [ NSApp beginSheet: window modalForWindow: parent modalDelegate: self 
        didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil ];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)code contextInfo:(void  *)contextInfo {
    //NSLog( @"in here, code: %i", code );
    [ username release ];
    returnCode = code;
    switch ( code ) {
    case 0: // cancel
        username = nil;
        break;
    case 1: // load
        username = [ [ NSString alloc ] initWithString: [ edUser stringValue ] ];
        break;
    case 2: // default
        username = nil;
        break;
    }
    [sheet orderOut:nil];
    [ [ NSNotificationCenter defaultCenter ] postNotificationName: locUserSelectedNotification object: self ];
}



// control actions

- (IBAction)cancelPressed:(id)sender {
    /*
    username = nil;
    [ self hideWindow ];
    returnCode = 0;
    */
    
    username = nil;
    [ NSApp endSheet: [ self window ] returnCode: 0 ];
}

- (IBAction)loadPressed:(id)sender {
    /*
    if ( username ) [ username release ];
    username = [ [ NSString alloc ] initWithString: [ edUser stringValue ] ];
    [ self hideWindow ];
    returnCode = 1;
    */
    
    [ NSApp endSheet: [ self window ] returnCode: 1 ];
}

- (IBAction)defaultPressed:(id)sender {
    /*
    username = nil;
    [ self hideWindow ];
    returnCode = 2;
    */
    
    username = nil;
    [ NSApp endSheet: [ self window ] returnCode: 2 ];
}



// delegates

// text field

- (void)controlTextDidChange:(NSNotification *)aNotification {
    [ btLoad setEnabled: ! [ [ edUser stringValue ] isEqualToString: @"" ] ];
}


@end
