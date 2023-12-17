module Tests::SequenceClonesTests

import util::Math;
import Algorithms::SequenceClones;
import Algorithms::GeneralizeClones;

// Tests on TestProject
test bool testFindSequenceClonesType1() {
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, clonePairs, cloneVisualLocation, cloneVisualLines> = findSequenceClones(|project://TestProject|, 1, 3, false);
    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines> == <3, 3, 43>;
}

test bool testFindSequenceClonesType2() {
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, clonePairs, cloneVisualLocation, cloneVisualLines> = findSequenceClones(|project://TestProject|, 2, 3, false);
    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines> == <3, 3, 43>;
}

test bool testFindSequenceClonesType3() {
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, clonePairs, cloneVisualLocation, cloneVisualLines> = findSequenceClones(|project://TestProject|, 3, 3, false);
    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines> == <3, 3, 43>;
}
