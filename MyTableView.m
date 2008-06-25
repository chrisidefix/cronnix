#import "MyTableView.h"

@implementation MyTableView

- (void)rightMouseDown: (NSEvent *)event {
    NSPoint p = [ self convertPoint: [ event locationInWindow ] fromView: nil ];
    int row = [ self rowAtPoint: p ];
    [ self selectRow: row byExtendingSelection: NO ];

    [ super rightMouseDown: event ];
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
	return NSDragOperationGeneric | NSDragOperationCopy | NSDragOperationMove;
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation {
	[[ self delegate ] draggedImage: anImage endedAt: aPoint operation: operation ];
}

@end
