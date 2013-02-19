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
- (IBAction)setMeasuringSystem:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *metricButton;
@property (weak, nonatomic) IBOutlet UIButton *usButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property Model *model;
@property MasterViewController *parent;
- (IBAction)changeColorLight:(id)sender;
- (IBAction)changeColorDark:(id)sender;

@end
