//
//  TaskObject.m
//  CronniX
//
//  Created by Sven A. Schmidt on Mon Dec 31 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "TaskObject.h"
#import "Crontab.h"
#import "SasString.h"
#import "CrInfoCommentLine.h"

@implementation TaskObject

- (id)init {
    return [ self initWithString: nil ];
}


- (id)initWithString:(NSString *)string forSystem: (BOOL)isSystemCrontab {
  [super init];
  task = [[ NSMutableDictionary alloc ] init ];
  isSystemCrontabTask = isSystemCrontab;
  
  NS_DURING
    [ self parseString: string ];
  NS_HANDLER
    NSLog( @"Error parsing line: %@", string );
  NS_ENDHANDLER
  
  return self;
}


- (id)initWithString:(NSString *)string {
    return [ self initWithString: string forSystem: NO ];
}

- (id)initWithTask:(id)aTask {
    return [ aTask copy ];
}

+ (id)taskWithString:(NSString *)string {
    return [[[ TaskObject alloc ] initWithString: string forSystem: NO ] autorelease ];
}


+ (id)taskWithTask:(id)value {
    return [[ value copy ] autorelease ];
}


- (void)dealloc {
    [ task release ];
    [ super dealloc ];
}


- (id)copy {
    id newTask = [[ TaskObject alloc ] init ];
    [ newTask setDictionary: task ];
    [ newTask setIsSystemCrontabTask: [ self isSystemCrontabTask ]];
    return newTask;
}



// ----------

+ (BOOL)isContainedInString: (NSString *)line {
  if ( [ line startsWithStringIgnoringWhitespace: @"#" ] &&
       ! [ line startsWithStringIgnoringWhitespace: DisableTag ] ) return NO;
  
  // ignore '@' commands (for now)
  if ( [ line startsWithStringIgnoringWhitespace: @"@" ] ) return NO;
    
    {
		NSCharacterSet *ws = [ NSCharacterSet whitespaceCharacterSet ];
		int fieldCount = [ line fieldCountSeperatedBy: ws ];
		if ( fieldCount < 6 ) return NO;
    }
    
    return YES;
}




- (void)parseString: (NSString *)string {
    NSScanner *scanner;
    NSCharacterSet *whitespace = [ NSCharacterSet whitespaceCharacterSet ];
    NSString *min;
    NSString *hour;
    NSString *mday;
    NSString *month;
    NSString *wday;
    NSString *user;
    NSString *command = nil;
    unsigned cind;
    
    if ( ! string ) return;
    
    //	NSLog( @"Parsing string: %@", string );
    
    if ( [ string hasPrefix: DisableTag ] ) {
	string = [ string substringFromIndex: [ DisableTag length ]];
	[ self setActive: NO ];
    } else {
	[ self setActive: YES ];
    }
    
    scanner =  [ NSScanner scannerWithString: string ];
    [ scanner scanUpToCharactersFromSet: whitespace intoString: &min ];
    [ scanner scanUpToCharactersFromSet: whitespace intoString: &hour ];
    [ scanner scanUpToCharactersFromSet: whitespace intoString: &mday ];
    [ scanner scanUpToCharactersFromSet: whitespace intoString: &month ];
    [ scanner scanUpToCharactersFromSet: whitespace intoString: &wday ];
    if ( [ self isSystemCrontabTask ] )
        [ scanner scanUpToCharactersFromSet: whitespace intoString: &user ];
    
    cind = [ scanner scanLocation ] + 1;
    if ( cind <= [ string length ] ) {
        command = [ string substringFromIndex: cind ];
	command = [ command stringByTrimmingCharactersInSet: whitespace ];
    }
    
    
    [ self setMinute: min ];
    [ self setHour: hour ];
    [ self setMday: mday ];
    [ self setMonth: month ];
    [ self setWday: wday ];
    if ( [ self isSystemCrontabTask ] )
	[ self setUser: user ];
    [ self setCommand: command ];
}


- (void)setObject:(id)anObject forKey:(id)aKey {
    [ task setObject: anObject forKey: aKey ];
}

- (id)objectForKey:(id)aKey {
    return [ task objectForKey: aKey ];
}

- (void)setActive: (BOOL)value {
    [ self setObject: [ NSString stringWithFormat: @"%u", value ] forKey: @"Active" ];
}

- (BOOL)isActive {
    return [[ self objectForKey: @"Active" ] intValue ] == 1;
}


- (void)setMinute: (NSString *)value {
    [ self setObject: value forKey: @"Min" ];
}

- (NSString *)minute {
    return [ self objectForKey: @"Min" ];
}


- (void)setHour: (NSString *)value {
    [ self setObject: value forKey: @"Hour" ];
}

- (NSString *)hour {
    return [ self objectForKey: @"Hour" ];
}


- (void)setMday: (NSString *)value {
    [ self setObject: value forKey: @"Mday" ];
}

- (NSString *)mday {
    return [ self objectForKey: @"Mday" ];
}


- (void)setMonth: (NSString *)value {
    [ self setObject: value forKey: @"Month" ];
}

- (NSString *)month {
    return [ self objectForKey: @"Month" ];
}


- (void)setWday: (NSString *)value {
    [ self setObject: value forKey: @"Wday" ];
}

- (NSString *)wday {
    return [ self objectForKey: @"Wday" ];
}


- (void)setCommand: (NSString *)value {
    [ self setObject: value forKey: @"Command" ];
}

- (NSString *)command {
    return [ self objectForKey: @"Command" ];
}


