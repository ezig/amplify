//
//  AppDelegate.h
//  amplify
//
//  Created by Ezra Zigmond on 6/28/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AmplifyViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, AmplifyPopoverDelegate>

-(void) togglePopover:(id)sender;

@end

