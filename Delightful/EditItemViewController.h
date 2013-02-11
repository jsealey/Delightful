//
//  EditItemViewController.h
//  Delightful
//
//  Created by Jared on 2/10/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditItemViewController : UIViewController

@property NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *measurement;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (void)updateItem;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)incrementQuantity:(id)sender;
- (IBAction)updateMeasurement:(id)sender;


@end
