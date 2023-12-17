import { Line } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function CloneClasses({data}) {
  ChartJS.register(
    CategoryScale
  );
  
  var subtreeClonesType1Classes = data?.classes[0];
  var subtreeClonesType1ClassesImproved = data?.classes[1];
  var sequenceClonesType1Classes = data?.classes[2];
  var sequenceClonesType1ClassesImproved = data?.classes[3];

  return (
    <Line 
    width={1000}
    height={1000}
    const data = {{
      labels: ['subtreeType1', 
      'subtreeType1Improved', 
      'sequenceType1', 
      'sequenceType1Improved', 
    ],
      datasets: [{
        label: 'Clone Classes',
        data: [subtreeClonesType1Classes, 
              subtreeClonesType1ClassesImproved,
              sequenceClonesType1Classes, 
              sequenceClonesType1ClassesImproved
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
