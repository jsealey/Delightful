//
//  Item.h
//  ShopHealthy
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * measurement;
@property (nonatomic, retain) NSString * name;

+ (NSString *)getMeasurementName:(NSNumber *)measurement;

@end
