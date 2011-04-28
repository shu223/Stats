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

@interface StatsDemoAppDelegate : NSObject <UIApplicationDelegate> {
    Stats *stats;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet StatsDemoViewController *viewController;

@property (nonatomic, retain) Stats *stats;

@end
