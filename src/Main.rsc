module Main

import IO;
import DateTime;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;
import Algorithms::GeneralizeClones;
import util::Math;
import lang::json::IO;
import Lib::Statistics;
void main() {
    datetime begin = now();
    // println(printTime(now(), "HH:mm:ss"));

    // loc projectLocation = |project://TestProject|;
    loc projectLocation = |project://smallsql0.21_src|;
    // loc projectLocation = |project://hsqldb-2.3.1|;
    int cloneType = 1;
    
    int massThreshold = 6; // for smallsql
    // int massThreshold = 4; // for TestProject
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, classes, cloneVisualLocation, cloneVisualLines> = findSubtreeClones(projectLocation, cloneType, massThreshold, true);
// //     println(classes);
    // list[map[str, value]] cloneData = [("classes": classes)];  
    // writeJSON(|cwd:///results/Tree_6_Typ2/Tree_6_Typ2.json|, cloneData, indent=1);
    // writeJSON(|cwd:///results/Tree_6_Typ2/VisualLocation_Tree_6_Typ2.json|, cloneVisualLocation, indent=1);
    // writeJSON(|cwd:///results/Tree_6_Typ2/VisualLines_Tree_6_Typ2.json|, cloneVisualLines, indent=1);

    // int minimumSequenceLengthThreshold = 6; // for smallsql
    // int minimumSequenceLengthThreshold = 3; // for TestProject
    // <clonePairs, cloneVisualLocation, cloneVisualLines> = findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold, false);
    // writeJSON(|cwd:///results/Seq_6_Typ1_Gen/Seq_6_Typ1_Gen.json|, clonePairs, indent=1);
    // writeJSON(|cwd:///results/Seq_6_Typ1_Gen/VisualLocation_Seq_6_Typ1_Gen.json|, cloneVisualLocation, indent=1);
    // writeJSON(|cwd:///results/Seq_6_Typ1_Gen/VisualLines_Seq_6_Typ1_Gen.json|, cloneVisualLines, indent=1);


            // writeJSON(|cwd:///results/Sequence_Type1_Smallsql.json|, cloneData, indent=1);
            // writeJSON(|cwd:///results/Sequence_Type1_TestProject.json|, cloneData, indent=1);
    // writeJSON(|cwd:///results/VisualLocation.json|, cloneVisualLocation, indent=1);
    // writeJSON(|cwd:///results/VisualLines.json|, cloneVisualLines, indent=1);
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
