#import <Cocoa/Cocoa.h>

/*!
	@class loadCrontabController
	@abstract 
	@discussion 
*/
@interface loadCrontabController : NSObject
{
/*! @var window description */
    IBOutlet NSPanel  *window;
/*! @var btCancel description */
    IBOutlet NSButton *btCancel;
/*! @var btLoad description */
    IBOutlet NSButton *btLoad;
/*! @var edUser description */
    IBOutlet NSTextField *edUser;
/*! @var username description */
    NSString *username;
/*! @var returnCode description */
    int returnCode;
}

// class methods
/*!
	@method sharedInstance
	@abstract 
	@discussion 
	@result 
*/
+ (loadCrontabController *)sharedInstance;
/*!
	@method showModalDialog
	@abstract 
	@discussion 
	@result 
*/
- (void)showModalDialog;

/*!
	@method window
	@abstract 
	@discussion 
	@result 
*/
- (NSPanel *)window;
/*!
	@method username
	@abstract 
	@discussion 
	@result 
*/
- (NSString *)username;
/*!
	@method returnCode
	@abstract 
	@discussion 
	@result 
*/
- (int)returnCode;
/*!
	@method hideWindow
	@abstract 
	@discussion 
	@result 
*/
- (void)hideWindow;

/*!
	@method beginSheetForWindow
	@abstract 
	@discussion 
	@result 
*/
- (void)beginSheetForWindow: (NSWindow *)parent;
/*!
	@method sheetDidEnd
	@abstract 
	@discussion 
	@result 
*/
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)code contextInfo:(void  *)contextInfo;


/*!
	@method loadPressed
	@abstract 
	@discussion 
	@result 
*/
- (IBAction)loadPressed:(id)sender;
/*!
	@method cancelPressed
	@abstract 
	@discussion 
	@result 
*/
- (IBAction)cancelPressed:(id)sender;
/*!
	@method defaultPressed
	@abstract 
	@discussion 
	@result 
*/
- (IBAction)defaultPressed:(id)sender;

@end
