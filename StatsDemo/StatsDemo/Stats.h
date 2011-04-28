//
//  Stats.h
//
//  Created by shu223 on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Stats : UILabel {

    NSTimer *timer;
    uint64_t lastUserTime;
    vm_size_t lastRss;
}
@property (nonatomic, retain) NSTimer *timer;
- (void)printHierarchyInApp;
- (void)printHierarchyInView:(UIView *)view level:(NSInteger)level;

@end
