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

/////////////////////////
///   Main function   ///
/////////////////////////
/*
    arguments: projectLocation, cloneType (can be 1,2,3)
    massThreshold: small pieces of code should be ignored
    similarityThreshold: how similar do we want the clones to be
    gets ASTs of the project 
    performs some preprocessing on ASTs, depending on the type of clones
    creates a hash table with the subtrees
    finds clones comparing the subtrees of each bucket
    prints statistics

*/
list[tuple[node, node]] findSubtreeClones(loc projectLocation, int cloneType) {
    int massThreshold = 6;
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    if (cloneType == 2) {
        real similarityThreshold = 1.0;
    } if (cloneType == 3) {
        real similarityThreshold = 1.0;
    }
    map[str, list[node]] hashTable = createSubtreeHashTable(ast, massThreshold, cloneType);
    // for (bucket <- hashTable) {
    //     println("<bucket>: <hashTable[bucket]> <size(hashTable[bucket])>\n");
    // }
    list[tuple[node, node]] clonePairs = findClonePairs(hashTable, similarityThreshold, cloneType);
    // println(clonePairs);
    // for(pair <- clonePairs) {
    //     println("pair = <pair[0]> <pair[1]> !!!!\n");
    // }
    getStatistics(clonePairs, projectLocation);
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
map[str, list[node]] createSubtreeHashTable(list[Declaration] ast, int massThreshold, int cloneType) {
    map[str, list[node]] hashTable = ();
    // int subtreeNumber = treeMass(ast);
    // int bucketNumber = subtreeNumber*10/100;
    visit (ast) {
		case node n: {
			int nodeMass = subtreeMass(n);
			if (nodeMass >= massThreshold) {
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

/////////////////////////
///    Find Clones    ///
/////////////////////////
/*
    arguments: hashTable, similarityThreshold, cloneType
    for every bucket, get a pair:
    - compare it using the compareTree function that checks for similarity between nodes
    - if compareTree returned 1, then it is an exact match, 
    - if not but we are looking for clones of type 2 or 3, we check if the comparison result is over the similarityThreshold
    - in any of these two cases, we get prepared to add the clone to our struct, checking first that we can add it
*/
list[tuple[node, node]] findClonePairs(map[str, list[node]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[node, node]] clones = [];
    // for each subtree i and j in the same bucket
	for (bucket <- hashTable) {	
        for (i <- hashTable[bucket], j <- hashTable[bucket]) {
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
    // println(size(clones));
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

/////////////////////////////
///    Remove subclones   ///
/////////////////////////////
/*
    arguments: clones, a pair of subtrees
    for every pair in clones:
    - visits the two subtrees 
    - checks if their children exist in clones, as <i,j> or flipped as <j,i>
    - if yes, it removes them, because their parents will be added, who are more powerful
    - because we are looking for the biggest subtree that is cloned
*/
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

/////////////////////////////////
///    Do not add subclones   ///
/////////////////////////////////
/*
    arguments: clones, a pair of subtrees
    for every pair in clones:
    - visits the two subtrees of the pair
    - checks if their children are the same as <i,j> or flipped as <j,i>
    - if yes, it returns False, because that means that the pair of clones we want to add
    - are subclones of already existent clones of our clones struct
    - so there is no need to add them, because we are looking for the biggest subtree that is cloned
    - otherwise, we can add them
*/
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

/*
    arguments: clones, a pair of subtrees
    - adds subtrees to the clones struct
    - if the flipped pair is not already in the struct
    - if they are not subclones of already existent clones
    - removes subclones of the pair that might exist in the clones struct
    - all in all, we ensure that we only add the biggest subtrees in the clones struct
    - and we do not have duplicates
*/
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

/*
    arguments: clones
    for every pair of clones:
    - calculates number of lines of code of the clone class, without comments and blank lines
    - finds the clone class with the most lines of code
    - returns both the node and the number of lines
*/
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
void getStatistics(list[tuple[node, node]] clonePairs, loc projectLocation) {
    // println(clonePairs);
    int numberOfClones = size(clonePairs);
    println(numberOfClones);
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
    println(numberOfCloneClasses);
    biggestCloneClass += 1;
    int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
}

<<<<<<< HEAD
////////////////////
///    Helpers   ///
////////////////////
/*
    arguments: ASTs
    counts number of nodes of tree
=======
void findSubtreeClones(loc projectLocation, int cloneType) {
    // small pieces of code are ignored
    int massThreshold = 6;
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    if (cloneType == 2) {
        real similarityThreshold = 1.0;
    } if (cloneType == 3) {
        real similarityThreshold = 1.0;
    }
    map[str, list[node]] hashTable = createSubtreeHashTable(ast, massThreshold, cloneType);
    // for (bucket <- hashTable) {
    //     println("<bucket>: <hashTable[bucket]> <size(hashTable[bucket])>\n");
    // }
    list[tuple[node, node]] clonePairs = findClonePairs(hashTable, similarityThreshold, cloneType);
    // println(clonePairs);
    // for(pair <- clonePairs) {
    //     println("pair = <pair[0]> <pair[1]> !!!!\n");
    // }
    getStatistics(clonePairs, projectLocation);
}

map[str, list[node]] createSubtreeHashTable(list[Declaration] ast, int massThreshold, int cloneType) {
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
        for (i <- hashTable[bucket], j <- hashTable[bucket]) {
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
    // println(size(clones));
    return clones;
}
>>>>>>> affd3be9746eb9517e34cd15c3829335779f3eda

*/
int treeMass(list[Declaration] ast) {
	int mass = 0;
	visit (ast) {
		case node _ : mass += 1;
	}
	return mass;
}

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

/*
    arguments: node
    normalize identifiers removing names 
*/
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