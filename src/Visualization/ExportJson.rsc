module Visualization::ExportJson

import List;
import Map;
import Set;
import IO;

import Algorithms::SequenceClones;
import Algorithms::SubtreeClones;

import util::Math;
import lang::json::IO;

void exportData(int pairs, int classesNum, int duplicatedLines, map[node, set[node]] classes) {
    list[tuple[loc biggestClass, int members]] biggestClassesMembers = get5BiggestSubtreeCloneClassesInMembers(classes);
    list[tuple[loc biggestClass, int lines]] biggestClonesLines = get5BiggestSubtreeClonesInLines(classes);
    map[str, value] cloneData =
        (
             "pairs": pairs,
             "classes": classesNum,
             "biggestLines": (
                "numbers": biggestClonesLines.lines, 
                "classes": biggestClonesLines.biggestClass
             ),
             "biggestMembers": (
                "numbers": biggestClassesMembers.members,
                "classes": biggestClassesMembers.biggestClass
             ),
             "duplicatedLines": duplicatedLines
        );

    writeJSON(|cwd:///clone-visualization/data.json|, cloneData, indent=1);
}