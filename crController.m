//
//  crController.m
//  CronniX
//
//  Created by sas on Sat Sep 15 2001.
//  Copyright (c) 2001 Sven A. Schmidt. All rights reserved.
//
//  abstracture IT-Beratung GmbH
//  www.abstracture.de
//  sas@abstracture.de
//

#import "crController.h"
#import "loadCrontabController.h"
#import "BLAuthentication.h"
#import "UserImageRep.h"
#import "RunNowNibController.h"
#import "NewTaskDialogController.h"
#import "EditTaskDialogController.h"
#import "SasString.h"

NSString *cronCommand = @"/usr/bin/crontab";
NSString *suCrontabResource = @"sucrontab";
static NSString *cronnixHomepage = @"http://www.abstracture.de/projects-en/cronnix";


@implementation crController

- (id)init {
  if ( self = [ super init ] ) {
    [ [ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(documentModified:) 
                                                    name: DocumentModifiedNotification object: nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(userSelected:) 
                                                    name: UserSelectedNotification object: nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(taskCreated:)
                                                    name: TaskCreatedNotification object: nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver: self selector:@selector(taskEdited:)
                                                    name: TaskEditedNotification object: nil ];
  }
  return self;
}

- (void)dealloc {
  [[ NSNotificationCenter defaultCenter ] removeObserver: self ];
  [ toolbar release ];
  [ currentCrontab release ];
  [ super dealloc];
}



// --------------------------------------------------------------------------------------------------------------
// controls

- (IBAction)loadCrontab:(id)sender {
  [ self loadCrontab ];
}

- (IBAction)newLine:(id)sender {
  if ( [ [ NSApp keyWindow ] isEqual: winMain ] )
    [ self newLine ];
  if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
    [ [ envVariablesNibController sharedInstance ] newLine ];
}

- (IBAction)newLineWithDialog:(id)sender {
  if ( [ [ NSApp keyWindow ] isEqual: winMain ] )
    [ self newLineWithDialog ];
}

- (IBAction)removeLine:(id)sender {
  if ( [ [ NSApp keyWindow ] isEqual: winMain ] ) {
		int lastSelectedRow = [ crTable selectedRow ];
    
    [ self removeLinesInList: [ crTable selectedRowEnumerator ] ];
    
    int nRows = [ crTable numberOfRows ];
		int rowToSelect = lastSelectedRow < nRows ? lastSelectedRow : nRows -1;
		[ crTable selectRow: rowToSelect byExtendingSelection: NO ];
	}
  if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
    [ [ envVariablesNibController sharedInstance ] removeLine: sender ];
}


- (IBAction)duplicateLine:(id)sender {
  if ( [ [ NSApp keyWindow ] isEqual: winMain ] ) {
    [ self duplicateLinesInList: [ crTable selectedRowEnumerator ] ];
    if ( [ crTable selectedRow ] == -1 ) {
      [ crTable selectRow: [ crTable numberOfRows ] -1 byExtendingSelection: NO ];
    }
  }
  
  if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
    [ [ envVariablesNibController sharedInstance ] duplicateLine ];
}


- (IBAction)writeCrontab:(id)sender {
  [ self writeCrontab ];
}

- (IBAction)showInfoPanel:(id)sender {
  [[NSApplication sharedApplication] orderFrontStandardAboutPanel:sender];
}


- (IBAction)openForUser:(id)sender {
  [ self crontabShouldLoad ];
}

- (IBAction)openSystemCrontab:(id)sender {
  [ self systemCrontabShouldLoad ];
}

- (void)openForUser {
  [ envVariablesNibController hideWindow ];
  [ [ loadCrontabController sharedInstance ] beginSheetForWindow: winMain ];
}

- (void)crontabShouldLoad {
  if ( [ self isDirty ] ) {
    NSBeginAlertSheet(
                      NSLocalizedString( @"Unsaved Data", @"Unsaved data alert sheet title" ),
                      NSLocalizedString( @"Save", @"Save in dialog" ),
                      NSLocalizedString( @"Discard", @"discard in dialog" ),
                      NSLocalizedString( @"Cancel", @"Cancel in dialog" ),
                      winMain, self, NULL,
                      @selector(didEndLoadSheet:returnCode:contextInfo:), nil,
                      NSLocalizedString( @"You have modified your crontab. Save changes?",
                                         @"unsaved changes warning in alert sheet" ) );
  } else {
    [ self openForUser ];
  }
}

- (void)systemCrontabShouldLoad {
  if ( [ self isDirty ] ) {
    NSBeginAlertSheet(
                      NSLocalizedString( @"Unsaved Data", @"Unsaved data alert sheet title" ),
                      NSLocalizedString( @"Save", @"Save in dialog" ),
                      NSLocalizedString( @"Discard", @"discard in dialog" ),
                      NSLocalizedString( @"Cancel", @"Cancel in dialog" ),
                      winMain, self, NULL,
                      @selector(didEndLoadSytemCrontabSheet:returnCode:contextInfo:), nil,
                      NSLocalizedString( @"You have modified your crontab. Save changes?",
                                         @"unsaved changes warning in alert sheet" ) );
  } else {
    [ self openSystemCrontab ];
  }
}


- (void)crontabShouldImport {
  if ( [ self isDirty ] ) {
    NSBeginAlertSheet(
                      NSLocalizedString( @"Unsaved Data", @"Unsaved data alert sheet title" ),
                      NSLocalizedString( @"Save", @"Save in dialog" ),
                      NSLocalizedString( @"Discard", @"discard in dialog" ),
                      NSLocalizedString( @"Cancel", @"Cancel in dialog" ),
                      winMain, self, NULL,
                      @selector(didEndImportCrontabSheet:returnCode:contextInfo:), nil,
                      NSLocalizedString( @"You have modified your crontab. Save changes?",
                                         @"unsaved changes warning in alert sheet" ) );
  } else {
    [ self importCrontab ];
  }
}


- (void)didEndLoadSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  switch ( returnCode ) {
    case NSAlertDefaultReturn: // yes, save
      [ self writeCrontab ];
      [ self openForUser ];
      break;
    case NSAlertAlternateReturn: // no, discard
      [ self openForUser ];
      break;
    case NSAlertOtherReturn: // cancel, go back
      break;
  }
}

- (void)didEndLoadSytemCrontabSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  switch ( returnCode ) {
    case NSAlertDefaultReturn: // yes, save
      [ self writeCrontab ];
      [ self openSystemCrontab ];
      break;
    case NSAlertAlternateReturn: // no, discard
      [ self openSystemCrontab ];
      break;
    case NSAlertOtherReturn: // cancel, go back
      break;
  }
}


