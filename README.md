# clone-detection

- AST-based clone detection
- implement and compare algorithms
- present design of solution, from literature
- describe implementation
- evaluation and reflection of design
- clone classes are written to a file in text
- clone classes that are included in others are dropped from the results
- scalable - hsqldb
- statistics, % of duplicated lines, number of clones, number of clone classes, biggest clone(in lines), biggest clone class(in members), example clones
- a java program to show correctness of our algorithms
- type of clones your tool detects, detailed definition that enables critical assessment of project
- detailed discussion of the differences in cloning statistics of algorithms
- to score higher implement many algorithms or visualizations

# Literature Conclusions

- Type I: exact copy, ignoring whitespace and comments.
- Type II: syntactical copy, changes allowed in variable, type, function identifiers.
- Type III: copy with changed, added, and deleted statements.
- Type IV: functionality is the same, code may be completely different.

# TODO
1) Clean code, comments
2) Cases for type 1, type 2, type 3, type 4
3) Parametrize thresholds etc
4) Export json
5) Make frontend
6) Create a test project
7) Tests
8) Report
9) Ensure results are correct