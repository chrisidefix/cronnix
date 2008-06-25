/* NewTaskDialogController */

#import <Cocoa/Cocoa.h>
#import "TaskDialogController.h"

@interface NewTaskDialogController : TaskDialogController {
}

// delegates

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)context;

@end
