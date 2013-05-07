//
//  ScrollablePickerView.m
//  Delightful
//
//  Created by Jared on 5/2/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "ScrollablePickerView.h"

@implementation ScrollablePickerView

- (UIScrollView *)findScrollableSuperview {
    
    UIView *parent = self.superview;
    while ((nil != parent) && (![parent isKindOfClass:[UIScrollView class]])) {
        parent = parent.superview;
    }
    UIScrollView* scrollView = (UIScrollView *)parent;
    
    return scrollView;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    UIScrollView* scrollView = [self findScrollableSuperview];
    
    if (CGRectContainsPoint(self.bounds, point)) {
        scrollView.canCancelContentTouches = NO;
        scrollView.delaysContentTouches = NO;
    } else {
        scrollView.canCancelContentTouches = YES;
        scrollView.delaysContentTouches = YES;
    }
    
    return [super hitTest:point withEvent:event];
}

@end