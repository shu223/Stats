//
//  StatsDemoViewController.m
//  StatsDemo
//
//  Created by shuichi on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatsDemoViewController.h"

@implementation StatsDemoViewController

@synthesize processInfoLabel;


- (void)dealloc
{
    self.processInfoLabel = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.processInfoLabel = [[[States alloc] initWithFrame:CGRectMake(10, 10, 100.0, 60.0)] autorelease];
    [self.view addSubview:processInfoLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark -------------------------------------------------------------------
#pragma mark IBAction

- (IBAction)pressBtn:(UIButton *)sender {
    if (!sender.selected) {
        UIImage *image = [UIImage imageNamed:@"shu223_icon.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.center = self.view.center;
        [self.view addSubview:imageView];
        [imageView release];
    }
    else {
        for (UIView *aView in self.view.subviews) {
            if ([aView isKindOfClass:[UIImageView class]]) {
                [aView removeFromSuperview];
            }
        }
    }
    sender.selected = !sender.selected;
}


@end
