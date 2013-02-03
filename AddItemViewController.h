//
//  AddItemViewController.h
//  ShopHealthy
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddItemViewController : UIViewController
- (IBAction)dismiss:(id)sender;
- (IBAction)addItem:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *measurement;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (IBAction)resign:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (void) timedPopup:(NSString *)name withQuantity:(NSString *)quantities;
@end
