module Algorithms::SubtreeClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import Map;
import util::Math;
import DateTime;
import Algorithms::GeneralizeClones;
import Visualization::ExportJson;
import Set;
import Type;
import Boolean;
import String;

public map[node, set[node]] pair0Subtrees = ();
public map[node, set[node]] pair1Subtrees = ();
public map[node, set[node]] subtrees = ();
 
/////////////////////////
///   Main function   ///
/////////////////////////
/*
    arguments: projectLocation, cloneType (can be 1,2,3), massThreshold: (integer) small subtrees should be ignored, generalize: bool (whether we should also run the 3rd algorithm)
    - sets similarityThreshold: how similar do we want the clones to be
        - for type 1: we are looking for exact matches, so 1.0
        - for type 2: we are looking still for exact matches, but ignoring identifiers, so 1.0
        - for type 3: we are not looking for exact matches, lines of code can be added or removed, so 0.8
    - gets ASTs of the project 
    - normalize for clones of type 2 and 3 (Lib/Utilities.rsc/normalizeAST)
    - creates a hash table with the subtrees
    - finds clones comparing the subtrees of each bucket
    - prints statistics

*/
set[tuple[node, node]] findSubtreeClones(loc projectLocation, int cloneType, int massThreshold, bool generalize) {
    list[Declaration] ast = getASTs(projectLocation);
    if (cloneType != 1) {
        ast = toList(normalizeAST(toSet(ast)));
    }
    // Creating hash table
    println("Creating subTree HashTable:");
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();
    <hashTable, childrenOfParents> = createSubtreeHashTable(ast, massThreshold, generalize);
    println("Number of buckets: <size(hashTable)>");
    // for (p <- hashTable) {
    //     println("<hashTable[p]>\n");
    // }
    println("---\n");

    // Finding clone pairs
    println("Finding clonePairs:");
    set[tuple[node, node]] clonePairs = {};
    real similarityThreshold = 1.0;
    if (cloneType == 1) {
        clonePairs = findTypeIClonePairs(hashTable, massThreshold);
    } else {
        if (cloneType == 3) {
            similarityThreshold = 0.8;
        }
        clonePairs = findTypeII_III_ClonePairs(hashTable, similarityThreshold, massThreshold);
    }
    println("---\n");
    // for (p <- clonePairs) {
    //     println("<p>\n");
    // }
    if (generalize) {
        clonePairs = generalizeClones(clonePairs, childrenOfParents, similarityThreshold, massThreshold);
    }
    // for (p <- clonePairs) {
    //     println("<p>\n");
    // }
    // println(childrenOfParents);
    // Calculating statistics
    println("Calculating Statistics:");
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines> = getSubtreeStatistics(clonePairs, projectLocation);

    return clonePairs;
}

//////////////////////////////
///    Create Hash Table   ///
//////////////////////////////
/*
    arguments: ast, massThreshold, generalize: bool (whether we should also run the 3rd algorithm)
    visits tree and for every node:
    - checks if nodeMass >= massThreshold, so that we ignore small subtrees
    - hashes the "clean" node with md5Hash. Nodes get "cleaned" with unsetRec, so that method locations are ignored
    - the hash is the key for each bucket and the value is the node or a normalized version of the node, if cloneType is 2 or 3
    - this way, clones end up in the same bucket and can easily and quickly be compared with each other
    - finally, returns hashTable and childrenOfParents struct(useful for the third algorithm). we get the children of every node in a map 
    - for that we take extra care, because sometimes the getChildren function returns a list inside a list, so we need to take the nested one
*/
tuple[map[str, list[node]], map[node, list[value]]] createSubtreeHashTable(list[Declaration] ast, int massThreshold, bool generalize) {
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();
    visit (ast) {
        case node n: {
            if (generalize) {
                list[value] children = getChildren(n);
                str childrenString = toString(children);
                if (startsWith(childrenString, "[[")) {
                    childrenOfParents[n] = children[0];
                } else {
                    childrenOfParents[n] = getChildren(n);
                }
            }
            if (subtreeMass(unsetRec(n)) >= massThreshold) {
                // an alternative way to hash nodes, by hashing all their children, concatenating their hashes and hashing once again
                // list[node] tohash = [];
                // for (node child <- n) {
                //     tohash += unsetRec(child);
                // }
                // str hash = md5Hash(toString(tohash));
                str hash = md5Hash(unsetRec(n));
                if (hash in hashTable) {
                    hashTable[hash] += n;
                } else {
                    hashTable[hash] = [n];
                }
            }
        }
    }
    return <hashTable, childrenOfParents>;
}

