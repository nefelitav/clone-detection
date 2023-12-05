import './App.css'
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { ClonePairs, CloneClasses, BiggestLines, BiggestMembers, DuplicatedLines } from './components'; 
import data from '../data.json';
import {useState, useEffect} from 'react';

function App() {
    const [data, setData] = useState();

    const fetchJson = () => {
      fetch('../data.json')
      .then(response => {
        return response.json();
      }).then(data => {
        setData(data);
      }).catch((e) => {
        console.log(e.message);
      });
    }

    useEffect(() => {
      fetchJson()
    },[])

  return (
    <Router>
        <Routes>
          <Route path="/pairs" element={
              <ClonePairs data={data}/>} />
          <Route path="/classes" element={
              <CloneClasses data={data}/>} />
          <Route path="/biggest/lines" element={
              <BiggestLines data={data}/>} />
          <Route path="/biggest/members" element={
              <BiggestMembers data={data}/>} />
          <Route path="/duplicatedlines" element={
              <DuplicatedLines data={data}/>} />
        </Routes>
    </Router>
  );
}

export default App;