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


@interface Stats ()
{
    uint64_t lastUserTime;
    vm_size_t lastRss;
}
@property (nonatomic, assign) NSTimer *timer;
@end


@implementation Stats

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
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                      target:self
                                                    selector:@selector(timerHandler:)
                                                    userInfo:nil
                                                     repeats:YES];
        [self.timer fire];
        lastUserTime = 0;
    }
    return self;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}


#pragma mark -------------------------------------------------------------------
#pragma Private

+ (unsigned int)getFreeMemory {
    
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }
    
    natural_t mem_free = vm_stat.free_count * pagesize;
    
    return (unsigned int)mem_free;
}


- (void)updateStates {
    
    struct task_basic_info basic_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    kern_return_t status;
    
    status = task_info(current_task(), TASK_BASIC_INFO,
                       (task_info_t)&basic_info, &t_info_count);
    
    if (status != KERN_SUCCESS)
    {
        NSLog(@"%s(): Error in task_info(): %s",
              __FUNCTION__, strerror(errno));
    }
    
    // メモリ使用量(bytes)
    vm_size_t rss = basic_info.resident_size;
    
    
    // 実行中のスレッドのCPU使用時間
    struct task_thread_times_info thread_info;
    t_info_count = TASK_THREAD_TIMES_INFO_COUNT;
    
    status = task_info(current_task(), TASK_THREAD_TIMES_INFO,
                       (task_info_t)&thread_info, &t_info_count);
    
    if (status != KERN_SUCCESS) {
        NSLog(@"%s(): Error in task_info(): %s",
              __FUNCTION__, strerror(errno));
        return;
    }
    
    uint64_t userTime   = tval2msec(thread_info.user_time);
    int64_t userTimePerSec = ((int64_t)userTime - lastUserTime) / kTimerInterval;
    
    int64_t rssPerSec = ((int64_t)rss - lastRss) / kTimerInterval;
    
    lastUserTime = userTime;
    lastRss = rss;
    
    self.text = [NSString stringWithFormat:@" MEM:%qi[kB]\n  %u[kB]\n CPU:%qi[ms]\n Views:%d",
                 rssPerSec / 1000, rss / 1000, userTimePerSec, [self countSubviewsInApp]];
}

- (int)countSubviewsInView:(UIView *)view {
    int cnt = 0;
    for (UIView *subview in [view subviews]) {
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

+ (void)printHierarchyInView:(UIView *)view level:(NSInteger)level {
    for (UIView *subview in view.subviews) {
        NSLog(@"%d:%@ %@", level, NSStringFromClass(subview.class), NSStringFromCGRect(subview.frame));
        if ([[subview subviews] count] > 0) {
            [self printHierarchyInView:subview level:level+1];
        }
    }
}




#pragma mark -------------------------------------------------------------------
#pragma mark Handler

- (void)timerHandler:(NSTimer *)timer {
    [self updateStates];
}



#pragma mark -------------------------------------------------------------------
#pragma mark Public

+ (void)printHierarchyInApp {
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *aWindow in windows) {
        for (UIView *aView in [aWindow subviews]) {
            NSLog(@"0:%@ %@", NSStringFromClass(aView.class), NSStringFromCGRect(aView.frame));
            [Stats printHierarchyInView:aView level:1];
        }
    }
}

+ (void)printHierarchyInView:(UIView *)view {
    
    [Stats printHierarchyInView:view level:0];
}

@end
