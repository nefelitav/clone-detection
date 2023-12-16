import { Radar } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 
import { Container, Row, Col } from 'react-grid-system';

export default function BiggestMembers({data}) {
  ChartJS.register(
    CategoryScale
  );

  var subtreeClonesType1BiggestMembers = data?.biggestMembers; 
//   var subtreeClonesType2BiggestMembers = data?.subtreeClones?.type2?.biggestMembers;  
//   var subtreeClonesType3BiggestMembers = data?.subtreeClones?.type3?.biggestMembers; 
//   var sequenceClonesType1BiggestMembers = data?.sequenceClones?.type1?.biggestMembers;  
//   var sequenceClonesType2BiggestMembers = data?.sequenceClones?.type2?.biggestMembers;  
//   var sequenceClonesType3BiggestMembers = data?.sequenceClones?.type3?.biggestMembers; 
//   var generalizedSubtreeClonesType1BiggestMembers = data?.generalizedClones?.subtreeClones?.type1?.biggestMembers; 
//   var generalizedSubtreeClonesType2BiggestMembers = data?.generalizedClones?.subtreeClones?.type2?.biggestMembers; 
//   var generalizedSubtreeClonesType3BiggestMembers = data?.generalizedClones?.subtreeClones?.type3?.biggestMembers; 
//   var generalizedSequenceClonesType1BiggestMembers = data?.generalizedClones?.sequenceClones?.type1?.biggestMembers; 
//   var generalizedSequenceClonesType2BiggestMembers = data?.generalizedClones?.sequenceClones?.type2?.biggestMembers; 
//   var generalizedSequenceClonesType3BiggestMembers = data?.generalizedClones?.sequenceClones?.type3?.biggestMembers; 

  return (
        <Radar 
            width={1200}
            height={1200}
            const data = {{
            labels: subtreeClonesType1BiggestMembers?.classes,
            datasets: [{
                label: 'Subtree Type 1: Biggest Classes in members',
                data: subtreeClonesType1BiggestMembers?.numbers, 
                backgroundColor: [
                'rgba(75, 192, 192, 0.2)',
                ],
                borderColor: [
                'rgb(75, 192, 192)',
                ],
                borderWidth: 1
            }]}}
        />
  );
}