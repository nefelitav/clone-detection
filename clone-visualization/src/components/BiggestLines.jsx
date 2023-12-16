import { PolarArea } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 

export default function BiggestLines({data}) {
  ChartJS.register(
    CategoryScale
  );

  var subtreeClonesType1BiggestLines = data?.biggestLines; 
//   var subtreeClonesType2BiggestLines = data?.biggestLines;  
//   var subtreeClonesType3BiggestLines = data?.subtreeClones?.type3?.biggestLines; 
//   var sequenceClonesType1BiggestLines = data?.sequenceClones?.type1?.biggestLines;  
//   var sequenceClonesType2BiggestLines = data?.sequenceClones?.type2?.biggestLines;  
//   var sequenceClonesType3BiggestLines = data?.sequenceClones?.type3?.biggestLines; 
//   var generalizedSubtreeClonesType1BiggestLines = data?.generalizedClones?.subtreeClones?.type1?.biggestLines; 
//   var generalizedSubtreeClonesType2BiggestLines = data?.generalizedClones?.subtreeClones?.type2?.biggestLines; 
//   var generalizedSubtreeClonesType3BiggestLines = data?.generalizedClones?.subtreeClones?.type3?.biggestLines; 
//   var generalizedSequenceClonesType1BiggestLines = data?.generalizedClones?.sequenceClones?.type1?.biggestLines; 
//   var generalizedSequenceClonesType2BiggestLines = data?.generalizedClones?.sequenceClones?.type2?.biggestLines; 
//   var generalizedSequenceClonesType3BiggestLines = data?.generalizedClones?.sequenceClones?.type3?.biggestLines; 

  return (
        <PolarArea 
            width={1200}
            height={1200}
            const data = {{
            labels: subtreeClonesType1BiggestLines?.classes,
            datasets: [{
                label: 'Subtree Type 1: Biggest Classes in lines',
                data: subtreeClonesType1BiggestLines?.numbers, 
                backgroundColor: [
                'rgba(75, 192, 192, 0.2)',
                'rgba(255, 159, 64, 0.2)',
                'rgba(255, 205, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(255, 99, 132, 0.2)',
                ],
                borderColor: [
                'rgb(75, 192, 192)',
                'rgb(255, 159, 64)',
                'rgb(255, 205, 86)',
                'rgb(75, 192, 192)',
                'rgb(255, 99, 132)',
                ],
                borderWidth: 1
            }]}}
        />
    
  );
}