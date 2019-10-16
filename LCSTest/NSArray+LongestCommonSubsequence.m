//
//  NSArray+LongestCommonSubsequence.m
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import "NSArray+LongestCommonSubsequence.h"

@implementation NSArray (LCS)

-(NSArray*)longestCommonSubsequence:(NSArray*)anArray {
    NSArray *a = self;
    NSArray *b = anArray;
    NSInteger n = a.count;
    NSInteger m = b.count;
    NSInteger i, j, k, t;
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
//    *s = malloc(t);
    for (i = n, j = m, k = t - 1; k >= 0;) {
        if (a[i - 1] == b[j - 1]) {
            s[t - 1 - k] = a[i - 1];
            i--;
            j--;
            k--;
        }
        else if (c[i][j - 1] > c[i - 1][j])
        {
            j--;
        }
        else
        {
            i--;
        }
    }
    free(c);
    free(z);
    return s.reverseObjectEnumerator.allObjects;
}


@end
