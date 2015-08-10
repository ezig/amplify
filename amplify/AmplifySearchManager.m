//
//  AmplifySearchManager.m
//  amplify
//
//  Created by Ezra Zigmond on 8/9/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifySearchManager.h"
#import "AmplifySearchResult.h"

@interface AmplifySearchManager ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation AmplifySearchManager

- (instancetype)init {
    if (self = [super init]) {
        _cache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSArray *)lookup:(NSString *)text {
    if ([self.cache objectForKey:text]) {
        return self.cache[text];
    } else {
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws.spotify.com/search/1/track.json?q=%@", text]];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        if (data) {
            NSArray *tracks = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"tracks"];
            
            self.cache[text] = [NSMutableArray array];
            
            for (id track in tracks) {
                AmplifySearchResult *result = [[AmplifySearchResult alloc] init];
                
                result.trackName = [track objectForKey:@"name"];
                result.url = [track objectForKey:@"href"];
                result.artist = [((NSArray *)[track objectForKey:@"artists"]) objectAtIndex:0];
                
                [self.cache[text] addObject:result];
            }
            
            return self.cache[text];
        }
        
        return nil;
    }
}

@end
