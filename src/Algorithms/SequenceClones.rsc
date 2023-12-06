module Algorithms::SequenceClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;
import Algorithms::GeneralizeClones;
import Visualization::ExportJson;

/////////////////////////
///   Main function   ///
/////////////////////////
/*
    arguments: projectLocation, cloneType (can be 1,2,3), minimumSequenceLengthThreshold: minimum number of sequences to group, generalize:  bool (whether we should also run the 3rd algorithm)
    similarityThreshold: how similar do we want the clones to be
    gets ASTs of the project 
    performs some preprocessing on ASTs, depending on the type of clones
    creates a hash table with the sequences
    finds clones comparing the sequences of each bucket
    prints statistics

*/
list[tuple[list[node], list[node]]] findSequenceClones(loc projectLocation, int cloneType, int minimumSequenceLengthThreshold, bool generalize) {
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    if (cloneType == 3) {
        real similarityThreshold = 0.8;
    }
    map[str, list[list[node]]] hashTable = ();
    map[list[node], list[value]] childrenOfParents = ();
    <hashTable, childrenOfParents> = createSequenceHashTable(ast, minimumSequenceLengthThreshold, cloneType, generalize);
    list[tuple[list[node], list[node]]] clonePairs = findSequenceClonePairs(hashTable, similarityThreshold, cloneType);
    if (generalize) {
        clonePairs = generalizeClones(clonePairs, childrenOfParents, similarityThreshold);
    }
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines> = getSequenceStatisticsFast(clonePairs, projectLocation);
    // list[tuple[node, int]] biggestClassesMembers = get5BiggestSubtreeCloneClassesInMembers(clonePairs);
    // list[tuple[node, int]] biggestClonesLines = get5BiggestSubtreeClonesInLines(clonePairs);
    // exportData(numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, biggestClassesMembers, biggestClonesLines, "subtreeClones");    
    return clonePairs;
}

