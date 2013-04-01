//
//  MasterViewController.m
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "MasterViewController.h"
#import "Item.h"
#import "AddItemViewController.h"
#import "EditItemViewController.h"
#import "SettingsViewController.h"
#import "Model.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _model = [Model modelSingleton];
    _model.fetchedResultsController = self.fetchedResultsController;
    NSLog(@"viewDidLoad");
    self.isEditingSingleCell = self.isEditing = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    [[AppDelegate alloc] setupTableViewBackground:self.tableView];
    [[AppDelegate alloc] setupNavigationTitle:self.navigationItem];
    [self priceNotification];
    // This is some example code for saving objects with Parse
    //    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    //    [testObject setObject:@"bar" forKey:@"foo"];
    //    [testObject save];
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    NSLog(@"%d  %d", self.isEditing, self.isEditingSingleCell);
    [self showEditButtonIfNotEmpty];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)showEditButtonIfNotEmpty {
    if([[_model.fetchedResultsController sections] count] > 0
       && [[_model.fetchedResultsController sections][0] numberOfObjects] > 0){
        if(self.isEditingSingleCell){
            self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:nil];
        } else if(self.isEditing){
            
            // Put setting button on top right navigation bar
            self.rightButtonTempHold = self.navigationItem.rightBarButtonItems;
            UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(changeSettings:)];
            
            // Hide the checkmark
            [self reloadVisibleCells];
            UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"todo.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(turnOffEditMode)];
            self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:settingsButton, editButton, nil];
            
        }else{
            UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pencil.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(setEditing:animated:)];
            
            NSArray *myButtonArray = [[NSArray alloc] initWithObjects:
                                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)],
                                      editButton,
                                      nil];
            self.navigationItem.rightBarButtonItems = myButtonArray;
        }
    } else {
        [self setEditing:NO];
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:
                                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)], nil];
    }
}

- (void) turnOffEditMode {
    self.isEditing = self.isEditingSingleCell = NO;
    [self setEditing:NO animated:YES];
    [self priceNotification];
    [self showEditButtonIfNotEmpty];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"addItem"]) {
        // Do nothing. (The model takes care of any data passing that would have happened here)
    } else if([[segue identifier] isEqualToString:@"detail"]){
        [[segue destinationViewController] setSelectedIndexPath:[self.tableView indexPathForSelectedRow]];
        [[segue destinationViewController] setTitle:@"Edit"];
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
    }
    [[segue destinationViewController] setParent:self];
}                                                                                                                                                                            
                                                                                                                                                                            
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqual:@"addItem"] || (self.tableView.editing == YES && [identifier isEqual:@"detail"])) {
        return YES;
    } else return NO;
}

