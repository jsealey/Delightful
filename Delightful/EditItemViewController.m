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
    _priceField.text = [[NSString alloc] initWithFormat:@"%.2f", object.price.doubleValue];
    
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
    [_priceField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateItem];
}

- (void) notification:(NSString *)title{
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0f];
}

- (void)updateItem {
    Item *object = [_model.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
    // This is just saying to only update when something was changed
    if(  ![_nameField.text isEqual:@""]
       && [_quantityField.text integerValue]
       // If at least one field has been changed...
       && (  ![_nameField.text isEqualToString:object.name]
           || [_quantityField.text integerValue]!=[object.quantity integerValue]
           || _measurement.selectedSegmentIndex!=[object.measurement integerValue]
           || _priceField.text.doubleValue!=[object.price doubleValue])
       ){
        object.name = _nameField.text;
        object.quantity = [[NSNumber alloc] initWithInt:[_quantityField.text integerValue]];
        object.measurement = [[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex];
        object.price = [[NSNumber alloc] initWithDouble:[_priceField.text doubleValue]];
        [_model updateItem:object];
        [self notification:[NSString stringWithFormat:@"%@ %@ of %@ at $%.2f", object.quantity,[Item getMeasurementName:object.measurement], object.name, object.price.doubleValue]];
        [_parent showEditButtonIfNotEmpty];
    }
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
