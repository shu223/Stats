//
//  StatsDemoViewController.h
//  StatsDemo
//
//  Created by shuichi on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "States.h"

@interface StatsDemoViewController : UIViewController {
    States *processInfoLabel;   
}
@property (nonatomic, retain) States *processInfoLabel;
- (IBAction)pressBtn:(UIButton *)sender;

@end
