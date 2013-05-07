//
//  AppDelegate.m
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "AppDelegate.h"
#import "Model.h"
#import "ParseTableViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Test Parse Credentials
    [Parse setApplicationId:@"Y2Hf7AOgPtxE9PtX8Mc52gjoR9aDt1ErJdiZhcVM" clientKey:@"NpxMaC9Zdz3GGtZPkKLDUpZEZPODtz7eaxdqKOwL"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)setupNavigationTitle:(UINavigationItem *)navController {
    CGRect frame = CGRectMake(0, 0, 40, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"SnellRoundhand-BlackScript" size:23.0f];
    label.textAlignment = 1;
    label.textColor = [UIColor whiteColor];
    label.text = @" Delightful ";
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    navController.titleView = label;
}

- (void)setupTableViewBackground:(UITableView *)tableView{
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retina_wood.png"]];
    [tempImageView setFrame:tableView.frame];
    tableView.backgroundView = tempImageView;
}
@end
