//
//  States.h
//  KOF
//
//  Created by shuichi on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface States : UILabel {

    NSTimer *timer;
}
@property (nonatomic, retain) NSTimer *timer;
- (void)updateProcessInfo;

@end
