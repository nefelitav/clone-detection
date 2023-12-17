import { Line } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function CloneClasses({data}) {
  ChartJS.register(
    CategoryScale
  );
  
  var subtreeClonesType1Classes = data?.classes[0];
  var subtreeClonesType2Classes = data?.classes[1];
  var subtreeClonesType3Classes = data?.classes[2];
  // var sequenceClonesType1Classes = data?.sequenceClones?.type1?.classes;
  // var sequenceClonesType2Classes = data?.sequenceClones?.type2?.classes;
  // var sequenceClonesType3Classes = data?.sequenceClones?.type3?.classes;
  // var generalizedSubtreeClonesType1Classes = data?.generalizedClones?.subtreeClones?.type1?.classes;
  // var generalizedSubtreeClonesType2Classes = data?.generalizedClones?.subtreeClones?.type2?.classes;
  // var generalizedSubtreeClonesType3Classes = data?.generalizedClones?.subtreeClones?.type3?.classes;
  // var generalizedSequenceClonesType1Classes = data?.generalizedClones?.sequenceClones?.type1?.classes;
  // var generalizedSequenceClonesType2Classes = data?.generalizedClones?.sequenceClones?.type2?.classes;
  // var generalizedSequenceClonesType3Classes = data?.generalizedClones?.sequenceClones?.type3?.classes;   

  return (
    <Line 
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
        label: 'Clone Classes',
        data: [subtreeClonesType1Classes, 
              subtreeClonesType2Classes, 
              subtreeClonesType3Classes, 
              // sequenceClonesType1Classes, 
              // sequenceClonesType2Classes, 
              // sequenceClonesType3Classes, 
              // generalizedSubtreeClonesType1Classes,
              // generalizedSubtreeClonesType2Classes,
              // generalizedSubtreeClonesType3Classes,
              // generalizedSequenceClonesType1Classes,
              // generalizedSequenceClonesType2Classes,
              // generalizedSequenceClonesType3Classes   
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
