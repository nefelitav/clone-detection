module Algorithms::GeneralizingClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;

// list[tuple[list[node], list[node]]] generalizeClones(list[tuple[list[node], list[node]]] clonePairs, int similarityThreshold) {
//     list[tuple[list[node], list[node]]] clonesToGeneralize = clonePairs;
//     while(clonesToGeneralize != null) {
//         for(pair <- clonePairs) { 
//             clonesToGeneralize -= <pair[0], pair[1]>;
//             if (compareClones(parentOf(i), parentOf(j)) > similarityThreshold) {
//                 removeClonePair(clonePairs,i,j);
//                 addClonePair(clonePairs, parentOf(i), parentOf(j));
//                 addClonePair(clonesToGeneralize, parentOf(i),parentOf(j));
//             }
//         }
//     }
//     return clonesToGeneralize;
// }