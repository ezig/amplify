//
//  PreferencesViewController.h
//  amplify
//
//  Created by Ezra Zigmond on 7/19/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PreferencesDelegate <NSObject>

@property (nonatomic, assign) BOOL launchOnLogin;

@end

@interface PreferencesViewController : NSViewController

@property (nonatomic, strong) id<PreferencesDelegate> delegate;

@end
