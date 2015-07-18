//
//  AmplifyViewController.h
//  amplify
//
//  Created by Ezra Zigmond on 6/29/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol AmplifyPopoverDelegate <NSObject>

@property (nonatomic, assign) BOOL launchOnLogin;

- (void)togglePopover:(id)sender;

@end

@interface AmplifyViewController : NSViewController

@property (nonatomic, strong) id<AmplifyPopoverDelegate> delegate;
@property (nonatomic, assign) BOOL isVisible;

@end