- (void)didEndImportCrontabSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  switch ( returnCode ) {
    case NSAlertDefaultReturn: // yes, save
      [ self writeCrontab ];
      [ self importCrontab ];
      break;
    case NSAlertAlternateReturn: // no, discard
      [ self importCrontab ];
      break;
    case NSAlertOtherReturn: // cancel, go back
      break;
  }
}


- (BOOL)isSystemCrontab {
  return [ [ self crontabForUser ] isEqualToString: @"system" ];
}

- (void)openSystemCrontab {
  NSFileHandle *fh = [ NSFileHandle fileHandleForReadingAtPath: @"/etc/crontab" ];
  NSData *crondata;
  if ( fh ) {
    crondata = [ fh readDataToEndOfFile ];
		if ( ! crondata ) return; // pop up an error sheet...
		[ self clearCrontab ];
    // need to set this early, because "system" parsing is slightly different
    [ self setCrontabForUser: @"system" ];
		[ self parseCrontab: crondata ];
    [ self setDirty: NO ];
  }
}

- (void)insertProgram:(id)sender {
  int result;
  //NSArray *fileTypes = [NSArray arrayWithObject:@"app"];
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];
  
  [ oPanel setAllowsMultipleSelection: YES ];
  [ oPanel setPrompt: NSLocalizedString( @"Insert", @"Insert program std file open dialog: alternative label for open button" ) ];
  result = [ oPanel runModalForDirectory: NSHomeDirectory() file: nil types: nil ];
  if (result == NSOKButton) {
    NSArray *filenames = [oPanel filenames];
    NSEnumerator *iter = [ filenames objectEnumerator ];
    NSString *fname;
    while ( fname = [ iter nextObject ] )
      [ self insertProgramWithString: fname ];
  }
}

- (void)envVariables:(id)sender {
  [ envVariablesNibController showWindow ];
}


- (void)activeButtonToggled {
  [ [ NSNotificationCenter defaultCenter ] postNotificationName: DocumentModifiedNotification object: self ];
}


- (IBAction)runSelectedCommand:(id)sender {
  [ self runSelectedCommand ];
}


- (void)runSelectedCommand {
  NSTextView *tv = [ [ RunNowNibController sharedInstance ] outputTextField ];
  NSString *cmd = [ [ self selectedTask ] objectForKey: @"Command" ];
  NSData *output;
  NSString *outputString;
  
  [ [ RunNowNibController sharedInstance ] showWindow ];
  //   NSLog( @"Running command %@", cmd );
  [ tv setEditable: YES ];
  [ tv setString: NSLocalizedString( @"Running command\n", @"Information text displayed in the runNowPanel" ) ];
  [ tv insertText: cmd ];
  [ tv insertText: NSLocalizedString( @"\nThe output will appear below when the command has finished executing\n", @"Information text displayed in the runNowPanel" ) ];
  [ tv setEditable: NO ];
  output = [ self runCliCommand: @"/bin/tcsh" WithArgs: [ NSArray arrayWithObjects: @"-c", cmd, nil ] ];
  if ( ! output )
    outputString = @"- no output from command -";
  else
    outputString = [ [ [ NSString alloc ] initWithData: output
                                              encoding: [ NSString defaultCStringEncoding ] ] autorelease ];
  //NSLog( outputString );
  [ tv setEditable: YES ];
  [ tv insertText: outputString ];
  [ tv setEditable: NO ];
  //[ outputString release ];
}




- (void)runSelectedCommandOld {
  NSTextView *tv = [ [ RunNowNibController sharedInstance ] outputTextField ];
  NSString *cmd = [ [ self selectedTask ] objectForKey: @"Command" ];
  NSData *output;
  NSString *outputString;
  
  [ [ RunNowNibController sharedInstance ] showWindow ];
  //   NSLog( @"Running command %@", cmd );
  [ tv setEditable: YES ];
  [ tv setString: NSLocalizedString( @"Running command\n", @"Information text displayed in the runNowPanel" ) ];
  [ tv insertText: cmd ];
  [ tv insertText: NSLocalizedString( @"\nThe output will appear below when the command has finished executing\n", @"Information text displayed in the runNowPanel" ) ];
  [ tv setEditable: NO ];
  output = [ self runCliCommand: @"/bin/tcsh" WithArgs: [ NSArray arrayWithObjects: @"-c", cmd, nil ] ];
  if ( ! output )
    outputString = @"- no output from command -";
  else
    outputString = [ [ [ NSString alloc ] initWithData: output 
                                              encoding: [ NSString defaultCStringEncoding ] ] autorelease ];
  //NSLog( outputString );
  [ tv setEditable: YES ];
  [ tv insertText: outputString ];
  [ tv setEditable: NO ];
  //[ outputString release ]; 
}


- (IBAction)openHomepage:(id)sender {
  [[ NSWorkspace sharedWorkspace ] openURL: [ NSURL URLWithString: cronnixHomepage ]];
}


- (IBAction)checkForUpdates:(id)sender {
  NSString *currentVersion = [[[ NSBundle bundleForClass: [ self class ]] infoDictionary ]
		objectForKey: @"CFBundleVersion" ];
  NSString *url = [ NSString stringWithFormat: @"%@/%@", cronnixHomepage, @"version.xml" ];
  NSDictionary *dict = [ NSDictionary dictionaryWithContentsOfURL: [ NSURL URLWithString: url ]];
  
  if ( ! dict ) {
    NSBeginAlertSheet(
                      NSLocalizedString( @"Connection failure",
                                         @"Check for update failure sheet title" ),
                      NSLocalizedString( @"Bummer",
                                         @"Check for update connection failure acknowledgement button title" ),
                      nil,
                      nil,
                      winMain, self, NULL,
                      nil, nil,
                      NSLocalizedString( @"Someone tripped over the wire to the internet. Or maybe it's the rain. Wait for clear skies and try again.",
                                         @"update check connection failure dialog text" ) );
  }
  
  NSString *latestVersion = [ dict valueForKey: @"Version" ];
  
  if ( ! [ latestVersion isEqualToString: currentVersion ] ) {
		id changes = [ dict objectForKey: @"Changes" ];
		
		NSString *msg = [ NSString stringWithFormat: NSLocalizedString( @"There's a new version available at %@.\n\nChanges in version %@:\n", @"new version available dialog text" ),
			cronnixHomepage, latestVersion ];
		NSString *s = [ changes componentsJoinedByString: @"\n¥ " ];
  s = [ NSString stringWithFormat: @"%@\n¥ %@", msg, s ];
  NSBeginAlertSheet(
                    NSLocalizedString( @"Update Available",
                                       @"Update available alert sheet title" ),
                    NSLocalizedString( @"Go to download page",
                                       @"go to download page button title in 'update available' dialog" ),
                    nil,
                    NSLocalizedString( @"Cancel", @"Cancel in dialog" ),
                    winMain, self, NULL,
                    @selector(didEndUpdateAvailableSheet:returnCode:contextInfo:), nil,
                    s );
  } else {
    NSBeginAlertSheet(
                      NSLocalizedString( @"No Update Available",
                                         @"No update available alert sheet title" ),
                      NSLocalizedString( @"Too bad",
                                         @"confirmation button title in 'no update available' dialog" ),
                      nil,
                      nil,
                      winMain, self, NULL,
                      nil, nil,
                      NSLocalizedString( @"There's no new version available.",
                                         @"no new version available dialog text" ) );
  }
}

