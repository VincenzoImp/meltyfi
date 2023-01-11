import LotteryCard from '../components/lotteryCard.jsx';
import { Container, Row, Col } from 'react-bootstrap';
import {ThirdwebSDK} from "@thirdweb-dev/sdk";
import {useAddress} from "@thirdweb-dev/react";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import {useEffect, useState} from "react";
import {addressMeltyFiNFT} from "../App";
import BuyWonkaBar from '../components/buyWonkaBar.jsx';



async function getNFTData(sdk, meltyfi, lottery) {
    const contract = await sdk.getContract(await meltyfi.call("getLotteryPrizeContract", lottery), "nft-collection");
    const token = await meltyfi.call("getLotteryPrizeTokenId", lottery);
    const metadata = (await contract.get(token)).metadata;
    const owner = await meltyfi.call("getLotteryOwner", lottery);
    const collectionName = await contract.call('name');
    console.log(collectionName);
    console.log(metadata.id);
    return {contract, token, name: metadata.name, image: metadata.image, owner};
}

async function getLotteryInfo(meltyfi, lottery){
    let [expiration, wonkaBarPrice, wonkaBarsMaxSupply, wonkaBarsSold] = await Promise.all([
        meltyfi.call("getLotteryExpirationDate", lottery),
        meltyfi.call("getLotteryWonkaBarPrice", lottery),
        meltyfi.call("getLotteryWonkaBarsMaxSupply", lottery),
        meltyfi.call("getLotteryWonkaBarsSold", lottery),
    ]);
    
    const remainingWonkaBars = await (wonkaBarsMaxSupply - wonkaBarsSold);
      
    return {expiration, wonkaBarPrice, wonkaBarsMaxSupply, remainingWonkaBars};
}

async function getLotteries(sdk){
    const meltyfi = await sdk.getContract(addressMeltyFiNFT, MeltyFiNFT);
    const lotteriesId = await meltyfi.call("activeLotteryIds");
    const lotteries = new Array();

    for (const lottery of lotteriesId){
        const {expiration, wonkaBarPrice, wonkaBarsMaxSupply, remainingWonkaBars} = await getLotteryInfo(meltyfi, lottery);
        const {contract, token, name, image} = await getNFTData(sdk, meltyfi, lottery);
        lotteries.push({expiration, wonkaBarPrice, wonkaBarsMaxSupply, remainingWonkaBars, contract, token, name, image})
    }
    return lotteries;

}


function useRenderLotteries(sdk) {
    const [lotteries, setLotteries] = useState([]);
    useEffect(() => {
        getLotteries(sdk).then(setLotteries)
    }, []);

    
    return lotteries.map((lottery) => {
        const date = new Date(parseInt(lottery.expiration) * 1000);
        const dateString = date.toLocaleString();
        const text = <p>
            <li> Expiry date: {dateString} </li>
            <li> WonkaBar price: {parseInt(lottery.wonkaBarPrice)}</li>
            <li> Remaining WonkaBars: {parseInt(lottery.remainingWonkaBars)}</li>
            </p> ;
        const myButton = <BuyWonkaBar/>;
        return <Col>
            {LotteryCard({
                src: lottery.image,
                name: lottery.name,
                text: text,
                lotteryId: 1,
                action: myButton
            })}
        </Col>
    });
}


function Lotteries() {
    const sdk = new ThirdwebSDK("goerli");

    return (
        <Container>
            <Row>
                {useRenderLotteries(sdk)}
            </Row>
        </Container>
    );
}

export default Lotteries;