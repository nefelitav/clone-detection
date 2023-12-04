module Algorithms::SubtreeClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;
import DateTime;
import Algorithms::GeneralizeClones;

/////////////////////////
///   Main function   ///
/////////////////////////
/*
    arguments: projectLocation, cloneType (can be 1,2,3), massThreshold: (integer) small subtrees should be ignored
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
    real similarityThreshold = 1.0;
    if (cloneType == 3) {
        real similarityThreshold = 0.8;
    }
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();
    <hashTable, childrenOfParents> = createSubtreeHashTable(ast, massThreshold, cloneType);
    println("---\n");
    list[tuple[node, node]] clonePairs = findClonePairs(hashTable, similarityThreshold, cloneType);
    println("---\n");
    if (generalize) {
        clonePairs = generalizeClones(clonePairs, childrenOfParents, similarityThreshold);
    }
    getSubtreeStatisticsFast(clonePairs, projectLocation);
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
*/
tuple[map[str, list[node]], map[node, list[value]]] createSubtreeHashTable(list[Declaration] ast, int massThreshold, int cloneType) {
    map[str, list[node]] hashTable = ();
    map[node, list[value]] childrenOfParents = ();
    visit (ast) {
		case node n: {
            childrenOfParents[n] = getChildren(n);
			if (subtreeMass(n) >= massThreshold) {
                node normalizedIdentifier = n;
                if (cloneType != 1) {
                   normalizedIdentifier = normalizeIdentifiers(n);
                } 
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
        if (size(hashTable[bucket]) > 1) {
            for (i <- hashTable[bucket], j <- hashTable[bucket]) {
                if (i != j) {
                    int comparison = compareTree(i, j);
                    if ((cloneType == 1) && (unsetRec(i) == unsetRec(j)) || ((cloneType != 1) && (comparison >= similarityThreshold))) {
                        clones = addSubtreeClone(clones, i, j);
                    } 
                }
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
    - calculates:
        Similarity = 2 x S / (2 x S + L + R)
        where:
        S = number of shared nodes
        L = number of different nodes in sub-tree 1
        R = number of different nodes in sub-tree 2
    - if the two subtress are identical, it will return 1, otherwise a value between 0 and 1
*/
int compareTree(node node1, node node2) {
	list[node] subtree1Nodes = [];
	list[node] subtree2Nodes = [];

    visit (node1) {
        case node n : {
            subtree1Nodes += [unsetRec(normalizeIdentifiers(n))];
        }
    }

    visit (node2) {
        case node n : {
            subtree2Nodes += [unsetRec(normalizeIdentifiers(n))];
        }
    }

	int sharedNodes = size(subtree1Nodes & subtree2Nodes);
    int subtree1NodesNumber = size(subtree1Nodes - subtree2Nodes);
    int subtree2NodesNumber = size(subtree2Nodes - subtree1Nodes);
	return 2 * sharedNodes / (2 * sharedNodes + subtree1NodesNumber + subtree2NodesNumber);
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
    for(pair <- clones) {
        // remove subclones
        node isSubcloneOfI = isSubclone(pair[0], i, pair[1]); 
        node isSubcloneOfJ = isSubclone(pair[1], j, pair[0]); 
        if ((isSubcloneOfI == pair[0] && isSubcloneOfJ == pair[1]) || (isSubcloneOfJ == pair[0] &&  isSubcloneOfI == pair[1])) {
            clones -= pair;
            continue;
        }
        // check if subclone, otherwise add it
        node isSubcloneOfPair0 = isSubclone(i, pair[0], j); 
        node isSubcloneOfPair1 = isSubclone(i, pair[1], j); 
        if ((isSubcloneOfPair0 == i && isSubcloneOfPair1 == j) || (isSubcloneOfPair1 == i && isSubcloneOfPair0 == j)) {
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
        if (<j,i> in clones) {
            return clones;
        }
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
map[node, list[node]] getSubtreeCloneClasses(list[tuple[node, node]] clonePairs) {
    map[node, list[node]] cloneMap = (); 
    for(pair <- clonePairs) { 
        if (pair[0] in cloneMap && pair[1] notin cloneMap[pair[0]]) {
            cloneMap[pair[0]] += pair[1];
        } else if (pair[1] in cloneMap && pair[0] notin cloneMap[pair[1]]) {
            cloneMap[pair[1]] += pair[0];
        } else {
            bool added = false;
            for (key <- cloneMap) {
                bool pair0inmap = pair[0] in cloneMap[key];
                bool pair1inmap = pair[1] in cloneMap[key];
                if (pair0inmap && !pair1inmap) {
                    cloneMap[key] += pair[1];
                    added = true;
                    break;
                } else if (pair1inmap && !pair0inmap) {
                    cloneMap[key] += pair[0];
                    added = true;
                    break;
                } else if (pair0inmap && pair1inmap) {
                    added = true;
                    break;
                }
            }
            if (added == false) {
                cloneMap[pair[0]] = [pair[1]];
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
tuple[node, int] getBiggestSubtreeCloneInLines(list[tuple[node, node]] clonePairs) {
    int maxLines = 0;
    node maxNode = clonePairs[0][0];
    for(pair <- clonePairs) {
        int numberOfLines = UnitLOC((pair[0]).src);
        if (numberOfLines > maxLines) {
            maxLines = numberOfLines;
            maxNode = pair[0];
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
int getBiggestSubtreeCloneClassInMembers(list[tuple[node, node]] clonePairs) {
    map[node, list[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
    int biggestCloneClass = 0;
    for (class <- cloneClasses) {
        int classSize = size(cloneClasses[class]);
        if (classSize > biggestCloneClass) {
            biggestCloneClass = classSize;
        }
    }
    biggestCloneClass += 1;
    return biggestCloneClass;
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
    map[node, list[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
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
    map[node, list[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
    int duplicatedLines = 0;
    for (class <- cloneClasses) {
        duplicatedLines += (size(cloneClasses[class]) + 1) * UnitLOC(class.src);
    }
    int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
    return percentageOfDuplicatedLines;
}

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
    int biggestCloneClass = getBiggestSubtreeCloneClassInMembers(clonePairs);
    int percentageOfDuplicatedLines = getPercentageOfDuplicatedLinesSubtrees(clonePairs, projectLocation);

    println("-------------------------");
    println("Subtree Clones Statistics");
    println("-------------------------");
    println("example of clone pair: <clonePairs[0]>\n");
    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClass>");
    println("biggest clone class in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");
}

// a faster version of the above
void getSubtreeStatisticsFast(list[tuple[node, node]] clonePairs, loc projectLocation) {
    println("-------------------------");
    println("Subtree Clones Statistics");
    println("-------------------------");

    int numberOfClones = 0;
    int numberOfCloneClasses = 0;
    int biggestCloneClass = 0;
    int percentageOfDuplicatedLines = 0;
    int biggestCloneLines = 0;

    if (size(clonePairs) != 0) {
        numberOfClones = size(clonePairs);
        node biggestClone = clonePairs[0][0];
        <biggestClone, biggestCloneLines> = getBiggestSubtreeCloneInLines(clonePairs);
        map[node, list[node]] cloneClasses =  getSubtreeCloneClasses(clonePairs);
        numberOfCloneClasses = 0;
        biggestCloneClass = 0;
        int duplicatedLines = 0;
        for (class <- cloneClasses) {
            numberOfCloneClasses += 1;
            int classSize = size(cloneClasses[class]);
            duplicatedLines += (size(cloneClasses[class]) + 1) * UnitLOC(class.src);
            if (classSize > biggestCloneClass) {
                biggestCloneClass = classSize;
            }
        }
        biggestCloneClass += 1;
        percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 

        println("example of clone pair: <clonePairs[0]>\n");
    }

    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClass>");
    println("biggest clone class in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");
}

////////////////////
///    Helpers   ///
////////////////////
/*
    arguments: ASTs
    counts number of nodes of subtree

*/
int subtreeMass(node currentNode) {
	int mass = 0;
	visit (currentNode) {
		case node _ : mass += 1;
	}
	return mass;
}