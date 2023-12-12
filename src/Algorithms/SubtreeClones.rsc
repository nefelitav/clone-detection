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
    - performs some preprocessing on ASTs, depending on the type of clones
    - creates a hash table with the subtrees
    - finds clones comparing the subtrees of each bucket
    - prints statistics

*/
list[tuple[node, node]] findSubtreeClones(loc projectLocation, int cloneType, int massThreshold, bool generalize) {
    list[Declaration] ast = getASTs(projectLocation);

    // Creating hash table
    println("Creating subTree HashTable:");
    datetime begin = now();
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();
    <hashTable, childrenOfParents> = createSubtreeHashTable(ast, cloneType, massThreshold, generalize);
    println(size(hashTable));
    datetime end = now();
    interval runTime = createInterval(begin, end);
    print("Duration: \<years, months, days, hours, minutes, seconds, milliseconds\>: ");
    println("<createDuration(runTime)>\n");
    println("---\n");


    // Finding clone pairs
    println("Finding clonePairs:");
    begin = now();
    list[tuple[node, node]] clonePairs = [];
    real similarityThreshold = 1.0;
    if (cloneType == 1) {
        clonePairs = findTypeIClonePairs(hashTable);
    } else {
        if (cloneType == 3) {
            similarityThreshold = 0.8;
        }
        clonePairs = findTypeII_III_ClonePairs(hashTable, similarityThreshold);
    }
    println(size(clonePairs));
    end = now();
    runTime = createInterval(begin, end);
    print("Duration: \<years, months, days, hours, minutes, seconds, milliseconds\>: ");
    println("<createDuration(runTime)>\n");
    println("---\n");


    // if (generalize) {
    //     clonePairs = generalizeClones(clonePairs, childrenOfParents, similarityThreshold);
    // }

    // Calculating statistics
    println("Calculating Statistics:");
    begin = now();
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines> = getSubtreeStatistics(toList(toSet(clonePairs)), projectLocation);
    end = now();
    runTime = createInterval(begin, end);
    print("Duration: \<years, months, days, hours, minutes, seconds, milliseconds\>: ");
    println("<createDuration(runTime)>\n");
    println("---\n");

    return clonePairs;
}