- (void)setUser: (NSString *)value {
    [ self setObject: value forKey: @"User" ];
}

- (NSString *)user {
    return [ self objectForKey: @"User" ];
}



- (NSString *)info {
    return [ self objectForKey: @"Info" ];
}

- (void)setInfo: (NSString *)aValue {
    id string = [ NSMutableString stringWithString: [ aValue stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]]];
	[ string replaceOccurrencesOfString: [ NSString stringWithFormat: @"%@ ", CrInfoComment ]
							 withString: @"" 
								options: NSLiteralSearch
								  range: NSMakeRange( 0, [ string length ] ) ];
	[ string replaceOccurrencesOfString: [ NSString stringWithFormat: @"%@\t", CrInfoComment ]
							 withString: @"" 
								options: NSLiteralSearch
								  range: NSMakeRange( 0, [ string length ] ) ];
	/*
    if ( [ string startsWithString: CrInfoComment ] ) {
		string = [ string substringFromIndex: [ CrInfoComment length ] -1 ];
		string = [ string stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    }
 */
    [ self setObject: string forKey: @"Info" ];
}


- (NSData *)data {
	NSMutableData *data = [ NSMutableData data ];
    
	// add info line
	if ( [ self info ] ) {
		id string = [ NSMutableString stringWithFormat: @"%@ %@", CrInfoComment, [ self info ]];
		[ string replaceOccurrencesOfString: @"\n" 
								 withString: [ NSString stringWithFormat: @"\n%@ ", CrInfoComment ] 
									options: NSLiteralSearch 
									  range: NSMakeRange( 0, [ string length ] ) ];
		[ string appendString: @"\n" ];
		[ data appendData: [ string dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
	}
	
	// prepare the task line

	id line;

	// prepare the active/inactive string
	id activeString = [ self isActive ] ?  @"" : [ NSString stringWithFormat: @"%@ ", DisableTag ];
	id asterisk = @"*";
	if ( [ self isSystemCrontabTask ] ) {
		line = [ NSString stringWithFormat: @"%@%@\t%@\t%@\t%@\t%@\t%@\t%@",
			activeString,
			[[ self objectForKey: @"Min" ] length ] != 0 ? [ self objectForKey: @"Min" ] : asterisk,
			[[ self objectForKey: @"Hour" ] length ] != 0 ? [ self objectForKey: @"Hour" ] : asterisk,
			[[ self objectForKey: @"Mday" ] length ] != 0 ? [ self objectForKey: @"Mday" ] : asterisk,
			[[ self objectForKey: @"Month" ] length ] != 0 ? [ self objectForKey: @"Month" ] : asterisk,
			[[ self objectForKey: @"Wday" ] length ] != 0 ? [ self objectForKey: @"Wday" ] : asterisk,
			[[ self objectForKey: @"User" ] length ] != 0 ? [ self objectForKey: @"User" ] : @"root",
			[[ self objectForKey: @"Command" ] length ] != 0 ? [ self objectForKey: @"Command" ] : asterisk ];
	} else {
		line = [ NSString stringWithFormat: @"%@%@\t%@\t%@\t%@\t%@\t%@",
			activeString,
			[[ self objectForKey: @"Min" ] length ] != 0 ? [ self objectForKey: @"Min" ] : asterisk,
			[[ self objectForKey: @"Hour" ] length ] != 0 ? [ self objectForKey: @"Hour" ] : asterisk,
			[[ self objectForKey: @"Mday" ] length ] != 0 ? [ self objectForKey: @"Mday" ] : asterisk,
			[[ self objectForKey: @"Month" ] length ] != 0 ? [ self objectForKey: @"Month" ] : asterisk,
			[[ self objectForKey: @"Wday" ] length ] != 0 ? [ self objectForKey: @"Wday" ] : asterisk,
			[[ self objectForKey: @"Command" ] length ] != 0 ? [ self objectForKey: @"Command" ] : asterisk ];
	}

	[ data appendData: [ line dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
    
    return data;	
}

- (NSString *)description {
	id string = [[ NSString alloc ] initWithData: [ self data ] encoding: [ NSString defaultCStringEncoding ]];
	return [ string autorelease ];
}


// accessors

- (void)setDictionary:(NSDictionary *)dict {
    task = [[ NSMutableDictionary alloc ] initWithDictionary: dict ];
}

- (BOOL)isSystemCrontabTask {
    return isSystemCrontabTask;
}

- (void)setIsSystemCrontabTask: (BOOL)aValue {
    isSystemCrontabTask = aValue;
}


// transparent forwarding

/* essential forwarding methods
- (void)forwardInvocation: (NSInvocation *)invocation {
    NSLog( @"forward" );
    if ( [[ self task ] respondsToSelector: [invocation selector] ] ) {
        [ invocation invokeWithTarget: [ self task ] ];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ( [ self respondsToSelector: aSelector ] ) {
	return [ self methodSignatureForSelector: aSelector ];
    } else {
	return [[ self task ] methodSignatureForSelector: aSelector ];
    }
} */


/* not really needed
- (BOOL)respondsToSelector: (SEL)aSelector {
    NSLog( @"responds" );
    return [ super respondsToSelector: aSelector ] || [[ self task ] respondsToSelector: aSelector ];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [[ self task ] isKindOfClass: aClass ];
}

+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
    NSLog( @"instance responds" );
    return [ self instancesRespondToSelector: aSelector ] || [[ self task ] instancesRespondToSelector: aSelector ];
}*/



@end
