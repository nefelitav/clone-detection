module Main

import IO;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;
import DateTime;

void main() {
    println(printTime(now(), "HH:mm:ss"));

    // loc projectLocation = |project://TestProject|;
    loc projectLocation = |project://smallsql0.21_src|;
    int cloneType = 1;
    
    int massThreshold = 6;
    findSubtreeClones(projectLocation, cloneType, massThreshold);
    println(printTime(now(), "HH:mm:ss"));

    println("\n");
    int minimumSequenceLengthThreshold = 2;
    findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold);
}
