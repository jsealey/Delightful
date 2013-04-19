//
//  Item.h
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * measurement;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * name;

+ (NSString *)getMeasurementName:(NSNumber *)measurement;
+ (NSString *)getCategoryName:(NSNumber *)categoryid;

@end
