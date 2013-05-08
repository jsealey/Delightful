//
//  ParseTableViewController.h
//  Delightful
//
//  Created by Jared on 5/6/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "ParseTableViewController.h"
#import "AddItemViewController.h"
#import "EditItemViewController.h"


@implementation ParseTableViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = @"item";
        self.textKey = @"text";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToCategoryTypeMap = [NSMutableDictionary dictionary];
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
    }
    
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        
        // Call refreshControlValueChanged: when the user pulls the table view down.
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    [[Model modelSingleton] setParseTableView:self];
    _cellBgColor = [[UIColor whiteColor] colorWithNoiseWithOpacity:0.05 andBlendMode:kCGBlendModeDarken];
    
    [[AppDelegate alloc] setupTableViewBackground:self.tableView];
    [[AppDelegate alloc] setupNavigationTitle:self.navigationItem];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(Share:)];
    shareButton.tintColor = [UIColor colorWithRed:111/255.0 green:135/255.0 blue:131/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:self.navigationItem.leftBarButtonItem, shareButton, nil];
    [self setEditing:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
    
    [self.sections removeAllObjects];
    [self.sectionToCategoryTypeMap removeAllObjects];
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    for (PFObject *object in self.objects) {
        NSString *categoryType = [[Model categories] objectAtIndex:[[object objectForKey:@"category"] integerValue]];
        NSMutableArray *objectsInSection = [self.sections objectForKey:categoryType];
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            // this is the first time we see this sportType - increment the section index
            [self.sectionToCategoryTypeMap setObject:categoryType forKey:[NSNumber numberWithInt:section++]];
        }
        
        [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
        [self.sections setObject:objectsInSection forKey:categoryType];
    }
    [self.tableView reloadData];
    [self priceNotification];
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    // The user just pulled down the table view. Start loading data.
    [self loadObjects];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if([PFUser currentUser])
        [query whereKey:@"userObjectId" equalTo:[[PFUser currentUser] objectId]];
    else [query whereKey:@"userObjectId" equalTo:@-1];
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByAscending:@"category"];
    return query;
}

- (NSString *)categoryTypeForSection:(NSInteger)section {
    return [self.sectionToCategoryTypeMap objectForKey:[NSNumber numberWithInt:section]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *categoryType = [self categoryTypeForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:categoryType];
    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *categoryType = [self categoryTypeForSection:section];
    return categoryType;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [(UILabel *)[cell viewWithTag:1] setText:[object objectForKey:@"name"]];
    NSString *subtext =[NSString stringWithFormat:@"%@ %@",[object objectForKey:@"quantity"],[Item getMeasurementName:[object objectForKey:@"measurement"]]];
    if([object objectForKey:@"price"])
        subtext = [NSString stringWithFormat:@"%@ - $%.2f",
                   subtext,
                   [[object objectForKey:@"price"] doubleValue] *
                   [[object objectForKey:@"quantity"] integerValue] *
                   (([[[Model modelSingleton] getTaxRate] doubleValue]/100)+1)
                   ];
    [(UILabel *)[cell viewWithTag:2]setText:subtext];
    [(UILabel *)[cell viewWithTag:3] setHidden:self.isEditing];
    cell.selectionStyle = self.isEditing ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone;
    if([[object objectForKey:@"checked"] boolValue] == YES)[(UILabel *)[cell viewWithTag:3] setText:@"\u2705"];
    else [(UILabel *)[cell viewWithTag:3] setText:@"\u2B1C"];
    cell.backgroundColor = _cellBgColor;
    
    return cell;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *categoryType = [self categoryTypeForSection:indexPath.section];
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:categoryType];
    
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    return [self.objects objectAtIndex:[rowIndex intValue]];
}

 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         PFObject *object = [self objectAtIndexPath:indexPath];
         [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             [self loadObjects];
         }];
     }
 }

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}
 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.isEditing){
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        PFObject *object = [self objectAtIndexPath:indexPath];
        
         UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        if([[object objectForKey:@"checked"] boolValue] == NO)
            [(UILabel *)[cell viewWithTag:3] setText:@"\u2705"];
        else [(UILabel *)[cell viewWithTag:3] setText:@"\u2B1C"];
        
        [object setObject:@([[[NSNumber alloc] initWithBool:[[object objectForKey:@"checked"] boolValue]==NO] boolValue]) forKey:@"checked"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            ParseTableViewController *myTable = (ParseTableViewController *)self;
            [myTable loadObjects];
        }];
    }
}

#pragma mark - Other Methods

