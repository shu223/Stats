//
//  StatsDemoAppDelegate.h
//  StatsDemo
//
//  Created by shu223 on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stats.h"

@class StatsDemoViewController;

@interface StatsDemoAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) StatsDemoViewController *viewController;
@property (nonatomic, strong) Stats *stats;

@end