- (void) priceNotification{
    _totalPriceNotificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                         showActivity:NO
                                   inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom
                                    inView:self.navigationController.view];
    double total=0;
    for(int i=0; i < _model.fetchedResultsController.fetchedObjects.count;++i){
        Item *object = [_model.fetchedResultsController.fetchedObjects objectAtIndex:i];
        total += object.quantity.integerValue * object.price.doubleValue;
    }
    [self.totalPriceNotificationView setTextLabel:[NSString stringWithFormat:@"Total: $%.2f", total]];
    [self.totalPriceNotificationView show:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[_model.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [_model.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_model.managedObjectContext deleteObject:[_model.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error = nil;
        if (![_model.managedObjectContext save:&error]) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing == YES) {
        // Don't toggle checked status during editing
    } else {
        Item *object = [_model.fetchedResultsController objectAtIndexPath:indexPath];
        object.checked = object.checked.boolValue ? [[NSNumber alloc] initWithBool:NO] : [[NSNumber alloc] initWithBool:YES];
        NSError *error = nil;
        if (![_model.managedObjectContext save:&error]) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}
#pragma mark - Table View Editing

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willBeginEditingRowAtIndexPath");
    self.isEditing = self.isEditingSingleCell = YES;
    self.currentEditIndexPath = indexPath;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [_totalPriceNotificationView hide:YES];
    [self showEditButtonIfNotEmpty];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didEndEditingRowAtIndexPath");
    self.isEditing = self.isEditingSingleCell =  NO;
    self.currentEditIndexPath = nil;
    [self reloadVisibleCells];
    [self showEditButtonIfNotEmpty];
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [self priceNotification];
}

- (void) reloadVisibleCells {
    for (UITableViewCell *cell in [[NSMutableArray alloc] initWithArray:self.tableView.visibleCells]){
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[self.tableView indexPathForCell:cell], nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    NSLog(@"Editing %d %d %d", self.isEditingSingleCell, self.isEditing, editing);
    if(self.isEditingSingleCell){
        [self tableView:self.tableView didEndEditingRowAtIndexPath:self.currentEditIndexPath];
    } else {
        self.isEditing = editing;
        if(editing){
            [_totalPriceNotificationView hide:YES];
            // Put setting button on top right navigation bar
            self.rightButtonTempHold = self.navigationItem.rightBarButtonItems;
            UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(changeSettings:)];
            
            // Hide the checkmark
            [self reloadVisibleCells];
            UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"todo.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(turnOffEditMode)];
            self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:settingsButton, editButton, nil];
        } else {
            // Put "+" button on top right navigation bar
            self.navigationItem.rightBarButtonItems = self.rightButtonTempHold;
            [self performSelector:@selector(reloadVisibleCells) withObject:nil afterDelay:.25];
            self.rightButtonTempHold = nil;
        }
    }
    [super setEditing:editing animated:animated];
}

- (void)insertNewObject:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AddItemViewController *addItemController = (AddItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"addItem"];
    [addItemController setParent:self];
    [self.navigationController presentViewController:addItemController animated:YES completion:nil];
}

- (void)changeSettings:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SettingsViewController *settingsViewController = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"settings"];
    [settingsViewController setParent:self];
    [self.navigationController presentViewController:settingsViewController animated:YES completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController{
    if (_model.fetchedResultsController != nil) {
        return _model.fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:_model.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_model.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    _model.fetchedResultsController = aFetchedResultsController;
	NSError *error = nil;
	if (![_model.fetchedResultsController performFetch:&error]) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    return _model.fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
//NSLog(@"isEditing:%i isEditingSingleCell:%i  row:%i currentIndexPathEqual:%i", self.isEditing ,self.isEditingSingleCell, indexPath.row, [self.currentEditIndexPath isEqual:indexPath]);
    Item *object = [_model.fetchedResultsController objectAtIndexPath:indexPath];
    [(UILabel *)[cell viewWithTag:1] setText:object.name];
    NSString *subtext =[NSString stringWithFormat:@"%@ %@",object.quantity,[Item getMeasurementName:object.measurement]];
    if(object.price.integerValue)
        subtext = [NSString stringWithFormat:@"%@ - $%.2f",subtext,object.price.doubleValue * object.quantity.integerValue];
    [(UILabel *)[cell viewWithTag:2]setText:subtext];
        

    // Hide checkmark when configuring cells in edit mode
    if(self.isEditingSingleCell){
        [(UILabel *)[cell viewWithTag:3] setHidden:[self.currentEditIndexPath isEqual:indexPath]];
    } else [(UILabel *)[cell viewWithTag:3] setHidden:self.isEditing];

    cell.selectionStyle = self.isEditing ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone;
    if(object.checked.boolValue == YES)[(UILabel *)[cell viewWithTag:3] setText:@"\u2705"];
    else [(UILabel *)[cell viewWithTag:3] setText:@"\u2B1C"];
    
    cell.backgroundColor = [[UIColor whiteColor] colorWithNoiseWithOpacity:0.05 andBlendMode:kCGBlendModeDarken];
}

@end
