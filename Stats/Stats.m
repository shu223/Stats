//
//  Stats.m
//
//  Created by Shuichi Tsutsumi on 11/04/28.
//  Copyright 2011 Shuichi Tsutsumi. All rights reserved.
//

#import "Stats.h"
#import <mach/mach.h>
#import <QuartzCore/QuartzCore.h>


#define tval2msec(tval) ((tval.seconds * 1000) + (tval.microseconds / 1000))


@interface Stats ()
{
    CFTimeInterval lastTimestamp;
    uint64_t lastUserTime;
    vm_size_t lastMemSize;
}
@property (nonatomic, assign) CADisplayLink *displayLink;
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
        self.textAlignment = NSTextAlignmentLeft;
        self.numberOfLines = 0;
        lastUserTime = 0;
        lastTimestamp = CACurrentMediaTime();
        
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimer:)];
        displayLink.frameInterval = 30;
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = displayLink;
        [self onTimer:self.displayLink];
    }
    return self;
}

- (void)dealloc
{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}


#pragma mark -------------------------------------------------------------------
#pragma Private

- (void)updateStatesWithInterval:(CFTimeInterval)interval {
    NSLog(@"interval:%f", interval);
    kern_return_t status;
    mach_msg_type_number_t infoCount;
    
    struct task_basic_info basicInfo;
    infoCount = TASK_BASIC_INFO_COUNT;
    status = task_info(current_task(),
                       TASK_BASIC_INFO,
                       (task_info_t)&basicInfo,
                       &infoCount);
    if (status != KERN_SUCCESS) {
        NSLog(@"%s(): Error in task_info(): %s", __FUNCTION__, strerror(errno));
        return;
    }
    vm_size_t memSize = basicInfo.resident_size;    // Memory usage [bytes]
    int64_t memSizePerSec = (memSize - lastMemSize) / interval;   // Variation of memory usage
    lastMemSize = memSize;
    
    struct task_thread_times_info threadTimesInfo;
    infoCount = TASK_THREAD_TIMES_INFO_COUNT;
    status = task_info(current_task(),
                       TASK_THREAD_TIMES_INFO,
                       (task_info_t)&threadTimesInfo,
                       &infoCount);
    if (status != KERN_SUCCESS) {
        NSLog(@"%s(): Error in task_info(): %s", __FUNCTION__, strerror(errno));
        return;
    }
    uint64_t userTime   = tval2msec(threadTimesInfo.user_time);    // CPU time
    int64_t userTimePerSec = (userTime - lastUserTime) / interval;    // Variation of CPU time
    lastUserTime = userTime;
    
    self.text = [NSString stringWithFormat:@" MEM:%lld[kB]\n  %lu[kB]\n CPU:%lld[ms]\n Views:%lu",
                 memSizePerSec / 1000, memSize / 1000, userTimePerSec, (unsigned long)[self countSubviewsInApp]];
}

- (NSUInteger)countSubviewsInView:(UIView *)view {
    
    NSUInteger cnt = 0;
    
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

- (void)printHierarchyInView:(UIView *)view level:(NSInteger)level {
    for (UIView *subview in view.subviews) {
        
        NSLog(@"%ld:%@ %@", (long)level,
              NSStringFromClass(subview.class),
              NSStringFromCGRect(subview.frame));
        
        if ([[subview subviews] count] > 0) {
            
            [self printHierarchyInView:subview level:level+1];
        }
    }
}


#pragma mark -------------------------------------------------------------------
#pragma mark Public

- (void)printHierarchyInApp {
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    
    for (UIWindow *aWindow in windows) {
        for (UIView *aView in [aWindow subviews]) {
            
            NSLog(@"0:%@ %@",
                  NSStringFromClass(aView.class),
                  NSStringFromCGRect(aView.frame));
            
            [self printHierarchyInView:aView level:1];
        }
    }
}

- (void)printHierarchyInView:(UIView *)view {
    [self printHierarchyInView:view level:0];
}



#pragma mark -------------------------------------------------------------------
#pragma mark Timer Handler

- (void)onTimer:(CADisplayLink *)link
{
    CFTimeInterval now = link.timestamp;
    CFTimeInterval interval = now - lastTimestamp;
    [self updateStatesWithInterval:interval];
    lastTimestamp = now;
}

@end
