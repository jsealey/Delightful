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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)dismiss:(id)sender {
    [self addItem:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addItem:(id)sender {
    if(![_nameField.text isEqual:@""] && [_quantityField.text integerValue]){
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        Item *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        newManagedObject.timeStamp = [NSDate date];
        newManagedObject.name = _nameField.text;
        newManagedObject.category = @"Dairy";
        newManagedObject.measurement = [[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex];
        newManagedObject.quantity = [[NSNumber alloc] initWithInt:[_quantityField.text integerValue]];
        newManagedObject.checked = [[NSNumber alloc] initWithBool:NO];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
      
        progressAlert = [[UIAlertView alloc]
                        initWithTitle:[NSString stringWithFormat:@"Added %@", _nameField.text]
                              message:[NSString stringWithFormat:@"%@ %@", _quantityField.text, [Item getMeasurementName:newManagedObject.measurement]]
                             delegate: self
                    cancelButtonTitle: nil
                    otherButtonTitles: nil];
        [progressAlert show];
        [self performSelector:@selector(dismissAlertView:) withObject:progressAlert afterDelay:1];
        [self dismissKeyboard:nil];
        [_nameField setText:@""];
        [_quantityField setText:@""];
    }
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
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 60; // tweak as needed
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
