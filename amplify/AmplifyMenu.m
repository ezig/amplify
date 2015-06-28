//
//  AmplifyMenu.m
//  amplify
//
//  Created by Ezra Zigmond on 6/28/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifyMenu.h"
#import "Spotify.h"

@interface AmplifyMenu ()

@property (strong, nonatomic) SpotifyApplication *spotify;

@property (weak) IBOutlet NSMenuItem *playItem;
@property (weak) IBOutlet NSMenuItem *nextItem;
@property (weak) IBOutlet NSMenuItem *prevItem;
@property (weak) IBOutlet NSMenuItem *quitItem;


@end

@implementation AmplifyMenu

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    }
    
    return self;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (![self.spotify isRunning] && menuItem != self.quitItem) {
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)didPressPlay:(id)sender {
    if ([self.spotify isRunning]) {
        [self.spotify playpause];
    }
}

- (IBAction)didPressNext:(id)sender {
    if ([self.spotify isRunning]) {
        [self.spotify nextTrack];
    }
}

- (IBAction)didPressPrev:(id)sender {
    if ([self.spotify isRunning]) {
        [self.spotify previousTrack];
    }
}

- (IBAction)didPressQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

@end
