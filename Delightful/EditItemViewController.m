//
//  EditItemViewController.m
//  Delightful
//
//  Created by Jared on 2/10/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "EditItemViewController.h"

#import "Item.h"

@interface EditItemViewController ()

@end

@implementation EditItemViewController
dispatch_queue_t myQueue;
UIAlertView *progressAlert;

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
    Item *object = [_model.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
    _nameField.text = object.name;
    _quantityField.text = [NSString stringWithFormat:@"%i",[object.quantity integerValue]];
    _measurement.selectedSegmentIndex = [object.measurement integerValue];
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
                                                                  inView:_scrollView];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setupMeasurementValues {
    for(int i=0; i < 3;++i)
        [_measurement
         setTitle:[Item getMeasurementName:[[NSNumber alloc] initWithInteger:i] ]
         forSegmentAtIndex:i];
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
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   // [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
   // [self animateTextField: textField up: NO];
    [self updateItem];
}

- (void) notification:(NSString *)title{
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0];
}

- (void)updateItem {
    if(![_nameField.text isEqual:@""] && [_quantityField.text integerValue]){
        Item *object = [_model.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
        object.name = _nameField.text;
        object.quantity = [[NSNumber alloc] initWithInt:[_quantityField.text integerValue]];
        object.measurement = [[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex];
        NSError *error = nil;
        if (![_model.managedObjectContext save:&error]) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [self notification:[NSString stringWithFormat:@"Updated: %@ %@ of %@", object.quantity,[Item getMeasurementName:object.measurement], object.name]];
    }
}



- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 50; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.parentViewController.view.frame = CGRectOffset(self.parentViewController.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction)incrementQuantity:(id)sender {
    _quantityField.text = [NSString stringWithFormat:@"%i",_quantityField.text.integerValue + 1];
    [self updateItem];
}

- (IBAction)updateMeasurement:(id)sender {
    [self updateItem];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard:nil];
    return YES;
}



@end