/////////////////////////
///    Find Clones    ///
/////////////////////////
/*
    arguments: hashTable, massThreshold
    for every bucket:
    - get a pair of subtrees:
        - ensure we are not comparing the same subtree with itself and also the flipped ones, because that would be a waste of time
        - for two subtrees to be in the same bucket, and since we are looking for clones of type 1, the subtrees must be equal
        - we get prepared to add the clone to our struct, checking first that we can add it
*/
set[tuple[node, node]] findTypeIClonePairs(map[str, list[node]] hashTable, int massThreshold) {
    set[tuple[node, node]] clones = {};
    int c=0;
	for (bucket <- hashTable) {	
        c+=1;
        list[node] nodes = hashTable[bucket];
        for (i <- [0 .. size(nodes) - 1], j <- [i+1 .. size(nodes)]) {
            println("<c> of <size(hashTable)>, size: <size(nodes)>, <i> of <j>");
            clones = addSubtreeClone(clones, nodes[i], nodes[j], massThreshold);
        }
    }
    return clones;
}

/*
    arguments: hashTable, similarityThreshold, massThreshold
    for every bucket:
    - get a pair of subtrees:
        - ensure we are not comparing the same subtree with itself and also the flipped ones, because that would be a waste of time
        - compare it using the compareTree function that checks for similarity between nodes, to see if they are clones
        - we check if the comparison result is over the similarityThreshold 
        - we cache the comparison result, so that we do not have to calculate it every time we meet the same pair or the flipped one
            - we use a struct of map[list[str], real] type, and the reason for using list, is so that order doesn't matter
            - and so we dont have to check also if the flipped one is in the struct
        - we get prepared to add the clone to our struct, checking first that we can add it
*/
set[tuple[node, node]] findTypeII_III_ClonePairs(map[str, list[node]] hashTable, real similarityThreshold, int massThreshold) {
    set[tuple[node, node]] clones = {};
    map[list[str], real] similarities = ();
    real comparison = 0.0;
    int c=0;
	for (bucket <- hashTable) {	
        c+=1;
        list[node] nodes = hashTable[bucket];
        for (i <- [0 .. size(hashTable[bucket]) - 1], j <- [i+1 .. size(hashTable[bucket])]) {
            println("<c> of <size(hashTable)>, size: <size(nodes)>, <i> of <j>");
            list[str] ij = [toString(i), toString(j)];

            if (ij in similarities) {
                comparison = similarities[ij];
            } else {
                comparison = compareTree(nodes[i], nodes[j], massThreshold);
                similarities[ij] = comparison;
            } 

            if (comparison >= similarityThreshold) {
                clones = addSubtreeClone(clones, nodes[i], nodes[j], massThreshold);
            }
        }
    }
    return clones;
}

