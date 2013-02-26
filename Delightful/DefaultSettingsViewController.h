//
//  DefaultSettingsViewController.h
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/14/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "KGNoise.h"
@interface DefaultSettingsViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *synchronizeButton;
@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;
- (IBAction)logOutButtonTapAction:(id)sender;
- (IBAction)showLogin:(id)sender;
- (IBAction)synchronize:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *NavigationItem;

@property PFLogInViewController *logInViewController;

@end
