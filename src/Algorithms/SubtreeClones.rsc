module Algorithms::SubtreeClones

import Lib::Utilities;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;

// int hash(str s) {
//     return 0;
// }

void findSubtreeClones(loc projectLocation, int cloneType) {
    // small pieces of code are ignored
    int massThreshold = 10;
    real similarityThreshold = 1.0;
    list[Declaration] ast = getASTs(projectLocation);
    map[str, list[node]] hashTable = createHashTable(ast, massThreshold);
    // for (bucket <- hashTable) {
    //     println("<bucket>: <hashTable[bucket]> <size(hashTable[bucket])>\n");
    // }
    findClones(hashTable, similarityThreshold);

}

void findClones(map[str, list[node]] hashTable, real similarityThreshold) {
    clones = ();
	for (bucket <- hashTable) {	
        for (bucketNode <- hashTable[bucket]) {
            for (bucketNode2 <- hashTable[bucket]) {
                if (bucketNode != bucketNode2) {
                    if (compareTree(bucketNode, bucketNode2) > similarityThreshold) {
                        // visit (bucketNode) {
                        //     case node n: {
                        //         if (n in clones) {
                        //             delete(clones, n);
                        //         }
                        //     }
                        // }
                        // visit (bucketNode2) {
                        //     case node n: {
                        //         if (n in clones) {
                        //             delete(clones, n);
                        //         }
                        //     }
                        // }
                        clones[bucketNode] = bucketNode2;
                    }
                }
            }
        }	
    }
}


map[str, list[node]] createHashTable(list[Declaration] ast, int massThreshold) {
    map[str, list[node]] hashTable = ();
    int subtreeNumber = treeMass(ast);
    int bucketNumber = subtreeNumber*10/100;

    visit (ast) {
		case node n: {
			int nodeMass = subtreeMass(n);
			if (nodeMass >= massThreshold) {
                // hash n to bucket -> remove line numbers of nodes
                if (md5Hash(unsetRec(n)) in hashTable) {
                    hashTable[md5Hash(unsetRec(n))] += n;
                } else {
                    hashTable[md5Hash(unsetRec(n))] = [n];
                }
			}
		}
	}
    return hashTable;
}

int treeMass(list[Declaration] ast) {
	int mass = 0;
	visit (ast) {
		case node n : mass += 1;
	}
	return mass;
}

int subtreeMass(node currentNode) {
	int mass = 0;
	visit (currentNode) {
		case node n : mass += 1;
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
		case \methodCall(x, _, z) => \methodCall(x, "name", z)
		case \methodCall(x, y, _, z) => \methodCall(x, y, "name", z) 
		case \number(_) => \number("0")
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("name")
        case \variable(_,y) => \variable("name", y) 
		case \variable(_,y,z) => \variable("name", y, z) 
        case \simpleName(_) => \simpleName("name")
	}
}
