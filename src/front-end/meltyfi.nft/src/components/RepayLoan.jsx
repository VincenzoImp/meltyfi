import Card from 'react-bootstrap/Card';
import {Alert, Container} from 'react-bootstrap';
import {ethers} from "ethers";
import {addressMeltyFiNFT} from "../App";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import Button from "react-bootstrap/Button";
import {useState} from "react";

function RepayLoan({wonkaBarsOwned, lottery, toRepayETH}) {
    const [showAlert, setShowAlert] = useState(true);
    let onClick;
    onClick = async () => {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        await provider.send("eth_requestAccounts", []);
        const signer = provider.getSigner();
        let meltyfi = new ethers.Contract(addressMeltyFiNFT, MeltyFiNFT, provider);
        meltyfi = meltyfi.connect(signer);
        const response = await meltyfi.repayLoan(
            lottery,
            {value: ethers.utils.parseEther(toRepayETH.toString())}
        );
        console.log("response", response);
    }
    return <Container>
        <Button className="CardButton" onClick={onClick}>
            Melt {wonkaBarsOwned} WonkaBars
        </Button>
        <Alert variant="danger" show={showAlert} onClose={() => setShowAlert(false)} dismissible>
            <Alert.Heading>Oh snap! You got an error!</Alert.Heading>
            <p>Please try again.</p>
        </Alert>
    </Container>
}

export default RepayLoan;
