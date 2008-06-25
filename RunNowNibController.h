#import <Cocoa/Cocoa.h>

/*!
	@class RunNowNibController
	@abstract 
	@discussion 
*/
@interface RunNowNibController : NSObject {
/*! @var window description */
    IBOutlet NSPanel  		*window;
/*! @var outputTextField description */
    IBOutlet NSTextView		*outputTextField;
}


/*!
	@method sharedInstance
	@abstract 
	@discussion 
	@result 
*/
+ (RunNowNibController *)sharedInstance;
/*!
	@method showWindow
	@abstract 
	@discussion 
	@result 
*/
//+ (void)showWindow;
/*!
	@method hideWindow
	@abstract 
	@discussion 
	@result 
*/
//+ (void)hideWindow;

// accessors
/*!
	@method window
	@abstract 
	@discussion 
	@result 
*/
- (NSPanel *)window;
/*!
	@method outputTextField
	@abstract 
	@discussion 
	@result 
*/
- (NSTextView *)outputTextField;

// workers
/*!
	@method showWindow
	@abstract 
	@discussion 
	@result 
*/
- (void)showWindow;
/*!
	@method hideWindow
	@abstract 
	@discussion 
	@result 
*/
- (void)hideWindow;


@end
