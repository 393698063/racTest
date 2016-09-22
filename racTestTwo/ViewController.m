//
//  ViewController.m
//  racTestTwo
//
//  Created by HEcom on 16/9/20.
//  Copyright © 2016年 Jorgon. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PlayerViewModle.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *iPlayerName;
@property (weak, nonatomic) IBOutlet UIStepper *iStepper;
@property (nonatomic, strong) PlayerViewModle *iViewModel;
@property (weak, nonatomic) IBOutlet UIButton *iUploadButton;
@property (weak, nonatomic) IBOutlet UILabel *iScoreField;
@property (weak, nonatomic) IBOutlet UILabel *iStepperValue;

@property (nonatomic, assign) NSUInteger scoreUpdates;
@end

static NSInteger const kMaxUploads = 5;
@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.iViewModel = [[PlayerViewModle alloc] init];
  @weakify(self);
  //Start binding our properties
  RAC(self.iPlayerName,text) = [RACObserve(self.iViewModel, playerName)distinctUntilChanged];
  [[self.iPlayerName.rac_textSignal distinctUntilChanged] subscribeNext:^(id x) {
    //this creates a reference to self that when used with @weakify(self);
    //makes sure self isn't retained
    @strongify(self);
    self.iViewModel.playerName = x;
  }];
  
  //the score property is a double, RC gives us updates as NSNumber which we just call
  //stringValue on and bind that to the scorefield text
  RAC(self.iScoreField,text) = [RACObserve(self.iViewModel,points) map:^id(NSNumber *value) {
    return [value stringValue];
  }];
  
  //Setup bind the steppers values
  self.iViewModel.points = self.iStepper.value;
  RAC(self.iStepper,stepValue) = RACObserve(self.iViewModel,stepAmount);
  RAC(self.iStepper,maximumValue) = RACObserve(self.iViewModel,maxPoints);
  RAC(self.iStepper,minimumValue) = RACObserve(self.iViewModel,minPoints);
  
  //bind the hidden field to a signal keeping track if
  //we've updated less than a certain number times as the view model specifies
  RAC(self.iStepper,hidden) = [RACObserve(self,scoreUpdates) map:^id(NSNumber *x) {
    @strongify(self);
    return @(x.intValue >= self.iViewModel.maxPointUpdates);
  }];

  //this signal should only trigger if we have "bad words" in our name
    [self.iViewModel.forbiddenNameSignal subscribeNext:^(NSString *name) {
      @strongify(self);
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forbidden Name!"
                                                      message:[NSString stringWithFormat:@"The name %@ has been forbidden!",name]
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
      [alert show];
      self.iViewModel.playerName = @"";
    }];
  
  //let the upload(save) button only be enabled when the view model says its valid
  RAC(self.iUploadButton,enabled) = self.iViewModel.modelIsValidSignal;
  
  //set the control action for our button to be the ViewModels action method
  [self.iUploadButton addTarget:self.iViewModel
                        action:@selector(uploadData:)
              forControlEvents:UIControlEventTouchUpInside];
  
  //we can subscribe to the same thing in multiple locations
  //here we skip the first 4 signals and take only 1 update
  //and then disable/hide certain UI elements as our app
  //only allows 5 updates
  [[[[self.iUploadButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     skip:(kMaxUploads - 1)] take:1] subscribeNext:^(id x) {
    @strongify(self);
    self.iPlayerName.enabled = NO;
    self.iStepper.hidden = YES;
    self.iUploadButton.hidden = YES;
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