// --------------------------------------------------------------------------------------------------------------
// workhorses

- (void)alertForNonExistentUser: (NSString *)user{
  NSBeginAlertSheet(
                    NSLocalizedString( @"User does not exist", @"user doesn't exist warning in open failure alert sheet" ),
                    NSLocalizedString( @"OK", @"Ok in dialog" ),
                    nil, nil, winMain, winMain, NULL, NULL, nil,
                    NSLocalizedString( @"I couldn't find a home directory for '%@' on your system. Maybe you mistyped the name or (god no!) deleted the directory. Better have look...", @"Home directory not found warning in open failure alert sheet" ),
                    user );
}

- (void)loadCrontab {
  [ self loadCrontabForUser: nil ];
}



- (void)loadCrontabForUser: (NSString *)user {
  
  if ( ! user || [ user isEqualToString: NSUserName() ] ) {
		[ self loadCrontabForDefaultUser ];
  } else if ( [ user isEqualToString: @"system" ] ) {
		[ self openSystemCrontab ];
		return;
  } else {
    NSMutableArray *args = [ NSMutableArray array ];
    NSString *cronString;
    BLAuthentication *authObj = [ BLAuthentication sharedInstance ];
		
		// best solution found to test for user existence
		NSString *userHome = NSHomeDirectoryForUser( user );
		if ( ! userHome ) {
			[ self alertForNonExistentUser: user ];
			return;
		}
    
    //NSLog( @"Loading for user %@", user );
		
    [ args addObject: @"-u" ];
    [ args addObject: user ];
    [ args addObject: @"-l" ];
		
    cronString = [ authObj executeCommand: [ self suCronCommand ] withArgs: args ];
    //NSLog( @"------- Received cronstring of length: %i", [ cronString length ] );
    //NSLog( cronString );
		
    if ( [ cronString length ] != 0 ) {
      NSData *cronData = [ NSData dataWithData: [ cronString dataUsingEncoding: [ NSString defaultCStringEncoding ] ] ];
			[ self clearCrontab ];
      [ self setCrontabForUser: user ]; // setting this before parsing is important!
      [ self parseCrontab: cronData ];
      [ self setDirty: NO ];
      //NSLog( @"Opened for user: %@", user );
    } else {
      NSBeginAlertSheet( 
                         NSLocalizedString( @"Empty Crontab", @"empty crontab alert sheet" ), 
                         NSLocalizedString( @"OK", @"Ok in dialog" ), 
                         nil, nil, winMain, winMain, NULL, NULL, nil, 
                         NSLocalizedString( @"The system returned an empty crontab for '%s'. This probably just means that there's no crontab for this user yet. Pressing OK will allow you to edit and install a new crontab and you will never see this alert sheet again. If, however, you are sure that '%s' does have a crontab, then you may have encountered an temporal anomaly. Contact the author (see the About box) and complain like there's no tomorrow.", @"descriptive text in empty crontab alert sheet (make sure translations preserve the sarcastic tone ;-)" ),
                         [ user cString ], [ user cString ] );
      [ self clearCrontab ];
      [ self setCrontabForUser: user ];
      [ self setDirty: NO ];
    }
  }
  
}

// new still testing
- (void)loadCrontabForDefaultUser {
  int status;
  NSTask *task;
  NSMutableArray *args = [ NSMutableArray array ];
  NSPipe *stdOutPipe = [ NSPipe pipe ];
  NSPipe *stdErrPipe = [ NSPipe pipe ];
  NSFileHandle *stdOutReadHandle = [ stdOutPipe fileHandleForReading ];
  NSFileHandle *stdErrReadHandle = [ stdErrPipe fileHandleForReading ];
  NSData *cronData;
  NSData *stdErrData;
  NSString *stdErrString;
  
  [ args addObject: @"-l" ];
  
  task = [[ NSTask alloc ] init ];
  [ task setCurrentDirectoryPath: @"." ];
  [ task setLaunchPath: cronCommand ];
  [ task setArguments: args ];
  [ task setStandardOutput: stdOutPipe ];
  [ task setStandardError: stdErrPipe ];
  
  [ task launch ];
  [ task waitUntilExit ];
  
  cronData = [ [ NSData alloc ] initWithData :[ stdOutReadHandle readDataToEndOfFile ] ];
  stdErrData = [ [ NSData alloc ] initWithData :[ stdErrReadHandle readDataToEndOfFile ] ];
  
  status = [ task terminationStatus ];
  [ task release ];
  
  
  stdErrString = [ [ NSString alloc ] initWithData: stdErrData encoding: [ NSString defaultCStringEncoding ] ];
  // Check for "no crontab for" in stderr: If we get this, this user doesn't have a crontab, yet. Not a problem,
  // we just parse the empty cronData below.
  if ( [ stdErrString isLike: @"*no crontab for*" ] ) {
    status = 0; // set status OK
  }
  
  
  switch ( status ) {
    case 0: // everything ok
			[ self clearCrontab ];
      [ self setCrontabForUser: nil ];
      [ self parseCrontab: cronData ];
      [ self setDirty: NO ];
      break;
    case 1: // failure (not privileged)
      NSBeginAlertSheet( 
                         NSLocalizedString( @"Failure", @"open failure alert sheet" ), 
                         NSLocalizedString( @"OK", @"Ok in dialog" ), 
                         nil, nil, winMain, winMain, NULL, NULL, nil, 
                         NSLocalizedString( @"Something prevented me from reading your crontab - maybe some ion storm in the asteroid belt. See if it's that and fix it or otherwise mail the author (see the About box) and complain like there's no tomorrow.", @"descriptive text in generic failure alert sheet. Try to get fatalism and ignorance across in translation..." ) );
      //[ self setCrontabForUser: nil ];
      break;
  }
  
  [ cronData release ];
  [ stdErrData release ];
  [ stdErrString release ];
}


