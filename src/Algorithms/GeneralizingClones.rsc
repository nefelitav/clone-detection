module Algorithms::GeneralizingClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;

list[tuple[list[node], list[node]]] generalizeClones(loc projectLocation, list[tuple[list[node], list[node]]] clonePairs, int similarityThreshold) {
    list[Declaration] ast = getASTs(projectLocation);
    list[tuple[list[node], list[node]]] clonesToGeneralize = clonePairs;
    parentsOfClones = ();
    visit (ast) {
        case Statement s: {
            parentsOfClones[s] = getChildren(s);
        }
        case Declaration d: {
            parentsOfClones[d] = getChildren(d);
        }
    }
    // for(pair <- parentsOfClones) {
    //     println("<pair> <parentsOfClones[pair]>\n");
    // }
    // while(size(clonesToGeneralize) != 0) {
    //     for(pair <- clonePairs) { 
    //         clonesToGeneralize -= <pair[0], pair[1]>;
    //         if (!hasParent(pair.origin)) {
    //             continue;
    //         }
    //         if (compareClones(parentOf(pair[0]), parentOf(pair[1])) > similarityThreshold) {
    //             removeClonePair(clonePairs, pair[0], pair[1]);
    //             clonePairs = addClonePair(clonePairs, parentOf(pair[0]), parentOf(pair[1]));
    //             clonesToGeneralize = addClonePair(clonesToGeneralize, parentOf(pair[0]), parentOf(pair[1]));
    //         }
    //     }
    // }
    return clonesToGeneralize;
}

// int compareClones(list[node] i, list[node] j) {

// }

// list[tuple[list[node], list[node]]] addClonePair(list[tuple[list[node], list[node]]] clonePairs, list[node] i, list[node] j) {
//     clonePairs += <i, j>;
//     return clonePairs;
// }

// list[node] parentOf(list[node] i) {

// }

// removeClonePair(list[tuple[list[node], list[node]]] clonePairs, list[node] i, list[node] j) {

// }
