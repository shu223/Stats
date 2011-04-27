//
//  Stats.m
//
//  Created by shu223 on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Stats.h"
#import <mach/mach.h>

#define kTimerInterval 1.0

@implementation Stats

@synthesize timer;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.7;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:10.0f];
        self.textAlignment = UITextAlignmentCenter;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
        [self.timer fire];
    }
    return self;
}

- (void)dealloc
{
    self.timer = nil;
    [super dealloc];
}

- (void)updateProcessInfo {
    struct task_basic_info t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    
    if (task_info(current_task(), TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count)!= KERN_SUCCESS)
    {
        NSLog(@"%s(): Error in task_info(): %s",
              __FUNCTION__, strerror(errno));
    }
    
    // 物理メモリの使用量(byte) - Activity MonitorのReal Memoryに該当
    u_int rss = t_info.resident_size;
    
    self.text = [NSString stringWithFormat:@"%u", rss];
}

- (void)timerHandler:(NSTimer *)timer {
    [self updateProcessInfo];
}

@end
