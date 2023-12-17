import { Bar } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function ClonePairs({data}) {
  ChartJS.register(
    CategoryScale
  );
  
  var subtreeClonesType1Pairs = data?.pairs[0];
  var subtreeClonesType1PairsImproved = data?.pairs[1];
  var sequenceClonesType1Pairs = data?.pairs[2];
  var sequenceClonesType1PairsImproved = data?.pairs[3];

  return (
    <Bar 
    width={1000}
    height={1000}
    const data = {{
      labels: ['subtreeType1', 
              'subtreeType1Improved', 
              'sequenceType1', 
              'sequenceType1Improved', 
            ],
      datasets: [{
        label: 'Clone Pairs',
        data: [subtreeClonesType1Pairs, 
              subtreeClonesType1PairsImproved,
              sequenceClonesType1Pairs, 
              sequenceClonesType1PairsImproved
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
