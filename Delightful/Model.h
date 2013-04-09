//
//  Model.h
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Model : NSObject

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property UIViewController *masterController;

+ (Model *)modelSingleton;

#pragma mark Create
- (void) addItemWithName:(NSString *)name
    withCategory:(NSString *)category
 withMeasurement:(NSNumber*)measurement
    withQuantity:(NSNumber*)quantity
       withPrice:(NSNumber*)price;

#pragma mark Read

- (BOOL) getMeasuringSetting;
- (NSNumber*) getTaxRate;

#pragma mark Update

- (void) setMeasuringSetting:(BOOL)measuring;
- (void) setTaxRate:(NSNumber*)measuring;
- (void) updateItem:(Item*)item;

#pragma mark Delete

@end
