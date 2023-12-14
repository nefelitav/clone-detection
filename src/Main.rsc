module Main

import IO;
import DateTime;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;
import Algorithms::GeneralizeClones;

void main() {
    datetime begin = now();
    // println(printTime(now(), "HH:mm:ss"));

    loc projectLocation = |project://TestProject|;
    // loc projectLocation = |project://smallsql0.21_src|;
    // loc projectLocation = |project://hsqldb-2.3.1|;
    int cloneType = 1;
    
    // int massThreshold = 6; // for smallsql
    int massThreshold = 4; // for TestProject
    findSubtreeClones(projectLocation, cloneType, massThreshold, true);

    // int minimumSequenceLengthThreshold = 6; // for smallsql
    // int minimumSequenceLengthThreshold = 4; // for TestProject
    // findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold, true);

    // list[tuple[node, int]] biggestClassesMembers = get5BiggestSubtreeCloneClassesInMembers(clonePairs);
    // list[tuple[node, int]] biggestClonesLines = get5BiggestSubtreeClonesInLines(clonePairs);
    // println(biggestClassesMembers);
    // println(biggestClonesLines);
    // exportData(numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, biggestClassesMembers, biggestClonesLines, "subtreeClones");

    // list[tuple[node, int]] biggestClassesMembers = get5BiggestSubtreeCloneClassesInMembers(clonePairs);
    // list[tuple[node, int]] biggestClonesLines = get5BiggestSubtreeClonesInLines(clonePairs);
    // exportData(numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, biggestClassesMembers, biggestClonesLines, "subtreeClones");   

    datetime end = now();
    interval runTime = createInterval(begin, end);
    print("Total Duration: \<years, months, days, hours, minutes, seconds, milliseconds\>: ");
    println("<createDuration(runTime)>\n");
}
