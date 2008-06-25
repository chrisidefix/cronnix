//
//  Toolbar.m
//  CronniX
//
//  Created by sas on Sun Jun 10 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "Toolbar.h"
#import "UserImageView.h"


NSString *ItemName1 = @"New";
NSString *ItemName2 = @"Delete";
NSString *ItemName3 = @"Open";
NSString *ItemName4 = @"Save";
NSString *ItemName5 = @"User";
NSString *ItemName6 = @"RunNow";
NSString *ItemName7 = @"InsertProgram";
NSString *ItemName8 = @"Edit";


@implementation Toolbar


- (id)initWithController: (crController *)aController {
    if ( self = [ super init ] ) {
        NSString *itemName;
        NSToolbarItem *item;
        
        controller = aController;

        // toolbar setup ---------------------------------
        items = [ [ NSMutableDictionary alloc ] init ];
        
        // new entry item
        itemName = ItemName1;
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"New", @"toolbar item name" ) ]; // name for the "Customize Toolbar" sheet
        [ item setLabel: NSLocalizedString( @"New", @"toolbar item name" ) ]; // name for the item in the toolbar
        [ item setToolTip:  NSLocalizedString( @"Create new crontab entry", @"toolbar item tooltip" ) ]; // tooltip
        [ item setTarget: self ]; // what should happen when it's clicked
        [ item setAction: @selector(newLineToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ]; // add to toolbar list
		[ self setImageWithName: @"new" forItem: item ];
        [ item release ];
        
        // remove entry item
        itemName = ItemName2;
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"Delete", @"toolbar item name" ) ];
        [ item setLabel: NSLocalizedString( @"Delete", @"toolbar item name" ) ];
        [ item setToolTip: NSLocalizedString( @"Remove crontab entry", @"toolbar item tooltip" ) ];
        [ item setTarget: self ];
        [ item setAction: @selector(removeLineToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ];
		[ self setImageWithName: @"delete" forItem: item ];
        [ item release ];
        
        // "open for user" entry item
        itemName = ItemName3;
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"Open", @"toolbar item name" ) ];
        [ item setLabel: NSLocalizedString( @"Open", @"toolbar item name" ) ];
        [ item setToolTip: NSLocalizedString( @"Open crontab for different user", @"toolbar item tooltip" ) ];
        [ item setTarget: self ];
        [ item setAction: @selector(openForUserToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ];
		[ self setImageWithName: @"user" forItem: item ];
        [ item release ];

        // "Save" entry item
        itemName = ItemName4;
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"Save", @"toolbar item name" ) ];
        [ item setLabel: NSLocalizedString( @"Save", @"toolbar item name" ) ];
        [ item setToolTip: NSLocalizedString( @"Save crontab", @"toolbar item tooltip" ) ];
        [ item setTarget: self ];
        [ item setAction: @selector(writeCrontabToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ];
		[ self setImageWithName: @"save" forItem: item ];
        [ item release ];
        
        // "user" entry item
        itemName = ItemName5;
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"Current crontab", @"toolbar palette label" ) ];
        [ item setLabel: NSLocalizedString( @"Current crontab", @"toolbar label" ) ];
        [ item setToolTip: NSLocalizedString( @"Current crontab", @"toolbar item tooltip" ) ];
        [ items setObject: item forKey: itemName ];
        useritem = item;
        [ self setUser: [ controller crontabForUser ] ];
        [ item release ];

        // "RunNow" entry item
        itemName = ItemName6;
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"Run now", @"toolbar item name" ) ];
        [ item setLabel: NSLocalizedString( @"Run Now", @"toolbar item name" ) ];
        [ item setToolTip: NSLocalizedString( @"Run task now", @"toolbar item tooltip" ) ];
        [ item setTarget: self ];
        [ item setAction: @selector(runNowToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ];
		[ self setImageWithName: @"runnow" forItem: item ];
        [ item release ];

        // "Edit" entry item
        itemName = ItemName8;
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"Edit", @"toolbar item name" ) ];
        [ item setLabel: NSLocalizedString( @"Edit", @"toolbar item name" ) ];
        [ item setToolTip: NSLocalizedString( @"Edit task", @"toolbar item tooltip" ) ];
        [ item setTarget: self ];
        [ item setAction: @selector(editToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ];
		[ self setImageWithName: @"edit" forItem: item ];
        [ item release ];

		
        // create toolbar
        toolbar = [ [ NSToolbar alloc ] initWithIdentifier: @"Toolbar" ];
        [ toolbar setDelegate: self ];
        [ toolbar setAllowsUserCustomization: YES ];
        [ toolbar setAutosavesConfiguration: YES ];
        
        [ [ controller mainWindow ] setToolbar:toolbar];
    
    }
    return self;
}