//////////////////////////////
///    Create Hash Table   ///
//////////////////////////////
/*
    arguments: asts, minimumSequenceLengthThreshold, cloneType
    - visits tree and add every block that has size bigger than the minimum acceptable one to a list
    - for every sequence, get all subsequences with size bigger than the minimum acceptable one.
    - hash every "clean" subsequence with md5Hash. By clean I mean that it does not have locations etc.
    - these subsequence hashes are concatenated into a string, which is also hashed later on.
    - this sequence hash is the bucket key, and the value is the sequence or a normalized version of the sequence, if cloneType is 2 or 3.
    - finally, returns hashTable and childrenOfParents struct(useful for the third algorithm)
*/
tuple[map[str, list[list[node]]], map[list[node], list[value]]] createSequenceHashTable(list[Declaration] ast, int minimumSequenceLengthThreshold, int cloneType, bool generalize) {
    map[str, list[list[node]]] hashTable = ();
    list[list[node]] sequences = [];
    map[list[node], list[value]] childrenOfParents = ();
    visit (ast) {
        case \block(statements): {
            list[node] sequence = statements;
            if (size(sequence) >= minimumSequenceLengthThreshold) {
                sequences += [sequence];
            }
            childrenOfParents[sequence] = [];
            if (generalize) {
                for (n <- sequence) {
                    childrenOfParents[sequence] += getChildren(n);
                }
            }
        }
    }
    // written in a stupid way to check only once for the clone type and save time
    if (cloneType != 1) {
        for (sequence <- sequences) {
            for (i <- [0..(size(sequence) + 1)], j <- [0..(size(sequence) + 1)]) {
                if ((j >= i + minimumSequenceLengthThreshold)) {
                    list[node] subsequence = sequence[i..j];
                    str subsequenceHash = "";
                    for (n <- subsequence) {
                        subsequenceHash += md5Hash(unsetRec(normalizeIdentifiers(n)));
                    }
                    str sequenceHash = md5Hash(subsequenceHash);
                    if (sequenceHash in hashTable) {
                        hashTable[sequenceHash] += [subsequence];
                    } else {
                        hashTable[sequenceHash] = [subsequence];
                    }
                }
            }
        }
    } else {
        for (sequence <- sequences) {
            for (i <- [0..(size(sequence) + 1)], j <- [0..(size(sequence) + 1)]) {
                if ((j >= i + minimumSequenceLengthThreshold)) {
                    list[node] subsequence = sequence[i..j];
                    str subsequenceHash = "";
                    for (n <- subsequence) {
                        subsequenceHash += md5Hash(unsetRec(n));
                    }
                    str sequenceHash = md5Hash(subsequenceHash);
                    if (sequenceHash in hashTable) {
                        hashTable[sequenceHash] += [subsequence];
                    } else {
                        hashTable[sequenceHash] = [subsequence];
                    }
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
        - compare it using the compareSequences function that checks for similarity between sequences, to see if they are clones
        - if cloneType == 1, we are looking for an exact match, 
        - if we are looking for clones of type 2 or 3, we check if the comparison result is over the similarityThreshold 
        or equal for the case of cloneType=2 && similarityThreshold==1.0
        - in any of these two cases, we get prepared to add the clone to our struct, checking first that we can add it
*/
list[tuple[list[node], list[node]]] findSequenceClonePairs(map[str, list[list[node]]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[list[node], list[node]]] clones = [];
    if (cloneType == 1) {
        for (bucket <- hashTable) {	
            if (size(hashTable[bucket]) > 1) {
                for (i <- hashTable[bucket], j <- hashTable[bucket]) {
                    if (i != j) {
                        list[node] i_items = [];
                        list[node] j_items = [];
                        for (i_item <- i) {
                            visit (i_item) {
                                case node n : {
                                    i_items += unsetRec(n);
                                }
                            }
                        }
                        for (j_item <- j) {
                            visit (j_item) {
                                case node n : {
                                    j_items += unsetRec(n);
                                }
                            }
                        }
                        if (i_items == j_items) {
                            clones = addSequenceClone(clones, i, j);
                        }
                    }
                }	
            }
        }        
    } else {
        for (bucket <- hashTable) {	
            if (size(hashTable[bucket]) > 1) {
                for (i <- hashTable[bucket], j <- hashTable[bucket]) {
                    if (i != j) {
                        int comparison = compareSequences(i, j);
                        if (comparison >= similarityThreshold) {
                            clones = addSequenceClone(clones, i, j);
                        }
                    }
                }	
            }
        }
    }

    return clones;
}

/*
    arguments: two sequences
    - visits every node of the two sequences and counts the number of nodes they have
    - finds shared nodes of the two sequences, "cleaning" the nodes with unsetRec, 
    so that method locations and other useless informations are ignored
    - also normalizes identifiers, since this function is used for near-misses
    - calculates:
        Similarity = 2 x S / (2 x S + L + R)
        where:
        S = number of shared nodes
        L = number of different nodes in sequence 1
        R = number of different nodes in sequence 2
    - if the two sequences are identical, it will return 1, otherwise a value between 0 and 1
*/
int compareSequences(list[node] nodelist1, list[node] nodelist2) {
	list[node] nodelist1Nodes = [];
	list[node] nodelist2Nodes = [];

    for (nodeInList <- nodelist1) {
        visit (nodeInList) {
            case node n : {
                visit (n) {
                    case node nodeDeeper : {
                        nodelist1Nodes += [unsetRec(normalizeIdentifiers(nodeDeeper))];
                    }
                }
            }
        }
    }

    for (nodeInList <- nodelist2) {
        visit (nodeInList) {
            case node n : {
                visit (n) {
                    case node nodeDeeper : {
                        nodelist2Nodes += [unsetRec(normalizeIdentifiers(nodeDeeper))];
                    }
                }
            }
        }
    }

	int sharedNodes = size(nodelist1Nodes & nodelist2Nodes);
    int nodelist1NodesNumber = size(nodelist1Nodes - nodelist2Nodes);
    int nodelist2NodesNumber = size(nodelist2Nodes - nodelist1Nodes);
	return 2 * sharedNodes / (2 * sharedNodes + nodelist1NodesNumber + nodelist2NodesNumber);
} 

////////////////////////////////////////////////////
///    Remove subclones. Do not add subclones    ///
////////////////////////////////////////////////////
/*
    arguments: clones, a pair of sequences
    for every pair in clones:
    - checks if they are sublists of the given pair, either as is <i,j> or flipped <j,i>, remove them
    - dig deeper into the subtrees of the given pair as we did for subtree clones
        - if their subtree nodes are the same as the clone pair(the lists of the pair should contain only one node in that case), remove the pair
        - if the blocks in the subtrees contain the clone pair, remove it
    because we are looking for the biggest sequence that is cloned
    then:
    - visits the two sequences of the pair, check three cases:
        - if they have sublists that are the same as <i,j> or flipped as <j,i>. 
        - otherwise, we dig deeper, looking into the subtrees of the clones, as we did for subtreeClones:
            - if the sequences only have one node, and the clone pair also has only one node, and they are the same
            - if they have blocks inside their subtrees that contain the pair as sublists
        In any of these cases, it returns clones as is, because that means that the pair of clones we want to add
        are subclones of already existent clones of our clones struct.
        so there is no need to add them, because we are looking for the biggest sequence that is cloned.
    - otherwise, we can add them
*/
list[tuple[list[node], list[node]]] addSequence(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        // remove subclones
        if ((pair[0] <= i && pair[1] <= j) || (pair[1] <= i && pair[0] <= j)) {
            clones -= pair;
            continue;
        }
        for(i_node <- i, j_node <- j) {
            node isSubcloneOfI = isSubclone(pair[0][0], i_node, pair[1][0]); 
            node isSubcloneOfJ = isSubclone(pair[0][0], j_node, pair[1][0]); 
            if (size(pair[0]) == 1 && ((isSubcloneOfI == i_node && isSubcloneOfJ == pair[1][0]) || (isSubcloneOfJ == pair[0][0] && isSubcloneOfI == pair[1][0]))) {
                clones -= pair;
                continue;
            }
            list[node] listIsSubcloneOfI = isSubcloneSequence(pair[0], i_node, pair[1]); 
            list[node] listIsSubcloneOfJ = isSubcloneSequence(pair[0], j_node, pair[1]); 
            if ((listIsSubcloneOfI == pair[0] && listIsSubcloneOfJ == pair[1]) || (listIsSubcloneOfJ == pair[0] && listIsSubcloneOfI == pair[1])) {
                clones -= pair;
                continue;
            }
        }
        // check if subclone, otherwise add it
        if (i <= pair[0] && j <= pair[1]) {
            return clones;
        }
        for(member1 <- pair[0], member2 <- pair[1]) {
            node isSubcloneOfMember1 = isSubclone(i[0], member1, j[0]); 
            node isSubcloneOfMember2 = isSubclone(i[0], member2, j[0]); 
            if (size(i) == 1 && ((isSubcloneOfMember1 == i[0] && isSubcloneOfMember2 == j[0]) || (isSubcloneOfMember2 == i[0] && isSubcloneOfMember1 == j[0]))) {
                return clones;
            }
            list[node] listIsSubcloneOfMember1 = isSubcloneSequence(i, member1, j); 
            list[node] listIsSubcloneOfMember2 = isSubcloneSequence(i, member2, j);
            if ((listIsSubcloneOfMember1 == i && listIsSubcloneOfMember2 == j) || (listIsSubcloneOfMember2 == i && listIsSubcloneOfMember1 == j)) {
                return clones;
            }
        }
    }
    clones += <i,j>;
    return clones;
}

/*
    arguments: clones, a pair of sequences
    - adds sequences to the clones struct
    - if the flipped pair is not already in the struct
    - if they are not subclones of already existent clones
    - removes subclones of the pair that might exist in the clones struct
    - all in all, we ensure that we only add the biggest sequences in the clones struct
    - and we do not have duplicates
*/
list[tuple[list[node], list[node]]] addSequenceClone(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    if (size(clones) == 0) {
        return [<i, j>];
    } else {
        if (<j,i> in clones) {
            return clones;
        }
        return addSequence(clones, i, j);
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
map[list[node], list[list[node]]] getSequenceCloneClasses(list[tuple[list[node], list[node]]] clonePairs) {
    map[list[node], list[list[node]]] cloneMap = (); 
    for(pair <- clonePairs) { 
        if (pair[0] in cloneMap && pair[1] notin cloneMap[pair[0]]) {
            cloneMap[pair[0]] += [pair[1]];
        } else if (pair[1] in cloneMap && pair[0] notin cloneMap[pair[1]]) {
            cloneMap[pair[1]] += [pair[0]];
        } else {
            bool added = false;
            for (key <- cloneMap) {
                bool pair0inmap = pair[0] in cloneMap[key];
                bool pair1inmap = pair[1] in cloneMap[key];
                if (pair0inmap && !pair1inmap) {
                    cloneMap[key] += [pair[1]];
                    added = true;
                    break;
                } else if (pair1inmap && !pair0inmap) {
                    cloneMap[key] += [pair[0]];
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
tuple[list[node], int] getBiggestSequenceCloneInLines(list[tuple[list[node], list[node]]] clonePairs) {
    int maxLines = 0;
    list[node] maxNodeList = clonePairs[0][0];
    for(pair <- clonePairs) {
        int numberOfLines = 0;
        for(pairNode <- pair[0]) {
            numberOfLines += UnitLOC(pairNode.src);
        }
        if (numberOfLines > maxLines) {
            maxLines = numberOfLines;
            maxNodeList = pair[0];
        }
    }
    return <maxNodeList, maxLines>;
}

/*
    arguments: clones
    for every clone class:
    - finds maximum number of members 
    - adds 1 at the end, for the original code that was cloned
*/
int getBiggestSequenceCloneClassInMembers(list[tuple[list[node], list[node]]] clonePairs) {
    map[list[node], list[list[node]]] cloneClasses =  getSequenceCloneClasses(clonePairs);
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
int getNumberOfSequenceClonePairs(list[tuple[list[node], list[node]]] clonePairs) {
    return size(clonePairs);
}

/*
    arguments: clones
    counts number of clone classes
*/
int getNumberOfSequenceCloneClasses(list[tuple[list[node], list[node]]] clonePairs) {
    map[list[node], list[list[node]]] cloneClasses =  getSequenceCloneClasses(clonePairs);
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
int getPercentageOfDuplicatedLinesSequences(list[tuple[list[node], list[node]]] clonePairs, loc projectLocation) {
    map[list[node], list[list[node]]] cloneClasses =  getSequenceCloneClasses(clonePairs);
    int duplicatedLines = 0;
    for (class <- cloneClasses) {
        int classDuplicatedLines = 0;
        for(classNode <- class) {
            classDuplicatedLines += UnitLOC(classNode.src);
        }
        duplicatedLines += (size(cloneClasses[class]) + 1) * classDuplicatedLines;
    }
    int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
    return percentageOfDuplicatedLines;
}

/*  
    arguments: clones
    gets 5 biggest sequence clones in lines
    returns both the clones and the number of lines that corresponds to them
*/
// list[tuple[list[node], int]] get5BiggestSequenceClonesInLines(list[tuple[list[node], list[node]]] clonePairs) {
//     list[tuple[list[node], int]] maxSequencesAndLines = [];
//     while(size(maxSequencesAndLines) != 5) {
//         int maxLines = 0;
//         tuple[list[node],list[node]] maxPair = clonePairs[0];
//         for(pair <- clonePairs) {
//           int numberOfLines = 0;
//           for(pairNode <- pair[0]) {
//              numberOfLines += UnitLOC(pairNode.src);
//           }
//           if (numberOfLines > maxLines) {
//              maxLines = numberOfLines;
//              maxPair = pair;
//           }
//.        }
//         clonePairs -= pair;
//         maxSequencesAndLines += <maxPair[0], maxLines>;
//     }
//     return maxSequencesAndLines;
// }

/*  
    arguments: clones
    gets 5 biggest sequence clone classes in members
    returns both the clone classes and the number of members that corresponds to them
*/
// list[tuple[list[node], int]] get5BiggestSubtreeCloneClassesInMembers(list[tuple[list[node], list[node]]] clonePairs) {
//     list[tuple[list[node], int]] maxSequencesAndLines = [];
//     list[node] biggestCloneClass = "null"(0);
//     map[list[node], list[list[node]]] cloneClasses =  getSequenceCloneClasses(clonePairs);
//     while(size(maxNodesAndMembers) != 5) {
//         int biggestCloneClassMembers = 0;
//         for (class <- cloneClasses) {
//             int classSize = size(cloneClasses[class]);
//             if (classSize > biggestCloneClassMembers && <class, classSize> notin maxSequencesAndLines) {
//                 biggestCloneClassMembers = classSize;
//                 biggestCloneClass = class;
//             }
//         }
//         biggestCloneClassMembers += 1;
//         maxSequencesAndLines += <biggestCloneClass, biggestCloneClassMembers>;
//     }
//     return maxSequencesAndLines;
// }

/*
    arguments: clones, projectLocation
    prints:
        - number of clone pairs
        - biggest clone in lines
        - biggest clone class in members
        - number of clone classes
        - number of duplicated lines
        - percentage of duplicated lines

*/
void getSequenceStatistics(list[tuple[list[node], list[node]]] clonePairs, loc projectLocation) {
    int numberOfClones = getNumberOfSequenceClonePairs(clonePairs);
    <biggestClone, biggestCloneLines> = getBiggestSequenceCloneInLines(clonePairs);
    int numberOfCloneClasses = getNumberOfSequenceCloneClasses(clonePairs);
    int biggestCloneClass = getBiggestSequenceCloneClassInMembers(clonePairs);
    int percentageOfDuplicatedLines = getPercentageOfDuplicatedLinesSequences(clonePairs, projectLocation);
    
    println("-------------------------");
    println("Sequence Clones Statistics");
    println("-------------------------");
    println("example of clone pair: <clonePairs[0]>\n");
    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClass>");
    println("biggest clone class in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");
}

// a faster version of the above
tuple[int, int, int, int] getSequenceStatisticsFast(list[tuple[list[node], list[node]]] clonePairs, loc projectLocation) {
    println("-------------------------");
    println("Sequence Clones Statistics");
    println("-------------------------");

    int numberOfClones = 0;
    int numberOfCloneClasses = 0;
    int biggestCloneClass = 0;
    int percentageOfDuplicatedLines = 0;
    int biggestCloneLines = 0;
    int projectLines = 0;

    if (size(clonePairs) != 0) {
        numberOfClones = size(clonePairs);
        list[node] biggestClone = clonePairs[0][0];
        <biggestClone, biggestCloneLines> = getBiggestSequenceCloneInLines(clonePairs);
        map[list[node], list[list[node]]] cloneClasses =  getSequenceCloneClasses(clonePairs);
        int duplicatedLines = 0;
        for (class <- cloneClasses) {
            numberOfCloneClasses += 1;
            int classSize = size(cloneClasses[class]);
            int classDuplicatedLines = 0;
            for(classNode <- class) {
                classDuplicatedLines += UnitLOC(classNode.src);
            }
            duplicatedLines += (size(cloneClasses[class]) + 1) * classDuplicatedLines;
            if (classSize > biggestCloneClass) {
                biggestCloneClass = classSize;
            }
        }
        biggestCloneClass += 1;
        projectLines = LOC(projectLocation);
        percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 

        println("example of clone pair: <clonePairs[0]>\n");
    }
    println("number of clone pairs: <numberOfClones>");
    println("number of clone classes: <numberOfCloneClasses>");
    println("biggest clone class in members: <biggestCloneClass>");
    println("biggest clone class in lines: <biggestCloneLines>");
    println("percentage of duplicated lines: <percentageOfDuplicatedLines>%");

    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines>;
}
