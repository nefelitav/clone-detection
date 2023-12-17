module Tests::SubtreeClonesTests

import IO;
import List;
import Algorithms::SubtreeClones;
import Algorithms::GeneralizeClones;

// Tests on TestProject
test bool testFindSubtreeClonesType1() {
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, classes, cloneVisualLocation, cloneVisualLines> = findSubtreeClones(|project://TestProject|, 1, 4, false);
    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines> == <8, 8, 59>;
}

test bool testFindSubtreeClonesType2() {
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, classes, cloneVisualLocation, cloneVisualLines> = findSubtreeClones(|project://TestProject|, 2, 4, false);
    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines> == <33, 5, 38>;
}

test bool testFindSubtreeClonesType3() {
    <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines, projectLines, classes, cloneVisualLocation, cloneVisualLines> = findSubtreeClones(|project://TestProject|, 3, 4, false);
    return <numberOfClones, numberOfCloneClasses, percentageOfDuplicatedLines> == <33, 5, 38>;
}

test bool md5hashTest() {
    return md5Hash("nefeli"(0)) == md5Hash("nefeli"(0)) && md5Hash("nefeli"(0)) != md5Hash("anandan"(1)) ;
}