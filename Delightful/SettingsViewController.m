//
//  SettingsViewController.m
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "SettingsViewController.h"
#import "MasterViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [Model modelSingleton];
    _buttonContainerView.backgroundColor = [_buttonContainerView.backgroundColor colorWithNoiseWithOpacity:0.1 andBlendMode:kCGBlendModeDarken];
    CALayer *layer = _buttonContainerView.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor darkGrayColor].CGColor;
    [[AppDelegate alloc] setupNavigationTitle:self.navigationItem];
    
    _notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                            showActivity:NO
                                                      inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                  inView:self.view];
    _measurementSegmentedController.selectedSegmentIndex = [_model getMeasuringSetting];
    _taxTextField.text = [NSString stringWithFormat:@"%.2f",[[_model getTaxRate] doubleValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)setMeasuringSystem:(id)sender {
    [_model setMeasuringSetting:[[[NSNumber alloc] initWithInt:((UISegmentedControl *)sender).selectedSegmentIndex] boolValue]];
    [self notification:[NSString stringWithFormat:@"Updated to %@",[((UISegmentedControl *)sender) titleForSegmentAtIndex:((UISegmentedControl *)sender).selectedSegmentIndex]]];
    [(MasterViewController*)_model.masterController reloadVisibleCells];
}

- (IBAction)setTaxRate:(id)sender {
    if([((UITextView *)sender).text doubleValue] != [[_model getTaxRate] doubleValue]){
        [_model setTaxRate:[[NSNumber alloc] initWithDouble:[((UITextView *)sender).text doubleValue]]];
        [self notification:[NSString stringWithFormat:@"Updated tax rate: %.2f%%",[((UITextView *)sender).text doubleValue]]];
        [(MasterViewController*)_model.masterController reloadVisibleCells];
        [(MasterViewController*)_model.masterController priceNotification];
    }
}

- (IBAction)dismissKeyboard:(id)sender {
    [_taxTextField resignFirstResponder];
}

- (void) notification:(NSString *)title{
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0f];
}
@end
