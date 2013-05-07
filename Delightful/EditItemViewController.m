//
//  EditItemViewController.m
//  Delightful
//
//  Created by Jared on 2/10/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "EditItemViewController.h"

#import "Item.h"

@interface EditItemViewController ()

@end

@implementation EditItemViewController
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
    _nameField.text = [_object objectForKey:@"name"];
    _quantityField.text = [NSString stringWithFormat:@"%i",[[_object objectForKey:@"quantity"] integerValue]];
    _measurement.selectedSegmentIndex = [[_object objectForKey:@"measurement"] integerValue];
    [self setupMeasurementValues];
    _priceField.text = [[NSString alloc] initWithFormat:@"%.2f", [[_object objectForKey:@"price"] doubleValue]];
    
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
    self.selectedIndex = [[_object objectForKey:@"category"] integerValue];
    [self.pickerView scrollToElement:self.selectedIndex animated:YES];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setupMeasurementValues {
    for(int i=0; i < 3;++i)
        [_measurement
         setTitle:[Item getMeasurementName:[[NSNumber alloc] initWithInteger:i] ]
         forSegmentAtIndex:i];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField{}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateItem];
}

- (void) notification:(NSString *)title{
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0f];
}

- (void)updateItem {
    // This is just saying to only update when something was changed
    if(  ![_nameField.text isEqual:@""]
       && [_quantityField.text integerValue]
       // If at least one field has been changed...
       && (  ![_nameField.text isEqualToString:[_object objectForKey:@"name"]]
           || [_quantityField.text integerValue]!=[[_object objectForKey:@"quantity"] integerValue]
           || _measurement.selectedSegmentIndex!=[[_object objectForKey:@"measurement"] integerValue]
           || _priceField.text.doubleValue!=[[_object objectForKey:@"price"] doubleValue]
           || _pickerView.currentSelectedIndex!=[[_object objectForKey:@"category"] integerValue])
       ){
        BOOL updatingCategory = _pickerView.currentSelectedIndex!=[[_object objectForKey:@"category"] integerValue];
        [_object setObject:_nameField.text forKey:@"name"];
        [_object setObject:[[NSNumber alloc] initWithInt:[_quantityField.text integerValue]] forKey:@"quantity"];
        [_object setObject:[[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex] forKey:@"measurement"];
        [_object setObject:[[NSNumber alloc] initWithDouble:[_priceField.text doubleValue]] forKey:@"price"];
        [_object setObject:[[NSNumber alloc] initWithInteger:_pickerView.currentSelectedIndex] forKey:@"category"];
        [_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Refresh the table when the object is done saving.
            ParseTableViewController *myTable = (ParseTableViewController *)_parent;
            [myTable loadObjects];
        }];
        
        if(updatingCategory)
            [self notification:[NSString stringWithFormat:@"Updated Category to %@",[[Model categories] objectAtIndex:[[_object objectForKey:@"category"] integerValue]]]];
        else
            [self notification:[NSString stringWithFormat:@"%d %@ of %@ at $%.2f",
                                    [[_object objectForKey:@"quantity"] integerValue],
                                    [Item getMeasurementName:[[NSNumber alloc] initWithInt:_measurement.selectedSegmentIndex]],
                                    [_object objectForKey:@"name"],
                                    [[_object objectForKey:@"price"] doubleValue]
                                ]
             ];
    }
}

- (IBAction)incrementQuantity:(id)sender {
    _quantityField.text = [NSString stringWithFormat:@"%i",_quantityField.text.integerValue + 1];
    [self updateItem];
}

- (IBAction)updateMeasurement:(id)sender {
    [self updateItem];
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

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    if(index!=[[_object objectForKey:@"category"] integerValue])
        [self updateItem];
}



@end
