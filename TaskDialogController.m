#import "TaskDialogController.h"
#import "SasString.h"

@implementation TaskDialogController

/*
 static id sharedInstance = nil;
 
 + (id)sharedInstance {
     return sharedInstance ? sharedInstance : [[self alloc] init];
 }
 */

-(id)init {
    [ super init ];
    [ NSBundle loadNibNamed:@"TaskDialog" owner:self ];
    
    [[ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(minuteChanged:)
						   name: MinuteChangedNotification object: nil ];
    [[ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(hourChanged:)
						   name: HourChangedNotification object: nil ];
    [[ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(mdayChanged:)
						   name: MdayChangedNotification object: nil ];
    [[ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(monthChanged:)
						   name: MonthChangedNotification object: nil ];
    [[ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(wdayChanged:)
						   name: WdayChangedNotification object: nil ];
    [[ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(commandChanged:)
						   name: CommandChangedNotification object: nil ];
    return self;
}


- (void)dealloc {
    [[ NSNotificationCenter defaultCenter ] removeObserver: self ];
    [ window close ];
    [ task release ];
    [ super dealloc ];
}


// accessors

- (id)window {
    if ( ! window ) {
        if (![NSBundle loadNibNamed:@"TaskDialog" owner:self])  {
            NSLog(@"Failed to load TaskDialog.nib");
            NSBeep();
            return nil;
        }
    }
    return window;
}

- (TaskObject *)task {
    return task;
}

- (void)setTask: (TaskObject *)aValue {
    if ( task != aValue ) {
        [ task release ];
	// make a copy so we can discard it if the user cancels the action
        task = [ aValue copy ];
	
	[ minuteSlider setIntValue: [[ task minute ] intValue ]];
	[ hourSlider setIntValue:   [[ task hour ] intValue ]];
	[ mdaySlider setIntValue:   [[ task mday ] intValue ]];
	[ monthSlider setIntValue:  [[ task month ] intValue ]];
	
	[ anyMinuteCheckbox setState: [[ task minute ] isEqual: @"*" ] ];
	[ anyHourCheckbox   setState: [[ task hour ] isEqual: @"*" ] ];
	[ anyMdayCheckbox   setState: [[ task mday ] isEqual: @"*" ] ];
	[ anyMonthCheckbox  setState: [[ task month ] isEqual: @"*" ] ];
	[ anyWdayCheckbox   setState: [[ task wday ] isEqual: @"*" ] ];
	
	[ simpleMinuteTextField setStringValue:  [ task minute ]];
	[ simpleHourTextField setStringValue:    [ task hour ]];
	[ simpleMdayTextField setStringValue:    [ task mday ]];
	[ simpleMonthTextField setStringValue:   [ task month ]];
	
	[ minuteTextField setStringValue:  [ task minute ]];
	[ hourTextField setStringValue:    [ task hour ]];
	[ mdayTextField setStringValue:    [ task mday ]];
	[ monthTextField setStringValue:   [ task month ]];
	[ wdayTextField setStringValue:    [ task wday ]];
	[ commandTextField setStringValue: [ task command ]];
	
	[ self setWdayCheckboxState: [ task wday ]];
	
	NSString *pattern = [ NSString stringWithFormat: @"%@*", openCommand ];
	[ openCheckbox setState: [[ task command ] isLike: pattern ]];
    }
}


// IB actions

- (IBAction)acceptButtonClicked:(id)sender {
    [ NSApp endSheet: [ self window ] returnCode: NSOKButton ];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [ NSApp endSheet: [ self window ] returnCode: NSCancelButton ];
}

- (IBAction)anyMinuteCheckboxClicked:(id)sender {
    if ( [ sender state ] == YES ) {
	[ minuteSlider setIntValue: [ minuteSlider minValue ] ];
	[[ NSNotificationCenter defaultCenter ] postNotificationName: MinuteChangedNotification object: @"*" ];
    }
}

- (IBAction)anyHourCheckboxClicked:(id)sender {
    if ( [ sender state ] == YES ) {
	[ hourSlider setIntValue: [ hourSlider minValue ] ];
	[[ NSNotificationCenter defaultCenter ] postNotificationName: HourChangedNotification object: @"*" ];
    }
}

- (IBAction)anyMdayCheckboxClicked:(id)sender {
    if ( [ sender state ] == YES ) {
	[ mdaySlider setIntValue: [ mdaySlider minValue ] ];
	[[ NSNotificationCenter defaultCenter ] postNotificationName: MdayChangedNotification object: @"*" ];
    }
}

- (IBAction)anyMonthCheckboxClicked:(id)sender {
    if ( [ sender state ] == YES ) {
	[ monthSlider setIntValue: [ monthSlider minValue ] ];
	[[ NSNotificationCenter defaultCenter ] postNotificationName: MonthChangedNotification object: @"*" ];
    }
}

- (IBAction)anyWdayCheckboxClicked:(id)sender {
    if ( [ sender state ] == YES ) {
	[ self setWdayCheckboxStates: NO ];
	[[ NSNotificationCenter defaultCenter ] postNotificationName: WdayChangedNotification object: @"*" ];
    }
}

- (IBAction)wdayCheckboxClicked:(id)sender {
    [[ NSNotificationCenter defaultCenter ] postNotificationName: WdayChangedNotification
							  object: [ self generateWdayString ] ];
}


- (void)sliderMoved:(id)sender {
    int tag = [ sender tag ];
    NSString *val = [ NSString stringWithFormat: @"%i", [ sender intValue ] ];
    switch ( tag ) {
	case 0 : // minute
	    [ simpleMinuteTextField setStringValue: val ];
	    [ anyMinuteCheckbox setState: NO ];
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: MinuteChangedNotification
								  object: val ];
	    break;
	case 1 : // hour
	    [ simpleHourTextField setStringValue: val ];
	    [ anyHourCheckbox setState: NO ];
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: HourChangedNotification
								  object: val ];
	    break;
	case 2 : // mday
	    [ simpleMdayTextField setStringValue: val ];
	    [ anyMdayCheckbox setState: NO ];
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: MdayChangedNotification
								  object: val ];
	    break;
	case 3 : // month
	    [ simpleMonthTextField setStringValue: val ];
	    [ anyMonthCheckbox setState: NO ];
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: MonthChangedNotification
								  object: val ];
	    break;
    }
}


- (IBAction)openCheckboxClicked:(id)sender {
    [ self checkOpenCheckboxState ];
}


- (IBAction)browseButtonClicked:(id)sender {
    int result;
    //NSArray *fileTypes = [NSArray arrayWithObject:@"app"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [ oPanel setAllowsMultipleSelection: NO ];
    [ oPanel setPrompt: NSLocalizedString( @"Insert", @"Insert program std file open dialog: alternative label for open button" ) ];
    result = [ oPanel runModalForDirectory: NSHomeDirectory() file: nil types: nil ];
    if ( result == NSOKButton ) {
        NSString *fname = [[ oPanel filenames ] objectAtIndex: 0 ];
	if ( [ fname isLike: @"* *" ] )
	    fname = [ NSString stringWithFormat: @"\"%@\"", fname ];
	
	NSString *command;
	if ( [ openCheckbox state ] == YES ) {
	    command = [ NSString stringWithFormat: @"%@ %@", openCommand, fname ];
	} else {
	    command = fname;
	}
	[[ NSNotificationCenter defaultCenter ] postNotificationName: CommandChangedNotification object: command ];
    }	
}

// workers

-(void)hideWindow {
    // "window" is an NSPanel, so closing does not dispose
    [ [ self window ] close ];
}


- (void)modalForWindow: (NSWindow *)parent {
    [ NSApp beginSheet: [ self window ] modalForWindow: parent modalDelegate: self
        didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil ];
}


- (NSString *)generateWdayString {
    NSMutableArray *arr = [[ NSMutableArray alloc ] init ];
    if ( [ moCheckbox state ] ) [ arr addObject: @"1" ];
    if ( [ tuCheckbox state ] ) [ arr addObject: @"2" ];
    if ( [ weCheckbox state ] ) [ arr addObject: @"3" ];
    if ( [ thCheckbox state ] ) [ arr addObject: @"4" ];
    if ( [ frCheckbox state ] ) [ arr addObject: @"5" ];
    if ( [ saCheckbox state ] ) [ arr addObject: @"6" ];
    if ( [ suCheckbox state ] ) [ arr addObject: @"7" ];
    return [ arr componentsJoinedByString: @"," ];
}


- (void)setWdayCheckboxStates: (BOOL)state {
    [ moCheckbox setState: state ];
    [ tuCheckbox setState: state ];
    [ weCheckbox setState: state ];
    [ thCheckbox setState: state ];
    [ frCheckbox setState: state ];
    [ saCheckbox setState: state ];
    [ suCheckbox setState: state ];
}


- (void)setWdayCheckboxState: (NSString *)string {
    [ self setWdayCheckboxStates: NO ];
    NSArray *arr = [ string componentsSeparatedByString: @"," ];
    NSEnumerator *enumerator = [ arr objectEnumerator ];
    id anObject;
    while ( anObject = [ enumerator nextObject ] ) {
	if ( ! [ anObject startsWithNumber ] ) continue;
	switch ( [ anObject intValue ] ) {
	    case 1 :
		[ moCheckbox setState: YES ];
		break;
	    case 2 :
		[ tuCheckbox setState: YES ];
		break;
	    case 3 :
		[ weCheckbox setState: YES ];
		break;
	    case 4 :
		[ thCheckbox setState: YES ];
		break;
	    case 5 :
		[ frCheckbox setState: YES ];
		break;
	    case 6 :
		[ saCheckbox setState: YES ];
		break;
	    case 0 :
	    case 7 :
		[ suCheckbox setState: YES ];
		break;
	    default :
		break;
	}
    }
}


- (void)checkOpenCheckboxState {
    NSString *pattern = [ NSString stringWithFormat: @"%@*", openCommand ];
    NSString *newCommand = nil;
    NSString *command = [ commandTextField stringValue ];
    if ( [ openCheckbox state ] == YES ) {
	if ( ! [ command isLike: pattern ] ) { // if there's no "open", prepend it
	    newCommand = [ NSString stringWithFormat: @"%@ %@", openCommand, command ];
	}
    } else {
	if ( [ command isLike: pattern ] ) { // if there's an "open", remove it
	    newCommand = [ command substringFromIndex: [ openCommand length ]+1 ];
	}
    }
    if ( newCommand )
	[[ NSNotificationCenter defaultCenter ] postNotificationName: CommandChangedNotification
							      object: newCommand ];
}


// notification handlers


- (void)minuteChanged:(NSNotification *)aNotification {
    id val = [ aNotification object ];
    [[ self task ] setMinute: val ];
    [ minuteTextField setStringValue: val ];
    [ simpleMinuteTextField setStringValue: val ];
    [ minuteSlider setIntValue: [ val intValue ] ];
    [ anyMinuteCheckbox setState: [ val isEqual: @"*" ] ];
}

- (void)hourChanged:(NSNotification *)aNotification {
    id val = [ aNotification object ];
    [[ self task ] setHour: val ];
    [ hourTextField setStringValue: val ];
    [ simpleHourTextField setStringValue: val ];
    [ hourSlider setIntValue: [ val intValue ] ];
    [ anyHourCheckbox setState: [ val isEqual: @"*" ] ];
}

- (void)mdayChanged:(NSNotification *)aNotification {
    id val = [ aNotification object ];
    [[ self task ] setMday: val ];
    [ mdayTextField setStringValue: val ];
    [ simpleMdayTextField setStringValue: val ];
    [ mdaySlider setIntValue: [ val intValue ] ];
    [ anyMdayCheckbox setState: [ val isEqual: @"*" ] ];
}

- (void)monthChanged:(NSNotification *)aNotification {
    id val = [ aNotification object ];
    [[ self task ] setMonth: val ];
    [ monthTextField setStringValue: val ];
    [ monthSlider setIntValue: [ val intValue ] ];
    [ simpleMonthTextField setStringValue: val ];
    [ anyMonthCheckbox setState: [ val isEqual: @"*" ] ];
}

- (void)wdayChanged:(NSNotification *)aNotification {
    id val = [ aNotification object ];
    [[ self task ] setWday: val ];
    [ wdayTextField setStringValue: val ];
    [ self setWdayCheckboxState: val ];
    [ anyWdayCheckbox setState: [ val isEqual: @"*" ] ];
}

- (void)commandChanged:(NSNotification *)aNotification {
    id val = [ aNotification object ];
    [[ self task ] setCommand: val ];
    
    NSString *pattern = [ NSString stringWithFormat: @"%@*", openCommand ];
    [ openCheckbox setState: [ val isLike: pattern ]];
    
    if ( ! [[ commandTextField stringValue ] isEqualToString: val ] )
	[ commandTextField setStringValue: val ];
}



- (void)controlTextDidChange:(NSNotification *)aNotification {
    id editor = [[ aNotification userInfo ] objectForKey:@"NSFieldEditor" ];
    
    // there are for some reason two subviews between the text fiel and the current field editor
    id textView = [[ editor superview ] superview ];
    
    // all controls that change a certain field are assigned the same 'tag' in IB
    // this saves the hassle of interconnecting all the controls with the controller
    int tag = [ textView tag ];
    NSString *val = [ textView stringValue ];
    
    switch ( tag ) {
	case 0 : // minute controls
	    if ( [ val intValue ] != nil ) {
		if ( [ val intValue ] < 0 ) val = @"0";
		if ( [ val intValue ] > 59 ) val = @"59";
	    }
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: MinuteChangedNotification object: val ];
	    break;
	case 1 : // hour controls
	    if ( [ val intValue ] != nil ) {
		if ( [ val intValue ] < 0 ) val = @"0";
		if ( [ val intValue ] > 23 ) val = @"23";
	    }
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: HourChangedNotification object: val ];
	    break;
	case 2 : // mday controls
	    if ( [ val intValue ] != nil ) {
		if ( [ val intValue ] < 1 ) val = @"1";
		if ( [ val intValue ] > 31 ) val = @"31";
	    }
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: MdayChangedNotification object: val ];
	    break;
	case 3 : // month controls
	    if ( [ val intValue ] != nil ) {
		if ( [ val intValue ] < 1 ) val = @"1";
		if ( [ val intValue ] > 12 ) val = @"12";
	    }
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: MonthChangedNotification object: val ];
	    break;
	case 4 : // wday controls
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: WdayChangedNotification object: val ];
	    break;
	case 9 : // command controls
	    [[ NSNotificationCenter defaultCenter ] postNotificationName: CommandChangedNotification object: val ];
	    break;
    }
}



@end
