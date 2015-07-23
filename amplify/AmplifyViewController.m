//
//  AmplifyViewController.m
//  amplify
//
//  Created by Ezra Zigmond on 6/29/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AmplifyViewController.h"
#import "AmplifyScrollLabel.h"
#import "AmplifyHoverButton.h"
#import "Spotify.h"
#import "NSImage+Transform.h"
#include <ShortcutRecorder/ShortcutRecorder.h>
#include <Carbon/Carbon.h>

@interface AmplifyViewController () <NSUserNotificationCenterDelegate>

@property (weak) IBOutlet AmplifyHoverButton *nextButton;
@property (weak) IBOutlet AmplifyHoverButton *prevButton;
@property (weak) IBOutlet AmplifyHoverButton *playButton;

// not a hover button because the visual effect would be confusing
// (shuffle button changes color when clicked to indicate shuffling / not shuffling)≥
@property (weak) IBOutlet NSButton *shuffleButton;

@property (weak) IBOutlet NSButton *volumeUp;
@property (weak) IBOutlet NSButton *volumeDown;

@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSImageView *albumArtView;
@property (weak) IBOutlet AmplifyScrollLabel *songScrollLabel;

@property (nonatomic, strong) SpotifyApplication *spotify;

@property (nonatomic, strong) NSString *currentTrackURL;

@property (nonatomic, strong) NSColor *spotifyColor;

@property (nonatomic, strong) NSImage *albumArt;

@property (nonatomic, strong) NSImage *shuffleImage;
@property (nonatomic, strong) NSImage *shuffleTinted;

@end

@implementation AmplifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.theme" options:NSKeyValueObservingOptionInitial context:NULL];
    
    [self bindButtons];
    
    [self setupImages];
    
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    
    self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    self.albumArtView.imageScaling = NSImageScaleAxesIndependently;
    
    self.songScrollLabel.speed = 0.02;
    self.songScrollLabel.text = @"No song";
    
    // even though we force the
    if ([self.spotify isRunning]) {
        self.songScrollLabel.text = [self getFormattedSongTitle];
        
        // if there was already album art before the view loaded, set it
        if (self.albumArt) {
            self.albumArtView.image = self.albumArt;
        }
        // otherwise, get the album artwork
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [self updateArtworkWithCompletion:nil];
            });
        }
        
        // set the play button image (normally this changes whenever the playback changes, but
        // set it manually once when the view loads)
        if (self.spotify.playerState == SpotifyEPlSPlaying) {
            [self.playButton setImage:[NSImage imageNamed:@"pause"] withTint:self.spotifyColor];
        } else {
            [self.playButton setImage:[NSImage imageNamed:@"play"] withTint:self.spotifyColor];
        }
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
    } else {
        self.songScrollLabel.text = @"No song";
        self.albumArtView.image = [NSImage imageNamed:@"noArtworkImage"];
    }
}

- (void) setupImages {
    self.spotifyColor = [self colorForString:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"theme"]];
    
    self.shuffleImage = [NSImage imageNamed:@"shuffle"];
    self.shuffleTinted = [self.shuffleImage imageTintedWithColor:self.spotifyColor];
    
    // don't set the play button here because we're going to set that in playbackChanged anyway
    [self.nextButton setImage:[NSImage imageNamed:@"next"] withTint:self.spotifyColor];
    [self.prevButton setImage:[NSImage imageNamed:@"previous"] withTint:self.spotifyColor];
    [self.playButton setImage:[NSImage imageNamed:@"play"] withTint:self.spotifyColor];
}

