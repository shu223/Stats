//
//  StatsDemoViewController.m
//  StatsDemo
//
//  Created by shu223 on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatsDemoViewController.h"

@implementation StatsDemoViewController

@synthesize stats;


- (void)dealloc
{
    self.stats = nil;
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

    self.stats = [[[Stats alloc] initWithFrame:CGRectMake(10, 10, 100.0, 60.0)] autorelease];
    [self.view addSubview:stats];
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
