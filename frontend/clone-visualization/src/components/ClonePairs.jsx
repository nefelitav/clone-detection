import { Bar } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function ClonePairs({data}) {
  ChartJS.register(
    CategoryScale
  );
  
  var subtreeClonesType1Pairs = data?.subtreeClones?.type1?.pairs;
  var subtreeClonesType2Pairs = data?.subtreeClones?.type2?.pairs;
  var subtreeClonesType3Pairs = data?.subtreeClones?.type3?.pairs;
  var sequenceClonesType1Pairs = data?.sequenceClones?.type1?.pairs;
  var sequenceClonesType2Pairs = data?.sequenceClones?.type2?.pairs;
  var sequenceClonesType3Pairs = data?.sequenceClones?.type3?.pairs;
  var generalizedSubtreeClonesType1Pairs = data?.generalizedClones?.subtreeClones?.type1?.pairs;
  var generalizedSubtreeClonesType2Pairs = data?.generalizedClones?.subtreeClones?.type2?.pairs;
  var generalizedSubtreeClonesType3Pairs = data?.generalizedClones?.subtreeClones?.type3?.pairs;
  var generalizedSequenceClonesType1Pairs = data?.generalizedClones?.sequenceClones?.type1?.pairs;
  var generalizedSequenceClonesType2Pairs = data?.generalizedClones?.sequenceClones?.type2?.pairs;
  var generalizedSequenceClonesType3Pairs = data?.generalizedClones?.sequenceClones?.type3?.pairs;   

  return (
    <Bar 
    width={1000}
    height={1000}
    const data = {{
      labels: ['subtreeType1', 
              'subtreeType2', 
              'subtreeType3', 
              'sequenceType1', 
              'sequenceType2', 
              'sequenceType3', 
              'generalizedSubtreeType1',
              'generalizedSubtreeType2',
              'generalizedSubtreeType3',
              'generalizedSequenceType1',
              'generalizedSequenceType2',
              'generalizedSequenceType3'   
            ],
      datasets: [{
        label: 'Clone Pairs',
        data: [subtreeClonesType1Pairs, 
              subtreeClonesType2Pairs, 
              subtreeClonesType3Pairs, 
              sequenceClonesType1Pairs, 
              sequenceClonesType2Pairs, 
              sequenceClonesType3Pairs, 
              generalizedSubtreeClonesType1Pairs,
              generalizedSubtreeClonesType2Pairs,
              generalizedSubtreeClonesType3Pairs,
              generalizedSequenceClonesType1Pairs,
              generalizedSequenceClonesType2Pairs,
              generalizedSequenceClonesType3Pairs   
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
