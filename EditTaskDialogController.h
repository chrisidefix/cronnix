/* EditTaskDialogController */

#import <Cocoa/Cocoa.h>
#import "TaskDialogController.h"

@interface EditTaskDialogController : TaskDialogController {
}

//+ (id)sharedInstanceWithTask: (id)aTask;

- (id)initWithTask: (TaskObject *)aTask;

// delegates

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)context;

@end
