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

// cache similarities
// cache processed pairs  -> stringify
// real compareTree
// decrease buckets 
// set to remove duplicates

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
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();

    // Creating SubTreeHashTable
    println("Creating subTree HashTable:");
    datetime begin = now();
    <hashTable, childrenOfParents> = createSubtreeHashTable(ast, massThreshold, cloneType, generalize);
    datetime end = now();
    interval runTime = createInterval(begin, end);
    print("Duration: \<years, months, days, hours, minutes, seconds, milliseconds\>: ");
    println("<createDuration(runTime)>\n");
    println("---\n");

    // Finding Clone paris
    println("Finding clonePairs:");
    begin = now();
    list[tuple[node, node]] clonePairs = [];
    real similarityThreshold = 1.0;
    if (cloneType == 1) {
        clonePairs = findTypeIClonePairs(hashTable, similarityThreshold);
    }
    else{
        if (cloneType == 3){
            similarityThreshold = 0.8;
        }
        clonePairs = findTypeII_III_ClonePairs(hashTable, similarityThreshold);
    }
    // list[tuple[node, node]] clonePairs = findClonePairs(hashTable, similarityThreshold, cloneType);
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
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines> = getSubtreeStatisticsFast(clonePairs, projectLocation);
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
tuple[map[str, list[node]], map[node, list[value]]] createSubtreeHashTable(list[Declaration] ast, int massThreshold, int cloneType, bool generalize) {
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();
    visit (ast) {
		case node n: {
            // if (generalize) {
            //     childrenOfParents[n] = getChildren(n);
            // }
            unsetReced[n] = unsetRec(n);
            if (subtreeMass(unsetReced[n]) >= massThreshold) {
                node normalizedIdentifier = n;
                if (cloneType != 1) {
                    normalizedIdentifier = normalizeIdentifiers(n);
                }
                // str hash = hashSubtree(normalizedIdentifier);
                str hash = md5Hash(unsetRec(normalizedIdentifier));
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
list[tuple[node, node]] findClonePairs(map[str, list[node]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[node, node]] clones = [];
	for (bucket <- hashTable) {	
        // Cartesian product of all combinations
        lrel[node L, node R] subTreePairs = hashTable[bucket] * hashTable[bucket];
        for (subTreePair <- subTreePairs){
            // Avoiding pairs of same node. E.g. (x,x)
            if (subTreePair.L != subTreePair.R){
                // Removing location and comparing
                if (cloneType == 1){
                        clones += subTreePair;
                } elseif (cloneType != 1 && compareTree(subTreePair.L, subTreePair.R) >= similarityThreshold){
                        clones += subTreePair;
                }
            }
        }
    }
    return clones;
}

list[tuple[node, node]] findTypeIClonePairs(map[str, list[node]] hashTable, real similarityThreshold) {
    list[tuple[node, node]] clones = [];
	for (bucket <- hashTable) {	
        // Cartesian product of all combinations
        lrel[node L, node R] subTreePairs = hashTable[bucket] * hashTable[bucket];
        for (subTreePair <- subTreePairs){
            // Avoiding pairs of same node. E.g. (x,x)
            // Removing location and comparing
            if (subTreePair.L != subTreePair.R){
                clones += subTreePair;
            }
        }
    }
    return clones;
}

list[tuple[node, node]] findTypeII_III_ClonePairs(map[str, list[node]] hashTable, real similarityThreshold) {
    list[tuple[node, node]] clones = [];
	for (bucket <- hashTable) {	
        // Cartesian product of all combinations
        lrel[node L, node R] subTreePairs = hashTable[bucket] * hashTable[bucket];
        for (subTreePair <- subTreePairs){
            // Avoiding pairs of same node. E.g. (x,x)
            // Removing location and comparing
           if (subTreePair.L != subTreePair.R && compareTree(subTreePair.L, subTreePair.R) >= similarityThreshold){
                clones += subTreePair;
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
    list[node] subtree1Nodes = [normalizeIdentifiers(unsetRec(n)) | n <- getSubtreeNodes(node1)];
	list[node] subtree2Nodes = [normalizeIdentifiers(unsetRec(n)) | n <- getSubtreeNodes(node2)];
	// list[node] subtree1Nodes = [unsetReced[normalizeIdentifiers(n)] | n <- getSubtreeNodes(node1)];
	// list[node] subtree2Nodes = [unsetReced[normalizeIdentifiers(n)] | n <- getSubtreeNodes(node2)];
	real sharedNodes = toReal(size(subtree1Nodes & subtree2Nodes));
    real subtree1NodesNumber = toReal(size(subtree1Nodes - subtree2Nodes));
    real subtree2NodesNumber = toReal(size(subtree2Nodes - subtree1Nodes));
	return (2.0 * sharedNodes / (2.0 * sharedNodes + subtree1NodesNumber + subtree2NodesNumber));
    // int sharedNodes = size(subtree1Nodes & subtree2Nodes);
    // int subtree1NodesNumber = size(subtree1Nodes - subtree2Nodes);
    // int subtree2NodesNumber = size(subtree2Nodes - subtree1Nodes);
	// return toReal(2 * sharedNodes / (2 * sharedNodes + subtree1NodesNumber + subtree2NodesNumber));
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
list[tuple[node, node]] addSubtree(list[tuple[node, node]] clones, node i, node j) {
    if (<j,i> in clones || isSubset(i, j) || isSubset(j, i)) {
        return clones;
    }
    for(oldPair <- clones) {
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
    clones += <i, j>;
    return clones;  
}
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
        return addSubtree(clones, i, j);
    }
}

////////////////////////
///    Statistics    ///
////////////////////////
/*
    arguments: clones
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
map[node, set[node]] getSubtreeCloneClasses(list[tuple[node, node]] clonePairs) {
    map[node, set[node]] cloneMap = (); 
    for(pair <- clonePairs) { 
        if (pair[0] in cloneMap) {
            cloneMap[pair[0]] += pair[1];
        } else if (pair[1] in cloneMap) {
            cloneMap[pair[1]] += pair[0];
        } else {
            bool added = false;
            for (key <- cloneMap) {
                bool pair0inmap = pair[0] in cloneMap[key];
                bool pair1inmap = pair[1] in cloneMap[key];
                if (pair0inmap) {
                    cloneMap[key] += pair[1];
                    added = true;
                    break;
                } else if (pair1inmap) {
                    cloneMap[key] += pair[0];
                    added = true;
                    break;
                } else if (pair0inmap && pair1inmap) {
                    added = true;
                    break;
                }
            }
            if (added == false) {
                cloneMap[pair[0]] = {pair[1]};
            }
        }
    }
    return cloneMap;
}

/*
    arguments: clones
    for every pair of clones:
    - calculates number of lines of code of the clone class, without comments and blank lines
    - finds the clone class with the most lines of code
    - returns both the node and the number of lines
*/
tuple[node, int] getBiggestSubtreeCloneInLines(loc projectLocation, list[tuple[node, node]] clonePairs) {
    int maxLines = 0;
    node maxNode = "null"(0);
    for(pair <- clonePairs) {
        loc location = nodeLocation(projectLocation, pair[0]);
        if (location != projectLocation){
            int numberOfLines = UnitLOC(location);
            // int numberOfLines = UnitLOC((pair[0]).src);
            if (numberOfLines > maxLines) {
                maxLines = numberOfLines;
                maxNode = pair[0];
            }
        }
    }
    return <maxNode, maxLines>;
}

/*
    arguments: clones
    for every clone class:
    - finds maximum number of members 
    - adds 1 at the end, for the original code that was cloned
*/
tuple[node, int] getBiggestSubtreeCloneClassInMembers(list[tuple[node, node]] clonePairs) {
    map[node, set[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
    int biggestCloneClassMembers = 0;
    node biggestCloneClass = "null"(0);
    for (class <- cloneClasses) {
        int classSize = size(cloneClasses[class]);
        if (classSize > biggestCloneClassMembers) {
            biggestCloneClassMembers = classSize;
            biggestCloneClass = class;
        }
    }
    biggestCloneClassMembers += 1;
    return <biggestCloneClass, biggestCloneClassMembers>;
}

/*
    arguments: clones
    returns size of clones struct
*/
int getNumberOfSubtreeClonePairs(list[tuple[node, node]] clonePairs) {
    return size(clonePairs);
}

/*
    arguments: clones
    counts number of clone classes
*/
int getNumberOfSubtreeCloneClasses(list[tuple[node, node]] clonePairs) {
    map[node, set[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
    int numberOfCloneClasses = 0;
    for (_ <- cloneClasses) {
        numberOfCloneClasses += 1;
    }
    return numberOfCloneClasses;
}

/*
    arguments: clones, projectLocation
    for every clone class:
    - multiply size of code of the class with members of that class (+1 for the original code)
    sum up for all classes
    multiply with 100 and divide by the total number of lines of the project to get the percentage
*/
int getPercentageOfDuplicatedLinesSubtrees(list[tuple[node, node]] clonePairs, loc projectLocation) {
    map[node, set[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
    int duplicatedLines = 0;
    for (class <- cloneClasses) {
        duplicatedLines += (size(cloneClasses[class]) + 1) * UnitLOC(class.src);
    }
    int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
    return percentageOfDuplicatedLines;
}

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
void getSubtreeStatistics(list[tuple[node, node]] clonePairs, loc projectLocation) {
    int numberOfClones = getNumberOfSubtreeClonePairs(clonePairs);
    <biggestClone, biggestCloneLines> = getBiggestSubtreeCloneInLines(clonePairs);
    int numberOfCloneClasses = getNumberOfSubtreeCloneClasses(clonePairs);
    <biggestCloneClass, biggestCloneClassMembers> = getBiggestSubtreeCloneClassInMembers(clonePairs);
    int percentageOfDuplicatedLines = getPercentageOfDuplicatedLinesSubtrees(clonePairs, projectLocation);

    println("-------------------------");
    println("Subtree Clones Statistics");
    println("-------------------------");
    println("example of clone pair: <clonePairs[0]>\n");
    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClassMembers>");
    println("biggest clone class in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");
}

// a faster version of the above
tuple[int, int, int, int] getSubtreeStatisticsFast(list[tuple[node, node]] clonePairs, loc projectLocation) {
    println("-------------------------");
    println("Subtree Clones Statistics");
    println("-------------------------");

    int numberOfClones = size(clonePairs);
    int biggestCloneClassMembers = 0;
    int percentageOfDuplicatedLines = 0;
    int biggestCloneLines = 0;
    int projectLines = 0;
    int numberOfCloneClasses = 0;

    if (numberOfClones != 0) {
        node biggestClone = "null"(0);
        <biggestClone, biggestCloneLines> = getBiggestSubtreeCloneInLines(projectLocation, clonePairs);
        map[node, set[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
        numberOfCloneClasses = size(cloneClasses);
        int duplicatedLines = 0;
        for (class <- cloneClasses) {
            int classSize = size(cloneClasses[class]);
            loc location = nodeLocation(projectLocation, class);
            if (location != projectLocation){
                int numberOfLines = location.end.line - location.begin.line;
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
    }
    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClassMembers>");
    println("biggest clone class in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");

    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines>;
}
