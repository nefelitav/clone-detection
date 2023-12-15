module Tests::SubtreeClonesTests

import IO;
import Node;
import List;
import Map;
import util::Math;
import DateTime;
import Set;
import Type;
import Boolean;
import String;

// Tests on TestProject
test bool testFindSubtreeClonesType1() {
    return findSubtreeClones(|project://TestProject|, 1, 4, false) == <7, 7, _, _, _>;
}

test bool testFindSubtreeClonesType2() {
    return findSubtreeClones(|project://TestProject|, 1, 4, false) == <31, 3, _, _, _>;
}

test bool md5hashTest() {
    return md5Hash("nefeli"(0)) == md5Hash("nefeli"(0)) && md5Hash("nefeli"(0)) != md5Hash("anandan"(1)) ;
}