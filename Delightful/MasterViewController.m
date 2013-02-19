//
//  MasterViewController.m
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "MasterViewController.h"
#import "Item.h"
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
    [self showEditButtonIfNotEmpty];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.isEditing = NO;
    [[AppDelegate alloc] setupTableViewBackground:self.tableView];
    [[AppDelegate alloc] setupNavigationTitle:self.navigationItem];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)showEditButtonIfNotEmpty {
    if([[_model.fetchedResultsController sections] count] > 0 && [[_model.fetchedResultsController sections][0] numberOfObjects] > 0)
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    else {
        self.navigationItem.leftBarButtonItem = nil;
        if(self.rightButtonTempHold){
            self.navigationItem.rightBarButtonItem = self.rightButtonTempHold;
            [self setEditing:NO];
        }
    }
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
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqual:@"addItem"] || (self.tableView.editing == YES && [identifier isEqual:@"detail"])) {
        return YES;
    } else return NO;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
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
    self.isEditing = self.isEditingSingleCell = YES;
    self.currentEditIndexPath = indexPath;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.isEditing = self.isEditingSingleCell =  NO;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) reloadVisibleCells {
    for (UITableViewCell *cell in [[NSMutableArray alloc] initWithArray:self.tableView.visibleCells]){
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[self.tableView indexPathForCell:cell], nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if(self.isEditingSingleCell){
        [self tableView:self.tableView didEndEditingRowAtIndexPath:self.currentEditIndexPath];
    } else {
        self.isEditing = editing;
        if(editing){
            // Put setting button on top right navigation bar
            self.rightButtonTempHold = self.navigationItem.rightBarButtonItem;
            UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertNewObject:)];
            
            // Hide the checkmark
            [self reloadVisibleCells];
            self.navigationItem.rightBarButtonItem = settingsButton;
        } else {
            // Put "+" button on top right navigation bar
            self.navigationItem.rightBarButtonItem = self.rightButtonTempHold;
            [self performSelector:@selector(reloadVisibleCells) withObject:nil afterDelay:.25];
            self.rightButtonTempHold = nil;
        }
    }
    [super setEditing:editing animated:animated];
}

- (void)insertNewObject:(id)sender{
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
    [self showEditButtonIfNotEmpty];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Item *object = [_model.fetchedResultsController objectAtIndexPath:indexPath];
    [(UILabel *)[cell viewWithTag:1] setText:object.name];
    [(UILabel *)[cell viewWithTag:2]setText:[NSString stringWithFormat:@"%@ %@",object.quantity,[Item getMeasurementName:object.measurement]]];

    // Hide checkmark when configuring cells in edit mode
    [(UILabel *)[cell viewWithTag:3] setHidden:self.isEditing];
    cell.selectionStyle = self.isEditing ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone;
    if(object.checked.boolValue == YES)[(UILabel *)[cell viewWithTag:3] setText:@"\u2705"];
    else [(UILabel *)[cell viewWithTag:3] setText:@"\u2B1C"];
    
    cell.backgroundColor = [[UIColor whiteColor] colorWithNoiseWithOpacity:0.05 andBlendMode:kCGBlendModeDarken];
}

@end
