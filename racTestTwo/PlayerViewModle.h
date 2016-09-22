//
//  PlayerViewModle.h
//  racTestTwo
//
//  Created by HEcom on 16/9/20.
//  Copyright © 2016年 Jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PlayerViewModle : NSObject
@property(nonatomic, copy) NSString *playerName;

@property(nonatomic, assign) double points;
@property(nonatomic, assign) double stepAmount;
@property(nonatomic, assign) double maxPoints;
@property(nonatomic, assign) double minPoints;

@property(nonatomic, readonly) NSUInteger maxPointUpdates;

-(IBAction)resetToDefaults:(id)sender;

-(IBAction)uploadData:(id)sender;

-(RACSignal *)forbiddenNameSignal;

-(RACSignal *)modelIsValidSignal;
@end
