module Main

import IO;
import DateTime;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;
import Algorithms::GeneralizeClones;


void main() {
    println(printTime(now(), "HH:mm:ss"));

    loc projectLocation = |project://TestProject|;
    // loc projectLocation = |project://smallsql0.21_src|;
    int cloneType = 1;
    
    int massThreshold = 6;
    findSubtreeClones(projectLocation, cloneType, massThreshold, false);
    println(printTime(now(), "HH:mm:ss"));

    // println("\n");
    // int minimumSequenceLengthThreshold = 3;
    // findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold, false);

    // list[tuple[node, int]] biggestClassesMembers = get5BiggestSubtreeCloneClassesInMembers(clonePairs);
    // list[tuple[node, int]] biggestClonesLines = get5BiggestSubtreeClonesInLines(clonePairs);
    // println(biggestClassesMembers);
    // println(biggestClonesLines);
    // exportData(numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, biggestClassesMembers, biggestClonesLines, "subtreeClones");

    // list[tuple[node, int]] biggestClassesMembers = get5BiggestSubtreeCloneClassesInMembers(clonePairs);
    // list[tuple[node, int]] biggestClonesLines = get5BiggestSubtreeClonesInLines(clonePairs);
    // exportData(numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, biggestClassesMembers, biggestClonesLines, "subtreeClones");   

}
