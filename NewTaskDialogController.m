#import "NewTaskDialogController.h"
#import "TaskObject.h"

@implementation NewTaskDialogController

/*
+ (id)sharedInstance {
	self = [ super sharedInstance ];
	[ submitButton setTitle: NSLocalizedString( @"New", @"New task dialog submit button text" ) ];
	return self;
}
*/

- (id)initWithTask: (TaskObject *)aTask {
	[ super init ];
	[ self setTask: aTask ];
	[ submitButton setTitle: NSLocalizedString( @"New", @"New task dialog submit button text" ) ];
	return self;
}

// delegates

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)context {
	TaskObject *newtask;
	switch ( returnCode ) {
		case NSCancelButton :
			break;
		case NSOKButton :
			newtask = [ TaskObject taskWithTask: [ self task ]];
			[[ NSNotificationCenter defaultCenter ] postNotificationName: TaskCreatedNotification
														 object: newtask ];
			break;
    }
    [sheet orderOut:nil];
}


@end
