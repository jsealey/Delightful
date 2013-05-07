//
//  SettingsViewController.h
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "Model.h"
#import "GCDiscreetNotificationView.h"
#import "KGNoise.h"

@interface SettingsViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property Model *model;
@property (weak, nonatomic) IBOutlet UISegmentedControl *measurementSegmentedController;
@property (nonatomic, retain) GCDiscreetNotificationView *notificationView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *logout;
@property (weak, nonatomic) IBOutlet UITextField *taxTextField;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)setMeasuringSystem:(id)sender;
- (IBAction)setTaxRate:(id)sender;
- (IBAction)parseLogout:(id)sender;


@end