// returning nil will prevent alert sound
- (NSEvent *)handleKeyPress:(NSEvent *)event {
    if (self.isVisible) {
        switch ([event keyCode]) {
            case kVK_ANSI_Q:
                [self didPressQuit:nil];
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
            
            if (![self.currentTrackURL isEqualToString:self.spotify.currentTrack.spotifyUrl]) {
                self.currentTrackURL = [self.spotify.currentTrack.spotifyUrl copy];
                self.songScrollLabel.text = [self getFormattedSongTitle];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    [self updateArtworkWithCompletion:^(NSImage *album) {
                        [self sendNotification:album];
                    }];
                });
            }
            
            [self.playButton setImage:[NSImage imageNamed:@"pause"] withTint:self.spotifyColor];
        } else {
            [self.playButton setImage:[NSImage imageNamed:@"play"] withTint:self.spotifyColor];
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

- (IBAction)didPressVolumeDown:(id)sender {
    self.volumeSlider.integerValue = MAX(0, self.volumeSlider.integerValue - 5);
    [self didChangeSlider:nil];
}

- (IBAction)didPressVolumeUp:(id)sender {
    self.volumeSlider.integerValue = MIN(100, self.volumeSlider.integerValue + 5);
    [self didChangeSlider:nil];
}

#pragma mark - Settings pop up button actions

- (IBAction)didPressPreferences:(id)sender {
    [self.prefsWindow makeKeyAndOrderFront:nil];
    PreferencesViewController *contentView = [[PreferencesViewController alloc] initWithNibName:@"PreferencesViewController" bundle:nil];
    
    contentView.delegate = (id<PreferencesDelegate>)self.delegate;
    
    [self.delegate closePopover:nil];
    
    self.prefsWindow.contentViewController = contentView;
}


- (IBAction)didPressQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

#pragma mark - Private methods
- (NSColor *)colorForString:(NSString *)color {
    if ([color isEqualToString:@"classic"]) {
        return [NSColor colorWithRed:0.5176 green:0.741 blue:0.0 alpha:1.0];
    } else if ([color isEqualToString:@"new"]) {
        return [NSColor colorWithRed:0.1373 green:0.8118 blue:0.3725 alpha:1.0];
    } else {
        return [NSColor colorWithRed:0.4941 green:0.282352941 blue:0.8980 alpha:1.0];
    }
}

- (void)updateArtworkWithCompletion:(void (^)(NSImage *))completion {
    NSImage *album;
    
    NSString *spotifyURL = [self.spotify.currentTrack.spotifyUrl copy];
    
    NSURL *songURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://embed.spotify.com/oembed/?url=%@", spotifyURL]];
    
    NSURLRequest *songRequest = [[NSURLRequest alloc] initWithURL:songURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:songRequest returningResponse:nil error:nil];

    if (data) {
        NSURL *artURL = [NSURL URLWithString:[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"thumbnail_url"]];
         
        NSURLRequest *artRequest = [[NSURLRequest alloc] initWithURL:artURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0];
         
        data = [NSURLConnection sendSynchronousRequest:artRequest returningResponse:nil error:nil];
        
        if (data) {
            album = [[NSImage alloc] initWithData:data];
        } else {
            album = [NSImage imageNamed:@"noArtworkImage"];
        }
        
    } else {
        album = [NSImage imageNamed:@"noArtworkImage"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([spotifyURL isEqualToString:self.spotify.currentTrack.spotifyUrl]) {
            self.albumArt = album;
            self.albumArtView.image = album;
            if (completion) {
                completion(album);
            }
        }
    });
}

- (void) sendNotification:(NSImage *)album {
    // only actually send a notification if
    // 1. notifications are enabled in the settings
    // 2. the popover isn't visible and
    // 3. the user isn't currently in spotify
    if ([[[NSUserDefaultsController sharedUserDefaultsController] defaults] boolForKey:@"notifications"] &&
        !self.isVisible &&
        ![[[NSWorkspace sharedWorkspace] frontmostApplication].bundleIdentifier isEqualToString:@"com.spotify.client"]) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];

        notification.title = self.spotify.currentTrack.name;
        notification.subtitle = self.spotify.currentTrack.album;
        notification.informativeText = self.spotify.currentTrack.artist;
        
        notification.contentImage = album;
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}

- (void) bindButtons {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self.playButton bind:@"keyEquivalent"
                 toObject:defaults
              withKeyPath:@"values.play"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new]}];
    [self.playButton bind:@"keyEquivalentModifierMask"
                 toObject:defaults
              withKeyPath:@"values.play"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new]}];
    
    [self.nextButton bind:@"keyEquivalent"
                 toObject:defaults
              withKeyPath:@"values.next"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new]}];
    [self.nextButton bind:@"keyEquivalentModifierMask"
                 toObject:defaults
              withKeyPath:@"values.next"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new]}];
    
    [self.prevButton bind:@"keyEquivalent"
                 toObject:defaults
              withKeyPath:@"values.prev"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new]}];
    [self.prevButton bind:@"keyEquivalentModifierMask"
                 toObject:defaults
              withKeyPath:@"values.prev"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new]}];
    
    [self.shuffleButton bind:@"keyEquivalent"
                 toObject:defaults
              withKeyPath:@"values.shuffle"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new]}];
    [self.shuffleButton bind:@"keyEquivalentModifierMask"
                 toObject:defaults
              withKeyPath:@"values.shuffle"
                  options:@{NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new]}];
    
    [self.volumeUp bind:@"keyEquivalent"
                    toObject:defaults
                 withKeyPath:@"values.volumeUp"
                     options:@{NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new]}];
    [self.volumeUp bind:@"keyEquivalentModifierMask"
                    toObject:defaults
                 withKeyPath:@"values.volumeUp"
                     options:@{NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new]}];
    
    [self.volumeDown bind:@"keyEquivalent"
               toObject:defaults
            withKeyPath:@"values.volumeDown"
                options:@{NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new]}];
    [self.volumeDown bind:@"keyEquivalentModifierMask"
               toObject:defaults
            withKeyPath:@"values.volumeDown"
                options:@{NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new]}];
}

# pragma mark - NSObject
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"values.theme"]) {
        [self setupImages];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

# pragma mark - NSUserNotificationCenterDelegate methods

- (BOOL) userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

// clicking on notification launches Spotify
- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [[NSWorkspace sharedWorkspace] launchApplication:@"Spotify"];
}

@end
