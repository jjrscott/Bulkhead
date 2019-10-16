//
//  NSArray+LongestCommonSubsequence.m
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import "NSArray+LongestCommonSubsequence.h"

NSString *NSStringFromDiff(Diff action) {
    switch (action) {
        case DiffEqual: return @"equal";
        case DiffAddition: return @"addition";
        case DiffDeletion: return @"deletion";
    }
    return nil;
}

@interface ElementAction (Private)

@property (nonatomic, assign, readwrite) Diff action;
@property (nonatomic, strong, readwrite) id element;

-(instancetype)initWithAction:(Diff)action element:(id)element;

@end

@implementation NSArray (LCS)

-(NSArray<ElementAction*>*)longestCommonSubsequence:(NSArray*)anArray {
    NSArray *a = anArray;
    NSArray *b = self;
    NSInteger n = a.count;
    NSInteger m = b.count;
    NSInteger i, j, t;
    NSInteger *z = calloc((n + 1) * (m + 1), sizeof (NSInteger));
    NSInteger **c = calloc((n + 1), sizeof (NSInteger *));
    for (i = 0; i <= n; i++) {
        c[i] = &z[i * (m + 1)];
    }
    for (i = 1; i <= n; i++) {
        for (j = 1; j <= m; j++) {
            if ([a[i - 1] isEqual:b[j - 1]]) {
                c[i][j] = c[i - 1][j - 1] + 1;
            }
            else {
                c[i][j] = MAX(c[i - 1][j], c[i][j - 1]);
            }
        }
    }
    t = c[n][m];
    
    NSMutableArray *s = [NSMutableArray new];

    for (i = n, j = m; i > 0 && j > 0;) {
        NSLog(@"%ld - %ld", (long)i, (long)j);
        if (a[i - 1] == b[j - 1]) {
            [s addObject:[[ElementAction alloc] initWithAction:DiffEqual element:a[i - 1]]];
            i--;
            j--;
        }
        else if (c[i][j - 1] <= c[i - 1][j])
        {
            [s addObject:[[ElementAction alloc] initWithAction:DiffAddition element:a[i - 1]]];
            i--;
        }
        else
        {
            [s addObject:[[ElementAction alloc] initWithAction:DiffDeletion element:b[j - 1]]];
            j--;
        }
    }
    while (i > 0) {
        NSLog(@"%ld -  ", (long)i);
        [s addObject:[[ElementAction alloc] initWithAction:DiffAddition element:a[i - 1]]];
        i--;
    }
    
    while (j > 0) {
        NSLog(@"  - %ld", (long)j);
        [s addObject:[[ElementAction alloc] initWithAction:DiffDeletion element:b[j - 1]]];
        j--;
    }
    
    free(c);
    free(z);
    return s.reverseObjectEnumerator.allObjects;
}

@end

@implementation ElementAction

- (instancetype)initWithAction:(Diff)action element:(id)element {
    self = [super init];
    if (self) {
        _action = action;
        _element = element;
    }
    return self;
}

#if DEBUG
- (BOOL) isNSDictionary__
{
    return YES;
}
#endif

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
{
    return [NSString stringWithFormat:@"%@ {action = %@, element = %@}", super.description, NSStringFromDiff(_action), _element];
}

@end
