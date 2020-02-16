//
//  main.m
//  Shell
//
//  Created by John Scott on 07/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UTType+ObjC.h"

#import "NSArray+LongestCommonSubsequence.h"
#import "NSString+ComposedCharacterSequences.h"
#import "NSFileManager+DirectoryContents.h"
#import "NSTask+Execution.h"

void Print(NSString *format, ...)
{
    va_list argList;
    va_start(argList, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    puts(string.UTF8String);
}

void Conforms(NSString *uti, NSMutableArray *parentUTIs) {
    
    [parentUTIs addObject:uti];
    NSArray *parentUtis = [UTType copyDeclarationInUTI:uti][(__bridge id)kUTTypeConformsToKey];

    for (NSString* parentUti in parentUtis) {
        Conforms(parentUti, parentUTIs);
    }
}

@interface Foo : NSObject

@end

@implementation Foo

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *localPath = [NSUserDefaults.standardUserDefaults stringForKey:@"local"];
        NSString *remotePath = [NSUserDefaults.standardUserDefaults stringForKey:@"remote"];
        
        if (!localPath && !remotePath)
        {
            Print(@"%@ -local <local-file> -remote <remote-file> [-gui YES]", NSProcessInfo.processInfo.arguments[0].lastPathComponent);
            return 1;
        }

        BOOL shouldLaunchGUI = [NSUserDefaults.standardUserDefaults boolForKey:@"gui"];
        
        NSMutableArray *localPathUTIs = [NSMutableArray new];
        Conforms([UTType createPreferredIdentifierForTagInTagClass:UTTagClassFilenameExtension
                                                             inTag:localPath.pathExtension
                                                 inConformingToUTI:nil], localPathUTIs);
        
        NSMutableArray *remotePathUTIs = [NSMutableArray new];
        Conforms([UTType createPreferredIdentifierForTagInTagClass:UTTagClassFilenameExtension
                                                             inTag:remotePath.pathExtension
                                                 inConformingToUTI:nil], remotePathUTIs);
        
//        Print(@"localPathUTIs: %@", localPathUTIs);
//        Print(@"remotePathUTIs: %@", remotePathUTIs);
        
        NSArray <Patch<NSString*>*>* commonUTIs = [localPathUTIs longestCommonSubsequence:remotePathUTIs];
        
//        Print(@"%@",  commonUTIs);
        
        NSString *diffToolsPath = [[NSBundle bundleForClass:Foo.class] pathForResource:@"DiffTools" ofType:nil];
//        Print(@"DiffTools: %@",  foo);
        NSDictionary <NSString*,NSString*> *availableScripts = [NSFileManager.defaultManager mappedContentsOfDirectoryAtPath:diffToolsPath
                                                                                                                       error:NULL];
        
//        Print(@"availableScripts: %@", availableScripts);
        
        for (Patch<NSString*>*commonUTI in commonUTIs)
        {
            if ([commonUTI.left isEqual:commonUTI.right] && availableScripts[commonUTI.left]) {
//                Print(@"%@ : %@", commonUTI.element, availableScripts[commonUTI.element]);
                
                NSMutableArray *arguments = [NSMutableArray new];
                [arguments addObject:localPath];
                [arguments addObject:remotePath];
                
                NSData *standardOutput = nil;
                NSData *standardError = nil;
                NSError *error = nil;
                [NSTask executeTaskWithExecutableURL:[NSURL fileURLWithPath:availableScripts[commonUTI.left]]
                                           arguments:arguments
                                       standardInput:nil
                                      standardOutput:&standardOutput
                                       standardError:&standardError
                                               error:&error];
                
                if (shouldLaunchGUI) {
                    NSURL *temporaryURL = [[NSFileManager.defaultManager.temporaryDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:@".bulkhead"];

                    [standardOutput writeToURL:temporaryURL atomically:YES];

                    [NSTask executeTaskWithExecutableURL:[NSURL fileURLWithPath:@"/usr/bin/open"]
                                               arguments:@[@"-b", @"com.jjrscott.bulkhead", temporaryURL.path]
                                           standardInput:standardOutput
                                          standardOutput:nil
                                           standardError:nil
                                                   error:&error];
                } else {
                    Print(@"%@", [[NSString alloc] initWithData:standardOutput encoding:NSUTF8StringEncoding]);
                }
                
                return 0;
            }
        }
    }
    return 1;
}

