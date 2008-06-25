//
//  crController.h
//  CronniX
//
//  Created by sas on Sat Sep 15 2001.
//  Copyright (c) 2001 Sven A. Schmidt. All rights reserved.
//
//  abstracture IT-Beratung GmbH
//  www.abstracture.de
//  sas@abstracture.de
//

#import <Cocoa/Cocoa.h>
#import "envVariablesNibController.h"
#import "UserImageRep.h"
#import "Toolbar.h"
#import "SwitchFormatter.h"
#import "TaskObject.h"
#import "Crontab.h"

// notifications
static NSString *DocumentModifiedNotification __attribute__ ((unused)) = @"DocumentModified";
static NSString *UserSelectedNotification __attribute__ ((unused)) = @"UserSelected";


@class Toolbar;

@interface crController : NSObject {
  NSTableView *crTable;
  NSWindow    *winMain;
  NSMenuItem  *mInsertProgram;
  NSMenuItem  *mSave;
  NSMenuItem  *showHideMenuItem;
  NSMenuItem  *deleteMenuItem;
  NSMenuItem  *duplicateMenuItem;
  NSMenuItem  *editTaskMenuItem;
  NSMenuItem  *runNowMenuItem;
	NSTextField *infoTextField;
	NSMenu      *contextMenu;
	id          draggedObjects;
  
  NSString *crontabForUser;
  BOOL isDirty;
  Toolbar *toolbar;
	Crontab *currentCrontab;
	NSTableColumn *userColumn;
	NSTableColumn *commandColumn;
}

- (void)initDataSource;

- (void)loadCrontab;

- (void)loadCrontabForUser: (NSString *)user;

- (void)loadCrontabForDefaultUser;

- (void)writeCrontab;

- (id)defaultTask;

- (void)newLine;
- (void)newLineWithDialog;
- (void)newLineWithTask: (TaskObject *)aTask;
- (void)newLineWithCommand: (NSString *)cmd;

- (void)taskCreated: (NSNotification *)notification;

- (void)editSelectedTask;
- (void)taskEdited: (NSNotification *)notification;

- (void)insertProgramWithString:(NSString *)path;

- (void)removeLine;

- (void)replaceLineAtRow: (int)row withObject: (id)obj;

- (void)removeLinesInList: (NSEnumerator *)list;

- (void)duplicateLinesInList: (NSEnumerator *)list;

- (void)clearCrontab;

- (void)parseCrontab: (NSData *)data;

- (void)didEndTerminateSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)didEndUpdateAvailableSheet:(NSWindow *)sheet
										  returnCode:(int)returnCode
												  contextInfo:(void *)contextInfo;
- (void)openForUser;

- (void)openSystemCrontab;

- (void)crontabShouldLoad;

- (void)systemCrontabShouldLoad;

- (void)crontabShouldImport;

- (void)didEndLoadSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)didEndLoadSytemCrontabSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)didEndImportCrontabSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (BOOL)isSystemCrontab;

- (void)runSelectedCommand;

- (void)importCrontab: (id)sender;

- (void)importCrontab;

- (void)openCrontabFromFile: (NSString *)path;


// accessors

- (id)mainWindow;

- (id)window;

- (BOOL)isDirty;

- (void)setDirty: (BOOL)value;

- (void)documentModified: (NSNotification *)notification;

- (void)userSelected: (NSNotification *)notification;

- (void)setDraggedObjects: (NSArray *)objects;

- (NSString *)crontabForUser;

- (void)setCrontabForUser: (NSString *)user;

- (NSString *)suCronCommand;

- (int)selectedRow;
- (id)selectedTask;

- (NSWindow *)envVarWindow;
- (Crontab *)currentCrontab;

// actions -----------------------------------------------

- (IBAction)loadCrontab:(id)sender;

- (IBAction)newLine:(id)sender;

- (IBAction)newLineWithDialog:(id)sender;

- (IBAction)removeLine:(id)sender;

- (IBAction)duplicateLine:(id)sender;

- (IBAction)writeCrontab:(id)sender;

- (IBAction)openForUser:(id)sender;

- (IBAction)openSystemCrontab:(id)sender;

- (IBAction)showInfoPanel:(id)sender;

- (IBAction)insertProgram:(id)sender;

- (IBAction)envVariables:(id)sender;

- (IBAction)editSelectedTask:(id)sender;

- (void)activeButtonToggled;

- (IBAction)runSelectedCommand:(id)sender;

- (IBAction)openHomepage:(id)sender;

- (IBAction)checkForUpdates:(id)sender;

- (void)exportCrontab: (id)sender;

// toolbar menu actions

- (void)customizeToolbar:(id)sender;

- (void)showhideToolbar:(id)sender;


- (void)showInfoForTask:(int)index;


// test

- (NSData *)runCliCommand: (NSString *)cmd WithArgs: (NSArray *)args;

@end
