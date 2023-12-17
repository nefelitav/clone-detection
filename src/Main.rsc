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

    loc projectLocation = |project://TestProject|;
    // loc projectLocation = |project://smallsql0.21_src|;
    // loc projectLocation = |project://hsqldb-2.3.1|;
    int cloneType = 1;
    

    // int massThreshold = 6; // for smallsql
    int massThreshold = 4; // for TestProject
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, classes, cloneVisualLocation, cloneVisualLines> = findSubtreeClones(projectLocation, cloneType, massThreshold, false);
    list[map[str, value]] cloneData = [("classes": classes)];  
    writeJSON(|cwd:///results//Tree/VisualLocation.json|, cloneVisualLocation, indent=1);
    writeJSON(|cwd:///results//Tree/VisualLines.json|, cloneVisualLines, indent=1);

    // // int minimumSequenceLengthThreshold = 6; // for smallsql
    int minimumSequenceLengthThreshold = 3; // for TestProject
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, clonePairs, cloneVisualLocation, cloneVisualLines> = findSequenceClones(projectLocation, cloneType, minimumSequenceLengthThreshold, true);
    writeJSON(|cwd:///results//Seq/VisualLocation.json|, cloneVisualLocation, indent=1);
    writeJSON(|cwd:///results//Seq/VisualLines.json|, cloneVisualLines, indent=1);

    datetime end = now();
    interval runTime = createInterval(begin, end);
    print("Total Duration: \<years, months, days, hours, minutes, seconds, milliseconds\>: ");
    println("<createDuration(runTime)>\n");
}
