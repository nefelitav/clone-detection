module Algorithms::SequenceClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import Set;
import Map;
import util::Math;
import Algorithms::GeneralizeClones;
import Visualization::ExportJson;
import Type;
import Boolean;

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
    // println(size(hashTable));
    list[tuple[list[node], list[node]]] clonePairs = findSequenceClonePairs(hashTable, similarityThreshold, cloneType);
    // println(size(clonePairs));
    // for(pair <- clonePairs) {
    //     println("<pair>\n");
    // }

    // if (generalize) {
    //     clonePairs = generalizeClones(clonePairs, childrenOfParents, similarityThreshold);
    // }
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines> = getSequenceStatistics(clonePairs, projectLocation); 
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
    set[list[node]] sequences = {};
    map[list[node], list[value]] childrenOfParents = ();
    visit (ast) {
        case \block(statements): {
            list[node] sequence = statements;
            if (size(sequence) >= minimumSequenceLengthThreshold) {
                sequence = [unsetRec(n, {"decl", "messages", "typ"}) | n <- sequence];
                sequences += {sequence};
            }
            if (generalize) {
                childrenOfParents[sequence] = [];
                for (n <- sequence) {
                    childrenOfParents[sequence] += getChildren(n);
                }
            }
        }
    }
    map[node, str] hashes = ();
    for (sequence <- sequences) {
        int sequenceSize = size(sequence);
        for (i <- [0..(sequenceSize - minimumSequenceLengthThreshold + 1)], j <- [i + minimumSequenceLengthThreshold..(sequenceSize + 1)]) {
            if ((j >= i + minimumSequenceLengthThreshold)) {
                list[node] subsequence = sequence[i..j];
                str subsequenceHash = "";
                for (n <- subsequence) {
                    if (cloneType == 2) {
                        n = normalizeIdentifiers(unsetRec(n));
                    }
                    if (n in hashes) {
                        subsequenceHash += hashes[n];
                    } else {
                        str hash = md5Hash(unsetRec(n));
                        subsequenceHash += hash;
                        hashes[n] = hash; 
                    }
                    
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
    map[list[str], real] similarities = ();
    real comparison = 0.0;
    for (bucket <- hashTable) {	
        for (i <- hashTable[bucket], j <- hashTable[bucket] - [i]) {
            str i_str = toString(i);
            str j_str = toString(j);
            list[str] ij = [i_str, j_str];

            if (ij in similarities) {
                comparison = similarities[ij];
            } else if (cloneType != 1) {
                comparison = compareSequences(i, j);
                similarities[ij] = comparison;
            } else if (cloneType == 1) {
                similarities[ij] = 1.0;
            }

            if ((cloneType == 1) || (cloneType != 1 && comparison >= similarityThreshold)) {
                clones = addSequenceClone(clones, i, j);
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
real compareSequences(list[node] nodelist1, list[node] nodelist2) {
	list[node] nodelist1Nodes = [];
	list[node] nodelist2Nodes = [];

    for (subtree <- nodelist1) {
        visit (subtree) {
            case node n : {
                nodelist1Nodes += [unsetRec(n)];
            }
        }
    }

    for (subtree <- nodelist2) {
        visit (subtree) {
            case node n : {
                nodelist2Nodes += [unsetRec(n)];
            }
        }
    }

	real sharedNodes = toReal(size(nodelist1Nodes & nodelist2Nodes));
    real nodelist1NodesNumber = toReal(size(nodelist1Nodes - nodelist2Nodes));
    real nodelist2NodesNumber = toReal(size(nodelist2Nodes - nodelist1Nodes));
	return 2 * sharedNodes / (2.0 * sharedNodes + nodelist1NodesNumber + nodelist2NodesNumber);
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
list[tuple[list[node], list[node]]] addSequenceClone(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    if (size(clones) == 0) {
        clones = [<i, j>];
    } else {
        if (<j,i> in clones) {
            return clones;
        }
        set[tuple[list[node], list[node]]] cloneSet = toSet(clones);
        set[tuple[list[node], list[node]]] subclones = {[s, s2] | s <- i, s2 <- j, {s, s2} in cloneSet || {s2, s} in cloneSet};
        clones = toList(cloneSet - subclones);

        for (pair <- clones) {
            map[tuple[list[node], list[node]], str] pair0IsSubset = ();
            map[tuple[list[node], list[node]], str] pair1IsSubset = ();

            bool pair0Value = false;
            bool pair1Value = false;

            if (<pair[0], i> in pair0IsSubset) {
                pair0Value = fromString(pair0IsSubset[<pair[0], i>]);
            } else {
                pair0Value = isSubset(i, pair[0]);
                pair0IsSubset[<pair[0],i>] = toString(pair0Value);
            }

            if (pair0Value) {
                return clones;
            }
            
            if (<pair[1], j> in pair1IsSubset) {
                pair1Value = fromString(pair1IsSubset[<pair[1], j>]);
            } else {
                pair1Value = isSubset(j, pair[1]);
                pair1IsSubset[<pair[1],j>] = toString(pair1Value);
            }
            
            if (pair1Value) {
                return clones;
            }               
        }
    }
    clones += <i, j>;
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
map[list[node], set[list[node]]] getSequenceCloneClasses(list[tuple[list[node], list[node]]] clonePairs) {
    map[list[node], set[list[node]]] cloneClasses = (); 

    for(pair <- clonePairs) { 
        if (pair[0] in cloneClasses) {
            cloneClasses[pair[0]] += {pair[1]};
        } else if (pair[1] in cloneClasses) {
            cloneClasses[pair[1]] += {pair[0]};
        } else {
            bool added = false;
            for (key <- cloneClasses) {
                if (pair[0] in cloneClasses[key] || pair[1] in cloneClasses[key]) {
                    cloneClasses[key] += {pair[1]};
                    cloneClasses[key] += {pair[0]};
                    added = true;
                    break;
                }
            }
            if (added == false) {
                cloneClasses[pair[0]] = {pair[1]};
            }
        }
    }
    return cloneClasses;
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
tuple[int, int, int, int] getSequenceStatistics(list[tuple[list[node], list[node]]] clonePairs, loc projectLocation) {
    println("-------------------------");
    println("Sequence Clones Statistics");
    println("-------------------------");

    int numberOfClones = size(clonePairs);
    int biggestCloneClassMembers = 0;
    int percentageOfDuplicatedLines = 0;
    int biggestCloneLines = 0;
    int projectLines = 0;
    int numberOfCloneClasses = 0;
    list[node] biggestClone = [];
    int duplicatedLines = 0;
    map[list[node], set[list[node]]] cloneClasses = ();

    for(pair <- clonePairs) { 
        if (pair[0] in cloneClasses) {
            cloneClasses[pair[0]] += {pair[1]};
        } else if (pair[1] in cloneClasses) {
            cloneClasses[pair[1]] += {pair[0]};
        } else {
            bool added = false;
            for (key <- cloneClasses) {
                if (pair[0] in cloneClasses[key] || pair[1] in cloneClasses[key]) {
                    cloneClasses[key] += {pair[1]};
                    cloneClasses[key] += {pair[0]};
                    added = true;
                    break;
                }
            }
            if (added == false) {
                cloneClasses[pair[0]] = {pair[1]};
            }
        }

        int numberOfLines = 0;
        for(pairNode <- pair[0]) {
            numberOfLines += UnitLOC(pairNode.src);
        }
        if (numberOfLines > biggestCloneLines) {
            biggestCloneLines = numberOfLines;
            biggestClone = pair[0];
        }
    }
    numberOfCloneClasses = size(cloneClasses);
    for (class <- cloneClasses) {
        int classSize = size(cloneClasses[class]);
        int classDuplicatedLines = 0;
        for(classNode <- class) {
            classDuplicatedLines += UnitLOC(classNode.src);
        }
        duplicatedLines += (size(cloneClasses[class]) + 1) * classDuplicatedLines;
        if (classSize > biggestCloneClassMembers) {
            biggestCloneClassMembers = classSize;
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
