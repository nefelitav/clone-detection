module Lib::Utilities

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

public map[node, set[loc]] getSubtrees(list[Declaration] decl) {
	map[node, set[loc]] subtrees = ();

	for (d <- decl) {				
		visit(d) {
			case node n : {
                println("!!<n>!!");
				// subtrees[n] = n@src;
			}
		}
	}
	
	return subtrees;
}