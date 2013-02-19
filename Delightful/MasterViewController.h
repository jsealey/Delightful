//
//  MasterViewController.h
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "Model.h"
#import "KGNoise.h"
#import "AppDelegate.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property UIBarButtonItem *rightButtonTempHold;
@property BOOL isEditing;
@property BOOL isEditingSingleCell;
@property NSIndexPath *currentEditIndexPath;
@property Model *model;
- (void) reloadVisibleCells;
@end
