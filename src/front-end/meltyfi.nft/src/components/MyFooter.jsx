import {Col, Container, Row} from 'react-bootstrap';
import {ThirdwebSDK} from "@thirdweb-dev/sdk";
import ABI from "../contracts/MeltyFiNFT.json";
import {useEffect, useState} from "react";
import {addressMeltyFiNFT} from "../App";

function getLink(address) {
    return `https://goerli.etherscan.io/address/${address}`;
}

async function getLinks() {
    const sdk = new ThirdwebSDK("goerli");
    const meltyfi = await sdk.getContract(addressMeltyFiNFT, ABI);
    const logoCollection = await meltyfi.call("addressLogoCollection");
    const chocoChip = await meltyfi.call("addressChocoChip");
    const meltyfiDAO = await meltyfi.call("addressMeltyFiDAO");
    return [addressMeltyFiNFT, logoCollection, chocoChip, meltyfiDAO];
}

function MyFooter() {
    const [links, setLinks] = useState([]);
    useEffect(() => {
        getLinks().then(setLinks)
    }, []);
    const [meltyfi, logoCollection, chocoChip, meltyfiDAO] = links;
    return (
        <Container className='Footer'>
            <Row>
                <Col>
                    <div>MeltyFiNFT address: <a href={getLink(meltyfi)}>{meltyfi}</a></div>
                    <div>MeltyFiDAO address: <a href={getLink(meltyfiDAO)}>{meltyfiDAO}</a></div>
                </Col>
                <Col>
                    <div>ChocoChip address: <a href={getLink(chocoChip)}>{chocoChip}</a></div>
                    <div>LogoCollection address: <a href={getLink(logoCollection)}>{logoCollection}</a></div>
                </Col>
            </Row>
        </Container>
    );
}

export default MyFooter;