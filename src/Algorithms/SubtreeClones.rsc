module Algorithms::SubtreeClones

import Lib::Utilities;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;

// TODO
// choose what to keep in normalizeIdentifiers
// choose similarityThreshold for type 2 and 3
// how to handle similarityThreshold=1.0 in findClones

list[tuple[node, node]] findSubtreeClones(loc projectLocation, int cloneType) {
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
    return findClones(hashTable, similarityThreshold, cloneType);

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


list[tuple[node, node]] findClones(map[str, list[node]] hashTable, real similarityThreshold, int cloneType) {
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
    println(size(clones));
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
