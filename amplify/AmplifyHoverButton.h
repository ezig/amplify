//
//  AmplifyHoverButton.h
//  amplify
//
//  Created by Ezra Zigmond on 7/12/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AmplifyHoverButton : NSButton

// Sets the image as the normal image and tints the image to create the hover image
- (void) setImage:(NSImage *)image withTint:(NSColor *)tint hoverTint:(NSColor *)hoverTint;

@end
