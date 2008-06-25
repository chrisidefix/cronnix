//
//  Crontab.m
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Jan 16 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Crontab.h"
#import "CommentLine.h"
#import "CrInfoCommentLine.h"
#import "UnparsedLine.h"

@implementation Crontab

- (id)init {
	return [ self initWithString: nil forUser: nil ];
}

- (id)initWithString: (NSString *)string {
	return [ self initWithString: string forUser: nil ];
}

- (id)initWithContentsOfFile: (NSString *)path forUser: (NSString *)aUser {
  id data = [ NSData dataWithContentsOfFile: path ];
	id string = [[ NSString alloc ] initWithData: data 
                                      encoding: [ NSString defaultCStringEncoding ]];
  return [ self initWithString: string forUser: aUser ];
}

- (id)initWithData: (NSData *)data forUser: (NSString *)aUser {
	id string = [[ NSString alloc ] initWithData: data 
                                      encoding: [ NSString defaultCStringEncoding ]];
	return [ self initWithString: string forUser: aUser ];
}

// designated constructor
- (id)initWithString: (NSString *)string forUser: (NSString *)aUser {
  [super init];
  
  objects = [[ NSMutableArray alloc ] init ];
  
  [ self setUser: aUser ];
  
  if ( string ) {
		[ self parseString: string ];
		
		// tell the world that there's a new crontab
		[[ NSNotificationCenter defaultCenter ] postNotificationName: NewCrontabParsedNotification
                                                          object: [ self tasks ]];
  }
  
  return self;
}

- (void)dealloc {
  [ objects release ];
  [ user release ];
  [ super dealloc ];
}


+ (BOOL)isContainedInString: (NSString *)string {
	id theLines = [[ string componentsSeparatedByString: @"\n" ] objectEnumerator ];
	id aLine;
	while ( aLine = [ theLines nextObject ] ) {
		if ( [ TaskObject isContainedInString: aLine ] ||
         [ EnvVariable isContainedInString: aLine ] ) return true;
	}
	return NO;
}


// workers

- (void)clear {
  [ objects removeAllObjects ];
  [ self setUser: nil ];
}


- (void)parseString: (NSString *)string {
	id lines = [ string componentsSeparatedByString: @"\n" ];
	id iter = [ lines objectEnumerator ];
  id line;
  while ( line = [ iter nextObject ] ) {
		id obj = nil;
		
		if ( [ line length ] == 0 ) {
			
			continue;
      
		} else if ( [ EnvVariable isContainedInString: line ] ) {
			
			obj = [[ EnvVariable alloc ] initWithString: line ];
		} else if ( [ CrInfoCommentLine isContainedInString: line ] ) {
			
			// do nothing: TaskObject will check if there are info comments in lines before it
			// make sure this stays in front of if ( [ CommentLine isContainedInString: line ] ) though
			
		} else if ( [ CommentLine isContainedInString: line ] ) {
			
			obj = [[ CommentLine alloc ] initWithString: line ];
			
		} else if ( [ TaskObject isContainedInString: line ] ) {
			
      obj = [[ TaskObject alloc ] initWithString: line forSystem: [ self isSystemCrontab ]];
			int index = [ lines indexOfObjectIdenticalTo: line ];
			int i;
			id infoStrings = [ NSMutableArray array ];
			for ( i = index -1; i >= 0; i-- ) {
				id prevLine = [ lines objectAtIndex: i ];
				if ( [ CrInfoCommentLine isContainedInString: prevLine ] ) {
					[ infoStrings insertObject: prevLine atIndex: 0 ];
				} else {
					break;
				}
			}
			if ( [ infoStrings count ] > 0 )
				[ obj setInfo: [ infoStrings componentsJoinedByString: @"\n" ]];
			
		} else {
			
			obj = [[ UnparsedLine alloc ] initWithString: line ];
		}
		[ obj autorelease ];
		
		if ( obj ) [ objects addObject: obj ];
  }
}



- (BOOL) isSystemCrontab {
  return [[ self user ] isEqualToString: systemCrontabUser ];
}


// accessors

- (NSArray *)objectsForClass: (Class)aClass {
  NSMutableArray *filteredObjects = [ NSMutableArray array ];
  NSEnumerator *iter = [ objects objectEnumerator ];
  id obj;
  while ( obj = [ iter nextObject ] ) {
		if ( [ obj isKindOfClass: aClass ] ) [ filteredObjects addObject: obj ];
  }
  return filteredObjects;
}

- (NSEnumerator *)objectEnumeratorForClass: (Class)aClass {
  return [[ self objectsForClass: aClass ] objectEnumerator ];
}

- (NSEnumerator *)reverseObjectEnumeratorForClass: (Class)aClass {
  return [[ self objectsForClass: aClass ] reverseObjectEnumerator ];
}

- (int)objectCountForClass: (Class)aClass {
  id iter = [ self objectEnumeratorForClass: aClass ];
  return [[ iter allObjects ] count ];
}


- (NSEnumerator *)reverseTasks {
  return [ self reverseObjectEnumeratorForClass: [ TaskObject class ]];
}

- (NSEnumerator *)reverseEnvVariables {
  return [ self reverseObjectEnumeratorForClass: [ EnvVariable class ]];
}

- (NSEnumerator *)tasks {
  return [ self objectEnumeratorForClass: [ TaskObject class ]];
}

- (int)taskCount {
  return [[[ self tasks ] allObjects ] count ];
}


- (NSString *)user {
  return user;
}

