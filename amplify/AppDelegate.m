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

@property (weak) IBOutlet NSMenu *statusMenu;

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
    
    self.statusMenu.delegate = self;
//    self.statusItem.menu = self.statusMenu;
    self.statusItem.action = @selector(togglePopover:);
    
    [self setupHotkey];
    
    self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    _popover = [NSPopover new];
    _popover.contentViewController = [[AmplifyViewController alloc] initWithNibName:@"AmplifyViewController" bundle:nil];
    _popover.contentSize = (NSSize) {300, 150};
}

- (void)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self.popover performClose:sender];
    } else {
        [self.popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSMinYEdge];
    }
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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)statusItemClicked:(id)sender {
    //show the popup menu associated with the status item.
    [self.statusItem.button performClick:nil];
}

- (void)menuWillOpen:(NSMenu *)menu {
    if (![self.spotify isRunning]) {
    }
}

@end
