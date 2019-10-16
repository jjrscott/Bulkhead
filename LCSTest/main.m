//
//  main.m
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdio.h>
#include <stdlib.h>
#import "NSArray+LongestCommonSubsequence.h"
#import "NSString+ComposedCharacterSequences.h"

int lcs (char *a, int n, char *b, int m, char **s) {
    int i, j, k, t;
    int *z = calloc((n + 1) * (m + 1), sizeof (int));
    int **c = calloc((n + 1), sizeof (int *));
    for (i = 0; i <= n; i++) {
        c[i] = &z[i * (m + 1)];
    }
    for (i = 1; i <= n; i++) {
        for (j = 1; j <= m; j++) {
            if (a[i - 1] == b[j - 1]) {
                c[i][j] = c[i - 1][j - 1] + 1;
            }
            else {
                c[i][j] = MAX(c[i - 1][j], c[i][j - 1]);
            }
        }
    }
    t = c[n][m];
    *s = malloc(t);
    for (i = n, j = m, k = t - 1; k >= 0;) {
        if (a[i - 1] == b[j - 1]) {
            (*s)[k] = a[i - 1];
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
    return t;
}

int main () {
    NSString *a = @"thisisatest";
    NSString *b = @"testing123testing";

    NSLog(@"a: %@", a);
    NSLog(@"b: %@", b);

    NSLog(@"%@", [[[a composedCharacterSequences] longestCommonSubsequence:[b composedCharacterSequences]] componentsJoinedByString:@""]);
    
    
    return 0;
}

