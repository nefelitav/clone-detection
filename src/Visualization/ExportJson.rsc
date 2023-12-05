module Visualization::ExportJson

import List;
import Map;
import Set;

import Algorithms::SequenceClones;
import Algorithms::SubtreeClones;

import util::Math;
import lang::json::IO;

void exportData(int numberOfClones, int numberOfCloneClasses, int percentageOfDuplicatedLines, int projectLines, list[tuple[node, int]] biggestClassesMembers, list[tuple[node, int]] biggestClonesLines, str algorithm) {

    list[map[str, value]] cloneData =
    [
        (
            "projectLines": 100,
            "subtreeClones": (
                "type1": (
                    "pairs": 10,
                    "classes": 5,
                    "biggestLines": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "biggestMembers": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "duplicatedLines": 10
                ),
                "type2": (
                    "pairs": 20,
                    "classes": 6,
                    "biggestLines": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "biggestMembers": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "duplicatedLines": 20
                ),
                "type3": (
                    "pairs": 30,
                    "classes": 7,
                    "biggestLines": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "biggestMembers": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "duplicatedLines": 30
                )
            ),
            "sequenceClones": (
                "type1": (
                    "pairs": 5,
                    "classes": 8,
                    "biggestLines": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "biggestMembers": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "duplicatedLines": 40
                ),
                "type2": (
                    "pairs": 15,
                    "classes": 9,
                    "biggestLines": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "biggestMembers": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "duplicatedLines": 50
                ),
                "type3": (
                    "pairs": 25,
                    "classes": 10,
                    "biggestLines": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "biggestMembers": (
                        "numbers": [10, 9, 8, 7, 6],
                        "classes": [
                            "x=1", "y=1", "z=1", "w=1", "q=1"
                        ]
                    ),
                    "duplicatedLines": 60            
                )
            ),
            "generalizedClones": (
                "subtreeClones": (
                    "type1": (
                        "pairs": 35,
                        "classes": 11,
                        "biggestLines": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "biggestMembers": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "duplicatedLines": 70
                    ),
                    "type2": (
                        "pairs": 45,
                        "classes": 12,
                        "biggestLines": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "biggestMembers": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "duplicatedLines": 80
                    ),
                    "type3": (
                        "pairs": 55,
                        "classes": 13,
                        "biggestLines": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "biggestMembers": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "duplicatedLines": 90            
                    )
                ),
                "sequenceClones": (
                    "type1": (
                        "pairs": 40,
                        "classes": 14,
                        "biggestLines": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "biggestMembers": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "duplicatedLines": 95
                    ),
                    "type2": (
                        "pairs": 50,
                        "classes": 15,
                        "biggestLines": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "biggestMembers": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "duplicatedLines": 45
                    ),
                    "type3": (
                        "pairs": 60,
                        "classes": 16,
                        "biggestLines": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "biggestMembers": (
                            "numbers": [10, 9, 8, 7, 6],
                            "classes": [
                                "x=1", "y=1", "z=1", "w=1", "q=1"
                            ]
                        ),
                        "duplicatedLines": 56            
                    )
                )
            )
        )
    ];

    writeJSON(|cwd:///clone-visualization/data.json|, cloneData, indent=1);
}