/*
    arguments: two subtrees, massThreshold
    - visits the two subtrees and counts the number of nodes they have
    - finds shared nodes of the two subtrees, "cleaning" the nodes with unsetRec, 
    so that method locations and other useless informations are ignored
    - also the identifiers are already normalized, since this function is only used for near-misses
    - calculates:
        Similarity = 2 x S / (2 x S + L + R)
        where:
        S = number of shared nodes
        L = number of different nodes in sub-tree 1
        R = number of different nodes in sub-tree 2
    - if the two subtress are identical, it will return 1.0, otherwise a value between 0.0 and 1.0
*/
real compareTree(node node1, node node2, int massThreshold) {
    subtree1Nodes = getSubtreeNodesUnsetRec(node1, massThreshold);
    subtree2Nodes = getSubtreeNodesUnsetRec(node2, massThreshold);
	real sharedNodes = toReal(size(subtree1Nodes & subtree2Nodes));
    real subtree1NodesNumber = toReal(size(subtree1Nodes - subtree2Nodes));
    real subtree2NodesNumber = toReal(size(subtree2Nodes - subtree1Nodes));
	return 2.0 * sharedNodes / (2.0 * sharedNodes + subtree1NodesNumber + subtree2NodesNumber);
} 

///////////////////////////////////////////////////
///    Remove subclones. Do not add subclones   ///
///////////////////////////////////////////////////
/*
    arguments: clones, a pair of subtrees, massThreshold
    - adds subtrees to the clones struct
    - if the flipped pair is not already in the struct
    - if the one subtree isnt a sunclone of the other one
    - if they are not subclones of already existent clones
    - removes subclones of the pair that might exist in the clones struct
    - all in all, we ensure that we only add the biggest subtrees in the clones struct
    - and we do not have duplicates
    - also, we cache the subtree nodes in global variables, which saves us a lot of time
*/
set[tuple[node, node]] addSubtreeClone(set[tuple[node, node]] clones, node i, node j, int massThreshold) {
    if (<j,i> in clones || isSubset(i, j) || isSubset(j, i)) {
        return clones;
    }
    if (i notin subtrees) {
        subtrees[i] = getSubtreeNodes(i, massThreshold);
    }
    if (j notin subtrees) {
        subtrees[j] = getSubtreeNodes(j, massThreshold);
    }
    set[tuple[node, node]] toRemove = {};
    set[node] ijSubtrees = subtrees[i] + subtrees[j];
    for (pair <- clones) {
        if (pair[0] in ijSubtrees || pair[1] in ijSubtrees) {
            toRemove += pair;
        }
    }
    // for (oldPair <- clones) {
    //     // CORRECT VERSION - NOT BASED ON PAPER
    //     // if it's a subclone of an existing one, dont add it
    //     if ((i in pair0Subtrees[oldPair[0]] && j in pair1Subtrees[oldPair[1]]) || (i in pair1Subtrees[oldPair[1]] && j in pair0Subtrees[oldPair[0]])) {
    //         return clones;
    //     }
    //     // remove subclones
    //     if ((oldPair[0] in subtrees[i] && oldPair[1] in subtrees[j]) || (oldPair[0] in subtrees[j] && oldPair[1] in subtrees[i])) {
    //         toRemove += oldPair;
    //     }
    // }
    // pair0Subtrees[i] = subtrees[i];
    // pair1Subtrees[j] = subtrees[j];
    clones -= toRemove;
    clones += <i, j>;
    return clones;  
}

////////////////////////
///    Statistics    ///
////////////////////////

// /*
//     arguments: clones
//     get 5 biggest subtree clones in lines
//     return both the subtrees and the number of lines that corresponds to them
// */
// list[tuple[node, int]] get5BiggestSubtreeClonesInLines(list[tuple[node, node]] clonePairs) {
//     list[tuple[node, int]] maxNodesAndLines = [];
//     while(size(maxNodesAndLines) != 5) {
//         int maxLines = UnitLOC((clonePairs[0][0]).src);
//         tuple[node, node] maxNode = clonePairs[0];
//         for(pair <- clonePairs) {
//             int numberOfLines = UnitLOC((pair[0]).src);
//             if (numberOfLines > maxLines) {
//                 maxLines = numberOfLines;
//                 maxNode = pair;
//             }
//         }
//         clonePairs -= maxNode;
//         maxNodesAndLines += <maxNode[0], maxLines>;
//     }
//     return maxNodesAndLines;
// }

