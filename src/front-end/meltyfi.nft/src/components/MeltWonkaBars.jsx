import {Alert, Container} from "react-bootstrap";
import {useState} from "react";
import Button from "react-bootstrap/Button";
import {ethers} from "ethers";
import {addressMeltyFiNFT} from "../App";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";

function MeltWonkaBars({disabled, wonkaBarsOwned, lottery}) {
    const [showAlert, setShowAlert] = useState(false);
    let onClick;
    if (disabled) {
        onClick = () => {
        }
    } else {
        onClick = async () => {
            try {
                const provider = new ethers.providers.Web3Provider(window.ethereum)
                await provider.send("eth_requestAccounts", []);
                const signer = provider.getSigner();
                let meltyfi = new ethers.Contract(addressMeltyFiNFT, MeltyFiNFT, provider);
                meltyfi = meltyfi.connect(signer);
                const response = await meltyfi.meltWonkaBars(lottery, wonkaBarsOwned);
                console.log("response", response);
            } catch (err) {
                setShowAlert(true);
                console.log(err);
            }
        }
    }
    return <Container>
        <Button className="CardButton" disabled={disabled} onClick={onClick}>
            Melt {wonkaBarsOwned} WonkaBars
        </Button>
        <Alert variant="danger" show={showAlert} onClose={() => setShowAlert(false)} dismissible>
            <Alert.Heading>Oh snap! You got an error!</Alert.Heading>
            <p>Please try again.</p>
        </Alert>
    </Container>
}

export default MeltWonkaBars;