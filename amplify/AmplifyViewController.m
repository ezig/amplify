//
//  AmplifyViewController.m
//  amplify
//
//  Created by Ezra Zigmond on 6/29/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifyViewController.h"
#import "Spotify.h"
#include <Carbon/Carbon.h>

@interface AmplifyViewController ()

@property (weak) IBOutlet NSTextField *songLabel;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSImageView *albumArt;


@property (nonatomic, strong) SpotifyApplication *spotify;

@end

@implementation AmplifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    self.albumArt.imageScaling = NSImageScaleAxesIndependently;
    
    if ([self.spotify isRunning]) {
        [self.songLabel setStringValue:[self getFormattedSongTitle]];
        [self updateArtwork];
    }
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask
                                          handler:^(NSEvent *event) {
                                              return [self handleKeyPress:event];
                                          }];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(playbackChanged:)
                                                            name:@"com.spotify.client.PlaybackStateChanged"
                                                          object:nil
                                              suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
}

- (void) viewDidAppear {
    if ([self.spotify isRunning]) {
        self.volumeSlider.intValue = (int) self.spotify.soundVolume;
    }
}

// returning nil will prevent alert sound
- (NSEvent *) handleKeyPress:(NSEvent *)event {
    if (self.isVisible) {
        switch ([event keyCode]) {
            case kVK_ANSI_P:
                [self didPressPlay:nil];
                break;
            
            case kVK_ANSI_D:
                [self didPressNext:nil];
                break;
                
            case kVK_ANSI_A:
                [self didPressPrev:nil];
                break;
            
            case kVK_ANSI_U:
                [self didPressShuffle:nil];
                break;
                
            case kVK_ANSI_Q:
                [self didPressQuit:nil];
                break;
                
            case kVK_ANSI_W:
                self.volumeSlider.integerValue = MIN(100, self.volumeSlider.integerValue + 5);
                [self didChangeSlider:nil];
                break;
            
            case kVK_ANSI_S:
                self.volumeSlider.integerValue = MAX(0, self.volumeSlider.integerValue - 5);
                [self didChangeSlider:nil];
                break;
                
            case kVK_Escape:
                [self.delegate togglePopover:self];
                break;
                
            default:
                return event;
        }
        
        return nil;
    } else {
        return event;
    }
}

- (void)playbackChanged:(NSNotification *)notification {
    if ([self.spotify isRunning]) {
        if (self.spotify.playerState == SpotifyEPlSPlaying) {
            [self.songLabel setStringValue:[self getFormattedSongTitle]];
            
            [self updateArtwork];
            
            [self.playButton setTitle:@"\u25B6"];
        } else {
            [self.playButton setTitle:@"\u2759 \u2759"];
        }
    } else {
        [self.songLabel setStringValue:@"No song"];
    }
}

// TODO: Display loading while fetching artwork
- (void) updateArtwork {
    dispatch_async(dispatch_get_main_queue(), ^ {
        self.albumArt.image = [self getAlbumArt];
    });
}

// TODO: Handle text that is too large for the view
- (NSString *)getFormattedSongTitle {
    return [NSString stringWithFormat:@"%@ - %@", self.spotify.currentTrack.name, self.spotify.currentTrack.artist];
}

// TODO: fix the image size
- (NSImage *)getAlbumArt {
    NSURL *request = [NSURL URLWithString:[NSString stringWithFormat:@"https://embed.spotify.com/oembed/?url=%@", self.spotify.currentTrack.spotifyUrl]];
    NSData *data = [NSData dataWithContentsOfURL:request];
    
    if (data) {
        NSURL *artRequest = [NSURL URLWithString:[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"thumbnail_url"]];
        NSData *artData = [NSData dataWithContentsOfURL:artRequest];
        if (artData) {
            return [[NSImage alloc] initWithData:artData];
        }
    }
    
    return nil;
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
