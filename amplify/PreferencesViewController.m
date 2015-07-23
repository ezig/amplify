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

@property (weak) IBOutlet SRRecorderControl *playShortcut;
@property (weak) IBOutlet SRRecorderControl *shuffleShortcut;
@property (weak) IBOutlet SRRecorderControl *nextShortcut;
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
    
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self.playShortcut bind:NSValueBinding
                  toObject:defaults
               withKeyPath:@"values.play"
                   options:nil];
    
    [self.playShortcut setAllowedModifierFlags:NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask requiredModifierFlags:0 allowsEmptyModifierFlags:YES];
    
    [self.shuffleShortcut bind:NSValueBinding
                      toObject:defaults
                   withKeyPath:@"values.shuffle"
                       options:nil];
    [self.shuffleShortcut setAllowedModifierFlags:NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask requiredModifierFlags:0 allowsEmptyModifierFlags:YES];
    
    [self.nextShortcut bind:NSValueBinding
                  toObject:defaults
               withKeyPath:@"values.next"
                   options:nil];
    
    [self.nextShortcut setAllowedModifierFlags:NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask requiredModifierFlags:0 allowsEmptyModifierFlags:YES];
    
    [self.previousShortcut bind:NSValueBinding
                  toObject:defaults
               withKeyPath:@"values.prev"
                   options:nil];
    
    [self.previousShortcut setAllowedModifierFlags:NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask requiredModifierFlags:0 allowsEmptyModifierFlags:YES];
    
    [self.volumeUpShortcut bind:NSValueBinding
                  toObject:defaults
               withKeyPath:@"values.volumeUp"
                   options:nil];
    
    [self.volumeDownShortcut setAllowedModifierFlags:NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask requiredModifierFlags:0 allowsEmptyModifierFlags:YES];
    
    [self.volumeDownShortcut bind:NSValueBinding
                   toObject:defaults
                withKeyPath:@"values.volumeDown"
                    options:nil];
    
    [self.volumeUpShortcut setAllowedModifierFlags:NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask requiredModifierFlags:0 allowsEmptyModifierFlags:YES];
    
    [self.globalShortcut bind:NSValueBinding
                         toObject:defaults
                      withKeyPath:@"values.global"
                          options:nil];
}

- (void)viewDidAppear {
    if (self.delegate.launchOnLogin) {
        self.enableLaunchOnLogin.state = NSOnState;
    } else {
        self.enableLaunchOnLogin.state = NSOffState;
    }
    
    if ([[[NSUserDefaultsController sharedUserDefaultsController] defaults] boolForKey:@"notifications"]) {
        self.enableNotifications.state = NSOnState;
    } else {
        self.enableNotifications.state = NSOffState;
    }
}

- (IBAction)didChangeLaunchOnLogin:(id)sender {
    if (self.enableLaunchOnLogin.state == NSOnState) {
        self.delegate.launchOnLogin = YES;
    } else {
        self.delegate.launchOnLogin = NO;
    }
}

- (IBAction)didChangeEnableNotifications:(id)sender {
    if (self.enableNotifications.state == NSOnState) {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@YES forKey:@"notifications"];
    } else {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@NO forKey:@"notifications"];
    }
}


@end
