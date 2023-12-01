module Algorithms::SequenceClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;

// TODO
// type 2,3
// subclones

/////////////////////////
///   Main function   ///
/////////////////////////
/*
    arguments: projectLocation, cloneType (can be 1,2,3)
    massThreshold: small subtrees should be ignored
    similarityThreshold: how similar do we want the clones to be
    minimumSequenceLengthThreshold: minimum number of sequences to group
    gets ASTs of the project 
    performs some preprocessing on ASTs, depending on the type of clones
    creates a hash table with the sequences
    finds clones comparing the sequences of each bucket
    prints statistics

*/
list[tuple[list[node], list[node]]] findSequenceClones(loc projectLocation, int cloneType, int minimumSequenceLengthThreshold) {
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    if (cloneType == 3) {
        real similarityThreshold = 0.8;
    }
    map[str, list[list[node]]] hashTable = createSequenceHashTable(ast, minimumSequenceLengthThreshold, cloneType);
    list[tuple[list[node], list[node]]] clonePairs = findSequenceClonePairs(hashTable, similarityThreshold, cloneType);
    getSequenceStatistics(clonePairs, projectLocation);
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
*/
map[str, list[list[node]]] createSequenceHashTable(list[Declaration] ast, int minimumSequenceLengthThreshold, int cloneType) {
    map[str, list[list[node]]] hashTable = ();
    list[list[node]] sequences = [];
    visit (ast) {
        case \block(statements): {
            list[node] sequence = statements;
            if (size(sequence) >= minimumSequenceLengthThreshold) {
                sequences += [sequence];
            }
        }
    }
    for (sequence <- sequences) {
        for (i <- [0..(size(sequence) + 1)], j <- [0..(size(sequence) + 1)]) {
            if ((j >= i + minimumSequenceLengthThreshold)) {
                list[node] subsequence = sequence[i..j];
                str subsequenceHash = "";
                for (n <- subsequence) {
                    subsequenceHash += md5Hash(unsetRec(n));
                }
                str sequenceHash = md5Hash(subsequenceHash);

                //if (cloneType != 1) {
                //    list[node] normalizedSubsequence = [];
                //    for (n <- subsequence) {
                //        normalizedSubsequence += normalizeIdentifiers(n);
                //    }
                //    subsequence = normalizedSubsequence;
                //}

                if (sequenceHash in hashTable) {
                    hashTable[sequenceHash] += [subsequence];
                } else {
                    hashTable[sequenceHash] = [subsequence];
                }
            }
        }
    }
    return hashTable;
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
        - if compareSequences returned 1, then it is an exact match, 
        - if not but we are looking for clones of type 2 or 3, we check if the comparison result is over the similarityThreshold 
        or equal for the case of cloneType=2 && similarityThreshold==1.0
        - in any of these two cases, we get prepared to add the clone to our struct, checking first that we can add it
*/
list[tuple[list[node], list[node]]] findSequenceClonePairs(map[str, list[list[node]]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[list[node], list[node]]] clones = [];
	for (bucket <- hashTable) {	
        if (size(hashTable[bucket]) > 1) {
            for (i <- hashTable[bucket], j <- hashTable[bucket]) {
                if (i != j) {
                    int comparison = compareSequences(i, j);
                    if ((cloneType == 1 && comparison == 1) || ((cloneType == 2 || cloneType == 3) && (comparison >= similarityThreshold))) {
                        clones = addSequenceClone(clones, i, j);
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
    - calculates:
        Similarity = 2 x S / (2 x S + L + R)
        where:
        S = number of shared nodes
        L = number of different nodes in sub-tree 1
        R = number of different nodes in sub-tree 2
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
                        nodelist1Nodes += [unsetRec(nodeDeeper)];
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
                        nodelist2Nodes += [unsetRec(nodeDeeper)];
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

/////////////////////////////
///    Remove subclones   ///
/////////////////////////////
/*
    arguments: clones, a pair of sequences
    for every pair in clones:
    - checks if they are sublists of the given pair, either as is <i,j> or flipped <j,i>
    - if yes, it removes them, 
    - because we are looking for the biggest sequence that is cloned
*/
list[tuple[list[node], list[node]]] removeSequenceSubclones(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        if (pair[0] <= i && pair[1] <= j) {
            clones -= <pair[0], pair[1]>;
        } else if (pair[1] <= i && pair[0] <= j) {
            clones -= <pair[1], pair[0]>;
        }
    }
    return clones;
}

/////////////////////////////////
///    Do not add subclones   ///
/////////////////////////////////
/*
    arguments: clones, a pair of sequences
    for every pair in clones:
    - visits the two sequences of the pair
    - checks if their children are the same as <i,j> or flipped as <j,i>
    - if yes, it returns False, because that means that the pair of clones we want to add
    - are subclones of already existent clones of our clones struct
    - so there is no need to add them, because we are looking for the biggest sequence that is cloned
    - otherwise, we can add them
*/
bool canAddSequence(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        // for(member1 <- pair[0], member2 <- pair[1]) {
            // visit(member1) {
            //     case node s: {
            //         visit(member2) {
            //             case node s2: {
                            // i,j sublists of pair that is in clones, no need to add it
                            if (i <= pair[0] && j <= pair[1]) {
                                return false;
                            }
                        // }
                    // }
                // }
            // }
        // }
    }
    return true;
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
        clones = [<i, j>];
        return clones;
    } else {
        if (<j,i> in clones) {
            return clones;
        }
        clones = removeSequenceSubclones(clones, i, j);
        if (canAddSequence(clones, i, j)) {
            clones += <i, j>;
        }
        return clones;
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
map[list[node], list[list[node]]] findSequenceCloneClasses(list[tuple[list[node], list[node]]] clonePairs) {
    map[list[node], list[list[node]]] cloneMap = (); 
    for(pair <- clonePairs) { 
        if (pair[0] in cloneMap) {
            if (pair[1] notin cloneMap[pair[0]]) {
                cloneMap[pair[0]] += pair[1];
            }
        } else if (pair[1] in cloneMap) {
            if (pair[0] notin cloneMap[pair[1]]) {
                cloneMap[pair[1]] += pair[0];
            }
        } else {
            bool added = false;
            for (key <- cloneMap) {
                if (pair[0] in cloneMap[key] && pair[1] notin cloneMap[key]) {
                    cloneMap[key] += pair[1];
                    added = true;
                    break;
                } else if (pair[0] in cloneMap[key] && pair[1] in cloneMap[key]) {
                    added = true;
                }
            }
            if (added == false) {
                for (key <- cloneMap) {
                    if (pair[1] in cloneMap[key] && pair[0] notin cloneMap[key]) {
                        cloneMap[key] += pair[0];
                        added = true;
                        break;
                    }
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
tuple[list[node], int] findBiggestSequenceClone(list[tuple[list[node], list[node]]] clonePairs) {
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
    int numberOfClones = size(clonePairs);
    list[node] biggestClone = clonePairs[0][0];
    int lines = 0;
    <biggestClone, biggestCloneLines> = findBiggestSequenceClone(clonePairs);
    map[list[node], list[list[node]]] cloneClasses =  findSequenceCloneClasses(clonePairs);
    int numberOfCloneClasses = 0;
    int biggestCloneClass = 0;
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
    int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
    
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