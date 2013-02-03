//
//  AddItemViewController.m
//  ShopHealthy
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addItem:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Item *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    newManagedObject.timeStamp = [NSDate date];
    newManagedObject.name = _nameField.text;
    newManagedObject.category = @"Dairy";
    newManagedObject.measurement = [[NSNumber alloc] initWithInt:1];
    newManagedObject.quantity = [[NSNumber alloc] initWithInt:[_quantityField.text integerValue]];
    newManagedObject.checked = [[NSNumber alloc] initWithBool:NO];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    myQueue = dispatch_queue_create("com.lynda.gcdtest", NULL);
    dispatch_async(myQueue, ^{[self timedPopup:_nameField.text withQuantity:[NSString stringWithFormat:@"%@ %@", _quantityField.text, [Item getMeasurementName:newManagedObject.measurement]]];});
    [_nameField resignFirstResponder];
    [_quantityField resignFirstResponder];
    [_nameField setText:@""];
    [_quantityField setText:@""];
}

- (void) timedPopup:(NSString *)name withQuantity:(NSString *)quantities
{
    dispatch_async(dispatch_get_main_queue(), ^{
        progressAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Added %@", name]
                                                  message:quantities
                                                 delegate: self
                                        cancelButtonTitle: nil
                                        otherButtonTitles: nil];
        [progressAlert show];
    });
    [NSThread sleepForTimeInterval:0.4];
    dispatch_async(dispatch_get_main_queue(), ^{[progressAlert dismissWithClickedButtonIndex:0 animated:YES];});
}

- (IBAction)dismissKeyboard:(id)sender {
    [_nameField resignFirstResponder];
    [_quantityField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard:nil];
    return YES;
}
@end
