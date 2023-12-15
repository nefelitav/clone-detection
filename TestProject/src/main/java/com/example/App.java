package com.example;

/**
 * Hello world!
 *
 */

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

    // public void h() {
    //     while(1) {
    //         System.out.println("hello");
    //     }
    // }
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
    // Lines e.g. 13-23 are a subclone of the first clone, so we dont want it.
    // We expect 7 clone classes:

    // Clone type 2
    // We expect 7 clone pairs:
    // 1) body of f - body of g
    // 2) line 13 - line 17
    // 3) line 14 - line 18
    // 4) line 15 - line 19
    // 5) line 23 - line 27
    // 6) line 24 - line 28
    // 7) line 25 - line 29
