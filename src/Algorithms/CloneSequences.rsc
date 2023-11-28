module Algorithms::CloneSequences

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;


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

void getSequenceStatistics(list[tuple[list[node], list[node]]] clonePairs, loc projectLocation) {
    // println(clonePairs);
    int numberOfClones = size(clonePairs);
    // println(numberOfClones);

    list[node] biggestClone = clonePairs[0][0];
    int lines = 0;
    <biggestClone, lines> = findBiggestSequenceClone(clonePairs);
    map[list[node], list[list[node]]] cloneClasses =  findSequenceCloneClasses(clonePairs);
    // println(cloneClasses);
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
    // println(numberOfCloneClasses);
    biggestCloneClass += 1;
    int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
}

list[tuple[list[node], list[node]]] findSequenceClones(loc projectLocation, int cloneType) {
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    int minimumSequenceLengthThreshold = 2;
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
    // println(clonePairs);
    // for(pair <- clonePairs) {
    //     println("pair = <pair[0]> <pair[1]> !!!!\n");
    // }
    // getSequenceStatistics(clonePairs, projectLocation);
    return clonePairs;
}


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
                // hash every subsequence
                str subsequenceHash = "";
                for (n <- subsequence) {
                    subsequenceHash += md5Hash(unsetRec(n));
                }
                // println("<subsequence> <i> <j> <subsequenceHash>\n");
                str sequenceHash = md5Hash(subsequenceHash);
                // println("<subsequence> <i> <j> <subsequenceHash> <sequenceHash>\n");
                // if (cloneType == 2) {
                //     n = normalizeIdentifiers(n);
                // } else if (cloneType == 3) {
                //     n = normalizeIdentifiers(n);
                // }
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


list[tuple[list[node], list[node]]] removeSequenceSubclones(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        // pair has sublists of i,j
        if (pair[0] <= i && pair[1] <= j) {
            clones -= <pair[0], pair[1]>;
        } else if (pair[1] <= i && pair[0] <= j) {
            clones -= <pair[1], pair[0]>;
        }
    }
    return clones;
}

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

list[tuple[list[node], list[node]]] addSequenceClone(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    // if clones is empty, just add the pair
    if (size(clones) == 0) {
        clones = [<i, j>];
        return clones;
    } else {
        // check if the pair is already in clones, as is or as a subclone
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

list[tuple[list[node], list[node]]] findSequenceClonePairs(map[str, list[list[node]]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[list[node], list[node]]] clones = [];
    // for each sequence i and j in the same bucket
	for (bucket <- hashTable) {	
        for (i <- hashTable[bucket], j <- hashTable[bucket]) {
            // ensure we are not comparing one thing with itself
            if (i != j) {
                // println("<i> <j>\n");
                int comparison = compareSequences(i, j);
                // check if are clones
                if ((cloneType == 1 && comparison == 1) || ((cloneType == 2 || cloneType == 3) && (comparison > similarityThreshold))) {
                    // println("<i> <j> <bucket>\n");
                    clones = addSequenceClone(clones, i, j);
                }
            }
        }	
    }
    // println(size(clones));
    return clones;
}

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
