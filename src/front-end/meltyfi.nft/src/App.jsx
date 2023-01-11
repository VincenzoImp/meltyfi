import './styles/App.css';
import Bootstrap from './bootstrap';
import {BrowserRouter, Routes, Route} from 'react-router-dom';
import MyNavbar from './components/MyNavbar';
import Home from './pages/Home';
import Lotteries from './pages/Lotteries';
import Profile from './pages/Profile'
import MyFooter from './components/MyFooter';
import {Container} from 'react-bootstrap';
import {ThirdwebSDK} from "@thirdweb-dev/sdk";

/*
instanziare qui come costante:
l'address di MeltyFiNFT
la API_KEY di alchemy
la API_KEY di etherscan se dovesse servire

costanti di riverimento:
BlackBean: '#3d1a0c',    colore marrone scuro principale
Tumbleweed: '#d9ad91',   colore marrone chiaro principale
CafeAuLait: '#725a56',   link color when hover
CaputMortuum: '#54251f', colore del logo
BurntUmber: '#8a3a2e'

padding/margin small 1.4rem;
padding/margin medium: 2.8rem;
padding/margin large: 5.6rem;
*/

export const addressMeltyFiNFT = "0x8fDa2E4E75e2966757ccC32369B885F2244BD77A";
export const sdk = new ThirdwebSDK("goerli");

function App() {
    return (
        <div className="App">
            <Bootstrap/>
            <MyNavbar/>
            <Container className="Body">
                <BrowserRouter>
                    <Routes>
                        <Route path="" element={<Home/>}/>
                        <Route path="home" element={<Home/>}/>
                        <Route path="lotteries" element={<Lotteries/>}/>
                        <Route path="profile" element={<Profile/>}/>
                        <Route path="*" element={<Home/>}/>
                    </Routes>
                </BrowserRouter>
            </Container>
            <MyFooter/>
        </div>
    );
}

export default App;