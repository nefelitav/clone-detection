module Algorithms::CloneSequences

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;


void findSequenceClones(loc projectLocation, int cloneType) {
    // small pieces of code are ignored
    int sequenceThreshold = 7;
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    int minimumSequenceLengthThreshold = 3;
    if (cloneType == 2) {
        real similarityThreshold = 1.0;
    } if (cloneType == 3) {
        real similarityThreshold = 1.0;
    }
    map[str, list[list[node]]] hashTable = createSequenceHashTable(ast, minimumSequenceLengthThreshold, cloneType);
    // for (bucket <- hashTable) {
    //     println("<bucket>: <hashTable[bucket]> <size(hashTable[bucket])>\n");
    // }
    list[tuple[list[node], list[node]]] clonePairs = findSequenceClonePairs(hashTable, similarityThreshold, cloneType);
    // // println(clonePairs);
    // // for(pair <- clonePairs) {
    // //     println("pair = <pair[0]> <pair[1]> !!!!\n");
    // // }
    // getStatistics(clonePairs, projectLocation);
}


map[str, list[list[node]]] createSequenceHashTable(list[Declaration] ast, int minimumSequenceLengthThreshold, int cloneType) {
    map[str, list[list[node]]] hashTable = ();
    list[list[node]] sequences = [];
    visit (ast) {
        case \block(statements): {
            list[node] sequence = statements;
            if (size(sequence) >= minimumSequenceLengthThreshold) {
                sequences += sequence;
            }
        }
    }
    for (sequence <- sequences) {
        for (i <- [minimumSequenceLengthThreshold..(size(sequence) + 1)]) {
            for (j <- [minimumSequenceLengthThreshold..(size(sequence) + 1)]) {
                list[node] subsequence = sequence[i..j];
                // hash every sequence
                str sequenceHash = "";
                for (n <- sequence) {
                    sequenceHash += md5Hash(unsetRec(n));
                }
                str subsequenceHash = md5Hash(sequenceHash);
                // if (cloneType == 2) {
                //     n = normalizeIdentifiers(n);
                // } else if (cloneType == 3) {
                //     n = normalizeIdentifiers(n);
                // }
                if (subsequenceHash in hashTable) {
                    hashTable[subsequenceHash] += subsequence;
                } else {
                    hashTable[subsequenceHash] = [subsequence];
                }
            }
        }
    }
    return hashTable;
}


list[tuple[list[node], list[node]]] findSequenceClonePairs(map[str, list[list[node]]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[list[node], list[node]]] clones = [];
    // for each subtree i and j in the same bucket
	for (bucket <- hashTable) {	
        for (i <- hashTable[bucket]) {
            for (j <- hashTable[bucket]) {
                // ensure we are not comparing one thing with itself
                if (i != j) {
                    int comparison = compareSequences(i, j, k);
                    // check if are clones
                    if ((cloneType == 1 && comparison == 1) || ((cloneType == 2 || cloneType == 3) && (comparison > similarityThreshold))) {
                        // println("<hashTable[bucket]>\n");
                        clones = addSubsequenceClone(clones, i, j);
                    }
                }
            }
        }	
    }
    // println(size(clones));
    return clones;
}


list[tuple[list[node], list[node]]] removeSubsequenceSubclones(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        visit(i) {
            case node s: {
                visit(j) {
                    case node s2: {
                        if (pair[0] == s && pair[1] == s2) {
                            clones -= <s, s2>;
                        } else if (pair[0] == s2 && pair[1] == s) {
                            clones -= <s2, s>;
                        }
                    }
                }
            }
        }
    }
    return clones;   
}

bool canAddSubsequence(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        visit(pair[0]) {
            case node s: {
                visit(pair[1]) {
                    case node s2: {
                        if ((i == s && j == s2) || (i == s2 && j == s)) {
                            // println("cant add : <i> <j> <pair>\n");
                            return false;
                        }
                    }
                }
            }
        }
    }
    return true;
}

list[tuple[list[node], list[node]]] addSubsequenceClone(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    // if clones is empty, just add the pair
    if (size(clones) == 0) {
        clones = [<i, j>];
        return clones;
    } else {
        // check if the pair is already in clones, as is or as a subclone
        if (<j,i> in clones) {
            return clones;
        }
        clones = removeSubsequenceSubclones(clones, i, j);
        if (canAddSubsequence(clones, i, j)) {
            // println("can add \n");
            clones += <i, j>;
        }
        return clones;
    }
}

int compareSubsequenceTree(node node1, node node2) {
	int sharedNodes = 0;
	int subtree1Nodes = 0;
	int subtree2Nodes = 0;

    // count all nodes of subtree 1
	visit (node1) {
		case node n : {
            // check if node of subtree 1 is in subtree 2 too
            visit (node2) {
                case node n2 : {
                    if (unsetRec(n) == unsetRec(n2)) {
                        sharedNodes += 1;
                    }
                }
            }
            subtree1Nodes += 1;
        }
	}
    // count all nodes of subtree 2
    visit (node2) {
		case node _ : {
            subtree2Nodes += 1;
        }
	}
	return 2 * sharedNodes / (2 * sharedNodes + (subtree1Nodes - sharedNodes) + (subtree2Nodes - sharedNodes));
} 