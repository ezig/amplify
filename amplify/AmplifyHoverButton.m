//
//  AmplifyHoverButton.m
//  amplify
//
//  Created by Ezra Zigmond on 7/12/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifyHoverButton.h"
#import "NSImage+Transform.h"

@interface AmplifyHoverButton ()


@property (nonatomic, strong) NSImage *normalImage;
@property (nonatomic, strong) NSImage *hoverImage;

@property (nonatomic, strong) NSTrackingArea *trackingArea;

@property (nonatomic, assign) BOOL mouseIn;

@end

@implementation AmplifyHoverButton

- (void) setImage:(NSImage *)image withTint:(NSColor *)tint hoverTint:(NSColor *)hoverTint {
    
    if (tint) {
        self.normalImage = [image imageTintedWithColor:tint];
    } else {
        self.normalImage = image;
    }
    
    if (hoverTint) {
        self.hoverImage = [image imageTintedWithColor:hoverTint];
    } else {
        self.normalImage = image;
    }
    
    self.alternateImage = self.hoverImage;
    
    // make sure to use the correct image tint when setting the image
    if (self.mouseIn) {
        self.image = self.hoverImage;
    } else {
        self.image = self.normalImage;
    }
}

#pragma mark - Mouseover Handling
- (void)mouseEntered:(NSEvent *)theEvent {
    self.mouseIn = YES;
    self.image = self.hoverImage;
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.mouseIn = NO;
    self.image = self.normalImage;
}

- (void)updateTrackingAreas {
    if (self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

@end
