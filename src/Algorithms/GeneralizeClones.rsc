module Algorithms::GeneralizeClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import Set;
import util::Math;
import DateTime;
import Algorithms::SubtreeClones;
import Algorithms::SequenceClones;

/*
    arguments: clonePairs, childrenOfParents struct, similarityThreshold
    generalizes all clone pairs, by comparing their parents
    if the parents are similar they are added to the clones and their children are removed
    this function is for the subtree clones
*/
set[tuple[node, node]] generalizeClones(set[tuple[node, node]] clonePairs, map[node, list[value]] childrenOfParents, real similarityThreshold, int massThreshold) {
    set[tuple[node, node]] clonesToGeneralize = clonePairs;
    while (size(clonesToGeneralize) != 0) {
        for (pair <- clonesToGeneralize) {
            clonesToGeneralize -= pair;
            list[node] parents0 = parentsOf(pair[0], childrenOfParents);
            list[node] parents1 = parentsOf(pair[1], childrenOfParents);

            for (i <- parents0, j <- parents1) {
                if (i != j) {
                    if (compareTree(i, j, massThreshold) >= similarityThreshold) {
                        clonePairs -= pair;
                        addSubtreeClone(clonePairs, i, j, massThreshold);
                        addSubtreeClone(clonesToGeneralize, i, j, massThreshold);
                    }
                }
            }
        }
    }
    return clonePairs;
}

/*
    arguments: clonePairs, childrenOfParents struct, similarityThreshold
    generalizes all clone pairs, by comparing their parents
    if the parents are similar they are added to the clones and their children are removed
    this function is for the sequence clones
*/
list[tuple[list[node], list[node]]] generalizeClones(list[tuple[list[node], list[node]]] clonePairs, map[list[node], list[value]] childrenOfParents, real similarityThreshold) {
    list[tuple[list[node], list[node]]] clonesToGeneralize = clonePairs;
    while (size(clonesToGeneralize) != 0) {
        for (pair <- clonesToGeneralize) {
            clonesToGeneralize -= pair;
            list[list[node]] parents0 = parentsOf(pair[0], childrenOfParents);
            list[list[node]] parents1 = parentsOf(pair[1], childrenOfParents);
            for (i <- parents0, j <- parents1) {
                if (i != j) {
                    if (compareSequences(i, j) >= similarityThreshold) {
                        clonePairs -= pair;
                        addSequenceClone(clonePairs, i, j);
                        addSequenceClone(clonesToGeneralize, i, j);
                    }
                }
           }
        }
    }
    return clonePairs;
}

/*
    arguments: child node, childrenOfParents struct
    searches for the parent of the child
    if it is not found, returns something random, like "null"(0)
*/
list[node] parentsOf(node child, map[node, list[value]] childrenOfParents) {
    list[node] parents = [];
    for (parent <- childrenOfParents) {
        if (child in childrenOfParents[parent]) {
            parents += parent;
        }
    }
    return parents;
}

/*
    arguments: sequence, childrenOfParents struct
    searches for the parent of the sequence
    if it is not found, returns empty list
*/
list[list[node]] parentsOf(list[node] child, map[list[node], list[value]] childrenOfParents) {
    list[list[node]] parents = [];
    for (parent <- childrenOfParents) {
        if (child <= childrenOfParents[parent]) {
            parents += parent;
        }
    }
    return parents;
}