import { PolarArea } from 'react-chartjs-2';
import { Chart as ChartJS } from 'chart.js/auto'
import {CategoryScale} from 'chart.js'; 
import { Container, Row, Col } from 'react-grid-system';

export default function BiggestLines({data}) {
  ChartJS.register(
    CategoryScale
  );

  var subtreeClonesType1BiggestLines = data?.subtreeClones?.type1?.biggestLines; 
  var subtreeClonesType2BiggestLines = data?.subtreeClones?.type2?.biggestLines;  
  var subtreeClonesType3BiggestLines = data?.subtreeClones?.type3?.biggestLines; 
  var sequenceClonesType1BiggestLines = data?.sequenceClones?.type1?.biggestLines;  
  var sequenceClonesType2BiggestLines = data?.sequenceClones?.type2?.biggestLines;  
  var sequenceClonesType3BiggestLines = data?.sequenceClones?.type3?.biggestLines; 
  var generalizedSubtreeClonesType1BiggestLines = data?.generalizedClones?.subtreeClones?.type1?.biggestLines; 
  var generalizedSubtreeClonesType2BiggestLines = data?.generalizedClones?.subtreeClones?.type2?.biggestLines; 
  var generalizedSubtreeClonesType3BiggestLines = data?.generalizedClones?.subtreeClones?.type3?.biggestLines; 
  var generalizedSequenceClonesType1BiggestLines = data?.generalizedClones?.sequenceClones?.type1?.biggestLines; 
  var generalizedSequenceClonesType2BiggestLines = data?.generalizedClones?.sequenceClones?.type2?.biggestLines; 
  var generalizedSequenceClonesType3BiggestLines = data?.generalizedClones?.sequenceClones?.type3?.biggestLines; 

  return (
    <Container>
    <Row>
        <Col>
        <p>Subtree Type 1</p>
        <PolarArea 
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
        </Col>
        <Col>
        <p>Subtree Type 2</p>
        <PolarArea 
            const data = {{
            labels: subtreeClonesType2BiggestLines?.classes,
            datasets: [{
                label: 'Subtree Type 2: Biggest Classes in lines',
                data: subtreeClonesType2BiggestLines?.numbers, 
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
        </Col>
        <Col>
        <p>Subtree Type 3</p>
        <PolarArea 
            const data = {{
            labels: subtreeClonesType3BiggestLines?.classes,
            datasets: [{
                label: 'Subtree Type 3: Biggest Classes in lines',
                data: subtreeClonesType3BiggestLines?.numbers, 
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
        </Col>
    </Row>
    <Row>
        <Col>
        <p>Sequence Type 1</p>
        <PolarArea 
            const data = {{
            labels: sequenceClonesType1BiggestLines?.classes,
            datasets: [{
                label: 'Sequence Type 1: Biggest Classes in lines',
                data: sequenceClonesType1BiggestLines?.numbers, 
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
        </Col>
        <Col>
        <p>Sequence Type 2</p>
        <PolarArea 
            const data = {{
            labels: sequenceClonesType2BiggestLines?.classes,
            datasets: [{
                label: 'Sequence Type 2: Biggest Classes in lines',
                data: sequenceClonesType2BiggestLines?.numbers, 
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
        </Col>
        <Col>
        <p>Sequence Type 3</p>
        <PolarArea 
            const data = {{
            labels: sequenceClonesType3BiggestLines?.classes,
            datasets: [{
                label: 'Sequence Type 3: Biggest Classes in lines',
                data: sequenceClonesType3BiggestLines?.numbers, 
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
        </Col>
    </Row>
    </Container>
  );
}