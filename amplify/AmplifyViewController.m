//
//  AmplifyViewController.m
//  amplify
//
//  Created by Ezra Zigmond on 6/29/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifyViewController.h"
#import "Spotify.h"

@interface AmplifyViewController ()

@property (weak) IBOutlet NSTextField *songLabel;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSSlider *volumeSlider;


@property (nonatomic, strong) SpotifyApplication *spotify;

@end

@implementation AmplifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    if ([self.spotify isRunning]) {
        [self.songLabel setStringValue:[self getFormattedSongTitle]];
    }
    
    // register a listener for playback change
    // this notification will fire when the user presses pause/play
    // and also when the track changes
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(playbackChanged:)
                                                            name:@"com.spotify.client.PlaybackStateChanged"
                                                          object:nil
                                              suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
}

- (BOOL) acceptsFirstResponder {
    return YES;
}

- (void) keyDown:(NSEvent *)theEvent {
    NSLog(@"hey");
}

- (void) viewDidAppear {
    if ([self.spotify isRunning]) {
        self.volumeSlider.intValue = (int) self.spotify.soundVolume;
    }
}

- (void)playbackChanged:(NSNotification *)notification {
    if ([self.spotify isRunning]) {
        if (self.spotify.playerState == SpotifyEPlSPlaying) {
            [self.songLabel setStringValue:[self getFormattedSongTitle]];
            [self.playButton setTitle:@"\u25B6"];
        } else {
            [self.playButton setTitle:@"\u2759 \u2759"];
        }
    } else {
        [self.songLabel setStringValue:@"No song"];
    }
}

- (NSString *)getFormattedSongTitle {
    return [NSString stringWithFormat:@"%@ - %@", self.spotify.currentTrack.name, self.spotify.currentTrack.artist];
}

- (IBAction)didChangeSlider:(id)sender {
    if ([self.spotify isRunning]) {
        [self.spotify setSoundVolume:self.volumeSlider.integerValue];
    }
}

- (IBAction)didPressPrev:(id)sender {
    if ([self.spotify isRunning]) {
        [self.spotify previousTrack];
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

- (IBAction)didPressShuffle:(id)sender {
    if ([self.spotify isRunning]) {
        self.spotify.shuffling = !self.spotify.shuffling;
    }
}

- (IBAction)didPressQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

@end
