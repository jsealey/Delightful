//
//  AppDelegate.h
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
}

@property (strong, nonatomic) UIWindow *window;

- (void)setupNavigationTitle:(UINavigationItem *)navController;
- (void)setupTableViewBackground:(UITableView *)tableView;

@end
