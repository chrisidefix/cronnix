/* TaskDialogController */

#import <Cocoa/Cocoa.h>
#import "TaskObject.h"

static NSString *TaskCreatedNotification __attribute__ ((unused)) = @"TaskCreated";
static NSString *TaskEditedNotification __attribute__ ((unused)) = @"TaskEdited";

static NSString *MinuteChangedNotification __attribute__ ((unused)) = @"MinuteChanged";
static NSString *HourChangedNotification __attribute__ ((unused)) = @"HourChanged";
static NSString *MdayChangedNotification __attribute__ ((unused)) = @"MdayChanged";
static NSString *MonthChangedNotification __attribute__ ((unused)) = @"MonthChanged";
static NSString *WdayChangedNotification __attribute__ ((unused)) = @"WdayChanged";
static NSString *CommandChangedNotification __attribute__ ((unused)) = @"CommandChanged";

static NSString *openCommand __attribute__ ((unused)) = @"/usr/bin/open";

@interface TaskDialogController : NSObject {
  IBOutlet id anyHourCheckbox;
  IBOutlet id anyMdayCheckbox;
  IBOutlet id anyMinuteCheckbox;
  IBOutlet id anyMonthCheckbox;
  IBOutlet id anyWdayCheckbox;
  IBOutlet id browseButton;
  IBOutlet id commandTextField;
  IBOutlet id frCheckbox;
  IBOutlet id hourSlider;
  IBOutlet id hourTextField;
  IBOutlet id mdaySlider;
  IBOutlet id mdayTextField;
  IBOutlet id minuteSlider;
  IBOutlet id minuteTextField;
  IBOutlet id moCheckbox;
  IBOutlet id monthSlider;
  IBOutlet id monthTextField;
  IBOutlet id openCheckbox;
  IBOutlet id saCheckbox;
  IBOutlet id simpleHourTextField;
  IBOutlet id simpleMdayTextField;
  IBOutlet id simpleMinuteTextField;
  IBOutlet id simpleMonthTextField;
  IBOutlet id suCheckbox;
  IBOutlet id thCheckbox;
  IBOutlet id tuCheckbox;
  IBOutlet id wdayTextField;
  IBOutlet id weCheckbox;
  IBOutlet id submitButton;
  IBOutlet id window;
  
	TaskObject *task;
}

// constructors

//+ (id)sharedInstance;

//- (id)initWithTask: (TaskObject *)aTask;

// accessors
- (id)window;

- (TaskObject *)task;

- (void)setTask: (TaskObject *)aVal;

//workers

- (void)hideWindow;

- (void)modalForWindow: (NSWindow *)parent;

- (NSString *)generateWdayString;

- (void)checkOpenCheckboxState;

- (void)setWdayCheckboxState: (NSString *)string;
- (void)setWdayCheckboxStates: (BOOL)state;


// notification handlers

- (void)minuteChanged:(NSNotification *)aNotification;
- (void)hourChanged:(NSNotification *)aNotification;
- (void)mdayChanged:(NSNotification *)aNotification;
- (void)monthChanged:(NSNotification *)aNotification;
	

// IB actions

- (IBAction)acceptButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)browseButtonClicked:(id)sender;
- (IBAction)anyMinuteCheckboxClicked:(id)sender;
- (IBAction)anyHourCheckboxClicked:(id)sender;
- (IBAction)anyMdayCheckboxClicked:(id)sender;
- (IBAction)anyMonthCheckboxClicked:(id)sender;
- (IBAction)anyWdayCheckboxClicked:(id)sender;
- (IBAction)wdayCheckboxClicked:(id)sender;
- (IBAction)sliderMoved:(id)sender;
- (IBAction)openCheckboxClicked:(id)sender;


@end
