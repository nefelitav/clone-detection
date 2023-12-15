package com.example;

/**
 
Hello world!**/

public class App
{
    public void f() {
        if (true) {
            int a=1;
            int b=2;
            int c=3;
        }
        int a=1;
        int b=2;
        int c=3;
    }
    public void g() {
        if (true) {
            int a=1;
            int b=2;
            int c=3;
        }
        int a=1;
        int b=2;
        int c=3;
    }
}

// Subtrees Algorithm
    // Clone type 1
        // We expect 7 clone pairs:
        // 1) body of f - body of g
        // 2) line 13 - line 17
        // 3) line 14 - line 18
        // 4) line 15 - line 19
        // 5) line 23 - line 27
        // 6) line 24 - line 28
        // 7) line 25 - line 29
        // It would be a mistake if we considered as duplicates lines e.g. 11-21, since they are subclones of the 1) clone
        // We expect 7 clone classes, since nothing is duplicated more than 1 time.
        // We expect biggest clone class in members to be 2, for the same reason as above.
        // We expect the biggest clone in lines to be 10, that's the whole body of f.
        // Duplicated lines are 20.
        
    // Clone type 2
        // We expect 31 clone pairs:
        // 1) body of f - body of g
        // 2) line 11 - line 12
        // 3) line 11 - line 13
        // 4) line 11 - line 15
        // 5) line 11 - line 16
        // 6) line 11 - line 17
        // 7) line 12 - line 13
        // 8) line 12 - line 14
        // 9) line 12 - line 15
        // 10) line 12 - line 16
        // 11) line 12 - line 17
        // 12) line 13 - line 15
        // 13) line 13 - line 16
        // 14) line 13 - line 17
        // 15) line 15 - line 16
        // 16) line 15 - line 17
        // 17) line 16 - line 17
        // 18) line 21 - line 22
        // 19) line 21 - line 23
        // 20) line 21 - line 25
        // 21) line 21 - line 26
        // 22) line 21 - line 27
        // 23) line 22 - line 23
        // 24) line 22 - line 25
        // 25) line 22 - line 26
        // 26) line 22 - line 27
        // 27) line 23 - line 25
        // 28) line 23 - line 26
        // 29) line 23 - line 27
        // 30) line 25 - line 26
        // 31) line 25 - line 27
        // number of clone pairs: 31
        // number of clone classes: 3
        // biggest clone class in members: 6
        // biggest clone in lines: 1
        // percentage of duplicated lines: 50%

// Sequences Algorithm
    // Clone type 1
        // We expect 3 clone pairs:
        // 1) body of f - body of g
        // 2) line 13 - line 17
        // 3) line 14 - line 18
        // 4) line 15 - line 19
        // 5) line 23 - line 27
        // 6) line 24 - line 28
        // 7) line 25 - line 29

        // number of clone pairs: 3
        // number of clone classes: 3
        // biggest clone class in members: 2
        // biggest clone in lines: 8
        // percentage of duplicated lines: 67%

// Clone type 2
    // We expect 3 clone pairs:
        // 1) body of f - body of g
        // 2) line 13 - line 17
        // 3) line 14 - line 18
        // 4) line 15 - line 19
        // 5) line 23 - line 27
        // 6) line 24 - line 28
        // 7) line 25 - line 29

        // number of clone pairs: 3
        // number of clone classes: 3
        // biggest clone class in members: 2
        // biggest clone in lines: 8
        // percentage of duplicated lines: 67%

// Project Lines: 24
// Duplicated Lines: 12

// Project Lines: 24
// Duplicated Lines: 16

// Project Lines: 24
// Duplicated Lines: 20

// Type 3 clones are not caught here, because it's small project and so if something is missing in an item compared to another, they go to different buckets
