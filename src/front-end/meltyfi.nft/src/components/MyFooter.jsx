import {Col, Container, Row} from 'react-bootstrap';
import {ThirdwebSDK} from "@thirdweb-dev/sdk";
import ABI from "../contracts/nft.json";
import {useEffect, useState} from "react";

function getLink(address) {
    return `https://goerli.etherscan.io/address/${address}`;
}

async function getLinks() {
    const sdk = new ThirdwebSDK("goerli");
    const meltyfiAddress = "0x4dD4451E62f2b5faDf3fFc981880dBB36F97157A";
    const meltyfi = await sdk.getContract(meltyfiAddress, ABI);
    const logoCollection = await meltyfi.call("addressLogoCollection");
    const chocoChip = await meltyfi.call("addressChocoChip");
    const meltyfiDAO = await meltyfi.call("addressMeltyFiDAO");
    return [meltyfiAddress, logoCollection, chocoChip, meltyfiDAO];
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
                </Col>
                <Col>
                    <div>LogoCollection address: <a href={getLink(logoCollection)}>{logoCollection}</a></div>
                </Col>
                <Col>
                    <div>ChocoChip address: <a href={getLink(chocoChip)}>{chocoChip}</a></div>
                </Col>
                <Col>
                    <div>MeltyFiDAO address: <a href={getLink(meltyfiDAO)}>{meltyfiDAO}</a></div>
                </Col>
            </Row>
        </Container>
    );
}

export default MyFooter;