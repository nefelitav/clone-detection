import { Bar } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function ClonePairs({data}) {
  ChartJS.register(
    CategoryScale
  );
  
  var subtreeClonesType1Pairs = data?.pairs[0];
  var subtreeClonesType2Pairs = data?.pairs[1];
  var subtreeClonesType3Pairs = data?.pairs[2];
  // var sequenceClonesType1Pairs = data?.pairs[3];
  // var sequenceClonesType2Pairs = data?.pairs[0];
  // var sequenceClonesType3Pairs = data?.pairs[0];
  // var generalizedSubtreeClonesType1Pairs = data?.pairs[0];
  // var generalizedSubtreeClonesType2Pairs = data?.pairs[0];
  // var generalizedSubtreeClonesType3Pairs = data?.pairs[0];
  // var generalizedSequenceClonesType1Pairs = data?.pairs[0];
  // var generalizedSequenceClonesType2Pairs = data?.pairs[0];
  // var generalizedSequenceClonesType3Pairs = data?.pairs[0];

  return (
    <Bar 
    width={1000}
    height={1000}
    const data = {{
      labels: ['subtreeType1', 
              'subtreeType2', 
              'subtreeType3', 
              // 'sequenceType1', 
              // 'sequenceType2', 
              // 'sequenceType3', 
              // 'generalizedSubtreeType1',
              // 'generalizedSubtreeType2',
              // 'generalizedSubtreeType3',
              // 'generalizedSequenceType1',
              // 'generalizedSequenceType2',
              // 'generalizedSequenceType3'   
            ],
      datasets: [{
        label: 'Clone Pairs',
        data: [subtreeClonesType1Pairs, 
              subtreeClonesType2Pairs, 
              subtreeClonesType3Pairs, 
              // sequenceClonesType1Pairs, 
              // sequenceClonesType2Pairs, 
              // sequenceClonesType3Pairs, 
              // generalizedSubtreeClonesType1Pairs,
              // generalizedSubtreeClonesType2Pairs,
              // generalizedSubtreeClonesType3Pairs,
              // generalizedSequenceClonesType1Pairs,
              // generalizedSequenceClonesType2Pairs,
              // generalizedSequenceClonesType3Pairs   
            ],
        backgroundColor: [
          'rgba(255, 99, 132, 0.2)',
          'rgba(255, 99, 132, 0.2)',
          'rgba(255, 99, 132, 0.2)',

          'rgba(255, 159, 64, 0.2)',
          'rgba(255, 159, 64, 0.2)',
          'rgba(255, 159, 64, 0.2)',

          'rgba(255, 205, 86, 0.2)',
          'rgba(255, 205, 86, 0.2)',
          'rgba(255, 205, 86, 0.2)',

          'rgba(75, 192, 192, 0.2)',
          'rgba(75, 192, 192, 0.2)',
          'rgba(75, 192, 192, 0.2)',
        ],
        borderColor: [
          'rgb(255, 99, 132)',
          'rgb(255, 99, 132)',
          'rgb(255, 99, 132)',

          'rgb(255, 159, 64)',
          'rgb(255, 159, 64)',
          'rgb(255, 159, 64)',

          'rgb(255, 205, 86)',
          'rgb(255, 205, 86)',
          'rgb(255, 205, 86)',

          'rgb(75, 192, 192)',
          'rgb(75, 192, 192)',
          'rgb(75, 192, 192)',
        ],
        borderWidth: 1
      }]
    }}
     />
  );
}
