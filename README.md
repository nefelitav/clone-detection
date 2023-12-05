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
1) Export json
2) Make frontend
3) Create a test project. Tests
4) Report
5) Ensure results are correct
6) Improve time

# Questions
1) Are three algorithms enough if they work for type 1,2,3?
2) What to keep in normalizeIdentifiers?
3) Are our statistics correct?
4) Is the way we remove subclones correct?
5) What to do with type 2 and 3?

# Visualizations
- number of clone pairs and number of clone classes of each algorithm
- 5 biggest clone classes in lines for each algorithm
- 5 biggest clone class in members for each algorithm
- percentage of duplicated lines for each algorithm