- (void)dealloc {
    [ toolbar release ];
    [ items release ];
}

// --------------------------------------------------------------
// delegates

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [ items objectForKey:itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *arr = [ NSMutableArray array ];
    [ arr addObject: ItemName1 ];
    [ arr addObject: ItemName2 ];
    [ arr addObject: ItemName3 ];
    [ arr addObject: ItemName4 ];
    [ arr addObject: ItemName5 ];
    [ arr addObject: ItemName8 ];
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
    if ( [ item isEqual: [ items objectForKey: ItemName2 ] ] ) {
        return ( [ controller selectedRow ] != -1 );
    }

	// save button
	if ( [ item isEqual: [ items objectForKey: ItemName4 ] ] ) {
		return ( [ controller isDirty ] );
	}

	// run now button
	if ( [ item isEqual: [ items objectForKey: ItemName6 ] ] ) {
		return ( [ controller selectedRow ] != -1 );
	}

	// edit button
	if ( [ item isEqual: [ items objectForKey: ItemName8 ] ] ) {
		return ( [ controller selectedRow ] != -1 );
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
    //[ controller newLine: nil ];
	[ controller newLineWithDialog ];
}

- (void)removeLineToolbarItemClicked:(NSToolbarItem*)item {
    [ controller removeLine: nil ];
}

- (void)openForUserToolbarItemClicked:(NSToolbarItem*)item {
    [ controller crontabShouldLoad ];
}

- (void)writeCrontabToolbarItemClicked:(NSToolbarItem*)item {
    [ controller writeCrontab ];
}

- (void)runNowToolbarItemClicked:(NSToolbarItem*)item {
	[ controller runSelectedCommand ];
}

- (void)editToolbarItemClicked:(NSToolbarItem*)item {
	[ controller editSelectedTask ];
}

- (void)setUser: (NSString *)username {
/*
    NSImage *itemImage = nil;
    UserImageRep *userImageRep;

    userImageRep = [ [ UserImageRep alloc ] initWithUserName: username ? username : NSUserName() ];
//    itemImage = [ [ NSImage alloc ] initWithSize: [ userImageRep size ] ];
    [ useritem setMaxSize: NSMakeSize( 100, 100 ) ];
    [ useritem setMinSize: NSMakeSize( 100, 100 ) ];
    itemImage = [ [ NSImage alloc ] initWithSize: NSMakeSize( 100, 100 ) ];
    if ( itemImage ) {
        [ itemImage addRepresentation: userImageRep ];
        [ useritem setImage: itemImage ];
    }
    [ itemImage release ];
    [ userImageRep release ];
    */
    UserImageView *userView = [ [ UserImageView alloc ] init ];
    [ userView setUser: username ? username : NSUserName() ];
    [ useritem setMaxSize: [ userView size ] ];
    [ useritem setMinSize: [ userView size ] ];
    [ useritem setView: userView ];
    [ userView release ];
}

- (BOOL)isVisible {
    return [ toolbar isVisible ];
}


- (void) setImageWithName: (NSString *)name forItem: (NSToolbarItem *)item {
	NSImage *itemImage = nil;
	NSBundle *thisBundle = [ NSBundle bundleForClass: [controller class] ];
	NSString *imagePath = [ thisBundle pathForResource: name ofType: @"tiff" ];
	if ( imagePath )
		itemImage = [ [ NSImage alloc ] initWithContentsOfFile: imagePath ];
	if ( itemImage )
		[ item setImage: itemImage ];
	[ itemImage release ];
}



@end