// /*
//     arguments: clones
//     get 5 biggest subtree clone classes in members
//     return both the subtrees and the number of members that corresponds to them
// */
// list[tuple[node, int]] get5BiggestSubtreeCloneClassesInMembers(list[tuple[node, node]] clonePairs) {
//     list[tuple[node, int]] maxNodesAndMembers = [];
//     node biggestCloneClass = "null"(0);
//     map[node, list[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
//     while(size(maxNodesAndMembers) != 5) {
//         int biggestCloneClassMembers = 0;
//         for (class <- cloneClasses) {
//             int classSize = size(cloneClasses[class]);
//             if (classSize > biggestCloneClassMembers && <class, classSize> notin maxNodesAndMembers) {
//                 biggestCloneClassMembers = classSize;
//                 biggestCloneClass = class;
//             }
//         }
//         biggestCloneClassMembers += 1;
//         maxNodesAndMembers += <biggestCloneClass, biggestCloneClassMembers>;
//     }
//     return maxNodesAndMembers;
// }

/*
    arguments: clones, projectLocation
    prints:
        - number of clone pairs
        - biggest clone in lines
        - biggest clone class in members
        - number of clone classes
        - percentage of duplicated lines
   - calculates everything at the same time to save time
*/
/*
    Getting clone classes:
    - have a clone map
    - for every pair of clones
        - if the first element is in the clonemap but the second one isnt,
        add it in the map, using the first element as key and the second as value
        - if the first element isnt in the clonemap but the second one is,
        add it in the map, using the second element as key and the first as value
        - otherwise, if none of them exist in the map as keys, check if the first element is in the values of some key,
        if yes, add the second one to the list also. if the second element is in the values of some key, add the first one to the list.
        if they are both added already, return
        if they are not added anywhere directly or indirectly, add them, using the first element as key and the second as value.
*/
tuple[int, int, int, int] getSubtreeStatistics(set[tuple[node, node]] clonePairs, loc projectLocation) {
    println("-------------------------");
    println("Subtree Clones Statistics");
    println("-------------------------");

    int numberOfClones = size(clonePairs);
    int biggestCloneClassMembers = 0;
    int percentageOfDuplicatedLines = 0;
    int biggestCloneLines = 0;
    int projectLines = 0;
    int numberOfCloneClasses = 0;
    node biggestClone = "null"(0);
    int duplicatedLines = 0;
    map[node, set[node]] cloneClasses = ();

    for(pair <- clonePairs) { 
        // find clone classes
        if (pair[0] in cloneClasses) {
            cloneClasses[pair[0]] += pair[1];
        } else if (pair[1] in cloneClasses) {
            cloneClasses[pair[1]] += pair[0];
        } else {
            bool added = false;
            for (key <- cloneClasses) {
                if (pair[0] in cloneClasses[key] || pair[1] in cloneClasses[key]) {
                    cloneClasses[key] += pair[1];
                    cloneClasses[key] += pair[0];
                    added = true;
                    break;
                } 
            }
            if (added == false) {
                cloneClasses[pair[0]] = {pair[1]};
            }
        }
        // find biggest clone in lines
        loc location = getLocation(pair[0]);
        if (location != |unresolved:///|) {
            int numberOfLines = UnitLOC(location);
            if (numberOfLines > biggestCloneLines) {
                biggestCloneLines = numberOfLines;
                biggestClone = pair[0];
            }
        }
    }
    numberOfCloneClasses = size(cloneClasses);
    // find biggest clone class in members
    for (class <- cloneClasses) {
        int classSize = size(cloneClasses[class]);
        loc location = getLocation(class);
        if (location != |unresolved:///|) {
            int numberOfLines = UnitLOC(location);
            duplicatedLines += (classSize + 1) * numberOfLines;
            if (classSize > biggestCloneClassMembers) {
                biggestCloneClassMembers = classSize;
            }
        }
    }
    biggestCloneClassMembers += 1;
    projectLines = LOC(projectLocation);
    percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(projectLines)); 
    
    println("example of clone pair: <getOneFrom(clonePairs)>\n");
    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClassMembers>");
    println("biggest clone in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");

    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines>;
}
