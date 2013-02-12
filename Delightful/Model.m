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

@end
