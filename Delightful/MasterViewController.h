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
#import "GCDiscreetNotificationView.h"
#import "BlockActionSheet.h"
#import <Parse/Parse.h>

@interface MasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *rightButtonTempHold;
@property BOOL isEditing;
@property BOOL isEditingSingleCell;
@property NSIndexPath *currentEditIndexPath;
@property Model *model;
@property UIColor *cellBgColor;
- (void) reloadVisibleCells;
- (void)showEditButtonIfNotEmpty;
- (void) priceNotification;
- (void)confirmDeleteAll;
@property (nonatomic, retain) GCDiscreetNotificationView *totalPriceNotificationView;
@end
