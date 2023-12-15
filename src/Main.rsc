module Main

import IO;
import DateTime;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;
import Algorithms::GeneralizeClones;
import util::Math;
import lang::json::IO;

void main() {
    datetime begin = now();
    // println(printTime(now(), "HH:mm:ss"));

    loc projectLocation = |project://TestProject|;
//     loc projectLocation = |project://smallsql0.21_src|;
    // loc projectLocation = |project://hsqldb-2.3.1|;
    int cloneType = 1;
    
//     int massThreshold = 6; // for smallsql
    int massThreshold = 4; // for TestProject

    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, classes> = findSubtreeClones(projectLocation, cloneType, massThreshold, false);
//     println(classes);
//     list[map[str, value]] cloneData = [("classes": classes)];  
//     writeJSON(|cwd:///results/Subtree_Type1_Smallsql.json|, cloneData, indent=1);

//     int minimumSequenceLengthThreshold = 6; // for smallsql
    // int minimumSequenceLengthThreshold = 3; // for TestProject
    // findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold, false);
            // writeJSON(|cwd:///results/Sequence_Type1_Smallsql.json|, cloneData, indent=1);
            // writeJSON(|cwd:///results/Sequence_Type1_TestProject.json|, cloneData, indent=1);

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
