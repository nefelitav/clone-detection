package com.example;

/**
 * Hello world!
 *
 */

public class App
{
    // clone type 1 - we expect 3 clone pairs:
    // 1) body of f - body of g
    // 2) -
    // 3) - 
    // - are not pairs because they are subclones of the first clone pair

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