- (void)clearCrontab {
  [ crTable deselectAll: nil ];
  [ currentCrontab clear ];
  [ crTable reloadData ];
  [[ envVariablesNibController sharedInstance ] clear ];
  [ infoTextField setStringValue: @"" ];
  [ self setDirty: NO ];
}



- (void)showUserColumn {
  int commandColPos = [ crTable columnWithIdentifier: [ commandColumn identifier ]];
  if ( [ crTable columnWithIdentifier: [ userColumn identifier ]] == -1 ) {
		[ crTable addTableColumn: userColumn ];
  }
  if ( commandColPos < [ crTable columnWithIdentifier: [ userColumn identifier ]] )
		[ crTable moveColumn: [ crTable columnWithIdentifier: [ userColumn identifier ]]
                toColumn: commandColPos ];	
}



- (void)hideUserColumn {
  if ( [ crTable columnWithIdentifier: [ userColumn identifier ]] != -1 )
		[ crTable removeTableColumn: userColumn ];
}



- (void)parseCrontab: (NSData *)data {
  //[ currentCrontab autorelease ];
  [ currentCrontab release ]; // culprit, but why???
  currentCrontab = [[ Crontab alloc ] initWithData: data forUser: [ self crontabForUser ] ];
  
  [ crTable reloadData ];
  
  [[ envVariablesNibController sharedInstance ] setCrontab: currentCrontab ];
  
  [ self isSystemCrontab ] ? [ self showUserColumn ] : [ self hideUserColumn ];
}


- (void)openCrontabFromFile: (NSString *)path {
  [ currentCrontab release ];
  currentCrontab = [[ Crontab alloc ] initWithContentsOfFile: path forUser: NSUserName() ];
  [ self setCrontabForUser: nil ];
  
  [ crTable reloadData ];
  
  [[ envVariablesNibController sharedInstance ] setCrontab: currentCrontab ];
  
  [ self setDirty: NO ];
}


- (id)defaultTask {
  NSString *string;
  NSString *cmd = NSLocalizedString( @"echo \"Happy New Year!\"", 
                                     @"default command for new crontab tasks" );
  if ( [ self isSystemCrontab ] ) {
    string = [NSString stringWithFormat: @"0 0 1 1 * root %@", cmd];
  } else {
    string = [NSString stringWithFormat: @"0 0 1 1 * %@", cmd];
  }
  TaskObject *task = [[TaskObject alloc] initWithString: string 
                                              forSystem: [self isSystemCrontab]];
  return [task autorelease];
}


- (void)newLineWithCommand: (NSString *)cmd {
  id task = [self defaultTask];
  [task setCommand: cmd];
  [self newLineWithTask: task];
}


- (void)newLine {
  [self newLineWithTask: [self defaultTask]];
}


- (void)newLineWithDialog {
  [ crTable deselectAll: nil ];
  id dialog = [[ NewTaskDialogController alloc ] initWithTask: [self defaultTask]];
  //[ NewTaskDialogController sharedInstance ];
  [ dialog modalForWindow: [ self window ] ];
}


- (void)newLineWithTask: (TaskObject *)aTask {
  if ( [ self isSystemCrontab ] )
		[ aTask setUser: @"root" ];
  [ currentCrontab addTask: aTask ];
  [ crTable reloadData ];
  [ crTable selectRow: [ currentCrontab indexOfTask: aTask ] byExtendingSelection: NO ];
  [ self setDirty: YES ];	
}


- (void)editSelectedTask: (id)sender {
  [ self editSelectedTask ];
}

- (void)editSelectedTask {
  id task = [ self selectedTask ];
  id dialog = [[ EditTaskDialogController alloc ] initWithTask: task ];
  //[ EditTaskDialogController sharedInstanceWithTask: task ];
  [ dialog modalForWindow: [ self window ]];
}

- (void)insertProgramWithString: (NSString *)path {
  int row = [ crTable selectedRow ];
  NSMutableString *cmd;
  
  //NSLog( @"adding %@", path );
  
  if ( [ path isLike: @"* *" ] )
    cmd = [ NSString stringWithFormat: @"/usr/bin/open \"%s\"", [ path cString ] ];
  else
    cmd = [ NSString stringWithFormat: @"/usr/bin/open %s", [ path cString ] ];
  
  if ( row == -1 ) { // new line
    [ self newLineWithCommand: cmd ];
  } else { // modify existing line
    [ [ currentCrontab taskAtIndex: row ] setObject: cmd forKey: @"Command" ];
  }
  [ self setDirty: YES ];
}


- (void)removeLine {
  [ self removeLinesInList: [ crTable selectedRowEnumerator ]];
}


- (void)removeLinesInList: (NSEnumerator *)list {
  id item;
  list = [[ list allObjects ] reverseObjectEnumerator ];
  while ( item = [ list nextObject ] ) {
    [ currentCrontab removeTaskAtIndex: [ item intValue ] ];
  }
  [ crTable reloadData ];
  if ( [crTable selectedRow] != -1 )
    [self showInfoForTask: [crTable selectedRow]];
  [ self setDirty: YES ];
}

- (void)replaceLineAtRow: (int)row withObject: (id)obj {
  if ( row < 0 || row > [ crTable numberOfRows ]-1 ) {
    NSBeep();
    return;
  }
  [ currentCrontab replaceTaskAtIndex: row withTask: obj ];
  [ crTable reloadData ];
  [ self setDirty: YES ];
}



- (void)duplicateLinesInList: (NSEnumerator *)list {
  id index;
  BOOL firstInList = YES;
  int insertionPoint = 0;
  int listCount = 0;
  list = [[ list allObjects ] reverseObjectEnumerator ];
  
  while ( index = [ list nextObject ] ) {
    if ( firstInList ) {
			insertionPoint = [ index intValue ] +1;
      firstInList = NO;
    }
		id duplicate = [ TaskObject taskWithTask: [ currentCrontab taskAtIndex: [ index intValue ]]];
    [ currentCrontab insertTask: duplicate atIndex: insertionPoint ];
		listCount++;
  }
  
  [ crTable reloadData ];
  [ self setDirty: YES ];
  
  // select the newly created rows
  [ crTable selectRow: insertionPoint byExtendingSelection: NO ];
  int i;
  for ( i = 1; i < listCount; i++ ) {
		[ crTable selectRow: insertionPoint +i byExtendingSelection: YES ];
  }
}



