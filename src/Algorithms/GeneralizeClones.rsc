module Algorithms::GeneralizeClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;
import DateTime;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;


list[tuple[node, node]] generalizeClones(list[tuple[node, node]] clonePairs, map[node, list[value]] childrenOfParents, real similarityThreshold) {
    list[tuple[node, node]] clonesToGeneralize = clonePairs;
    while (size(clonesToGeneralize) != 0) {
        for (pair <- clonesToGeneralize) {
            clonesToGeneralize -= pair;
            node parentOf0 = parentOf(pair[0], childrenOfParents);
            if (parentOf0 != "null"(0)) {
                node parentOf1 = parentOf(pair[1], childrenOfParents);
                if (parentOf1 != "null"(0)) {
                    if (compareTree(parentOf0, parentOf1) >= similarityThreshold) {
                        clonePairs -= pair;
                        addSubtreeClone(clonePairs, parentOf0, parentOf1);
                        addSubtreeClone(clonesToGeneralize, parentOf0, parentOf1);
                    }
                }
            }
        }
    }
    return clonePairs;
}

list[tuple[list[node], list[node]]] generalizeClones(list[tuple[list[node], list[node]]] clonePairs, map[list[node], list[value]] childrenOfParents, real similarityThreshold) {
    list[tuple[list[node], list[node]]] clonesToGeneralize = clonePairs;
    while (size(clonesToGeneralize) != 0) {
        for (pair <- clonesToGeneralize) {
            clonesToGeneralize -= pair;
            list[node] parentOf0 = parentOf(pair[0], childrenOfParents);
            if (parentOf0 != []) {
                list[node] parentOf1 = parentOf(pair[1], childrenOfParents);
                if (parentOf1 != []) {
                    if (compareSequences(parentOf0, parentOf1) >= similarityThreshold) {
                        clonePairs -= pair;
                        addSequenceClone(clonePairs, parentOf0, parentOf1);
                        addSequenceClone(clonesToGeneralize, parentOf0, parentOf1);
                    }
                }
            }
        }
    }
    return clonePairs;
}

node parentOf(node child, map[node, list[value]] childrenOfParents) {
    for (parent <- childrenOfParents) {
        if (child in childrenOfParents[parent]) {
            return parent;
        }
    }
    return "null"(0);
}

list[node] parentOf(list[node] child, map[list[node], list[value]] childrenOfParents) {
    for (parent <- childrenOfParents) {
        if (child <= childrenOfParents[parent]) {
            return parent;
        }
    }
    return [];
}