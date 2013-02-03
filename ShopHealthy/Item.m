//
//  Item.m
//  ShopHealthy
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "Item.h"


@implementation Item

@dynamic timeStamp;
@dynamic category;
@dynamic checked;
@dynamic quantity;
@dynamic measurement;
@dynamic name;

+ (NSString *)getMeasurementName:(NSNumber *) measurement{
    NSLog(@"Integer value:");
    NSLog([NSString stringWithFormat:@"%i",[measurement integerValue]]);
    switch([measurement integerValue]){
        case 0: return @"pcs.";
        case 1: return @"lbs";
        case 2: return @"oz";
        default: return @"IDK";
    }
}

@end