- (int)writeSystemCrontab {
  NSPipe *pipe = [ NSPipe pipe ];
  NSFileHandle *writeHandle = [ pipe fileHandleForWriting ];
  NSData *cronData = [ currentCrontab data ];
  NSMutableArray *args = [ NSMutableArray array ];
  BLAuthentication *authObj = [ BLAuthentication sharedInstance ];
  
  [ args addObject: @"/etc/crontab" ];
  
  [ writeHandle writeData: cronData ];
  [ writeHandle closeFile ];
  
  [ authObj executeCommand: @"/usr/bin/tee" withArgs: args withPipe: pipe ];
  // error handling???
  return 0;
}


- (int)writeUserCrontab {
  NSPipe *pipe = [ NSPipe pipe ];
  NSFileHandle *writeHandle = [ pipe fileHandleForWriting ];
  NSData *cronData = [ currentCrontab data ];
  NSMutableArray *args = [ NSMutableArray array ];
  BLAuthentication *authObj = [ BLAuthentication sharedInstance ];
  [ args addObject: [ NSString stringWithFormat: @"-u" ] ];
  [ args addObject: [ self crontabForUser ] ];
  [ args addObject: @"-" ];
  
  //NSLog( @"Writing for user: %@", [ self loadedForUser ] );
  
  [ writeHandle writeData: cronData ];
  [ writeHandle closeFile ];
  
  [ authObj executeCommand: [ self suCronCommand ] withArgs: args withPipe: pipe ];
  // error handling???
  return 0;
}


- (int)writeStandardCrontab {
  NSPipe *pipe = [ NSPipe pipe ];
  NSFileHandle *writeHandle = [ pipe fileHandleForWriting ];
  NSData *cronData = [ currentCrontab data ];
  NSTask *task;
  int status;
  NSMutableArray *args = [ NSMutableArray array ];
  [ args addObject: @"-" ];
  
  task = [[ NSTask alloc ] init ];
  [ task setCurrentDirectoryPath: @"." ];
  [ task setLaunchPath: cronCommand ];
  [ task setArguments: args ];
  [ task setStandardInput: pipe ];
  
  [ task launch ];
  if ( [ task isRunning ] ) {
		[ writeHandle writeData: cronData ];
		[ writeHandle closeFile ];
  }
  
  [ task waitUntilExit ];
  
  status = [ task terminationStatus ];
  [ task release ];
  return status;
}

// 2.0
- (void)writeCrontab {
  
  int status;
  
  //NSLog( "write:\n%s", [ [ cronData description ] cString ] );
  //return;
  
  if ( [ self isSystemCrontab ] ) {
		status = [ self writeSystemCrontab ];
  } else if ( [ self crontabForUser ] ) {
		status = [ self writeUserCrontab ];
  } else {
		status = [ self writeStandardCrontab ];
  }
  
  //NSLog( @"writeCrontab status: %i", status );
  
  switch ( status ) {
		case 0: // everything ok
			[ self setDirty: NO ];
			break;
		case 1: // not privileged to open with username
			if ( [ self crontabForUser ] ) {
				NSBeginAlertSheet(
                          NSLocalizedString( @"Failure", @"write failure alert sheet" ),
                          NSLocalizedString( @"OK", @"Ok in dialog" ),
                          nil, nil, winMain, winMain, NULL, NULL, nil,
                          NSLocalizedString( @"Insufficient privileges to write crontab for user \"%s\".", @"descriptive  text in write failure alert sheet" ),
                          [ [ self crontabForUser ] cString ] );
			} else {
				NSBeginAlertSheet(
                          NSLocalizedString( @"Failure", @"write failure alert sheet" ),
                          NSLocalizedString( @"OK", @"Ok in dialog" ),
                          nil, nil, winMain, winMain, NULL, NULL, nil,
                          NSLocalizedString( @"Insufficient privileges to write crontab.", @"descriptive  text in write failure alert sheet" ) );
			}
			break;
  }
  
}


- (void)exportCrontab: (id)sender {
  NSSavePanel *savePanel = [ NSSavePanel savePanel ];
  
  [ savePanel setPrompt: NSLocalizedString( @"Export", @"Export dialog button title" ) ];
  int result = [ savePanel runModalForDirectory: NSHomeDirectory()
                                           file: [ NSString stringWithFormat: @"%@.crontab", NSLocalizedString( @"untitled", @"new crontab file name" ) ]];
  if ( result == NSFileHandlingPanelOKButton ) {
    NSString *filename = [ savePanel filename ];
		BOOL success = [[ self currentCrontab ] writeAtPath: filename ];
		if ( ! success ) {
			NSBeginAlertSheet(
                        NSLocalizedString( @"Export failure",
                                           @"Export failure sheet title" ),
                        NSLocalizedString( @"Darn!",
                                           @"Export failure acknowledgement button title" ),
                        nil,
                        nil,
                        winMain, self, NULL,
                        nil, nil,
                        NSLocalizedString( @"Could not export crontab. Are you sure you have a hard drive?",
                                           @"export failure dialog text" ) );
		}
  }
}




- (void)importCrontab: (id)sender {
  [ self crontabShouldImport ];
}

- (void)importCrontab {
  NSOpenPanel *openPanel = [ NSOpenPanel openPanel ];
  
  [ openPanel setAllowsMultipleSelection: NO ];
  [ openPanel setPrompt: NSLocalizedString( @"Import", @"Import file dialog: alternative label for open button" ) ];
  
  NSArray *fileTypes = [NSArray arrayWithObject:@"crontab"];
  int result = [ openPanel runModalForDirectory: NSHomeDirectory() file: nil types: fileTypes ];
  if (result == NSOKButton) {
    NSString *filename = [ openPanel filename ];
		[ self openCrontabFromFile: filename ];
		// set the dirty flag after importing
		[ self setDirty: YES ];
  }	
}


