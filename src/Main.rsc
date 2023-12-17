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

    // loc projectLocation = |project://TestProject|;
    loc projectLocation = |project://smallsql0.21_src|;
    // loc projectLocation = |project://hsqldb-2.3.1|;
    int cloneType = 1;
    

    // int massThreshold = 6; // for smallsql
    int massThreshold = 4; // for TestProject
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, classes, cloneVisualLocation, cloneVisualLines> = findSubtreeClones(projectLocation, cloneType, massThreshold, false);
    list[map[str, value]] cloneData = [("classes": classes)];  
    writeJSON(|cwd:///results/TestProject/Tree_4_Typ3_Ours/Clones.json|, cloneData, indent=1);
    writeJSON(|cwd:///results/TestProject/Tree_4_Typ3_Ours/VisualLocation.json|, cloneVisualLocation, indent=1);
    writeJSON(|cwd:///results/TestProject/Tree_4_Typ3_Ours/VisualLines.json|, cloneVisualLines, indent=1);

    // int minimumSequenceLengthThreshold = 6; // for smallsql
    int minimumSequenceLengthThreshold = 3; // for TestProject
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, clonePairs, cloneVisualLocation, cloneVisualLines> = findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold, true);
    writeJSON(|cwd:///results/TestProject/Seq_3_Typ3/Clones.json|, clonePairs, indent=1);
    writeJSON(|cwd:///results/TestProject/Seq_3_Typ3/VisualLocation.json|, cloneVisualLocation, indent=1);
    writeJSON(|cwd:///results/TestProject/Seq_3_Typ3/VisualLines.json|, cloneVisualLines, indent=1);


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
