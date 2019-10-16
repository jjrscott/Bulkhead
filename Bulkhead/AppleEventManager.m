//
//  AppleEventManager.m
//  Bulkhead
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import "AppleEventManager.h"

@implementation AppleEventManager

+(void)load
{
    [AppleEventManager sharedAppleEventManager];
}

NSString *NSStringForOSType(OSType type) {
    unichar c[4];
    c[0] = (type >> 24) & 0xFF;
    c[1] = (type >> 16) & 0xFF;
    c[2] = (type >> 8) & 0xFF;
    c[3] = (type >> 0) & 0xFF;
    NSString *string = [NSString stringWithCharacters:c length:4];
    return string;
}

- (OSErr)dispatchRawAppleEvent:(const AppleEvent *)theAppleEvent withRawReply:(AppleEvent *)theReply handlerRefCon:(SRefCon)handlerRefCon {
    
    Size size =  AEGetDescDataSize(theAppleEvent);
    NSMutableData *data = [NSMutableData dataWithLength:size];
    AEGetDescData(theAppleEvent, data.mutableBytes, size);
    NSLog(@"data: %@", data);
    
    NSLog(@"currentAppleEvent: %@", NSStringForOSType(theAppleEvent->descriptorType));
    OSErr result = [super dispatchRawAppleEvent:theAppleEvent withRawReply:theReply handlerRefCon:handlerRefCon];
    return result;
}

@end
