#import "EditTaskDialogController.h"
#import "TaskObject.h"

@implementation EditTaskDialogController

- (id)initWithTask: (TaskObject *)aTask {
	[ super init ];
	[ self setTask: aTask ];
	[ submitButton setTitle: NSLocalizedString( @"Apply", @"Edit task dialog submit button text" ) ];
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
			[[ NSNotificationCenter defaultCenter ] postNotificationName: TaskEditedNotification
														 object: newtask ];
			break;
    }
    [sheet orderOut:nil];
}


@end
