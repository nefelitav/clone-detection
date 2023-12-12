module Lib::Utilities

import lang::java::m3::Core;
import lang::java::m3::AST;
import Node;
import String;
import List;
import Set;


list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return toList(toSet(asts));
}

/*
    arguments: two nodes
    checks if first node is subset of the second one
    it's faster if we compare the strings of the nodes
*/
bool isSubset(node node1, node node2) {
    // visit(node2) {
    //     case node n: if (n == node1) {return true;}
    // }
    // return false;
    return contains(toString(node2), toString(node1));
}

/*
    arguments: two sequence
    checks if first sequence is subset of the sequence one
    first, checks directly if the one list is a sublit of the other
    then, checks if the two sequences' locations are in the same file and if the lines of the one are a subset of the lines of the other
*/
bool isSubset(list[node] subsequence, list[node] supersequence) {
    for (subsequence <= supersequence) {
        return true;
    }
    list[loc] supersequenceLocs = [getLocation(n) | n <- supersequence];
    list[loc] subsequenceLocs = [getLocation(n) | n <- subsequence];
    for (supersequenceLoc <- supersequenceLocs) {
        for (subsequenceLoc <- subsequenceLocs) {
            if ((supersequenceLoc.path == subsequenceLoc.path) && (supersequenceLoc.begin.line < subsequenceLoc.begin.line) && (supersequenceLoc.end.line > subsequenceLoc.end.line)) {
                return true;
            }
        }
    }
    return false;
}

/*
    arguments: node
    returns all children of node in a list
*/
list[node] getSubtreeNodes(node subtree) {
    list[node] subtreeNodes = [];
    visit (unsetRec(subtree)) {
		case node n: {
            subtreeNodes += n;
        }
    }
    return toList(toSet(subtreeNodes));
}

/*
    arguments: node
    counts number of children of subtree
    using the arity built-in function the buckets were decreased a lot, so the program could finish in a reasonable time.
    using our custom function that is commented out below, the buckets were too many
*/
int subtreeMass(node currentNode) {
    // int mass = 0;
    // visit (unsetRec(currentNode)) {
    //     case node _ : mass += 1;
    // }
    // return mass;
    return arity(currentNode) + 1;
}

/*
    arguments: node
    returns location of node, otherwise |unresolved:///|
*/
loc getLocation(node subTree) {
	loc location = |unresolved:///|;
	if (Declaration d := subTree) { 
		if (d@src?) {
			location = d@src;
		}
	} else if (Expression e := subTree) {
		if (e@src?) {
			location = e@src;
		}
	} else if (Statement s := subTree) {
		if (s@src?) {
			location = s@src;
		}
	}
	return location;
}

/*
    arguments: node
    normalize identifiers removing names 
    Type II: syntactical copy, changes allowed in variable, type, function identifiers
*/
public node normalizeIdentifiers(node currentNode) {
	return visit (currentNode) {
        case \enum(_, x, y, z) => \enum("enumName", x, y, z)
        case \enumConstant(_, y) => \enumConstant("enumConsName", y) 
		case \enumConstant(_, y, z) => \enumConstant("enumConsName", y, z)
		case \class(_, x, y, z) => \class("className", x, y, z)
		case \interface(_, x, y, z) => \interface("interfaceName", x, y, z)
        // case \method(_, _, list[Declaration] y, list[Expression] z, Statement w) => \method(short(), "methodName", y, z, w)
        // case \method(_, _, list[Declaration] y, list[Expression] z) => \method(short(), "methodName", y, z)
		case \constructor(_, x, y, z) => \constructor("constructorName", x, y, z)
		case \import(_) => \import("importName")
        case \package(_) => \package("packageName")
        case \package(x, "name") => \package(x, "packageName")
        case \typeParameter(_, x) => \typeParameter("typeName", x)
		case \annotationTypeMember(x, _) => \annotationTypeMember(x, "annotName")
		case \annotationTypeMember(x, _, y) => \annotationTypeMember(x, "annotName", y)
		case \parameter(x, _, y) => \parameter(x, "paramName", y)
		case \vararg(x, _) => \vararg(x, "varName") 
        case \fieldAccess(x, y, _) => \fieldAccess(x, y, "fieldName")
        case \fieldAccess(x, _) => \fieldAccess(x, "fieldName")
        case \variable(_,y) => \variable("varName", y) 
		case \variable(_,y,z) => \variable("varName", y, z) 
        case \simpleName(_) => \simpleName("simpleName")
		case \methodCall(x, _, z) => \methodCall(x, "methodCallName", z)
		case \methodCall(x, y, _, z) => \methodCall(x, y, "methodCallName", z) 
		case Modifier _ => \public()
        
        // i dont think we need these, because then they are not clones
    	// case \characterLiteral(_) => \characterLiteral("a")
		// case \booleanLiteral(_) => \booleanLiteral(true)
		// case \stringLiteral(_) => \stringLiteral("name")
		// case \number(_) => \number("0")
	}
}