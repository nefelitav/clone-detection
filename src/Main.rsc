module Main

import IO;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;

void main() {
    loc projectLocation = |project://TestProject|;
    int cloneType = 2;
    
    int massThreshold = 6;
    findSubtreeClones(projectLocation, cloneType, massThreshold);

    println("\n");
    int minimumSequenceLengthThreshold = 2;
    findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold);
}
