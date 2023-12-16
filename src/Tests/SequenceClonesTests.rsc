module Tests::SequenceClonesTests

import util::Math;
import Algorithms::SequenceClones;

// Tests on TestProject
test bool testFindSequenceClonesType1() {
    return findSequenceClones(|project://TestProject|, 1, 3, false) == <3, 3, _, _, _>;
}

test bool testFindSequenceClonesType2() {
    return findSequenceClones(|project://TestProject|, 1, 3, false) == <3, 3, _, _, _>;
}
