# Clone Detection
In this program we use Rascal to detect the following types of clones in software projects:

- Type I: exact copy, ignoring whitespace and comments.
- Type II: syntactical copy, changes allowed in variable, type, function identifiers.
- Type III: copy with changed, added, and deleted statements.
  
We used the following algorithms that are described in the Clone Detection using Abstract Syntax Trees paper:
- Subtrees Algorithm
- Sequences Algorithm
- Generalization Algorithm
  
And we end up with the following statistics:
- Clone pairs
- Clone classes
- Percentage of duplicated lines
- Biggest clone class in lines
- Biggest clone class in members
