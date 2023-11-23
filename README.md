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

## Clone Detection Using Abstract Syntax Trees
1) Basic Algorithm: detect sub-tree clones, categorizing sub-trees with hash values and buckets.
Eliminate sub-clones. We choose a B of approximately the same order as N; in practice, B=10% N means little additional space at great savings in terms of computation.
This approach works well when we are finding exact
clones. 
we used a hash function that ignores only the identifier names (leaves in the tree). Thus our hashing function puts trees which are similar modulo identifiers into the same hash bins for comparison.

Similarity = 2 x S / (2 x S + L + R)
where:
S = number of shared nodes
L = number of different nodes in sub-tree 1
R = number of different nodes in sub-tree 2

The mass threshold parameter specifies the minimum subtree mass (number of nodes) value to be considered, so that
small pieces of code (e.g., expressions) are ignored.

2) Sequence Detection Algorithm: detection of variable-size sequences of sub-tree clones, detect statement and declaration sequence clones
3) More complex near-miss clones by attempting to generalize combinations of other clones