//
//  AmplifySearchManager.h
//  amplify
//
//  Created by Ezra Zigmond on 8/9/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmplifySearchManager : NSObject

- (NSArray *)lookup:(NSString *)text;

@end