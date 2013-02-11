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

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showEditButtonIfNotEmpty];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.isEditing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.fetchedResultsController = nil;
}

- (void)showEditButtonIfNotEmpty {
    if([[self.fetchedResultsController sections] count] > 0 && [[self.fetchedResultsController sections][0] numberOfObjects] > 0)
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    else
        self.navigationItem.leftBarButtonItem = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addItem"]) {
        [[segue destinationViewController] setFetchedResultsController:self.fetchedResultsController];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else if([[segue identifier] isEqualToString:@"detail"]){
        [[segue destinationViewController] setFetchedResultsController:self.fetchedResultsController];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setSelectedIndexPath:[self.tableView indexPathForSelectedRow]];
        [[segue destinationViewController] setTitle:@"Edit"];
        // TODO: Set back button text to "back"
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqual:@"addItem"] || (self.tableView.editing == YES && [identifier isEqual:@"detail"])) {
        return YES;
    } else return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing == YES) {
        // Don't toggle checked status during editing
    } else {
        Item *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        object.checked = object.checked.boolValue ? [[NSNumber alloc] initWithBool:NO] : [[NSNumber alloc] initWithBool:YES];
        NSError *error = nil;
        if (![[self.fetchedResultsController managedObjectContext] save:&error]) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.isEditing = editing;
    if(editing){
        // Put setting button on top right navigation bar
        self.rightButtonTempHold = self.navigationItem.rightBarButtonItem;
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(insertNewObject:)];
        [self reloadVisibleCells];
        self.navigationItem.rightBarButtonItem = settingsButton;
        [super setEditing:editing animated:animated];
    } else {
        // Put "+" button on top right navigation bar
        self.navigationItem.rightBarButtonItem = self.rightButtonTempHold;
        [self performSelector:@selector(reloadVisibleCells) withObject:nil afterDelay:.25];
        [super setEditing:editing animated:animated];
    }
}

- (void) reloadVisibleCells {
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[self.tableView indexPathForCell:cell], nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)insertNewObject:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SettingsViewController *settingsViewController = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"settings"];
    [self.navigationController presentViewController:settingsViewController animated:YES completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
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
      newIndexPath:(NSIndexPath *)newIndexPath
{
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self showEditButtonIfNotEmpty];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [(UILabel *)[cell viewWithTag:1] setText:object.name];
    [(UILabel *)[cell viewWithTag:2]setText:[NSString stringWithFormat:@"%@ %@",object.quantity,[Item getMeasurementName:object.measurement]]];

    // Hide checkmark when configuring cells in edit mode
    [(UILabel *)[cell viewWithTag:3] setHidden:self.isEditing];
    if(object.checked.boolValue == YES)[(UILabel *)[cell viewWithTag:3] setText:@"\u2705"];
    else [(UILabel *)[cell viewWithTag:3] setText:@"\u2B1C"];
}

@end
