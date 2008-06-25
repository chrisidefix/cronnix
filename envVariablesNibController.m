#import "envVariablesNibController.h"
#import "crController.h"
#import "Crontab.h"


@implementation envVariablesNibController


static envVariablesNibController *sharedInstance = nil;


+ (envVariablesNibController *)sharedInstance {
  return sharedInstance ? sharedInstance : [[self alloc] init];
}

+ (void)showWindow {
  [ [ self sharedInstance ] showWindow ];
}

+ (void)hideWindow {
  [ [ self sharedInstance ] hideWindow ];
}



- (id)init {
  if (sharedInstance) {
    [self dealloc];
  } else {
    NSBundle *thisBundle = [ NSBundle bundleForClass: [self class] ];
    NSImage *itemImage = nil;
    NSString *imagePath = nil;
    NSString *itemName;
    NSToolbarItem *item;
		
    //NSLog( @"init" );
    [super init];
    sharedInstance = self;
    // The following does not work here, maybe because the nib's not displayed, yet.
    // Instead the data source has been set in IB.
    //[ envTable setDataSource: self ];
    
    // toolbar setup ---------------------------------
    items = [ [ NSMutableDictionary alloc ] init ];
    
    // new entry item
    itemName = @"New";
    item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
    [ item setPaletteLabel: NSLocalizedString( @"New", @"toolbar item name" ) ]; // name for the "Customize Toolbar" sheet
    [ item setLabel: NSLocalizedString( @"New", @"toolbar item name" ) ]; // name for the item in the toolbar
    [ item setToolTip: NSLocalizedString( @"Add new environment variable", @"toolbar item tooltip" ) ]; // tooltip
    [ item setTarget: self ]; // what should happen when it's clicked
    [ item setAction: @selector(newLineToolbarItemClicked:) ];
    [ items setObject: item forKey: itemName ]; // add to toolbar list
    imagePath = [ thisBundle pathForResource: @"new_env" ofType: @"tiff" ];
    if ( imagePath )
      itemImage = [ [ NSImage alloc ] initWithContentsOfFile: imagePath ];
    if ( itemImage )
      [ item setImage: itemImage ];
    [ itemImage release ];
    
    // "delete" entry item
    itemName = @"Delete";
    item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
    [ item setPaletteLabel: NSLocalizedString( @"Delete", @"toolbar item name" ) ]; // name for the "Customize Toolbar" sheet
    [ item setLabel: NSLocalizedString( @"Delete", @"toolbar item name" ) ]; // name for the item in the toolbar
    [ item setToolTip: NSLocalizedString( @"Remove environment variable", @"toolbar item tooltip" ) ]; // tooltip
    [ item setTarget: self ]; // what should happen when it's clicked
    [ item setAction: @selector(removeLineToolbarItemClicked:) ];
    [ items setObject: item forKey: itemName ]; // add to toolbar list
    imagePath = [ thisBundle pathForResource: @"delete" ofType: @"tiff" ];
    if ( imagePath )
      itemImage = [ [ NSImage alloc ] initWithContentsOfFile: imagePath ];
    if ( itemImage )
      [ item setImage: itemImage ];
    [ itemImage release ];
    
    // create toolbar
    toolbar = [ [ NSToolbar alloc ] initWithIdentifier: @"EnvToolbar" ];
    [ toolbar setDelegate: self ];
    [ toolbar setAllowsUserCustomization: YES ];
    [ toolbar setAutosavesConfiguration: YES ];
    
  }
  return sharedInstance;
}

- (void)dealloc {
  [ window close ];
  [ super dealloc ];
}

- (void)awakeFromNib {
	// register d&d
	[ envTable registerForDraggedTypes: [ NSArray arrayWithObject: NSStringPboardType ]];	
}

// accessors

- (void)setCrontab: (id)aCrontab {
  if ( crontab != aCrontab ) {
    [ crontab release ];
		crontab = [ aCrontab retain ];
		[ self reloadData ];
  }
}


- (NSPanel *)window{
  return window;
}

- (NSToolbar *)toolbar {
  return toolbar;
}



// workers

- (void)showWindow {
  //NSLog( @"show" );
  if ( ! window ) {
    if (![NSBundle loadNibNamed:@"envVariables" owner:self])  {
      NSLog(@"Failed to load envVariables.nib");
      NSBeep();
      return;
    }
  }
  [ window setMenu:nil];
  [ window setFrameUsingName: @"EnvVariablesWindow" ];
  [ window setFrameAutosaveName: @"EnvVariablesWindow" ];
  [ window makeKeyAndOrderFront:nil];
  [ window setToolbar: toolbar ];
}


-(void)hideWindow {
  // "window" is an NSPanel, so closing does not dispose
  //NSLog( @"hide" );
  [ window close ];
}

