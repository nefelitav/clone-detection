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

    // Clone type 2
        // We expect 31 clone pairs:
        // 1) body of f - body of g
        // 2) line 11 - line 12
        // 3) line 11 - line 13
        // 4) line 11 - line 15
        // 5) line 11 - line 16
        // 6) line 11 - line 17
        // 7) line 12 - line 13
        // 8) line 12 - line 15
        // 9) line 12 - line 16
        // 10) line 12 - line 17
        // 11) line 13 - line 15
        // 12) line 13 - line 16
        // 13) line 13 - line 17
        // 14) line 15 - line 16
        // 15) line 15 - line 17
        // 16) line 16 - line 17
        // 17) line 21 - line 22
        // 18) line 21 - line 23
        // 19) line 21 - line 25
        // 20) line 21 - line 26
        // 21) line 21 - line 27
        // 22) line 22 - line 23
        // 23) line 22 - line 25
        // 24) line 22 - line 26
        // 25) line 22 - line 27
        // 26) line 23 - line 25
        // 27) line 23 - line 26
        // 28) line 23 - line 27
        // 29) line 25 - line 26
        // 30) line 25 - line 27
        // 31) line 26 - line 27
        // It would be a mistake if we considered as duplicates lines e.g. 11-21, since they are subclones of the 1) clone
        // We expect 3 clone classes, one is the f/g function, one is one line from f, and one from g.
        // We expect biggest clone class in members to be 6, as shown above.
        // biggest clone in lines: 1 because the method has no src
        // Duplicated Lines: 12 (the if and the } do not count)

// Sequences Algorithm
    // Clone type 1
        // We expect 3 clone pairs:
        // 1) body of f - body of g
        // 2) 11-13 - 15-17
        // 3) 21-23 - 25-27
        // It would be a mistake if we considered as duplicates lines e.g. 11-13 with 21-23, since they are subclones of the 1) clone
        // We expect 3 clone classes, since nothing is duplicated more than 1 time.
        // We expect biggest clone class in members to be 2, for the same reason as above.
        // We expect the biggest clone in lines to be 8, that's the whole body of f.
        // Duplicated lines are 16.

// Clone type 2
        // same as for type 1 because methods are not captured in the blocks

// Type 3 clones are not caught here, because it's small project and so if something is missing in an item compared to another, they go to different buckets
