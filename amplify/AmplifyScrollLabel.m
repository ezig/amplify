//
//  AmplifyScrollLabel.m
//  amplify
//
//  Created by Ezra Zigmond on 7/5/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

#import "AmplifyScrollLabel.h"

// distance between the end of the text and the beginning of the wraparound
#define WRAPAROUND_OFFSET 50

@interface AmplifyScrollLabel () {
    // locations of the two strings
    NSPoint _point1;
    NSPoint _point2;
}

@property (nonatomic, strong) NSTimer *scroller;
@property (nonatomic, strong) NSMutableDictionary *stringAttrs;

// pixel width of text when drawn with stringAttrs
@property (nonatomic, assign) CGFloat stringWidth;

@property (nonatomic, strong) NSTrackingArea *trackingArea;

// scrolling is disabled if the text of the label
// is smaller than the label and thus fits totally in the label
@property (nonatomic, assign) BOOL scrollEnabled;


@end

@implementation AmplifyScrollLabel

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.color = [NSColor blackColor];
    NSFont *font = [NSFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    
    self.stringAttrs = [NSMutableDictionary dictionaryWithObjects:@[font, self.color] forKeys:@[NSFontAttributeName, NSForegroundColorAttributeName]];
    // default scroll mode is on hover
    self.mode = ScrollModeOnHover;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.text drawAtPoint:_point1 withAttributes:self.stringAttrs];
    
    // only draw the second string if scrolling
    if (self.scrollEnabled) {
        [self.text drawAtPoint:_point2 withAttributes:self.stringAttrs];
    }
}

- (void)resetPosition {
    _point1 = NSZeroPoint;
    
    _point2 = NSZeroPoint;
    _point2.x += self.stringWidth + WRAPAROUND_OFFSET;
}

#pragma mark - Setters
- (void) setText:(NSString *)newText {
    // reset the scrolling timer
    [self.scroller invalidate];
    self.scroller = nil;
    
    _text = [newText copy];
    
    self.stringWidth = [newText sizeWithAttributes:self.stringAttrs].width;
    
    [self resetPosition];
    
    // only enable scrolling if the text is actually wider than the label
    if (self.stringWidth < self.frame.size.width) {
        self.scrollEnabled = NO;
    } else {
        self.scrollEnabled = YES;
    }
    
    // conditionally start the scroll timer
    if (self.mode == ScrollModeContinuous && self.speed > 0 && self.scrollEnabled && self.text != nil) {
        self.scroller = [NSTimer scheduledTimerWithTimeInterval:self.speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
    }
    
    [self setNeedsDisplay:YES];
}

- (void) setSpeed:(NSTimeInterval)newSpeed {
    // restart the timer with the new interval
    if (newSpeed != _speed) {
        _speed = newSpeed;
        
        [self.scroller invalidate];
        self.scroller = nil;

        if (_speed > 0 && self.text != nil && self.scrollEnabled && self.mode == ScrollModeContinuous) {
            self.scroller = [NSTimer scheduledTimerWithTimeInterval:_speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        }
    }
}

- (void) setColor:(NSColor *)color {
    _color = color;
    
    self.stringAttrs[NSForegroundColorAttributeName] = _color;
}

#pragma mark - Private Methods

- (void) moveText:(NSTimer *)timer {
    _point1.x -= 1.0;
    _point2.x -= 1.0;
    
    // if right side of either string moves off the screen,
    // move the left side of the string to the right edge
    if (_point1.x < -self.stringWidth) {
        _point1.x += self.frame.size.width + self.stringWidth + WRAPAROUND_OFFSET;
    }
    if (_point2.x < -self.stringWidth) {
        _point2.x += self.frame.size.width + self.stringWidth + WRAPAROUND_OFFSET;
    }
    
    // if we are in hover mode and the second string gets back
    // to the original position of the first string, one full scroll has finished
    // so cancel the timer
    if (self.mode == ScrollModeOnHover) {
        if (fabs(_point2.x) < 0.5) {
            [self.scroller invalidate];
            self.scroller = nil;
            [self resetPosition];
        }
    }
    
    [self setNeedsDisplay:YES];
}

#pragma mark - Mouseover Handling
- (void)mouseEntered:(NSEvent *)theEvent {
    if (self.scrollEnabled) {
        if (self.mode == ScrollModeContinuous) {
            [self.scroller invalidate];
            self.scroller = nil;
        } else if (self.mode == ScrollModeOnHover && self.scroller == nil){
            self.scroller = [NSTimer scheduledTimerWithTimeInterval:self.speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        }
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    if (self.scrollEnabled) {
        if (self.mode == ScrollModeContinuous) {
            self.scroller = [NSTimer scheduledTimerWithTimeInterval:self.speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        }
    }
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