/*
 - (void)addEnvVariable:(NSString *)aKey withValue:(NSString *)aValue {
   [ crontab addEnvVariableWithValue: aValue forKey: aKey ];
   //[ envTable reloadData ];
 }
 */

- (void)removeAllObjects {
  [ crontab removeAllEnvVariables ];
}

- (void)reloadData {
  [ envTable reloadData ];
}

- (int)selectedRow {
  return [ envTable selectedRow ];
}

- (void)removeLine {
	[ self removeLinesInList: [ envTable selectedRowEnumerator ]];
}

- (void)removeLinesInList: (NSEnumerator *)list {
  id item;
  list = [[ list allObjects ] reverseObjectEnumerator ];
  while ( item = [ list nextObject ] ) {
    [ crontab removeEnvVariableAtIndex: [ item intValue ] ];
  }
  [ envTable reloadData ];
	
	[ self postModifiedNotification ];
}


- (void)duplicateLine {
  if ( [ envTable selectedRow ] == -1 ) {
    NSBeep();
    return;
  }
	int selectedRow = [ envTable selectedRow ];
	id duplicate = [ EnvVariable envVariableWithEnvVariable: [ crontab envVariableAtIndex: selectedRow ]];
	[ crontab insertEnvVariable: duplicate atIndex: selectedRow ];
  [ envTable reloadData ];
  
  // make sure that the last row remains selected
  if ( [ envTable selectedRow ] == -1 ) {
    [ envTable selectRow: [ envTable numberOfRows ] -1 byExtendingSelection: NO ];
  }
  
	[ self postModifiedNotification ];
}




- (void)newLine {
  [ self addLine ];
}

- (void)addLine {
  EnvVariable *env = [ EnvVariable envVariableWithValue: NSLocalizedString( @"value", 
                                                                            @"env. variable value template" ) 
                                                 forKey: NSLocalizedString( @"SOME_ENV", 
                                                                            @"env. variable name template" ) ];
	[ self addEnvVariable: env ];
}

- (void)addEnvVariable: (EnvVariable *)env {
  [ crontab addEnvVariable: env ];
  [ envTable reloadData ];
	[ self postAddedNotification: env ];
}

- (void)clear {
  [ crontab removeAllEnvVariables ];
  [ self reloadData ];
}

// ib actions

- (IBAction)hideWindow:(id)sender {
  [ self hideWindow ];
}

- (IBAction)addLine:(id)sender {
  [ self addLine ];
}

- (IBAction)removeLine:(id)sender {
	int lastSelectedRow = [ envTable selectedRow ];
	
	[ self removeLine ];
  
	int nRows = [ envTable numberOfRows ];
	int rowToSelect = lastSelectedRow < nRows ? lastSelectedRow : nRows -1;
	[ envTable selectRow: rowToSelect byExtendingSelection: NO ];
}

- (IBAction)duplicateLine:(id)sender {
  [ self duplicateLine ];
}


// table view delegates

- (int)numberOfRowsInTableView:(NSTableView *)table {
  //NSLog( @"rows: %i", [ envArray count ] );
  return [ crontab envVariableCount ];
}


- (id)tableView:(NSTableView *)table
        objectValueForTableColumn:(NSTableColumn *)col
            row:(int)row {
  if ( row >= 0 && row < [ crontab envVariableCount ] ) {
    id env = [ crontab envVariableAtIndex: row ];
		return [ env valueForKey: [ col identifier]];
  } else {
    return nil;
  }
}

- (void)tableView: (NSTableView *)table
   setObjectValue: (id)obj
   forTableColumn: (NSTableColumn *)col
              row: (int)row {
  if ( row >= 0 && row < [ crontab envVariableCount ] ) {
    id env = [ crontab envVariableAtIndex: row ];
		[ env setValue: obj forKey: [ col identifier ]];
  }
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
  BOOL state = ( [ envTable selectedRow ] != -1 );
  [ btRemove setEnabled: state ];
}


// --------------------------------------------------------------------------------------------
// Dragging

- (BOOL)tableView: (NSTableView *)table
       acceptDrop: (id <NSDraggingInfo>)info
              row: (int)row
    dropOperation: (NSTableViewDropOperation)operation {
  
	NSPasteboard *pboard = [ info draggingPasteboard ];
  NSString *type = [ pboard availableTypeFromArray: [ NSArray arrayWithObject: NSStringPboardType ]];
  
  if ( ! type ) return NO;
	
	if ( [ type isEqualToString: NSStringPboardType ] ) {
    NSData *data = [ pboard dataForType: NSStringPboardType ];
    id string = [ [ NSString alloc ] initWithData: data encoding: [ NSString defaultCStringEncoding ]];
		
		if ( [ EnvVariable isContainedInString: string ] ) {
			id cr = [[ Crontab alloc ] initWithString: string ];
			id iter = [ cr reverseEnvVariables ];
			id env;
			while ( env = [ iter nextObject ] ) {
				[ crontab insertEnvVariable: env atIndex: row ];
        [ self postAddedNotification: env ];
			}
			[ cr release ];
			
      // if the source is not self, reload now, otherwise the 
      // draggedImage:endedAt: msg will reload
      if ( [ info draggingSource ] != self )
        [ self reloadData ];

      return YES;		
		}
		
  }
  
  return NO;
}


