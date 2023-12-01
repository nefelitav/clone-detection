module Lib::Utilities

import lang::java::m3::Core;
import lang::java::m3::AST;

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

/*
    arguments: node
    normalize identifiers removing names 
    Type II: syntactical copy, changes allowed in variable, type, function identifiers
*/
public node normalizeIdentifiers(node currentNode) {
	return visit (currentNode) {
        case \enum(_, x, y, z) => \enum("name", x, y, z)
        case \enumConstant(_, y) => \enumConstant("name", y) 
		case \enumConstant(_, y, z) => \enumConstant("name", y, z)
		case \class(_, x, y, z) => \class("name", x, y, z)
		case \interface(_, x, y, z) => \interface("name", x, y, z)
        case \method(_, _, y, z, w) => \method(short(), "name", y, z, w)
        case \method(_, _, list[Declaration] y, list[Expression] z) => \method(short(), "methodName", y, z)
		case \constructor(_, x, y, z) => \constructor("name", x, y, z)
		case \import(_) => \import("name")
        case \package(_) => \package("name")
        case \package(x, "name") => \package(x, "name")
        case \typeParameter(_, x) => \typeParameter("name", x)
		case \annotationTypeMember(x, _) => \annotationTypeMember(x, "name")
		case \annotationTypeMember(x, _, y) => \annotationTypeMember(x, "name", y)
		case \parameter(x, _, y) => \parameter(x, "name", y)
		case \vararg(x, _) => \vararg(x, "name") 
        case \fieldAccess(x, y, _) => \fieldAccess(x, y, "name")
        case \fieldAccess(x, _) => \fieldAccess(x, "name")
        case \variable(_,y) => \variable("name", y) 
		case \variable(_,y,z) => \variable("name", y, z) 
        case \simpleName(_) => \simpleName("name")
		case \methodCall(x, _, z) => \methodCall(x, "name", z)
		case \methodCall(x, y, _, z) => \methodCall(x, y, "name", z) 
        case Type _ => short()
		case Modifier _ => \public()
        
        // i dont think we need these, because then they are not clones
    	// case \characterLiteral(_) => \characterLiteral("a")
		// case \booleanLiteral(_) => \booleanLiteral(true)
		// case \stringLiteral(_) => \stringLiteral("name")
		// case \number(_) => \number("0")
	}
}