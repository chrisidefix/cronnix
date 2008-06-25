//
//  Toolbar.h
//  CronniX
//
//  Created by sas on Sun Jun 10 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "crController.h"

@class crController;

@interface Toolbar : NSObject {
    crController *controller;
    NSToolbar *toolbar;
    NSMutableDictionary *items;
    NSToolbarItem *useritem;
}

- (id)initWithController: (crController *)controller;

// toolbar delegates

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;

- (int)count;

// user actions

- (void)newLineToolbarItemClicked:(NSToolbarItem*)item;

- (void)removeLineToolbarItemClicked:(NSToolbarItem*)item;

- (void)openForUserToolbarItemClicked:(NSToolbarItem*)item;

- (void)writeCrontabToolbarItemClicked:(NSToolbarItem*)item;

// toolbar menu actions

- (void)customize:(id)sender;

- (void)showhide:(id)sender;

- (void)setUser: (NSString *)username;

- (BOOL)isVisible;

// workers

- (void) setImageWithName: (NSString *)name forItem: (NSToolbarItem *)item;


@end
