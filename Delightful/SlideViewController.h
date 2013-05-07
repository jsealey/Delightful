//
//  SlideViewController.h
//  Delightful
//
//  Created by Jared on 3/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "SASlideMenuViewController.h"
#import "SASlideMenuDataSource.h"
#import <Parse/Parse.h>

@interface SlideViewController : SASlideMenuViewController <SASlideMenuDataSource,SASlideMenuDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
-(void) checkLogin;
@end
