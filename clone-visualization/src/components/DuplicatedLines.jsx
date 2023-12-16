import { Doughnut } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function DuplicatedLines({data}) {
  ChartJS.register(
    CategoryScale
  );
  
  var projectLines = data?.projectLines;
  var subtreeClonesType1DuplicatedLines = data?.duplicatedLines[0];
  var subtreeClonesType2DuplicatedLines = data?.duplicatedLines[1];
  // var subtreeClonesType3DuplicatedLines = data?.subtreeClones?.type3?.duplicatedLines;
  // var sequenceClonesType1DuplicatedLines = data?.sequenceClones?.type1?.duplicatedLines;
  // var sequenceClonesType2DuplicatedLines = data?.sequenceClones?.type2?.duplicatedLines;
  // var sequenceClonesType3DuplicatedLines = data?.sequenceClones?.type3?.duplicatedLines;
  // var generalizedSubtreeClonesType1DuplicatedLines = data?.generalizedClones?.subtreeClones?.type1?.duplicatedLines;
  // var generalizedSubtreeClonesType2DuplicatedLines = data?.generalizedClones?.subtreeClones?.type2?.duplicatedLines;
  // var generalizedSubtreeClonesType3DuplicatedLines = data?.generalizedClones?.subtreeClones?.type3?.duplicatedLines;
  // var generalizedSequenceClonesType1DuplicatedLines = data?.generalizedClones?.sequenceClones?.type1?.duplicatedLines;
  // var generalizedSequenceClonesType2DuplicatedLines = data?.generalizedClones?.sequenceClones?.type2?.duplicatedLines;
  // var generalizedSequenceClonesType3DuplicatedLines = data?.generalizedClones?.sequenceClones?.type3?.duplicatedLines;   

  return (
        <Doughnut 
            const data = {{
              labels: ['subtreeType1', 
                      'subtreeType2', 
                      // 'subtreeType3', 
                      'projectLines'
                    ],
              datasets: [{
                label: 'Subtree Clones: Duplicated Lines',
                data: [subtreeClonesType1DuplicatedLines, 
                      subtreeClonesType2DuplicatedLines, 
                      // subtreeClonesType3DuplicatedLines, 
                      projectLines
                    ],
                backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(255, 159, 64, 0.2)',
                  'rgba(255, 205, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                ],
                borderColor: [
                  'rgb(255, 99, 132)',
                  'rgb(255, 159, 64)',
                  'rgb(255, 205, 86)',
                  'rgb(75, 192, 192)',
                ],
                borderWidth: 1
              }]
            }}
            />
  );
}