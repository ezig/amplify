//
//  AmplifyViewController.m
//  amplify
//
//  Created by Ezra Zigmond on 6/29/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifyViewController.h"
#import "AmplifyScrollLabel.h"
#import "Spotify.h"
#import "NSImage+Transform.h"
#include <Carbon/Carbon.h>

@interface AmplifyViewController ()

@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSButton *prevButton;
@property (weak) IBOutlet NSButton *shuffleButton;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSImageView *albumArt;
@property (weak) IBOutlet AmplifyScrollLabel *songScrollLabel;

@property (nonatomic, strong) SpotifyApplication *spotify;

@property (nonatomic, strong) NSImage *shuffleImage;
@property (nonatomic, strong) NSImage *shuffleTinted;

@end

@implementation AmplifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self setupImages];
    
    self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    self.albumArt.imageScaling = NSImageScaleAxesIndependently;
    
    self.songScrollLabel.speed = 0.02;
    self.songScrollLabel.text = @"No song";
    
    if ([self.spotify isRunning]) {
        [self playbackChanged:nil];
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
        
        if ([self.spotify shuffling]) {
            self.shuffleButton.image = self.shuffleTinted;
        } else {
            self.shuffleButton.image = self.shuffleImage;
        }
    }
}

- (void) setupImages {
    self.shuffleImage = [NSImage imageNamed:@"shuffle"];
    self.shuffleTinted = [self.shuffleImage imageTintedWithColor:[NSColor colorWithRed:0.51 green:0.72 blue:0.10 alpha:1.0]];
    
    self.nextButton.alternateImage = [[NSImage imageNamed:@"nextButton"] imageTintedWithColor:[NSColor darkGrayColor]];
}

// returning nil will prevent alert sound
- (NSEvent *)handleKeyPress:(NSEvent *)event {
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
            self.songScrollLabel.text = [self getFormattedSongTitle];
            [self updateArtwork];
            
            [self.playButton setImage:[NSImage imageNamed:@"pause"]];
        } else {
            [self.playButton setImage:[NSImage imageNamed:@"play"]];
        }
    } else {
        self.songScrollLabel.text = @"No song";
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
    if ([self.spotify isRunning] && [self.spotify shufflingEnabled]) {
        if (!self.spotify.shuffling) {
            self.spotify.shuffling = YES;
            self.shuffleButton.image = self.shuffleTinted;
        }
        else {
            self.spotify.shuffling = NO;
            self.shuffleButton.image = self.shuffleImage;
        }
    }
}

- (IBAction)didPressQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)updateArtwork {
    NSURL *songURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://embed.spotify.com/oembed/?url=%@", self.spotify.currentTrack.spotifyUrl]];
    
    NSURLRequest *songRequest = [[NSURLRequest alloc] initWithURL:songURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0];
    
    [NSURLConnection sendAsynchronousRequest:songRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (data) {
             NSURL *artURL = [NSURL URLWithString:[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"thumbnail_url"]];
             
             NSURLRequest *artRequest = [[NSURLRequest alloc] initWithURL:artURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0];
             
             [NSURLConnection sendAsynchronousRequest:artRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
              {
                  if (data) {
                      dispatch_async(dispatch_get_main_queue(), ^ {
                          self.albumArt.image = [[NSImage alloc] initWithData:data];
                      });
                  } else {
                      self.albumArt.image = [NSImage imageNamed:@"noArtworkImage"];
                  }
              }];
         } else {
             self.albumArt.image = [NSImage imageNamed:@"noArtworkImage"];
         }
     }];
}

@end
