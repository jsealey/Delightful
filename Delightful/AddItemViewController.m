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

- (IBAction)dismiss:(id)sender {
    [self addItemPrivate:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) notification:(NSString *)title isForParent:(BOOL)isForParent{
    if(isForParent == YES){
        _notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                 showActivity:NO
                                                           inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                       inView:_parent.navigationController.navigationBar];
    } else {
        _notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                showActivity:NO
                                                          inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                      inView:_scrollView];
    }
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0];
}

- (void) addItemPrivate:(BOOL)isForParent {
    if(![_nameField.text isEqual:@""] && [_quantityField.text integerValue]){
        NSEntityDescription *entity = [[_model.fetchedResultsController fetchRequest] entity];
        Item *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:_model.managedObjectContext];
        newManagedObject.timeStamp = [NSDate date];
        newManagedObject.name = _nameField.text;
        newManagedObject.category = @"Dairy";
        newManagedObject.measurement = [[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex];
        newManagedObject.quantity = [[NSNumber alloc] initWithInt:[_quantityField.text integerValue]];
        newManagedObject.checked = [[NSNumber alloc] initWithBool:NO];
        NSError *error = nil;
        if (![_model.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        [self notification:[NSString stringWithFormat:@"Added %@ %@ of %@", _quantityField.text,[Item getMeasurementName:newManagedObject.measurement], _nameField.text] isForParent:isForParent];
        
        [self dismissKeyboard:nil];
        [_nameField setText:@""];
        [_quantityField setText:@""];
    }

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
