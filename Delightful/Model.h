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

+ (Model *)modelSingleton;

#pragma mark Create
- (void) setMeasuringSetting:(BOOL)measuring;

- (void) addItemWithName:(NSString *)name
    withCategory:(NSString *)category
 withMeasurement:(NSNumber*)measurement
    withQuantity:(NSNumber*)quantity;

#pragma mark Read

- (BOOL) getMeasuringSetting;

#pragma mark Update

- (void) updateItem:(Item*)item;

#pragma mark Delete

@end