- (void)setupUserColumn {
  NSLog( @"Setting up userColumn" );
  userColumn = [ [ NSTableColumn alloc ] initWithIdentifier: @"User" ];
  [ [ userColumn headerCell ] setStringValue: @"User" ];
  [ userColumn setWidth: 50 ];
  [ [ userColumn headerCell ] setFont: [NSFont systemFontOfSize:[NSFont systemFontSize]] ];
  [ [ userColumn headerCell ]
            setTitle: NSLocalizedString( @"User", @"Column title for extra column in system crontab. Generated programmatically (i.e. not in a nib) with width: 50" ) ];
  //	[ crTable addTableColumn: userColumn ];
  //	[ crTable moveColumn: [ crTable numberOfColumns ] -1 toColumn: [ crTable numberOfColumns ] -2 ];
  //	[ userColumn release ];
}

// Setting up the "Active" column
- (void)setupActiveColumn {
  NSTableColumn *col = [[ crTable tableColumns] objectAtIndex: 0];
  NSButtonCell *cell = [[NSButtonCell alloc] init];
  //SwitchFormatter *formatter = [ [ SwitchFormatter alloc ] init ];
  
  //[ cell setFormatter: formatter ];
  [ cell setButtonType: NSSwitchButton ];
  [ cell setAction: @selector(activeButtonToggled) ];
  [ cell setTarget: self ];
  
  [ col setDataCell: cell ];
  
  [ cell release ];
  //[ formatter release ];
}


// --------------------------------------------------------------------------------------------------------------
// accessors

- (id)mainWindow {
  return winMain;
}

- (id)window {
  return winMain;
}

- (BOOL)isDirty {
  return isDirty;
}

- (void)setDirty: (BOOL)value {
  isDirty = value;
}

- (void)documentModified: (NSNotification *)notification {
  [ self setDirty: YES ];
}

- (void)userSelected: (NSNotification *)notification {
  loadCrontabController *lcc = [ loadCrontabController sharedInstance ];
  NSString *username = [ lcc username ];
  int returnCode = [ lcc returnCode ];
  
  switch ( returnCode ) {
    case 0: // cancel
      break;  // don't do anything
    case 1: // load
      if ( username ) [ self loadCrontabForUser: username ];
      break;
    case 2: // default
      [ self loadCrontabForUser: nil ]; // load for default user
      break;
  }
}

- (void)taskCreated: (NSNotification *)notification {
  [ self newLineWithTask: [ notification object ]];
}

- (void)taskEdited: (NSNotification *)notification {
  [ self replaceLineAtRow: [ self selectedRow ] withObject: [ notification object ]];
}


- (BOOL)validateMenuItem: (id <NSMenuItem>)menuItem {
  if ( [ menuItem isEqual: mSave ] ) {
    return [ self isDirty ];
  }
  if ( [ menuItem isEqual: duplicateMenuItem ] ) {
    if ( [ [ NSApp keyWindow ] isEqual: winMain ] )
      return [ crTable selectedRow ] != -1; // validate if a row is selected
    if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
      return [ [ envVariablesNibController sharedInstance ] selectedRow ] != -1;
  }
  if ( [ menuItem isEqual: deleteMenuItem ] ) {
    if ( [ [ NSApp keyWindow ] isEqual: winMain ] )
      return [ crTable selectedRow ] != -1; // validate if a row is selected
    if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
      return [ [ envVariablesNibController sharedInstance ] selectedRow ] != -1;
  }
  if ( [ menuItem isEqual: showHideMenuItem ] ) {
    BOOL isVisible = YES;
    if ( [ [ NSApp keyWindow ] isEqual: winMain ] )
      isVisible = [ toolbar isVisible ];
    if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
      isVisible = [ [ [ envVariablesNibController sharedInstance ] toolbar ] isVisible ];
    isVisible ? [ menuItem setTitle: NSLocalizedString( @"Hide Toolbar", @"Hide toolbar menu item label" ) ] : [ menuItem setTitle: NSLocalizedString( @"Show Toolbar", @"Show toolbar menu item label" ) ];
  }
  if ( [ menuItem isEqual: runNowMenuItem ] ) {
    return [ crTable selectedRow ] != -1;
  }
  if ( [ menuItem isEqual: editTaskMenuItem ] ) {
    return [ crTable selectedRow ] != -1;
  }
  if ( [[ menuItem menu ] isEqual: contextMenu ] ) {
		return [ crTable selectedRow ] != -1;
  }
  return YES;
}


- (NSString *)crontabForUser {
  return crontabForUser;
}

- (void)setCrontabForUser: (NSString *)user {
  [ crontabForUser autorelease ];
  if ( user ) {
    crontabForUser = [ user copy ];
    //[ labelUser setStringValue: crontabForUser ];
    [ toolbar setUser: crontabForUser ];
  } else {
    crontabForUser = nil;
    //[ labelUser setStringValue: NSUserName() ];
    [ toolbar setUser: NSUserName() ];
  }
}


- (NSString *)suCronCommand {
  return [ [ NSBundle mainBundle ] pathForResource: suCrontabResource ofType: nil ];
}


- (int)selectedRow {
  return [ crTable selectedRow ];
}


- (id)selectedTask {
  if ( [ crTable selectedRow ] == -1 ) return nil;
  return [ currentCrontab taskAtIndex: [ crTable selectedRow ] ];
}


- (NSWindow *)envVarWindow {
  return [ [ envVariablesNibController sharedInstance ] window ];
}


- (void)showInfoForTask:(int)index {
  id task = [ currentCrontab taskAtIndex: index ];
  NSString *info = [ task info ] ? [ task info ] : @"";
  [ infoTextField setStringValue: info ];
}


- (Crontab *)currentCrontab {
  return currentCrontab;
}


// --------------------------------------------------------------------------------------------------------------
// delegates

// application

- (void)initDataSource {
  [ crTable setAutosaveName: @"TaskTable" ];
  [ crTable setAutosaveTableColumns: YES ];
  [ crTable setDataSource: self ];
	[ crTable setDelegate: self ];
  [ self loadCrontab ];
}


