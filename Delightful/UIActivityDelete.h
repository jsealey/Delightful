//
//  UIActivityDelete.h
//  Delightful
//
//  Created by Christopher Hansen on 4/10/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityDelete : UIActivity

@property (nonatomic) BOOL didClear;

- (NSString *)activityType;
- (NSString *)activityTitle;
- (NSString *)activityImage;

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems;
- (void)prepareWithActivityItems:(NSArray *)activityItems;
- (void)performActivity;

@end
