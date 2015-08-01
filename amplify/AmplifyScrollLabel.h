//
//  AmplifyScrollLabel.h
//  amplify
//
//  Created by Ezra Zigmond on 7/5/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum scroll_mode {
    ScrollModeContinuous, // scrolls continuously, stops on mouse over
    ScrollModeOnHover // on mouse over, the label will scroll once
} ScrollMode;

@interface AmplifyScrollLabel : NSView

@property (nonatomic, strong) NSString * text;
@property (nonatomic, assign) NSTimeInterval speed; // smaller is faster
@property (nonatomic, assign) ScrollMode mode;

- (void)resetPosition;

@end
