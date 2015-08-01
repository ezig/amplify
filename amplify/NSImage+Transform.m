//
//  NSImage+Transform.m
//  amplify
//
//  Created by Ezra Zigmond on 7/12/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "NSImage+Transform.h"

@implementation NSImage (Transform)

- (NSImage *)imageTintedWithColor:(NSColor *)tint
{
    NSImage *image = [self copy];
    
    if (tint) {
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [image unlockFocus];
    }
    
    return image;
}

@end