- (void)awakeFromNib {
  [ winMain setFrameUsingName: @"MainWindow" ];
  [ winMain setFrameAutosaveName: @"MainWindow" ];
  
  [ winMain makeKeyAndOrderFront: nil ];
  
	[ self initDataSource ];
	
  [ self setupActiveColumn ];
  [ userColumn retain ]; // need to retain this, because it might be removed by the autosave feature below
                         //[ self setupUserColumn ];
  
  [ crTable registerForDraggedTypes: [ NSArray arrayWithObjects: NSStringPboardType, NSFilenamesPboardType, nil ]];
  //    [ winMain makeFirstResponder: crTable ];
  
  /*{
    NSEnumerator *iter = [ [ crTable tableColumns ] objectEnumerator ];
    NSTableColumn *col;
    NSMenu *menu = [ [ NSMenu alloc ] init ];
    [ menu addItemWithTitle: NSLocalizedString( @"Run now", @"Run now context menu item" ) 
                     action: @selector(runSelectedCommand) keyEquivalent: @"" ];
    while ( col = [ iter nextObject ] )
      [ [ col dataCell ] setMenu: menu ];
    [ menu release ];        
  }*/
  
	unichar backspaceKey = NSBackspaceCharacter;
	[deleteMenuItem setKeyEquivalent:[NSString stringWithCharacters:&backspaceKey length:1]];
  
  toolbar = [ [ Toolbar alloc ] initWithController: self ];
}

// table view

- (int)numberOfRowsInTableView:(NSTableView *)table {
  //NSLog( @"rows: %i", [ currentCrontab taskCount ] );
  return [ currentCrontab taskCount ];
}


- (id)tableView:(NSTableView *)table
        objectValueForTableColumn:(NSTableColumn *)col
            row:(int)row {
  if ( row >= 0 && row < [ currentCrontab taskCount ] ) {
		//NSLog( [ [ tasks objectAtIndex: row ] objectForKey: [ col identifier ] ] );
    return [[ currentCrontab taskAtIndex: row ] objectForKey: [ col identifier ] ];
  } else {
    return nil;
  }
}

- (void)tableView: (NSTableView *)table
   setObjectValue: (id)obj
   forTableColumn: (NSTableColumn *)col
              row: (int)row {
  if ( row >= 0 && row < [ currentCrontab taskCount ] ) {
    if ( [[ col identifier ] isEqual: @"Active" ] ) {
      // we need special treatment of the Active column because unless we explicitely put in strings, writing won't work
      // correctly.
      [[ currentCrontab taskAtIndex: row ] setObject: [ obj description ] forKey: [ col identifier ]];
    } else {
      [[ currentCrontab taskAtIndex: row ] setObject: obj forKey: [ col identifier ]];
    }
  }
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
  [ infoTextField setEnabled: [crTable selectedRow] != -1 ];
  if ( [ crTable selectedRow ] != -1 ) {
		[ self showInfoForTask: [ crTable selectedRow ]];
  }
  //    BOOL state = ( [ crTable selectedRow ] != -1 );
}


- (void)tableView:(NSTableView *)view
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)col
              row:(int)row {
  
  /* 	if ( [ [ col identifier ] isEqualTo: @"Min" ] ) {
  SwitchFormatter *formatter = [ [ SwitchFormatter alloc ] init ];
  NSLog( @"Min column displaying" );
  //[cell setImage: [self theAppropriateImageForThisRow: row]];
  
  [ cell setFormatter: formatter ];
  } */
}


- (void)controlTextDidChange:(NSNotification *)aNotification {
  id ed = [ [ aNotification userInfo ] objectForKey: @"NSFieldEditor" ];
  int selrow = [ crTable selectedRow ];
  int edrow = [ crTable editedRow ];
  //NSLog( @"ed: %@", ed );
  if ( [[ed superview] superview] == infoTextField && selrow != -1 ) {
		NSString *info = [[ ed string ] copy ];
		TaskObject *task = [ currentCrontab taskAtIndex: selrow ];
		[ task setInfo: info ];
		[ self setDirty: YES ];
		[ info release ];
  } else if ( edrow != -1 ) {
		NSTableColumn *col = [[ crTable tableColumns ] objectAtIndex: [ crTable editedColumn ]];
		id obj = [[ ed string ] copy ];
		[[ currentCrontab taskAtIndex: edrow ] setObject: obj forKey: [ col identifier ]];
		[ self setDirty: YES ];
		[ obj release ];
  }
}


//- (void)mouseDown:(NSEvent *)theEvent {
//    NSLog( @"button pressed!" );
//}


// window

- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender {
  if ( [ self isDirty ] ) {
    NSBeginAlertSheet( 
                       NSLocalizedString( @"Unsaved Data", @"Unsaved data alert sheet title" ), 
                       NSLocalizedString( @"Save", @"Save button label" ),
                       NSLocalizedString( @"Discard", @"Discard chanes button label" ),
                       NSLocalizedString( @"Cancel", @"Cancel in dialogs" ),
                       winMain, self, NULL,
                       @selector(didEndTerminateSheet:returnCode:contextInfo:), nil, 
                       NSLocalizedString( @"You have modified your crontab. Save changes?", @"descriptive text in save changes alert sheet" ) );
    return NO;
  }
  return YES;
}

- (void)didEndTerminateSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  switch ( returnCode ) {
    case NSAlertDefaultReturn: // yes, save
      [ self writeCrontab ];
      [ NSApp terminate: self ];
      break;
    case NSAlertAlternateReturn: // no, discard
      [ self setDirty: NO ];
      [ NSApp terminate: self ];
      break;
    case NSAlertOtherReturn: // cancel, go back
      break;
  }
}

- (void)didEndUpdateAvailableSheet:(NSWindow *)sheet
                        returnCode:(int)returnCode
                       contextInfo:(void *)contextInfo {
  switch ( returnCode ) {
    case NSAlertDefaultReturn: // yes, save
			[ self openHomepage: nil ];
      break;
    case NSAlertOtherReturn: // cancel, go back
      break;
  }
}


// --------------------------------------------------------------------------------------------------------------
// Dragging

- (BOOL)acceptStringDrop: (id <NSDraggingInfo>)info 
                     row: (int)row 
           dropOperation: (NSTableViewDropOperation)operation {
	
  NSPasteboard *pboard = [info draggingPasteboard];
	NSData *data = [ pboard dataForType: NSStringPboardType ];
	id string = [ [ NSString alloc ] initWithData: data encoding: [ NSString defaultCStringEncoding ]];
	
	if ( [ Crontab isContainedInString: string ] ) {
		id crontab = [[[ Crontab alloc ] initWithString: string ] autorelease ];
		id iter = [ crontab reverseTasks ];
		id task;
		while ( task = [ iter nextObject ] ) {
			[ currentCrontab insertTask: task atIndex: row ];
		}
		[ self setDirty: YES ];
		return YES;
	} else {
		if ( operation == NSTableViewDropOn ) {
			// treat it as a drop on the command field (old behavior)
			if ( row == -1 ) { // new line
				[ self newLineWithCommand: string ];
			} else { // modify existing line
				[[ currentCrontab taskAtIndex: row ] setObject: string forKey: @"Command" ];
				[ self setDirty: YES ];
			}
			return YES;
		}
	}
	
	return NO;
}


