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

@property (weak) IBOutlet NSSegmentedControl *buttonThemeControl;
@property (weak) IBOutlet NSSegmentedControl *popoverThemeControl;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
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
    
    NSString *buttonTheme = [[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"buttonTheme"];
    
    if ([buttonTheme isEqualToString:@"classic"]) {
        self.buttonThemeControl.selectedSegment = 0;
    } else if ([buttonTheme isEqualToString:@"new"]) {
        self.buttonThemeControl.selectedSegment = 1;
    } else {
        self.buttonThemeControl.selectedSegment = 2;
    }

    NSString *popoverTheme = [[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"popoverTheme"];
    
    if ([popoverTheme isEqualToString:@"classic"]) {
        self.popoverThemeControl.selectedSegment = 0;
    } else if ([popoverTheme isEqualToString:@"vibrant"]) {
        self.popoverThemeControl.selectedSegment = 1;
    } else {
        self.popoverThemeControl.selectedSegment = 2;
    }
    
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
    [super viewDidAppear];
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

- (IBAction)didChangePopoverTheme:(id)sender {
    if (self.popoverThemeControl.selectedSegment == 0) {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@"classic" forKey:@"popoverTheme"];
    } else if (self.popoverThemeControl.selectedSegment == 1) {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@"vibrant" forKey:@"popoverTheme"];
    } else {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@"dark" forKey:@"popoverTheme"];
    }
}

- (IBAction)didChangeButtonTheme:(id)sender {
    if (self.buttonThemeControl.selectedSegment == 0) {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@"classic" forKey:@"buttonTheme"];
    } else if (self.buttonThemeControl.selectedSegment == 1) {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@"new" forKey:@"buttonTheme"];
    } else {
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@"night" forKey:@"buttonTheme"];
    }
}

@end
