import { Radar } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 
import { Container, Row, Col } from 'react-grid-system';

export default function BiggestMembers({data}) {
  ChartJS.register(
    CategoryScale
  );

  var subtreeClonesType1BiggestMembers = data?.subtreeClones?.type1?.biggestMembers; 
  var subtreeClonesType2BiggestMembers = data?.subtreeClones?.type2?.biggestMembers;  
  var subtreeClonesType3BiggestMembers = data?.subtreeClones?.type3?.biggestMembers; 
  var sequenceClonesType1BiggestMembers = data?.sequenceClones?.type1?.biggestMembers;  
  var sequenceClonesType2BiggestMembers = data?.sequenceClones?.type2?.biggestMembers;  
  var sequenceClonesType3BiggestMembers = data?.sequenceClones?.type3?.biggestMembers; 
  var generalizedSubtreeClonesType1BiggestMembers = data?.generalizedClones?.subtreeClones?.type1?.biggestMembers; 
  var generalizedSubtreeClonesType2BiggestMembers = data?.generalizedClones?.subtreeClones?.type2?.biggestMembers; 
  var generalizedSubtreeClonesType3BiggestMembers = data?.generalizedClones?.subtreeClones?.type3?.biggestMembers; 
  var generalizedSequenceClonesType1BiggestMembers = data?.generalizedClones?.sequenceClones?.type1?.biggestMembers; 
  var generalizedSequenceClonesType2BiggestMembers = data?.generalizedClones?.sequenceClones?.type2?.biggestMembers; 
  var generalizedSequenceClonesType3BiggestMembers = data?.generalizedClones?.sequenceClones?.type3?.biggestMembers; 

  return (
    <Container>
    <Row>
        <Col>
        <p>Subtree Type 1</p>
        <Radar 
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
        </Col>
        <Col>
        <p>Subtree Type 2</p>
        <Radar 
            const data = {{
            labels: subtreeClonesType2BiggestMembers?.classes,
            datasets: [{
                label: 'Subtree Type 2: Biggest Classes in members',
                data: subtreeClonesType2BiggestMembers?.numbers, 
                backgroundColor: [
                'rgba(75, 192, 192, 0.2)',
                ],
                borderColor: [
                'rgb(75, 192, 192)',
                ],
                borderWidth: 1
            }]}}
        />
        </Col>
        <Col>
        <p>Subtree Type 3</p>
        <Radar 
            const data = {{
            labels: subtreeClonesType3BiggestMembers?.classes,
            datasets: [{
                label: 'Subtree Type 3: Biggest Classes in members',
                data: subtreeClonesType3BiggestMembers?.numbers, 
                backgroundColor: [
                'rgba(75, 192, 192, 0.2)',
                ],
                borderColor: [
                'rgb(75, 192, 192)',
                ],
                borderWidth: 1
            }]}}
        />
        </Col>
    </Row>
    <Row>
        <Col>
        <p>Sequence Type 1</p>
        <Radar 
            const data = {{
            labels: sequenceClonesType1BiggestMembers?.classes,
            datasets: [{
                label: 'Sequence Type 1: Biggest Classes in members',
                data: sequenceClonesType1BiggestMembers?.numbers, 
                backgroundColor: [
                'rgba(75, 192, 192, 0.2)',
                ],
                borderColor: [
                'rgb(75, 192, 192)',
                ],
                borderWidth: 1
            }]}}
        />
        </Col>
        <Col>
        <p>Sequence Type 2</p>
        <Radar 
            const data = {{
            labels: sequenceClonesType2BiggestMembers?.classes,
            datasets: [{
                label: 'Sequence Type 2: Biggest Classes in members',
                data: sequenceClonesType2BiggestMembers?.numbers, 
                backgroundColor: [
                'rgba(75, 192, 192, 0.2)',
                ],
                borderColor: [
                'rgb(75, 192, 192)',
                ],
                borderWidth: 1
            }]}}
        />
        </Col>
        <Col>
        <p>Sequence Type 3</p>
        <Radar 
            const data = {{
            labels: sequenceClonesType3BiggestMembers?.classes,
            datasets: [{
                label: 'Sequence Type 3: Biggest Classes in members',
                data: sequenceClonesType3BiggestMembers?.numbers, 
                backgroundColor: [
                'rgba(75, 192, 192, 0.2)',
                ],
                borderColor: [
                'rgb(75, 192, 192)',
                ],
                borderWidth: 1
            }]}}
        />
        </Col>
    </Row>
    </Container>
  );
}