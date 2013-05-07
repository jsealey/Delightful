//
//  ParseTableViewController.h
//  Delightful
//
//  Created by Jared on 5/6/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import <Parse/Parse.h>
#import "KGNoise.h"
#import "Item.h"
#import "Model.h"
#import "UIActivityDelete.h"
#import "GCDiscreetNotificationView.h"
@interface ParseTableViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
    @property UIColor *cellBgColor;
    @property (nonatomic, retain) GCDiscreetNotificationView *totalPriceNotificationView;
    @property (nonatomic, retain) NSMutableDictionary *sections;
    @property (nonatomic, retain) NSMutableDictionary *sectionToCategoryTypeMap;
@end
