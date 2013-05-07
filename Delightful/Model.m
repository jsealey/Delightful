//
//  Model.m
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "Model.h"

@implementation Model

+ (Model *)modelSingleton
{
    static Model *modelSingleton;
    @synchronized(self)
    {
        if (!modelSingleton)
            modelSingleton = [[Model alloc] init];
        return modelSingleton;
    }
}
+ (NSArray *)categories
{
    static NSArray *categoriesSingleton;
    @synchronized(self)
    {
        if (!categoriesSingleton)
            categoriesSingleton = [[NSArray alloc] initWithObjects:
                                   @"Other",
                                   @"Dairy",
                                   @"Meat & Fish",
                                   @"Tinned Food",
                                   @"Fruits & Veget.",
                                   @"Drinks",
                                   @"Frozen Food",
                                   @"Houseware",
                                   @"Baked Goods",
                                   @"Candies",
                                   nil];
        return categoriesSingleton;
    }
}


#pragma mark - Read

// Metric = YES, US = NO
- (BOOL) getMeasuringSetting {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"measuringSetting"] boolValue];
}

- (NSNumber*) getTaxRate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"taxRate"];
}

#pragma mark - Update

// Metric = YES, US = NO
- (void) setMeasuringSetting:(BOOL)measuring {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:measuring forKey:@"measuringSetting"];
    [defaults synchronize];
}

- (void) setTaxRate:(NSNumber*)measuring {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:[measuring doubleValue] forKey:@"taxRate"];
    [defaults synchronize];
}
@end
