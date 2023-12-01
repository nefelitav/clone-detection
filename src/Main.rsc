module Main

import IO;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;

void main() {
    loc projectLocation = |project://TestProject|;
    int cloneType = 1;
    int massThreshold = 6;
    findSubtreeClones(projectLocation, cloneType, massThreshold);

    int minimumSequenceLengthThreshold = 2;
    findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold);
}
