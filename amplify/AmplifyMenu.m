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
@property (weak) IBOutlet NSMenuItem *shuffleItem;


@end

@implementation AmplifyMenu

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    }
    
    return self;
}

// TODO: clean up menu validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (![self.spotify isRunning] && menuItem != self.quitItem) {
        return NO;
    } else {
        
        if (menuItem == self.playItem) {
            if (self.spotify.playerState != SpotifyEPlSPlaying) {
                self.playItem.title = @"Play";
            } else {
                self.playItem.title = @"Pause";
            }
        }
        
        if (menuItem == self.shuffleItem) {
            if (self.spotify.shufflingEnabled) {
                if (self.spotify.shuffling) {
                    self.shuffleItem.title = @"Unshufflify";
                } else {
                    self.shuffleItem.title = @"Shufflify";
                }
            } else {
                return NO;
            }
        }
        
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

- (IBAction)didPressShuffle:(id)sender {
    if ([self.spotify isRunning] && self.spotify.shufflingEnabled) {
        self.spotify.shuffling = !self.spotify.shuffling;
    }
}

- (IBAction)didPressVolumeUp:(id)sender {
    if ([self.spotify isRunning]) {
        [self.spotify setSoundVolume:MIN(self.spotify.soundVolume + 5, 100)];
    }
}

- (IBAction)didPressVolumeDown:(id)sender {
    if ([self.spotify isRunning]) {
        [self.spotify setSoundVolume:MAX(self.spotify.soundVolume - 5, 0)];
    }
}

- (IBAction)didPressQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

@end
