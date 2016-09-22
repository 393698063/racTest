//
//  PlayerViewModle.m
//  racTestTwo
//
//  Created by HEcom on 16/9/20.
//  Copyright © 2016年 Jorgon. All rights reserved.
//

#import "PlayerViewModle.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface PlayerViewModle ()
@property(nonatomic, retain) NSArray *forbiddenNames;
@property(nonatomic, readwrite) NSUInteger maxPointUpdates;
@end

@implementation PlayerViewModle

- (instancetype)init
{
  if (self = [super init]) {
    _playerName = @"Coin";
    _points = 100.0;
    _stepAmount = 1000.0;
    _maxPoints = 0.0;
    _maxPointUpdates = 10;
    _forbiddenNames = @[@"dag nabbit",@"darn",@"poop"];
  }
  return self;
}
- (IBAction)resetToDefaults:(id)sender
{
  _playerName = @"Coin";
  _points = 100.0;
  _stepAmount = 1000.0;
  _maxPoints = 0.0;
  _maxPointUpdates = 10;
  _forbiddenNames = @[@"dag nabbit",@"darn",@"poop"];
}
- (void)uploadData:(id)sender
{
  @weakify(self);
  [[RACScheduler scheduler] schedule:^{
    [[RACScheduler mainThreadScheduler] schedule:^{
      @strongify(self);
      NSString *msg = [NSString stringWithFormat:@"Updated %@ with %.0f points",self.playerName,self.points];
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Upload Successfull"
    message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    }];
  }];
}
- (RACSignal *)forbiddenNameSignal
{
  @weakify(self);
  return [RACObserve(self,playerName) filter:^BOOL(NSString *newName) {
    @strongify(self);
    return [self.forbiddenNames containsObject:newName];
  }];
}
- (RACSignal *)modelIsValidSignal
{
  @weakify(self);
  return [RACSignal
          combineLatest:@[ RACObserve(self,playerName), RACObserve(self,points) ]
          reduce:^id(NSString *name, NSNumber *playerPoints){
            @strongify(self);
            return @((name.length > 0) &&
            (![self.forbiddenNames containsObject:name]) &&
            (playerPoints.doubleValue >= self.minPoints));
          }];
}

@end
