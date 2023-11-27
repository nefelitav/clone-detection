module Algorithms::SubtreeClones

import Lib::Utilities;
import Lib::Statistics;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;

// TODO
// choose what to keep in normalizeIdentifiers
// choose similarityThreshold for type 2 and 3
// how to handle similarityThreshold=1.0 in findClonePairs


// % of duplicated lines, 

map[node, list[node]] findCloneClasses(list[tuple[node, node]] clonePairs) {
    map[node, list[node]] cloneMap = (); 
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

// findBiggestCloneClass()

tuple[node, int] findBiggestClone(list[tuple[node, node]] clonePairs) {
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

void getStatistics(list[tuple[node, node]] clonePairs) {
    int numberOfClones = size(clonePairs);
    node biggestClone = clonePairs[0][0];
    int lines = 0;
    <biggestClone, lines> = findBiggestClone(clonePairs);
    map[node, list[node]] cloneClasses =  findCloneClasses(clonePairs);
    int numberOfCloneClasses = 0;
    int biggestCloneClass = 0;
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
    int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
}

void findSubtreeClones(loc projectLocation, int cloneType) {
    // small pieces of code are ignored
    int massThreshold = 10;
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    if (cloneType == 2) {
        real similarityThreshold = 1.0;
    } if (cloneType == 3) {
        real similarityThreshold = 1.0;
    }
    map[str, list[node]] hashTable = createHashTable(ast, massThreshold, cloneType);
    // for (bucket <- hashTable) {
    //     println("<bucket>: <hashTable[bucket]> <size(hashTable[bucket])>\n");
    // }
    list[tuple[node, node]] clonePairs = findClonePairs(hashTable, similarityThreshold, cloneType);
    getStatistics(clonePairs);
}

map[str, list[node]] createHashTable(list[Declaration] ast, int massThreshold, int cloneType) {
    map[str, list[node]] hashTable = ();
    // int subtreeNumber = treeMass(ast);
    // int bucketNumber = subtreeNumber*10/100;
    visit (ast) {
		case node n: {
			int nodeMass = subtreeMass(n);
			if (nodeMass >= massThreshold) {
                // hash n to bucket -> remove line numbers of nodes
                str hash = md5Hash(unsetRec(n));
                if (cloneType == 2) {
                    n = normalizeIdentifiers(n);
                } else if (cloneType == 3) {
                    n = normalizeIdentifiers(n);
                }
                if (hash in hashTable) {
                    hashTable[hash] += n;
                } else {
                    hashTable[hash] = [n];
                }
			}
		}
	}
    return hashTable;
}


list[tuple[node, node]] removeSubclones(list[tuple[node, node]] clones, node i, node j) {
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

bool canAdd(list[tuple[node, node]] clones, node i, node j) {
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

list[tuple[node, node]] addClone(list[tuple[node, node]] clones, node i, node j) {
    // if clones is empty, just add the pair
    if (size(clones) == 0) {
        clones = [<i, j>];
        return clones;
    } else {
        // check if the pair is already in clones, as is or as a subclone
        if (<j,i> in clones) {
            return clones;
        }
        clones = removeSubclones(clones, i, j);
        if (canAdd(clones, i, j)) {
            // println("can add \n");
            clones += <i, j>;
        }
        return clones;
    }
}


list[tuple[node, node]] findClonePairs(map[str, list[node]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[node, node]] clones = [];
    // for each subtree i and j in the same bucket
	for (bucket <- hashTable) {	
        for (i <- hashTable[bucket]) {
            for (j <- hashTable[bucket]) {
                // ensure we are not comparing one thing with itself
                if (i != j) {
                    int comparison = compareTree(i, j);
                    // check if are clones
                    if ((cloneType == 1 && comparison == 1) || ((cloneType == 2 || cloneType == 3) && (comparison > similarityThreshold))) {
                        // println("<hashTable[bucket]>\n");
                        clones = addClone(clones, i, j);
                    }
                }
            }
        }	
    }
    // println(size(clones));
    return clones;
}

int treeMass(list[Declaration] ast) {
	int mass = 0;
	visit (ast) {
		case node _ : mass += 1;
	}
	return mass;
}

int subtreeMass(node currentNode) {
	int mass = 0;
	visit (currentNode) {
		case node _ : mass += 1;
	}
	return mass;
}

int compareTree(node node1, node node2) {
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

public node normalizeIdentifiers(node currentNode) {
	return visit (currentNode) {
        case \enum(_, x, y, z) => \enum("name", x, y, z)
        case \enumConstant(_, y) => \enumConstant("name", y) 
		case \enumConstant(_, y, z) => \enumConstant("name", y, z)
		case \class(_, x, y, z) => \class("name", x, y, z)
		case \interface(_, x, y, z) => \interface("name", x, y, z)
		// case \method(x, _, y, z) => \method(x, "name", y, z)
        case \method(x, _, y, z, a) => \method(x, "name", y, z, a)
		case \constructor(_, x, y, z) => \constructor("name", x, y, z)
		case \import(_) => \import("name")
        case \package(_) => \package("name")
        case \package(x, "name") => \package(x, "name")
        case \typeParameter(_, x) => \typeParameter("name", x)
        case \annotationType(_, x) => \annotationType("name", x)
		case \annotationTypeMember(x, _) => \annotationTypeMember(x, "name")
		case \annotationTypeMember(x, _, y) => \annotationTypeMember(x, "name", y)
		case \parameter(x, _, y) => \parameter(x, "name", y)
		case \vararg(x, _) => \vararg(x, "name") 
		case \characterLiteral(_) => \characterLiteral("a")
        case \fieldAccess(x, y, _) => \fieldAccess(x, y, "name")
        case \fieldAccess(x, _) => \fieldAccess(x, "name")
		// case \methodCall(x, _, z) => \methodCall(x, "name", z)
		// case \methodCall(x, y, _, z) => \methodCall(x, y, "name", z) 
		// case \number(_) => \number("0")
		// case \booleanLiteral(_) => \booleanLiteral(true)
		// case \stringLiteral(_) => \stringLiteral("name")
        case \variable(_,y) => \variable("name", y) 
		case \variable(_,y,z) => \variable("name", y, z) 
        case \simpleName(_) => \simpleName("name")
	}
}
