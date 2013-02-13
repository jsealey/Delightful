//
//  Item.m
//  Delightful
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
    Model *model = [Model modelSingleton];
    
    if(model.getMeasuringSetting){
        switch([measurement integerValue]){
            case 0: return @"pcs.";
            case 1: return @"gr.";
            case 2: return @"ml.";
            default: return @"IDK";
        }
    } else {
        switch([measurement integerValue]){
            case 0: return @"pcs.";
            case 1: return @"lbs";
            case 2: return @"oz";
            default: return @"IDK";
        }
    }
}

@end
