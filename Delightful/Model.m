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

// Metric = YES
// US = NO
- (BOOL) getMeasuringSetting {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"measuringSetting"] boolValue];
}

- (void) setMeasuringSetting:(BOOL)measuring {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:measuring forKey:@"measuringSetting"];
    [defaults synchronize];
}

@end
