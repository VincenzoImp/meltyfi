import LotteryCard from '../components/lotteryCard.jsx';
import { Container, Row, Col } from 'react-bootstrap';
import {ThirdwebSDK} from "@thirdweb-dev/sdk";
import {useAddress} from "@thirdweb-dev/react";
import MeltyFiNFT from "../contracts/MeltyFiNFT.json";
import {useEffect, useState} from "react";


function renderLotteries(lotteries) {
    let text = <p>testo html<br/>accapo</p>
    const buyWonkaBars = () => {alert("ciao")}
    return lotteries.map((lottery) => {
        return <Col>
            {LotteryCard({
                src: lottery.image,
                name: lottery.name,
                text,
                onClickFunction: buyWonkaBars,
                onClickText: "Buy Wonka Bars"
            })}
        </Col>
    });
}

async function loadMetadata(sdk, meltyfi, lottery) {
    lottery = parseInt(lottery);
    const contract = await sdk.getContract(await meltyfi.call("getLotteryPrizeContract", lottery), "nft-collection");
    const token = await meltyfi.call("getLotteryPrizeTokenId", lottery);
    const metadata = (await contract.get(token)).metadata;
    const owner = await meltyfi.call("getLotteryOwner", lottery);
    return {lottery, name: metadata.name, image: metadata.image, owner};
}

async function getLotteryInfo(sdk, addressMeltyFiNFT){
    const meltyfi = await sdk.getContract(addressMeltyFiNFT, MeltyFiNFT);

    const lotteries = await meltyfi.call("activeLotteryIds");

    const lottery = lotteries[0];

    const expiration = await meltyfi.call("getLotteryExpirationDate", lottery);

    const wonkaBarPrice = await meltyfi.call("getLotteryWonkaBarPrice", lottery);

    const wonkaBarMaxSupply = await meltyfi.call("getLotteryWonkaBarMaxSupply", lottery);
    const wonkaBarSold = await meltyfi.call("getLotteryWonkaBarsSold", lottery);
    const remainingWonkaBar = wonkaBarMaxSupply - wonkaBarSold;

    const metaData = loadMetadata(sdk, meltyfi, lottery);

}


function Lotteries(props) {
    const sdk = new ThirdwebSDK("goerli");
    getLotteryInfo(sdk, props.addressMeltyFiNFT);

    return (
        <Container>
            <Row>
                <Col>
                    <LotteryCard src="https://i0.wp.com/technoblitz.it/wp-content/uploads/2018/06/immagini-4k.jpg?w=925&ssl=1" />
                </Col>
                <Col>
                    <LotteryCard src="https://media.elrond.com/nfts/asset/Qmf9DdY4tzgU3JEBe8TE88X2uD5pJfAYZRdLvXruRiF1uw/8146.png" />
                </Col>
                <Col>
                    <LotteryCard src="https://media.elrond.com/nfts/asset/Qmf9DdY4tzgU3JEBe8TE88X2uD5pJfAYZRdLvXruRiF1uw/8146.png" />
                </Col>
                <Col>
                    <LotteryCard src="https://media.elrond.com/nfts/asset/Qmf9DdY4tzgU3JEBe8TE88X2uD5pJfAYZRdLvXruRiF1uw/8146.png" />
                </Col>
            </Row>
        </Container>
    );
}

export default Lotteries;