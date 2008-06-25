//
//  crControllerTest.h
//  CronniX
//
//  Created by Sven A. Schmidt on Sun Mar 24 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <ObjcUnit/ObjcUnit.h>
#import "crController.h"


@interface crControllerTest : TestCase {
	crController *controller;
	NSData *cronData;
}

@end
