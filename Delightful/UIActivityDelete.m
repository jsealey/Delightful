//
//  UIActivityDelete.m
//  Delightful
//
//  Created by Christopher Hansen on 4/10/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "UIActivityDelete.h"
#import "MasterViewController.h"

@interface UIActivityDelete ()

@property (strong, nonatomic) MasterViewController *masterController;

@end

@implementation UIActivityDelete

- (NSString *)activityType {
  return @"Clear List";
}

- (NSString *)activityTitle {
  return @"Clear List";
}

- (UIImage *)activityImage {
  return [UIImage imageNamed:@"checkmark.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
  for (UIActivityItemProvider *item in activityItems) {
    if ([item isKindOfClass:[NSString class]]) {
      return YES;
    }
  }
  return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
  for (id item in activityItems) {
    if ([item isKindOfClass:[NSString class]]) {
      self.didClear = YES;
    }
  }
}

- (void)performActivity {
  [self activityDidFinish:YES];
}

@end
