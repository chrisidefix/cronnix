//
//  userImageView.h
//  CronniX
//
//  Created by sas on Sun Jun 10 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


/*!
	@class UserImageView
	@abstract 
	@discussion 
*/
@interface UserImageView : NSView {
/*! @var title description */
    NSString *title;
/*! @var user description */
    NSString *user;
/*! @var attributes description */
    NSMutableDictionary *attributes;
}

/*!
	@method setUser
	@abstract 
	@discussion 
	@result 
*/
- (void) setUser: (NSString *)user;
/*!
	@method title
	@abstract 
	@discussion 
	@result 
*/
- (NSString *)title;
/*!
	@method user
	@abstract 
	@discussion 
	@result 
*/
- (NSString *)user;
/*!
	@method size
	@abstract 
	@discussion 
	@result 
*/
- (NSSize)size;
/*!
	@method attributes
	@abstract 
	@discussion 
	@result 
*/
- (NSMutableDictionary *)attributes;

@end
