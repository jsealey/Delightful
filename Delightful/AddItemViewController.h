//
//  AddItemViewController.h
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface AddItemViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *measurement;
@property Model *model;

- (IBAction)dismiss:(id)sender;
- (IBAction)addItem:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)incrementQuantity:(id)sender;
@end