- (void)setUser: (NSString *)aValue {
  if ( user != aValue ) {
    [ user release ];
    user = ( aValue ) ? [ aValue retain ] : nil;
  }
}


- (void)addEnvVariable: (EnvVariable *)env {
	id iter = [ self reverseEnvVariables ];
	id lastEnv = [ iter nextObject ];
	int index;
	if ( lastEnv == nil ) {
		index = 0;
	} else {
		index = [ objects indexOfObjectIdenticalTo: lastEnv ];
	}
	if ( index +1 < [objects count] ) {
		[ objects insertObject: env atIndex: index +1 ];
	} else {
		[ objects addObject: env ];
	}
}

- (void)addEnvVariableWithValue: (NSString *)aValue forKey: (NSString *)aKey {
  [ self addEnvVariable: [ EnvVariable envVariableWithValue: aValue forKey: aKey ]];
}


- (void)removeAllEnvVariables {
  id allEnvs = [[ self envVariables ] allObjects ];
  id iter = [ allEnvs objectEnumerator ];
  id env;
  while ( env = [ iter nextObject ] ) {
		[ self removeEnvVariable: env ];
  }
}

- (void)removeEnvVariable: (EnvVariable *)env {
  //[ objects removeObject: env ];
  [ objects removeObjectIdenticalTo: env ];
}

- (void)removeEnvVariableWithKey: (NSString *)key {
  NSEnumerator *envs = [ self envVariables ];
  id env;
  while ( env = [ envs nextObject ] ) {
		if ( [[ env key ] isEqualToString: key ] ) {
			[ objects removeObject: env ];
			break;
		}
  }
}

- (void)removeEnvVariableAtIndex: (int)index {
  id env = [ self envVariableAtIndex: index ];
  [ objects removeObject: env ];
}


- (void)insertEnvVariable: (id)env atIndex: (int)index {
  NS_DURING
    int objIndex = [ self objectIndexOfEnvVariableAtIndex: index ];
    [ objects insertObject: env atIndex: objIndex ];
  NS_HANDLER
    if ( [[localException name] isEqualToString: NSRangeException] ) {
      //NSLog( @"
      [objects insertObject: env atIndex: [self objectIndexOfLastEnvVariable]+1];
    };
  NS_ENDHANDLER
}

- (void)addTask: (TaskObject *)task {
  [ objects addObject: task ];
}


- (void)removeTaskAtIndex: (int)index {
  id task = [ self taskAtIndex: index ];
  [ objects removeObject: task ];
}


- (void)removeTask: (TaskObject *)task {
	[ objects removeObjectIdenticalTo: task ];
}


- (int)objectIndexOfTaskAtIndex: (int)index {
  id task = [ self taskAtIndex: index ];
  return [ objects indexOfObjectIdenticalTo: task ];
}

- (int)objectIndexOfEnvVariableAtIndex: (int)index {
  id env = [ self envVariableAtIndex: index ];
  return [ objects indexOfObjectIdenticalTo: env ];
}


- (int)objectIndexOfLastEnvVariable {
  id lastEnv = [[self reverseEnvVariables] nextObject];
  return [objects indexOfObjectIdenticalTo: lastEnv];
}


- (void)insertTask: (TaskObject *)aTask atIndex: (int)index {
	if ( index > [ self taskCount ] -1 ) {
		[ objects addObject: aTask ];
	} else {
		int objIndex = [ self objectIndexOfTaskAtIndex: index ];
		[ objects insertObject: aTask atIndex: objIndex ];
	}
}

- (void)replaceTaskAtIndex: (int)index withTask: (TaskObject *)aTask {
  int objIndex = [ self objectIndexOfTaskAtIndex: index ];
  [ objects removeObjectAtIndex: objIndex ];
  [ objects insertObject: aTask atIndex: objIndex ];
}


- (void)addTaskWithString: (NSString *)string {
  [ objects addObject: [ TaskObject taskWithString: string ] ];
}

- (NSEnumerator *)envVariables {
  return [ self objectEnumeratorForClass: [ EnvVariable class ]];
}

- (int)envVariableCount {
  return [[[ self envVariables ] allObjects ] count ];
}

- (EnvVariable *)envVariableAtIndex: (int)index {
  return [[[ self envVariables ] allObjects ] objectAtIndex: index ];
}


- (NSData *)data {
	id data = [ NSMutableData data ];
	id iter = [ objects objectEnumerator ];
	id obj;
	
	while ( obj = [ iter nextObject ] ) {
		[ data appendData: [ obj data ]];
		[ data appendData: [ @"\n" dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
	}
	
	return data;
}


- (NSString *)description {
	id string = [[ NSString alloc ] initWithData: [ self data ] encoding: [ NSString defaultCStringEncoding ]];
	return [ string autorelease ];
}


- (TaskObject *)taskAtIndex: (int)index {
  return [[[ self tasks ] allObjects ] objectAtIndex: index ];
}


- (int)indexOfTask: (id)aTask {
  return [[[ self tasks ] allObjects ] indexOfObjectIdenticalTo: aTask ];
}


- (BOOL)writeAtPath: (NSString *)path {
  BOOL success = [[ self data ] writeToFile: path atomically: NO ];
  return success;
}

- (void)writeAtPath2: (NSString *)path {
  NSFileHandle *fh = [ NSFileHandle fileHandleForWritingAtPath: path ];
  NS_DURING
		[ fh writeData: [ self data ]];
		[ fh closeFile ];
  NS_HANDLER
		NSLog( @"failure writing file %@", path );
  NS_ENDHANDLER
}



@end
