import { Doughnut } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function DuplicatedLines({data}) {
  ChartJS.register(
    CategoryScale
  );
  
  var projectLines = data?.projectLines;
  var subtreeClonesType1DuplicatedLines = data?.duplicatedLines[0];
  var subtreeClonesType1DuplicatedLinesImproved = data?.duplicatedLines[1];
  var sequenceClonesType1DuplicatedLines = data?.duplicatedLines[2];
  var sequenceClonesType1DuplicatedLinesImproved = data?.duplicatedLines[3];
  return (
        <Doughnut 
            const data = {{
              labels: ['subtreeType1', 
                      'subtreeType1Improved', 
                      'sequenceType1', 
                      'sequenceType1Improved',
                      'projectLines'
                    ],
              datasets: [{
                label: 'Duplicated Lines',
                data: [subtreeClonesType1DuplicatedLines, 
                      subtreeClonesType1DuplicatedLinesImproved,
                      sequenceClonesType1DuplicatedLines,
                      sequenceClonesType1DuplicatedLinesImproved,
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