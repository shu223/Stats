//
//  Stats.m
//
//  Created by shu223 on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Stats.h"
#import <mach/mach.h>

#define kTimerInterval 1.0
#define tval2msec(tval) ((tval.seconds * 1000) + (tval.microseconds / 1000))


@interface Stats (Private)
- (void)updateStates;
- (int)countSubviewsInApp;
- (void)printHierarchyInView:(UIView *)view level:(NSInteger)level;
@end


@implementation Stats

@synthesize timer;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.7;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"Courier" size:10.0f];
        self.textAlignment = UITextAlignmentLeft;
        self.numberOfLines = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
        [self.timer fire];
        lastUserTime = 0;
    }
    return self;
}

- (void)dealloc
{
    self.timer = nil;
    [super dealloc];
}


#pragma mark -------------------------------------------------------------------
#pragma mark Public

- (void)printHierarchyInApp {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *aWindow in windows) {
        for (UIView *aView in [aWindow subviews]) {
            NSLog(@"0:%@ %@", NSStringFromClass(aView.class), NSStringFromCGRect(aView.frame));
            [self printHierarchyInView:aView level:1];
        }
    }
}

- (void)printHierarchyInView:(UIView *)view {
    [self printHierarchyInView:view level:0];
}



#pragma mark -------------------------------------------------------------------
#pragma mark Handler

- (void)timerHandler:(NSTimer *)timer {
    [self updateStates];
}


#pragma mark -------------------------------------------------------------------
#pragma Private

- (void)updateStates {
    struct task_basic_info t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    
    if (task_info(current_task(), TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count)!= KERN_SUCCESS)
    {
        NSLog(@"%s(): Error in task_info(): %s",
              __FUNCTION__, strerror(errno));
    }    
    
    // メモリ使用量(bytes)
    vm_size_t rss = t_info.resident_size;
    
    
    // 実行中のスレッドのCPU使用時間
    struct task_thread_times_info tti;
    t_info_count = TASK_THREAD_TIMES_INFO_COUNT;
    kern_return_t status = task_info(current_task(), TASK_THREAD_TIMES_INFO,
                                     (task_info_t)&tti, &t_info_count);
    if (status != KERN_SUCCESS) {
        NSLog(@"%s(): Error in task_info(): %s",
              __FUNCTION__, strerror(errno));
        return;
    }
    
    uint64_t userTime   = tval2msec(tti.user_time);
    int64_t userTimePerSec = ((int64_t)userTime - lastUserTime) / kTimerInterval;
    int64_t rssPerSec = ((int64_t)rss - lastRss) / kTimerInterval;
    lastUserTime = userTime;
    lastRss = rss;
    
    self.text = [NSString stringWithFormat:@" MEM:%qi[kB]\n  %u[kB]\n CPU:%qi[ms]\n Views:%d",
                 rssPerSec / 1000, rss / 1000, userTimePerSec, [self countSubviewsInApp]];
}

- (int)countSubviewsInView:(UIView *)view {
    NSArray *subviews = [view subviews];
    int cnt = 0;
    for (UIView *subview in subviews) {
        cnt++;
        if ([[subview subviews] count] > 0) {
            cnt += [self countSubviewsInView:subview];
        }
    }
    return cnt;
}

- (int)countSubviewsInApp {
    int cnt = 0;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *aWindow in windows) {
        for (UIView *aView in [aWindow subviews]) {
            cnt++;
            cnt += [self countSubviewsInView:aView];
        }
    }
    
    return cnt;
}

- (void)printHierarchyInView:(UIView *)view level:(NSInteger)level {
    for (UIView *subview in view.subviews) {
        NSLog(@"%d:%@ %@", level, NSStringFromClass(view.class), NSStringFromCGRect(view.frame));
        if ([[subview subviews] count] > 0) {
            [self printHierarchyInView:subview level:level+1];
        }
    }
}

@end
