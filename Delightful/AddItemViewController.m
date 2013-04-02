//
//  AddItemViewController.m
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "AddItemViewController.h"

#import "Item.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController

dispatch_queue_t myQueue;

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
    [self setupMeasurementValues];
    _formContainerView.backgroundColor = [_formContainerView.backgroundColor colorWithNoiseWithOpacity:0.1 andBlendMode:kCGBlendModeDarken];
    
    CALayer *layer = _formContainerView.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    _notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                           showActivity:NO
                                                     inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                 inView:self.view];
    _notificationView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setupMeasurementValues {
    for(int i=0; i < 3;++i)
        [_measurement
                    setTitle:[Item getMeasurementName:[[NSNumber alloc] initWithInteger:i]]
           forSegmentAtIndex:i];
}

- (IBAction)dismiss:(id)sender {
    [self addItemPrivate:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) notification:(NSString *)title isForParent:(BOOL)isForParent{
    if(isForParent == YES){
        _notificationView.view = _parent.tableView;
    } else {
        _notificationView.view = _scrollView;
    }
    _notificationView.hidden = NO;
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0];
    myQueue = dispatch_queue_create("My Queue", NULL);
    dispatch_async(myQueue, ^{
        [NSThread sleepForTimeInterval:1.20];
        dispatch_async(dispatch_get_main_queue(), ^{
            _notificationView.hidden = YES;
        });
    });
}

- (void) addItemPrivate:(BOOL)isForParent {
    if(![_nameField.text isEqual:@""] && [_quantityField.text integerValue]){
        
        [_model addItemWithName:_nameField.text withCategory:@"Default" withMeasurement:[[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex] withQuantity:[[NSNumber alloc] initWithInt:[_quantityField.text integerValue]] withPrice:[[NSNumber alloc] initWithDouble:[_priceField.text doubleValue]]];
        
        [self notification:[NSString stringWithFormat:@"Added %@ %@ of %@", _quantityField.text,[Item getMeasurementName:[[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex]], _nameField.text] isForParent:isForParent];
        
        [self dismissKeyboard:nil];
        [_nameField setText:@""];
        [_quantityField setText:@""];
        [_priceField setText:@""];
    }
    [self.parent priceNotification];
}

- (IBAction)addItem:(id)sender {
    [self addItemPrivate:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _scrollView.contentSize=CGSizeMake(0,600.0);
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [_nameField resignFirstResponder];
    [_quantityField resignFirstResponder];
    [_priceField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   // [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
   // [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 50; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction)incrementQuantity:(id)sender {
    _quantityField.text = [NSString stringWithFormat:@"%i",_quantityField.text.integerValue + 1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard:nil];
    return YES;
}

@end