//////////////////////////////
///    Create Hash Table   ///
//////////////////////////////
/*
    arguments: asts, massThreshold, cloneType
    visits tree and for every node:
    - checks if nodeMass >= massThreshold, so that we ignore small subtrees
    - hashes the "clean" node with md5Hash. Nodes get "cleaned" with unsetRec, so that method locations are ignored
    - the hash is the key for each bucket and the value is the node or a normalized version of the node, if cloneType is 2 or 3
    - this way, clones end up in the same bucket and can easily and quickly be compared with each other
    - finally, returns hashTable and childrenOfParents struct(useful for the third algorithm)
*/
tuple[map[str, list[node]], map[node, list[value]]] createSubtreeHashTable(list[Declaration] ast, int cloneType, int massThreshold, bool generalize) {
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();
    visit (ast) {
        case node n: {
            if (generalize) {
                childrenOfParents[n] = getChildren(n);
            }
            if (subtreeMass(unsetRec(n)) >= massThreshold) {
                node normalizedNode = n;
                if (cloneType != 1) {
                    normalizedNode = normalizeIdentifiers(n);
                }
                // list[node] tohash = [];
                // for (node child <- normalizedNode) {
                //     tohash += unsetRec(child);
                // }
                // str hash = md5Hash(toString(tohash));
                str hash = md5Hash(unsetRec(normalizedNode));
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
    arguments: hashTable, similarityThreshold, cloneType
    for every bucket:
    - if size == 1, nothing to compare
    - get a pair of subtrees:
        - ensure we are not comparing the same subtree with itself
        - compare it using the compareTree function that checks for similarity between nodes, to see if they are clones
        - if compareTree returned 1, then it is an exact match, 
        - if not but we are looking for clones of type 2 or 3, we check if the comparison result is over the similarityThreshold 
        or equal for the case of cloneType=2 && similarityThreshold==1.0
        - in any of these two cases, we get prepared to add the clone to our struct, checking first that we can add it
*/

list[tuple[node, node]] findTypeIClonePairs(map[str, list[node]] hashTable) {
    list[tuple[node, node]] clones = [];
	for (bucket <- hashTable) {	
        list[node] nodes = hashTable[bucket];
        for (i_index <- [0 .. size(nodes) - 1], j_index <- [i_index+1 .. size(nodes)]) {
            clones = addSubtreeClone(toList(toSet(clones)), nodes[i_index], nodes[j_index]);
        }
    }
    return clones;
}

list[tuple[node, node]] findTypeII_III_ClonePairs(map[str, list[node]] hashTable, real similarityThreshold) {
    list[tuple[node, node]] clones = [];
    map[list[str], real] similarities = ();
    real comparison = 0.0;
	for (bucket <- hashTable) {	
        list[node] nodes = toList(toSet(hashTable[bucket]));
        for (i_index <- [0 .. size(nodes) - 1], j_index <- [i_index+1 .. size(nodes)]) {
            node i = nodes[i_index];
            node j = nodes[j_index];

            str i_str = toString(i);
            str j_str = toString(j);
            list[str] ij = [i_str, j_str];

            if (ij in similarities) {
                comparison = similarities[ij];
            } else {
                comparison = compareTree(i, j);
                similarities[ij] = comparison;
            } 

            if (comparison >= similarityThreshold) {
                clones = addSubtreeClone(clones, i, j);
            }
        }
    }
    return clones;
}

/*
    arguments: two subtrees
    - visits the two subtrees and counts the number of nodes they have
    - finds shared nodes of the two subtrees, "cleaning" the nodes with unsetRec, 
    so that method locations and other useless informations are ignored
    - also normalizes identifiers, since this function is used for near-misses
    - calculates:
        Similarity = 2 x S / (2 x S + L + R)
        where:
        S = number of shared nodes
        L = number of different nodes in sub-tree 1
        R = number of different nodes in sub-tree 2
    - if the two subtress are identical, it will return 1, otherwise a value between 0 and 1
*/
real compareTree(node node1, node node2) {
    list[node] subtree1Nodes = toList(toSet([normalizeIdentifiers(unsetRec(n)) | n <- getSubtreeNodes(node1)]));
	list[node] subtree2Nodes = toList(toSet([normalizeIdentifiers(unsetRec(n)) | n <- getSubtreeNodes(node2)]));
	real sharedNodes = toReal(size(subtree1Nodes & subtree2Nodes));
    real subtree1NodesNumber = toReal(size(subtree1Nodes - subtree2Nodes));
    real subtree2NodesNumber = toReal(size(subtree2Nodes - subtree1Nodes));
	return 2.0 * sharedNodes / (2.0 * sharedNodes + subtree1NodesNumber + subtree2NodesNumber);
} 

///////////////////////////////////////////////////
///    Remove subclones. Do not add subclones   ///
///////////////////////////////////////////////////
/*
    arguments: clones, a pair of subtrees
    for every pair in clones:
    - visits the two subtrees 
    - checks if their children exist in clones, as <i,j> or flipped as <j,i>
    - if yes, it removes them, because their parents will be added, who are more powerful
    - because we are looking for the biggest subtree that is cloned
    then:
    - visits the two subtrees of the pair
    - checks if their children are the same as <i,j> or flipped as <j,i>
    - if yes, it returns clones as is, because that means that the pair of clones we want to add
    - are subclones of already existent clones of our clones struct
    - so there is no need to add them, because we are looking for the biggest subtree that is cloned
    - otherwise, we can add them
*/

/*
    arguments: clones, a pair of subtrees
    - adds subtrees to the clones struct
    - if the flipped pair is not already in the struct
    - if they are not subclones of already existent clones
    - removes subclones of the pair that might exist in the clones struct
    - all in all, we ensure that we only add the biggest subtrees in the clones struct
    - and we do not have duplicates
*/
list[tuple[node, node]] addSubtreeClone(list[tuple[node, node]] clones, node i, node j) {
    if (size(clones) == 0) {
        return [<i, j>];
    } else {
        if (<j,i> in clones || isSubset(i, j) || isSubset(j, i)) {
            return clones;
        }
        for (oldPair <- clones) {
            // remove subclones
            if ((isSubset(oldPair[0], i) && (isSubset(oldPair[1], j))) || (isSubset(oldPair[0], j) && (isSubset(oldPair[1], i)))) {
                clones -= oldPair;
                continue;
            }
            // check if subclone, otherwise add it
            if ((isSubset(i, oldPair[0]) && (isSubset(j, oldPair[1]))) || (isSubset(j, oldPair[0]) && (isSubset(i, oldPair[1])))) {
                return clones;
            }
        }
    }
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

*/
tuple[int, int, int, int] getSubtreeStatistics(list[tuple[node, node]] clonePairs, loc projectLocation) {
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
        loc location = nodeLocation(pair[0]);
        if (location != |unresolved:///|) {
            int numberOfLines = UnitLOC(location);
            if (numberOfLines > biggestCloneLines) {
                biggestCloneLines = numberOfLines;
                biggestClone = pair[0];
            }
        }
    }
    numberOfCloneClasses = size(cloneClasses);
    for (class <- cloneClasses) {
        int classSize = size(cloneClasses[class]);
        loc location = nodeLocation(class);
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
    
    println("example of clone pair: <clonePairs[0]>\n");
    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClassMembers>");
    println("biggest clone in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");

    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines>;
}
