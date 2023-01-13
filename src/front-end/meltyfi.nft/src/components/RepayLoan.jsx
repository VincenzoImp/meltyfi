import {Alert, Container} from 'react-bootstrap';
import {ethers} from "ethers";
import {addressMeltyFiNFT} from "../App";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import Button from "react-bootstrap/Button";
import {useState} from "react";

function RepayLoan({lottery, toRepayETH}) {
    const [showAlert, setShowAlert] = useState(false);
    return <Container>
        <Button className="CardButton" onClick={async () => {
            try {
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
            } catch (err) {
                setShowAlert(true);
                console.log(err);
            }
        }}>
            Repay loan
        </Button>
        <Alert variant="danger" show={showAlert} onClose={() => setShowAlert(false)} dismissible
               style={{marginTop: "1.4rem"}}>
            <Alert.Heading>Oh snap! You got an error!</Alert.Heading>
            <p>Please try again.</p>
        </Alert>
    </Container>
}

export default RepayLoan;
