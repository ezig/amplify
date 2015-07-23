//
//  AppDelegate.m
//  amplify
//
//  Created by Ezra Zigmond on 6/28/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AppDelegate.h"
#import "Spotify.h"
#import "AmplifyviewController.h"
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>

#import <Carbon/Carbon.h>

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) SpotifyApplication *spotify;
@property (strong, nonatomic) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.global" options:NSKeyValueObservingOptionInitial context:NULL];
    
    if (![[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"hasBeenLaunched"]) {
        [self setupUserDefaults];
        NSLog(@"Test");
        [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@YES forKey:@"hasBeenLaunched"];
    }
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSImage *icon = [NSImage imageNamed:@"statusIcon"];
    [icon setTemplate:YES];
    
    self.statusItem.image = icon;
    
    self.statusItem.action = @selector(togglePopover:);
    
    self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    self.popover = [NSPopover new];
    AmplifyViewController* contentView = [[AmplifyViewController alloc] initWithNibName:@"AmplifyViewController" bundle:nil];
    contentView.delegate = self;
    self.popover.contentViewController = contentView;
    self.popover.contentSize = (NSSize) {300, 125};
    
    [self.popover.contentViewController viewDidLoad];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    if (self.popover.shown) {
        [self togglePopover:nil];
    }
}

- (void)closePopover:(id)sender {
    [self.popover close];
    ((AmplifyViewController*) self.popover.contentViewController).isVisible = NO;
}

#pragma mark - Private methods

- (void)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self.popover close];
        ((AmplifyViewController*) self.popover.contentViewController).isVisible = NO;
        [[[NSWorkspace sharedWorkspace] menuBarOwningApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    } else {
        [NSApp activateIgnoringOtherApps:YES];
        
        [self.popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSMinYEdge];
        
        AmplifyViewController *contentView = (AmplifyViewController *) self.popover.contentViewController;
        [contentView.prefsWindow orderOut:nil];
        contentView.isVisible = NO;
    }
}

- (void) setupUserDefaults {
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@{@"charactersIgnoringModifiers" : @"a", @"characters" : @"a", @"keyCode" : @0, @"modifierFlags" : @0} forKey:@"prev"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@{@"charactersIgnoringModifiers" : @"d", @"characters" : @"d", @"keyCode" : @2, @"modifierFlags" : @0} forKey:@"next"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@{@"charactersIgnoringModifiers" : @"p", @"characters" : @"p", @"keyCode" : @35, @"modifierFlags" : @0} forKey:@"play"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@{@"charactersIgnoringModifiers" : @"u", @"characters" : @"u", @"keyCode" : @32, @"modifierFlags" : @0} forKey:@"shuffle"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@{@"charactersIgnoringModifiers" : @"w", @"characters" : @"w", @"keyCode" : @13, @"modifierFlags" : @0} forKey:@"volumeUp"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@{@"charactersIgnoringModifiers" : @"s", @"characters" : @"s", @"keyCode" : @1, @"modifierFlags" : @0} forKey:@"volumeDown"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@YES forKey:@"notifications"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:@"classic" forKey:@"theme"];
}

#pragma mark - NSObject

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"values.global"]) {
        
        PTHotKeyCenter *keyCenter = [PTHotKeyCenter sharedCenter];
        
        // deregister the previous hotkey
        PTHotKey *oldKey = [keyCenter hotKeyWithIdentifier:keyPath];
        [keyCenter unregisterHotKey:oldKey];
        
        NSDictionary *shortcut = [object valueForKeyPath:keyPath];
        
        // only register a new hotkey if there's a shortcut
        if (shortcut && (NSNull *)shortcut != [NSNull null]) {
            PTHotKey *newKey = [PTHotKey hotKeyWithIdentifier:keyPath
                                                     keyCombo:shortcut
                                                       target:self
                                                       action:@selector(togglePopover:)];
            [keyCenter registerHotKey:newKey];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

#pragma mark - Launch on login methods

- (BOOL)launchOnLogin {
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // get list of current user's login items
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems) {
        UInt32 seedValue;

        NSArray  *loginItemsSnapshot = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
        
        // iterate through the login items and check to see if any match this app
        for (id item in loginItemsSnapshot) {
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
            
            if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&url, NULL) == noErr) {
                NSString *urlPath = [(__bridge NSURL *)url path];
                if ([urlPath compare:appPath] == NSOrderedSame) {
                    return YES;
                }
            }
        }
    }
    
    // login items could not be retrieved or no match was found
    return NO;
}

- (void)setLaunchOnLogin:(BOOL)launchOnLogin {
    // get file path to app
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // get list of current user's login items
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    // only update the login items if we were able to get them
    if (loginItems) {
        // add to login items list
        if (launchOnLogin) {
            LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
            
            if (item) {
                CFRelease(item);
            }
        }
        // remove from login items list
        else {
            UInt32 seedValue;
            
            NSArray  *loginItemsSnapshot = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
            for (id item in loginItemsSnapshot) {
                LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
                
                // compare the item to the app path and remove if it matches
                if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&url, NULL) == noErr) {
                    NSString *urlPath = [(__bridge NSURL *)url path];
                    if ([urlPath compare:appPath] == NSOrderedSame) {
                        LSSharedFileListItemRemove(loginItems, itemRef);
                    }
                }
            }
        }
    }
    
    CFRelease(loginItems);
}

@end