- (unsigned int)tableView:(NSTableView*)tableView 
             validateDrop:(id <NSDraggingInfo>)info 
              proposedRow:(int)row 
    proposedDropOperation:(NSTableViewDropOperation)operation {
	NSPasteboard *pboard = [info draggingPasteboard];
	NSString *type = [ pboard availableTypeFromArray: [ NSArray arrayWithObject: NSStringPboardType ]];
  if ( type ) {
    if ( [ type isEqualToString: NSStringPboardType ] ) {
      return NSDragOperationGeneric;
    }
  }
  return NSDragOperationNone;
}


- (BOOL)tableView:(NSTableView *)aTableView
        writeRows:(NSArray *)rows
     toPasteboard:(NSPasteboard *)pboard {
	id objects = [ NSMutableArray array ];
	id iter = [ rows objectEnumerator ];
	id index;
	while ( index = [ iter nextObject ] ) 
		[ objects addObject: [ crontab envVariableAtIndex: [ index intValue ]]];
	[ self setDraggedObjects: objects ];
	[ pboard declareTypes: [ NSArray arrayWithObject: NSStringPboardType ] owner: self ];
	return YES;
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type {
	id cr = [[[ Crontab alloc] init ] autorelease ];
	id iter = [ draggedObjects objectEnumerator ];
	id env;
	while ( env = [ iter nextObject ] ) {
		[ cr addEnvVariable: env ];
	}
	
	[ sender setString: [ cr description ] forType: NSStringPboardType ];
}

- (void)setDraggedObjects: (NSArray *)list {
	if ( draggedObjects != list ) {
		[ draggedObjects release ];
		draggedObjects = [ list retain ];
	}
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation {
	if ( operation & NSDragOperationMove ||
       operation & NSDragOperationGeneric ) {
		id iter = [ draggedObjects objectEnumerator ];
		id object;
		while ( object = [ iter nextObject ] )
			[ crontab removeEnvVariable: object ];
    [ self postModifiedNotification ];
    [ self reloadData ];
	}
}



// -----------------------------------------------------------------

- (void)controlTextDidChange:(NSNotification *)aNotification {
	[ self postModifiedNotification ];
  
  id ed = [ [ aNotification userInfo ] objectForKey: @"NSFieldEditor" ];
  int edrow = [ envTable editedRow ];
  if ( edrow != -1 ) {
		NSTableColumn *col = [[ envTable tableColumns ] objectAtIndex: [ envTable editedColumn ]];
		
		id editedEnv = [ crontab envVariableAtIndex: edrow ];
		[ editedEnv setValue: [ ed string ] forKey: [ col identifier ]];
  }
}


// toolbar delegates

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  return [ items objectForKey:itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
  NSMutableArray *arr = [ NSMutableArray array ];
  [ arr addObject: @"New" ];
  [ arr addObject: @"Delete" ];
  /*    [ arr addObject: ItemName2 ];
  [ arr addObject: ItemName3 ];
  [ arr addObject: ItemName4 ];
  [ arr addObject: ItemName5 ]; */
  return arr;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
  return [ items allKeys];
}

- (int)count {
  return [ items count];
}

- (BOOL)validateToolbarItem: (NSToolbarItem *)item {
  // delete button
  if ( [ item isEqual: [ items objectForKey: @"Delete" ] ] ) {
    return ( [ self selectedRow ] != -1 );
  }
  return YES;
}


// actions


- (void)customize:(id)sender {
  [toolbar runCustomizationPalette:sender];
}

- (void)showhide:(id)sender {
  [toolbar setVisible:![toolbar isVisible]];
}


- (void)newLineToolbarItemClicked:(NSToolbarItem*)item {
  [ self addLine ];
}

- (void)removeLineToolbarItemClicked:(NSToolbarItem*)item {
  [ self removeLine ];
}


// notifications

- (void)postModifiedNotification {
  [[ NSNotificationCenter defaultCenter ] postNotificationName: DocumentModifiedNotification object: self ];
}

- (void)postAddedNotification: (id)addedObject {
	[ self postModifiedNotification ];
  [[ NSNotificationCenter defaultCenter ] postNotificationName: EnvVariableAddedNotification object: addedObject ];
}


@end
