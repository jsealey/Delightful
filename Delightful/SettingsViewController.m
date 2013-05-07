//
//  SettingsViewController.m
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    _buttonContainerView.backgroundColor = [_buttonContainerView.backgroundColor colorWithNoiseWithOpacity:0.1 andBlendMode:kCGBlendModeDarken];
    CALayer *layer = _buttonContainerView.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor darkGrayColor].CGColor;
    [[AppDelegate alloc] setupNavigationTitle:self.navigationItem];
    
    _notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                            showActivity:NO
                                                      inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                  inView:self.view];
    _measurementSegmentedController.selectedSegmentIndex = [_model getMeasuringSetting];
    _taxTextField.text = [NSString stringWithFormat:@"%.2f",[[_model getTaxRate] doubleValue]];
    [_logout.layer setCornerRadius:7.0f];
    [_logout.layer setMasksToBounds:YES];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)setMeasuringSystem:(id)sender {
    [_model setMeasuringSetting:[[[NSNumber alloc] initWithInt:((UISegmentedControl *)sender).selectedSegmentIndex] boolValue]];
    [self notification:[NSString stringWithFormat:@"Updated to %@",[((UISegmentedControl *)sender) titleForSegmentAtIndex:((UISegmentedControl *)sender).selectedSegmentIndex]]];
    
}

- (IBAction)setTaxRate:(id)sender {
    if([((UITextView *)sender).text doubleValue] != [[_model getTaxRate] doubleValue]){
        [_model setTaxRate:[[NSNumber alloc] initWithDouble:[((UITextView *)sender).text doubleValue]]];
        [self notification:[NSString stringWithFormat:@"Updated tax rate: %.2f%%",[((UITextView *)sender).text doubleValue]]];
    }
}

- (IBAction)parseLogout:(id)sender {
    [PFUser logOut];
    [self checkLogin];
}

- (IBAction)dismissKeyboard:(id)sender {
    [_taxTextField resignFirstResponder];
}

- (UIView*)generateLogo {
    CGRect frame = CGRectMake(0, 0, 170, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"SnellRoundhand-BlackScript" size:28.0f];
    label.textAlignment = 1;
    label.textColor = [UIColor whiteColor];
    label.text = @"Delightful";
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    return label;
}

- (void) checkLogin {
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        logInViewController.fields = PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsSignUpButton | PFLogInFieldsTwitter | PFLogInFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFLogInFieldsFacebook;
        
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        [logInViewController.logInView setLogo:[self generateLogo]];
        [signUpViewController.signUpView setLogo:[self generateLogo]];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        
        [[[Model modelSingleton] parseTableView] loadObjects];
    } else {
        if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        _loginLabel.text = [NSString stringWithFormat:@"Logged in with Facebook."];
        else _loginLabel.text = [NSString stringWithFormat:@"username: %@", [PFUser currentUser].username];
        
    }
}
#pragma mark - Login View Controller Delegate Methods
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Signup View Controller Delegate Methods
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (void) notification:(NSString *)title{
    [self.notificationView setTextLabel:title];
    [self.notificationView show:YES];
    [self.notificationView hideAnimatedAfter:1.0f];
}
@end
