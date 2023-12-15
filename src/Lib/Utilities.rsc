module Lib::Utilities

import lang::java::m3::Core;
import lang::java::m3::AST;
import Node;
import String;
import List;
import Set;
import Type;
import IO;

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
    // not sure if this is needed. Useful if they are not in the same block i guess
    list[loc] supersequenceLocs = [getLocation(n) | n <- supersequence];
    list[loc] subsequenceLocs = [getLocation(n) | n <- subsequence];
    for (supersequenceLoc <- supersequenceLocs, subsequenceLoc <- subsequenceLocs) {
        if ((supersequenceLoc.path == subsequenceLoc.path) && (supersequenceLoc.begin.line < subsequenceLoc.begin.line) && (supersequenceLoc.end.line > subsequenceLoc.end.line)) {
            return true;
        }
    }
    return false;
}

/*
    arguments: node, massThreshold
    returns all children of node in a list
*/
set[node] getSubtreeNodes(node subtree, int massThreshold) {
    set[node] subtreeNodes = {};
    visit (subtree) {
		case node n: {
            if (subtreeMass(subtree) >= massThreshold) {
                subtreeNodes += n;
            }
        }
    }
    return subtreeNodes;
}

/*
    arguments: node, massThreshold
    returns all children of node in a list, without locations
*/
set[node] getSubtreeNodesUnsetRec(node subtree, int massThreshold) {
    set[node] subtreeNodes = {};
    visit (subtree) {
		case node n: {
            if (subtreeMass(subtree) >= massThreshold) {
                subtreeNodes += unsetRec(n);
            }
        }
    }
    return subtreeNodes;
}

/*
    arguments: node
    counts number of children of subtree
    using the arity built-in function the buckets were decreased a lot, so the program could finish in a reasonable time.
    using our custom function that is commented out below, the buckets were too many
*/
int subtreeMass(node currentNode) {
    int mass = 0;
    visit (unsetRec(currentNode)) {
        case node _ : mass += 1;
    }
    return mass;
    // return arity(currentNode) + 1;
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
    arguments: ast
    normalize identifiers removing names 
    Type II: syntactical copy, changes allowed in variable, type, function identifiers
*/
set[Declaration] normalizeAST(set[Declaration] ast) {
    return visit(ast) {
        case \enum(_, x, y, z) => \enum("enumName", x, y, z)
        case \enumConstant(_, y) => \enumConstant("enumConsName", y) 
		case \enumConstant(_, y, z) => \enumConstant("enumConsName", y, z)
		case \class(_, x, y, z) => \class("className", x, y, z)
		case \interface(_, x, y, z) => \interface("interfaceName", x, y, z)
        case \method(x, _, y, z, w) => \method(x, "methodName", y, z, w)
        // case \method(x, _, y, z) => \method(x, "methodName", y, z)
		case \constructor(_, x, y, z) => \constructor("constructorName", x, y, z)
		case \import(_) => \import("importName")
        case \package(_) => \package("packageName")
        case \package(x, _) => \package(x, "packageName")
        case \typeParameter(_, x) => \typeParameter("typeName", x)
        case \annotationType(_, body) => \annotationType("annotName", body)
		case \annotationTypeMember(x, _) => \annotationTypeMember(x, "annotNameMember")
		case \annotationTypeMember(x, _, y) => \annotationTypeMember(x, "annotNameMember", y)
		case \parameter(x, _, y) => \parameter(x, "paramName", y)
		case \vararg(x, _) => \vararg(x, "varName") 
        case \assignment(lhs, _, rhs) => \assignment(lhs, "=", rhs)
        case \characterLiteral(_) => \characterLiteral("x")
        case \fieldAccess(x, y, _) => \fieldAccess(x, y, "fieldAccessName")
        case \fieldAccess(x, _) => \fieldAccess(x, "fieldAccessName")
        case \methodCall(x, _, y) => \methodCall(x, "methodCallName", y)
        case \methodCall(x, z, _, y) => \methodCall(x, z, "methodCallName", y)
        case \number(_) => \number("0")
        case \booleanLiteral(_) => \booleanLiteral(true)
        case \stringLiteral(_) => \stringLiteral("x")
        case \variable(_, x) => \variable("varName", x)
        case \variable(_, x, y) => \variable("varName", x, y)
        case \infix(lhs, _, rhs) => \infix(lhs, "+", rhs)
        case \postfix(x, _) => \postfix(x, "+")
        case \prefix(_, x) => \prefix("+", x)
        case \simpleName(_) => \simpleName("simpleName")
        case \markerAnnotation(_) => \markerAnnotation("markerAnnotationName")
        case \normalAnnotation(_, x) => \normalAnnotation("markerAnnotationName", x)
        case \memberValuePair(_, x) => \memberValuePair("memberValuePairName", x)
        case \singleMemberAnnotation(_, x) => \singleMemberAnnotation("singleMemberAnnotationName", x)
        case \break(_) => \break("breakName")
        case \label(_, x) => \label("labelName", x)
        case \continue(_) => \continue("continueName")
        case \int() => Type::\short()
        case short() => Type::\short()
        case long() => Type::\short()
        case float() => Type::\short()
        case double() => Type::\short()
        case char() => Type::\short()
        case string() => Type::\short()
        case byte() => Type::\short()
        case \void() => Type::\short()
        case \boolean() => Type::\short()
        case \private() => \public()
        case \public() => \public()
        case \protected() => \public()
        case \friendly() => \public()
    }
}