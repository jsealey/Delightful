//
//  Model.h
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "AppDelegate.h"
#import "ParseTableViewController.h"

@interface Model : NSObject

@property PFQueryTableViewController *parseTableView;
@property AppDelegate *appDelegate;

+ (Model *)modelSingleton;
+ (NSArray *) categories;

#pragma mark Read

- (BOOL) getMeasuringSetting;
- (NSNumber*) getTaxRate;

#pragma mark Update

- (void) setMeasuringSetting:(BOOL)measuring;
- (void) setTaxRate:(NSNumber*)measuring;

#pragma mark Delete

@end
