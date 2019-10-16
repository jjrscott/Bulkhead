//
//  NSArray+LongestCommonSubsequence.h
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, Diff) {
    DiffEqual,
    DiffAddition,
    DiffDeletion,
};

NSString *NSStringFromDiff(Diff action);

@interface ElementAction<Element> : NSObject;

@property (nonatomic, assign, readonly) Diff action;
@property (nonatomic, strong, readonly) Element element;

@end

@interface NSArray<Element> (LCS)

-(NSArray<ElementAction<Element>*>*)longestCommonSubsequence:(NSArray*)anArray;

@end
