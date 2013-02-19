//
//  SettingsViewController.m
//  Delightful
//
//  Created by Jared on 2/11/13.
//  Copyright (c) 2013 com.company. All rights reserved.
//

#import "SettingsViewController.h"
#import "MasterViewController.h"

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
	// Do any additional setup after loading the view.
    
    [self addGradient:_metricButton];
    [self addGradient:_usButton];
    _model = [Model modelSingleton];
    _buttonContainerView.backgroundColor = [_buttonContainerView.backgroundColor colorWithNoiseWithOpacity:0.1 andBlendMode:kCGBlendModeDarken];
    
    CALayer *layer = _buttonContainerView.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
}

-(void) addGradient:(UIButton *) _button {
    
    // Add Border
    CALayer *layer = _button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [layer addSublayer:shineLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)setMeasuringSystem:(id)sender {
    [self changeColorLight:sender];
    [_model setMeasuringSetting:[[[NSNumber alloc] initWithInt:[sender tag]] boolValue]];
    [self.parent reloadVisibleCells];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeColorLight:(id)sender {
    [sender setBackgroundColor:[[UIColor alloc] initWithRed:120.0f/255 green:166.0f/255 blue:143.0f/255 alpha:1.0f]];
}

- (IBAction)changeColorDark:(id)sender {
    [sender setBackgroundColor:[[UIColor alloc] initWithRed:83.0f/255 green:127.0f/255 blue:121.0f/255 alpha:1.0f]];
}
@end