- (void) toggleEditMode{
    [self setEditing:!self.isEditing];
    [self setEditing:!self.isEditing animated:YES];
    NSArray *objects = [self.tableView visibleCells];
    for(int i=0; i < objects.count;++i)
        [[[objects objectAtIndex:i] viewWithTag:3] setHidden:self.isEditing];
    if(self.isEditing) [_totalPriceNotificationView hide:YES];
    else [self priceNotification];
}

- (void) setEditing:(BOOL)isEditing {
    if(isEditing){
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteActionSheet:)];
        deleteButton.tintColor = [UIColor colorWithRed:0.83 green:0.00 blue:0.00 alpha:0.5];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEditMode)];
        editButton.tintColor = [UIColor colorWithRed:111/255.0 green:135/255.0 blue:131/255.0 alpha:1.0];
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:deleteButton, editButton, nil];
    }else{
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pencil.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEditMode)]; // turn on
        editButton.tintColor = [UIColor colorWithRed:111/255.0 green:135/255.0 blue:131/255.0 alpha:1.0];
        
        UIBarButtonItem *addButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        addButton.tintColor = [UIColor colorWithRed:111/255.0 green:135/255.0 blue:131/255.0 alpha:1.0];
        NSArray *myButtonArray = [[NSArray alloc] initWithObjects:addButton, editButton, nil];
        self.navigationItem.rightBarButtonItems = myButtonArray;
    }
}



- (IBAction)Share:(UIBarButtonItem *)sender {
    NSString *textToShare = @"Shopping List By Delightful\n\n";
    double total = 0;
    for(int i=0; i < self.objects.count;++i){
        PFObject *object = [self.objects objectAtIndex:i];
        total += [[object objectForKey:@"quantity"] integerValue] * [[object objectForKey:@"price"] doubleValue];
        textToShare = [NSString stringWithFormat:@"%@%d %@ of %@ at $%.2f\n",
                       textToShare,
                       [[object objectForKey:@"quantity"] integerValue],
                       [Item getMeasurementName:[[NSNumber alloc] initWithInt:[[object objectForKey:@"measurement"] integerValue]]],
                       [object objectForKey:@"name"],
                       [[object objectForKey:@"price"] doubleValue]
                       ];
    }
    textToShare = [NSString stringWithFormat:@"%@\n\nTax Rate: %.2f%%\n\nTotal Tax: $%.2f\nTotal:     $%.2f", textToShare, [[[Model modelSingleton] getTaxRate] doubleValue],total*([[[Model modelSingleton] getTaxRate] doubleValue]/100),total*(([[[Model modelSingleton] getTaxRate] doubleValue]/100)+1)];
    
    UISimpleTextPrintFormatter *printData = [[UISimpleTextPrintFormatter alloc]
                                             initWithText:textToShare];
    NSArray *itemsToShare = [[NSArray alloc] initWithObjects:textToShare,printData, nil];
    UIActivityViewController* activities = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activities.excludedActivityTypes = [[NSArray alloc] initWithObjects:UIActivityTypeSaveToCameraRoll,  UIActivityTypePostToWeibo, nil];
    
    [self presentViewController:activities animated:YES completion:nil];
}

- (void)deleteActionSheet:(id)sender{
    UIActivityDelete *deleteActivityItem = [[UIActivityDelete alloc] init];
    UIActivityViewController *deleteActivityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Clear All"] applicationActivities:@[deleteActivityItem]];
    
    [deleteActivityViewController setExcludedActivityTypes:@[UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    
    deleteActivityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (completed) {
            for (PFObject *object in self.objects)
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self loadObjects];
                }];
        }
    };
    [self presentViewController:deleteActivityViewController animated:YES completion:nil];
}

- (void)insertNewObject:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AddItemViewController *addItemController = (AddItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"addItem"];
    [addItemController setParent:self];
    [self.navigationController presentViewController:addItemController animated:YES completion:nil];
}

- (void) priceNotification{
    if (!_totalPriceNotificationView) {
        _totalPriceNotificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                          showActivity:NO
                                                                    inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom
                                                                                inView:self.navigationController.view];
    }
    double total=0;
    for(int i=0; i < self.objects.count;++i){
        PFObject *object = [self.objects objectAtIndex:i];
        total += [[object objectForKey:@"quantity"] integerValue] * [[object objectForKey:@"price"] doubleValue];
    }
    [self.totalPriceNotificationView setTextLabel:[NSString stringWithFormat:@"Total - $%.2f",total * (([[[Model modelSingleton] getTaxRate] doubleValue]/100) + 1)]];
    [self.totalPriceNotificationView show:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"detail"]){
        [[segue destinationViewController] setObject:[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]]];
        [[segue destinationViewController] setParent:self];
        [[segue destinationViewController] setTitle:@"Edit"];
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqual:@"addItem"] || (self.tableView.editing == YES && [identifier isEqual:@"detail"])) {
        return YES;
    } else return NO;
}



@end
