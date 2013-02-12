//
//  SettingsViewController.h
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewController : UIViewController
- (IBAction)setMeasuringSystem:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *metricButton;
@property (weak, nonatomic) IBOutlet UIButton *usButton;

@end
