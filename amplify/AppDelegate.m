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
#import <Carbon/Carbon.h>

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) SpotifyApplication *spotify;
@property (strong, nonatomic) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSImage *icon = [NSImage imageNamed:@"statusIcon"];
    [icon setTemplate:YES];
    
    self.statusItem.image = icon;
    
    self.statusItem.action = @selector(togglePopover:);
    
    [self setupHotkey];
    
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

- (void)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self.popover close];
        ((AmplifyViewController*) self.popover.contentViewController).isVisible = NO;
        [[[NSWorkspace sharedWorkspace] menuBarOwningApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    } else {
        [NSApp activateIgnoringOtherApps:YES];
        [self.popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSMinYEdge];
        ((AmplifyViewController*) self.popover.contentViewController).isVisible = YES;
    }
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

// TODO: clean up hot key handling
- (void)setupHotkey {
    EventHotKeyRef hotKeyRef;
    EventHotKeyID hotKeyID;
    EventTypeSpec eventType;
    
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    hotKeyID.signature = 'mhk1';
    hotKeyID.id = 1;
    
    InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, NULL, NULL);
    
   RegisterEventHotKey(kVK_ANSI_Period, cmdKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
}

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData)
{
    AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    [delegate togglePopover:nil];
    return noErr;
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
