//
//  Application.m
//  Bulkhead
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import "Application.h"

@interface NSApplication (Application)

- (NSEvent *)_nextEventMatchingEventMask:(NSEventMask)mask untilDate:(NSDate *)expiration inMode:(NSRunLoopMode)mode dequeue:(BOOL)deqFlag;

@end

@implementation Application

- (NSEvent *)nextEventMatchingMask:(NSEventMask)mask untilDate:(NSDate *)expiration inMode:(NSRunLoopMode)mode dequeue:(BOOL)deqFlag
{
    NSEvent *event = [super nextEventMatchingMask:mask untilDate:expiration inMode:mode dequeue:deqFlag];
    if (event.type == NSEventTypeSystemDefined)
    {
//        NSLog(@"type: %@ subtype: %@", @(event.type), @(event.subtype));
        
        argv
        
    }
    return event;
}

@end