- (BOOL)acceptFilenamesDrop: (id <NSDraggingInfo>)info 
                        row: (int)row 
              dropOperation: (NSTableViewDropOperation)operation {
  
  NSPasteboard *pboard = [info draggingPasteboard];
	NSArray *filenames = [pboard propertyListForType: NSFilenamesPboardType];
	NSEnumerator *iter = [ filenames  reverseObjectEnumerator ];
	NSString *fname;
	if ( row == -1 ) { // insertProgramWithString works differently depending on the selection
		[ crTable deselectAll: nil ];
	} else {
		[ crTable selectRow: row byExtendingSelection: NO ];
	}
	while ( fname = [ iter nextObject ] ) {
		[ self insertProgramWithString: fname ];
		[ crTable deselectAll: nil ];
	}
	return YES;
}	


- (BOOL)tableView: (NSTableView *)table
       acceptDrop: (id <NSDraggingInfo>)info
              row: (int)row
    dropOperation: (NSTableViewDropOperation)operation {
  
  NSPasteboard *pboard = [info draggingPasteboard];
  NSString *type = [ pboard availableTypeFromArray: [ NSArray arrayWithObjects: NSStringPboardType, 										NSFilenamesPboardType, NSTabularTextPboardType, nil ] ];
  
  if ( ! type ) return NO;
  
	if ( [ type isEqualToString: NSStringPboardType ] )
		return [ self acceptStringDrop: info row: row dropOperation: operation ];
		
  if ( [ type isEqualToString: NSFilenamesPboardType ] ) 
		return [ self acceptFilenamesDrop: info row: row dropOperation: operation ];
  
  return NO;
}


- (unsigned int)tableView:(NSTableView*)tableView 
             validateDrop:(id <NSDraggingInfo>)info 
              proposedRow:(int)row 
    proposedDropOperation:(NSTableViewDropOperation)operation {
  
	NSPasteboard *pboard = [info draggingPasteboard];
	NSString *type = [ pboard availableTypeFromArray: [ NSArray arrayWithObjects: NSStringPboardType,                                                                            NSFilenamesPboardType, NSTabularTextPboardType, nil ] ];
	//NSLog( @"type: %@", type );
  if ( type ) {
    if ( [ type isEqualToString: NSStringPboardType ] || 
         [ type isEqualToString: NSFilenamesPboardType ] ||
         [ type isEqualToString: NSTabularTextPboardType ] ) {
      return NSDragOperationGeneric;
    }
  }
  //NSLog( @"validateDrop in row %i", row );
  return NSDragOperationNone;
}


- (BOOL)tableView:(NSTableView *)aTableView
        writeRows:(NSArray *)rows
     toPasteboard:(NSPasteboard *)pboard {
	
	id objects = [ NSMutableArray array ];
	id iter = [ rows objectEnumerator ];
	id index;
	while ( index = [ iter nextObject ] ) 
		[ objects addObject: [ currentCrontab taskAtIndex: [ index intValue ]]];
	[ self setDraggedObjects: objects ];
	
	[ pboard declareTypes: [ NSArray arrayWithObject: NSStringPboardType ] owner: self ];
	
	return YES;
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type {
	id cr = [[[ Crontab alloc] init ] autorelease ];
	id iter = [ draggedObjects objectEnumerator ];
	id task;
	while ( task = [ iter nextObject ] )
		[ cr addTask: task ];
	
	[ sender setString: [ cr description ] forType: NSStringPboardType ];
}

- (void)setDraggedObjects: (NSArray *)objects {
	if ( draggedObjects != objects ) {
		[ draggedObjects release ];
		draggedObjects = [ objects retain ];
	}
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation {
	if ( operation & NSDragOperationMove ||
       operation & NSDragOperationGeneric ) {
		id iter = [ draggedObjects objectEnumerator ];
		id object;
		while ( object = [ iter nextObject ] )
			[ currentCrontab removeTask: object ];
		[ crTable reloadData ];
	}
}






// ------------------------------------------------------------------------------------------
// toolbar menu actions

- (void)customizeToolbar:(id)sender {
  if ( [ [ NSApp keyWindow ] isEqual: winMain ] )
    [ toolbar customize: sender ];
  if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
    [ [ envVariablesNibController sharedInstance ] customize: sender ];
}

- (void)showhideToolbar:(id)sender {
  if ( [ [ NSApp keyWindow ] isEqual: winMain ] ) {
    [ toolbar showhide: sender ];
    [ toolbar isVisible ] ? [ [ self mainWindow ] setTitle: @"CronniX" ]
                          : [ [ self mainWindow ] setTitle: [ @"CronniX - " stringByAppendingString: 
                                                                   crontabForUser ? crontabForUser : NSUserName() ] ];
  }
  if ( [ [ NSApp keyWindow ] isEqual: [ self envVarWindow ] ] )
    [ [ envVariablesNibController sharedInstance ] showhide: sender ];
  
  /*    if ( [ [ sender title ] isEqualToString: @"Hide Toolbar" ] ) {
  [ sender setTitle: @"Show Toolbar" ];
  } else {
    [ sender setTitle: @"Hide Toolbar" ];
} */
}



// test

- (NSData *)runCliCommand: (NSString *)cmd
                 WithArgs: (NSArray *)args
{
  int status;
  NSTask *task = [[ NSTask alloc ] init ];
  NSPipe *pipe = [ NSPipe pipe ];
  NSFileHandle *readHandle = [ pipe fileHandleForReading ];
  NSData *cmdOutput;
  
  //NSLog( @"Starting task %@", cmd );
  
  [ task setCurrentDirectoryPath: @"." ];
  [ task setLaunchPath: cmd ];
  if ( args )
    [ task setArguments: args ];
  [ task setStandardOutput: pipe ];
  
  [ task launch ];
  [ task waitUntilExit ];
  
  cmdOutput = [ [ NSData alloc ] initWithData :[ readHandle readDataToEndOfFile ] ];
  
  status = [ task terminationStatus ];
  //NSLog( @"Exit status %i", status );
  
  [ task release ];
  
  return [ cmdOutput autorelease ];
}



@end
