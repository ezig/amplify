//
//  PreferencesViewController.m
//  amplify
//
//  Created by Ezra Zigmond on 7/19/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "PreferencesViewController.h"
#include <ShortcutRecorder/ShortcutRecorder.h>

@interface PreferencesViewController ()

@property (weak) IBOutlet SRRecorderControl *playShorcut;
@property (weak) IBOutlet SRRecorderControl *shuffleShortcut;
@property (weak) IBOutlet SRRecorderControl *nextShorcut;
@property (weak) IBOutlet SRRecorderControl *previousShortcut;
@property (weak) IBOutlet SRRecorderControl *volumeUpShortcut;
@property (weak) IBOutlet SRRecorderControl *volumeDownShortcut;

@property (weak) IBOutlet SRRecorderControl *globalShortcut;

@property (weak) IBOutlet NSButton *enableLaunchOnLogin;
@property (weak) IBOutlet NSButton *enableNotifications;


@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear {
        if (self.delegate.launchOnLogin) {
            self.enableLaunchOnLogin.state = NSOnState;
        } else {
            self.enableLaunchOnLogin.state = NSOffState;
        }
}

- (IBAction)didChangeLaunchOnLogin:(id)sender {
    if (self.enableLaunchOnLogin.state == NSOnState) {
        self.delegate.launchOnLogin = YES;
    } else {
        self.delegate.launchOnLogin = NO;
    }
}

@end
