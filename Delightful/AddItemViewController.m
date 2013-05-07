//
//  AddItemViewController.m
//  Delightful
//
//  Created by Jared on 2/1/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "AddItemViewController.h"

#import "Item.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController

dispatch_queue_t myQueue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [Model modelSingleton];
    [self setupMeasurementValues];
    _formContainerView.backgroundColor = [_formContainerView.backgroundColor colorWithNoiseWithOpacity:0.1 andBlendMode:kCGBlendModeDarken];
    
    CALayer *layer = _formContainerView.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    _notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                           showActivity:NO
                                                     inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                 inView:self.view];
    _notificationView.hidden = YES;
    
    // Set up Horizontal Picker View
	CGFloat margin = 10.0f;
	CGFloat width = (self.formContainerView.bounds.size.width - (margin * 2.0f));
	CGFloat pickerHeight = 40.0f;
	CGFloat x = margin;
	CGFloat y = 125.0f;
	CGRect tmpFrame = CGRectMake(x, y, width, pickerHeight);
    
    self.pickerView = [[V8HorizontalPickerView alloc] initWithFrame:tmpFrame];
	self.pickerView.backgroundColor   = [UIColor clearColor];
	self.pickerView.selectedTextColor = [UIColor whiteColor];
	self.pickerView.textColor   = [UIColor grayColor];
	self.pickerView.delegate    = self;
	self.pickerView.dataSource  = self;
	self.pickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.pickerView.selectionPoint = CGPointMake(60, 0);
    
	// add carat or other view to indicate selected element
	UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
	self.pickerView.selectionIndicatorView = indicator;
    
    [self.formContainerView addSubview:self.pickerView];
    self.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setupMeasurementValues {
    for(int i=0; i < 3;++i)
        [_measurement
                    setTitle:[Item getMeasurementName:[[NSNumber alloc] initWithInteger:i]]
           forSegmentAtIndex:i];
}

- (IBAction)dismiss:(id)sender {
    [self addItemPrivate:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) notification:(NSString *)title isForParent:(BOOL)isForParent{
    if(isForParent == YES){
        _notificationView.view = _parent.tableView;
    } else {
        _notificationView.view = _scrollView;
    }
    _notificationView.hidden = NO;
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0];
    myQueue = dispatch_queue_create("My Queue", NULL);
    dispatch_async(myQueue, ^{
        [NSThread sleepForTimeInterval:1.20];
        dispatch_async(dispatch_get_main_queue(), ^{
            _notificationView.hidden = YES;
        });
    });
}

- (void) addItemPrivate:(BOOL)isForParent {
    if(![_nameField.text isEqual:@""] && [_quantityField.text integerValue]){
        
        PFObject *object = [PFObject objectWithClassName:@"item"];
        [object setObject:[[NSNumber alloc] initWithInteger:self.pickerView.currentSelectedIndex] forKey:@"category"];
        [object setObject:@NO forKey:@"checked"];
        [object setObject:[[NSNumber alloc] initWithInt:[_quantityField.text integerValue]] forKey:@"quantity"];
        [object setObject:[[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex] forKey:@"measurement"];
        [object setObject:[[NSNumber alloc] initWithDouble:[_priceField.text doubleValue]] forKey:@"price"];
        [object setObject:@"" forKey:@"notes"];
        [object setObject:_nameField.text forKey:@"name"];
        [object setObject:[[PFUser currentUser] objectId] forKey:@"userObjectId"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Refresh the table when the object is done saving.
            ParseTableViewController *myTable = (ParseTableViewController *)_parent;
            [myTable loadObjects];
        }];
        
        
        [self notification:[NSString stringWithFormat:@"Added %@ %@ of %@", _quantityField.text,[Item getMeasurementName:[[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex]], _nameField.text] isForParent:isForParent];
        
        [self dismissKeyboard:nil];
        [_nameField setText:@""];
        [_quantityField setText:@""];
        [_priceField setText:@""];
        [self.pickerView scrollToElement:0 animated:YES];
    }
    //[self.parent priceNotification];
}

- (IBAction)addItem:(id)sender {
    [self addItemPrivate:NO];
}

- (void)viewWillAppear:(BOOL)animated{
	[self.pickerView scrollToElement:0 animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _scrollView.contentSize=CGSizeMake(0,600.0);
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [_nameField resignFirstResponder];
    [_quantityField resignFirstResponder];
    [_priceField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   // [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
   // [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 50; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction)incrementQuantity:(id)sender {
    _quantityField.text = [NSString stringWithFormat:@"%i",_quantityField.text.integerValue + 1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard:nil];
    return YES;
}

#pragma mark - Picker View Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return [Model categories].count;
}
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    return [[Model categories] objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
	NSString *text = [[Model categories] objectAtIndex:index];
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
					   constrainedToSize:constrainedSize
						   lineBreakMode:NSLineBreakByWordWrapping];
	return textSize.width + 40.0f; // 20px padding on each side
}

@end
