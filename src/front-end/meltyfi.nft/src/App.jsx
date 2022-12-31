import './App.css';
import Bootstrap from './Bootstrap';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import MyNavbar from './components/MyNavbar';
import Home from './pages/Home';
import Lotteries from './pages/Lotteries';
import Profile from './pages/Profile'
import MyFooter from './components/MyFooter';

/*
const colors = {
	Tumbleweed: '#d9ad91',
	CaputMortuum: '#54251f',
	BlackBean: '#3d1a0c',
	CafeAuLait: '#a97d61',
	BurntUmber: '#8a3a2e'
}
*/

function App() {
	return (
		<div className="App">
			<Bootstrap />
			<MyNavbar />
			<BrowserRouter>
				<Routes>
					<Route path="" element={<Home />} />
					<Route path="home" element={<Home />} />
					<Route path="lotteries" element={<Lotteries />} />
					<Route path="profile" element={<Profile />} />
					<Route path="*" element={<Home />} />
				</Routes>
			</BrowserRouter>
			<MyFooter />
		</div>
	);
}

export default App;
