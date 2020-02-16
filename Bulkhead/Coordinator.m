//
//  Coordinator.m
//  Bulkhead
//
//  Created by John Scott on 16/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "Coordinator.h"

@implementation Coordinator

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

- (IBAction)installComandLineTools:(id)sender
{
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:@"/usr/local/bin/bulkhead"];
    
    [NSFileManager.defaultManager removeItemAtURL:url error:&error];
    
    NSLog(@"error: %@", error);
    error = nil;

    [NSFileManager.defaultManager createSymbolicLinkAtURL:url
                                       withDestinationURL:[NSBundle.mainBundle URLForAuxiliaryExecutable:@"Shell"]
                                                    error:&error];
    NSLog(@"error: %@", error);
}

@end
