//
//  AmplifyThemeManager.h
//  amplify
//
//  Created by Ezra Zigmond on 8/9/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

@interface AmplifyThemeManager : NSObject

+ (NSColor *)normalColorForTheme:(NSString *)color;
+ (NSColor *)hoverColorForButtonTheme:(NSString *)color;

@end
