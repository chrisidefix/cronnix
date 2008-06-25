//
//  UserImage.h
//  CronniX
//
//  Created by sas on Sun Jun 10 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>


/*!
	@class UserImageRep
	@abstract 
	@discussion 
*/
@interface UserImageRep : NSCustomImageRep {

/*! @var user description */
    NSString *user;

}

/*!
	@method initWithUserName
	@abstract 
	@discussion 
	@result 
*/
- (id)initWithUserName: (NSString *)username;

/*!
	@method setUser
	@abstract 
	@discussion 
	@result 
*/
- (void) setUser: (NSString *)user;
/*!
	@method user
	@abstract 
	@discussion 
	@result 
*/
- (NSString *)user;

@end
