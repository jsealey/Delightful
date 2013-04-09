//
//  SettingsViewController.h
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Model.h"
#import "MasterViewController.h"

@interface SettingsViewController : UIViewController
@property Model *model;
@property (weak, nonatomic) IBOutlet UISegmentedControl *measurementSegmentedController;
@property (nonatomic, retain) GCDiscreetNotificationView *notificationView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UITextField *taxTextField;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)setMeasuringSystem:(id)sender;
- (IBAction)setTaxRate:(id)sender;


@end
