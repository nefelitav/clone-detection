module Lib::Utilities

import lang::java::m3::Core;
import lang::java::m3::AST;
import Node;
import String;

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

/*
    arguments: two nodes
    checks if first node is subset of the second one

*/
bool isSubset(node node1, node node2) {
    return contains(toString(node2), toString(node1));
}

/*
    arguments: two lists of nodes, one node
    checks if first list or the third list are subsequences of the node
*/
list[node] isSubcloneSequence(list[node] node1, node node2, list[node] node3) {
    visit(node2) {
        case \block(statements): {
            list[node] sequence = statements;
            if (node1 <= sequence) {
                return node1;
            }
            if (node3 <= sequence) {
                return node3;
            }
        }
    }
    return [];
}

list[node] getSubtreeNodes(node subtree) {
    list[node] subtreeNodes = [];
    visit (subtree) {
		case node n: {
            subtreeNodes += n;
        }
    }
    return subtreeNodes;
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

// Get node location
public loc nodeLocation(loc projectLocation, node subTree) {
	if (Declaration d := subTree) { 
		if (d@src?) {
			projectLocation = d@src;
		}
	} else if (Expression e := subTree) {
		if (e@src?) {
			projectLocation = e@src;
		}
	} else if (Statement s := subTree) {
		if (s@src?) {
			projectLocation = s@src;
		}
	}
	return projectLocation;
}