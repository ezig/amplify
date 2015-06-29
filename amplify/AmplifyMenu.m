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

@property (weak) IBOutlet NSMenuItem *songItem;
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
        
        // TODO: set initial song title
        // register a listener for playback change
        // this notification will fire when the user presses pause/play
        // and also when the track changes
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(eventOccured:)
                                                                name:@"com.spotify.client.PlaybackStateChanged"
                                                              object:nil
                                                  suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    }
    
    return self;
}

- (void)eventOccured:(NSNotification *)notification {
    NSLog(@"%@", notification.userInfo);
    if (self.spotify.playerState == SpotifyEPlSPlaying) {
        self.playItem.title = @"Pause";
        self.songItem.title = [self getFormattedSongTitle];
    } else {
        self.playItem.title = @"Play";
    }
}

- (NSString *)getFormattedSongTitle {
    return [NSString stringWithFormat:@"%@ - %@", self.spotify.currentTrack.name, self.spotify.currentTrack.artist];
}

// TODO: clean up menu validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (![self.spotify isRunning] && menuItem != self.quitItem) {
        return NO;
    } else {
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
