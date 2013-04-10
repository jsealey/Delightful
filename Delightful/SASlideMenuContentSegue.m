//
//  SASlideContentSegue.m
//  SASlideMenu
//
//  Created by Stefano Antonelli on 1/17/13.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SASlideMenuContentSegue.h"
#import "SASlideMenuRootViewController.h"
#import "SASlideMenuViewController.h"

@implementation SASlideMenuContentSegue

-(void) perform{
 
    SASlideMenuViewController* source = self.sourceViewController;
    SASlideMenuRootViewController* rootController = source.rootController;
    UINavigationController* destination = self.destinationViewController;

    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuicon.png"] style:UIBarButtonItemStyleBordered target:rootController action:@selector(doSlideToSide)];
    menuBarButton.tintColor = [UIColor colorWithRed:111/255.0 green:135/255.0 blue:131/255.0 alpha:1.0];
    
    UINavigationItem* navigationItem = destination.navigationBar.topItem;
    navigationItem.leftBarButtonItem = menuBarButton;
    
    Boolean hasRightMenu = NO;
    rootController.isRightMenuEnabled = NO;
    NSIndexPath* selectedIndexPath = [rootController.leftMenu.tableView indexPathForSelectedRow];

    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(hasRightMenuForIndexPath:)]) {
        hasRightMenu = [rootController.leftMenu.slideMenuDataSource hasRightMenuForIndexPath:selectedIndexPath];
    }
    if (hasRightMenu) {
        rootController.isRightMenuEnabled = YES;
        if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(configureRightMenuButton:)]) {
            UIButton* rightMenuButton = [[UIButton alloc] init];
            [rootController.leftMenu.slideMenuDataSource configureRightMenuButton:rightMenuButton];
            [rightMenuButton addTarget:rootController action:@selector(rightMenuAction) forControlEvents:UIControlEventTouchUpInside];
            
            UINavigationItem* navigationItem = destination.navigationBar.topItem;
            navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightMenuButton];
        }
    }

    if([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(configureSlideLayer:)]) {
        [rootController.leftMenu.slideMenuDataSource configureSlideLayer:[destination.view layer]];        
    }else{
        CALayer* layer = destination.view.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.3;
        layer.shadowOffset = CGSizeMake(-15, 0);
        layer.shadowRadius = 10;
        layer.masksToBounds = NO;
        layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
    }
    
    [rootController switchToContentViewController:destination];

    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(segueIdForIndexPath:)]) {
        [rootController addContentViewController:destination withIndexPath:selectedIndexPath];        
    }
    Boolean disablePanGesture= NO;
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(disablePanGestureForIndexPath:)]) {
        disablePanGesture = [rootController.leftMenu.slideMenuDataSource disablePanGestureForIndexPath:selectedIndexPath];
    }
    if (!disablePanGesture) {
        UIPanGestureRecognizer* panGesture= [[UIPanGestureRecognizer alloc] initWithTarget:rootController action:@selector(panItem:)];
        [panGesture setMaximumNumberOfTouches:2];
        [panGesture setDelegate:source];
        
        //if([[destination.viewControllers objectAtIndex:0] isKindOfClass:[UITableViewController class]]) [(UIView*)destination.navigationBar addGestureRecognizer:panGesture];
        if([[destination.viewControllers objectAtIndex:0] conformsToProtocol:@protocol(UITableViewDelegate)]) [(UIView*)destination.navigationBar addGestureRecognizer:panGesture];
        else [destination.view addGestureRecognizer:panGesture];
    }
    
}

@end
