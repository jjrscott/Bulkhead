//
//  main.m
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArray+LongestCommonSubsequence.h"
#import "NSString+ComposedCharacterSequences.h"

int main () {
    NSArray *a = @[@"Hello", @"World"];
    NSArray *b = @[@"Big", @"World"];

    NSLog(@"a: %@", a);
    NSLog(@"b: %@", b);
    
    
    
    NSLog(@"%@", [a longestCommonSubsequence:b] );
    
    
    return 0;
}

