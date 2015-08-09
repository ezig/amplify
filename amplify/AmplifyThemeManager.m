//
//  AmplifyThemeManager.m
//  amplify
//
//  Created by Ezra Zigmond on 8/9/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifyThemeManager.h"

@implementation AmplifyThemeManager

+ (NSColor *)normalColorForTheme:(NSString *)color {
    if ([color isEqualToString:@"classic"] || [color isEqualToString:@"vibrant"]) {
        return nil;
    } else {
        return [NSColor lightGrayColor];
    }
}

+ (NSColor *)hoverColorForButtonTheme:(NSString *)color {
    if ([color isEqualToString:@"classic"]) {
        return [NSColor colorWithRed:0.5176 green:0.741 blue:0.0 alpha:1.0];
    } else if ([color isEqualToString:@"new"]) {
        return [NSColor colorWithRed:0.1373 green:0.8118 blue:0.3725 alpha:1.0];
    } else {
        return [NSColor colorWithRed:0.1686 green:0.3333 blue:0.5333 alpha:1.0];
    }
}

@end
