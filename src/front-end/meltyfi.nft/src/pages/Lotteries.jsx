import LotteryCard from '../components/lotteryCard.jsx';
import { Row, Col, Tabs, Tab } from 'react-bootstrap';
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import { useEffect, useState } from "react";
import { addressMeltyFiNFT, sdk } from "../App";
import BuyWonkaBar from '../components/buyWonkaBar.jsx';
import NftCard from '../components/nftCard.jsx';
import CreateLottery from '../components/createLottery';
import { ethers } from "ethers";
import axios from 'axios';



async function getLotteryInfo(meltyfi, lottery) {

    let lotteryId = parseInt(lottery);
    let [expirationDate, , , prizeContract, prizeTokenId, , , wonkaBarsSold, wonkaBarsMaxSupply, wonkaBarPrice] = await meltyfi.call(
        "getLottery", lotteryId);

    let contract = await sdk.getContract(prizeContract, "nft-collection");

    let [nft, collection] = await Promise.all([
        contract.get(prizeTokenId),
        contract.call("name"),
    ]);

    expirationDate = new Date(Number(expirationDate) * 1000);
    wonkaBarsMaxSupply = Number(wonkaBarsMaxSupply);
    wonkaBarsSold = Number(wonkaBarsSold);
    wonkaBarPrice = ethers.utils.formatEther(parseInt(wonkaBarPrice));
    return {
        lotteryId,
        name: nft.metadata.name,
        image: nft.metadata.image,
        prizeTokenId: nft.metadata.id,
        collection,
        expirationDate,
        wonkaBarsMaxSupply,
        wonkaBarsSold,
        wonkaBarPrice,
    };
}


async function getLotteries() {
    const meltyfi = await sdk.getContract(addressMeltyFiNFT, MeltyFiNFT);
    const lotteriesId = await meltyfi.call("activeLotteryIds");
    const lotteries = [];

    for (const lottery of lotteriesId) {
        const lotteryInfo = await getLotteryInfo(meltyfi, lottery);
        lotteries.push(lotteryInfo);
    }
    return lotteries;
}


function RenderLotteries() {
    const [lotteries, setLotteries] = useState([]);
    useEffect(() => {
        getLotteries().then(setLotteries)
    }, []);

    const cards = lotteries.map((lottery) => {
        const dateString = lottery.expirationDate.toLocaleString();
        const text = <p>
            <li className='NoDot'> <b>Expiry date:</b> {dateString} </li>
            <li className='NoDot'> <b>WonkaBar price:</b> {lottery.wonkaBarPrice < 0.00001 ? "< 0.00001" : lottery.wonkaBarPrice} ETH</li>
            <li className='NoDot'> <b>Sold WonkaBars:</b> {lottery.wonkaBarsSold}/{lottery.wonkaBarsMaxSupply}</li>
        </p>;
        const buyWonkaBar = <BuyWonkaBar nftImg={lottery.image} tokenId={lottery.prizeTokenId} collection={lottery.collection}
            lotteryId={lottery.lotteryId} expirationDate={dateString} wonkaBarPrice={lottery.wonkaBarPrice} />;
        return <Col>
            {LotteryCard({
                src: lottery.image,
                tokenId: lottery.prizeTokenId,
                collection: lottery.collection,
                text: text,
                lotteryId: lottery.lotteryId,
                action: buyWonkaBar
            })}
        </Col>
    });
    return <Row align='center'>{cards}</Row>
}


async function getNFTs() {

    async function getAssets() {
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum)
            await provider.send("eth_requestAccounts", []);
            const signer = provider.getSigner()
            const address = await signer.getAddress()
            const response = await axios.get('https://testnets-api.opensea.io/api/v1/assets?format=json&owner=' + address);
            const assets = response.data.assets;
            return assets;
        } catch (error) {
            console.error(error);
        }
    }

    let nfts = await getAssets();
    let nftsInfo = [];

    for (const nft of nfts) {
        if (nft.asset_contract.schema_name === "ERC721") {
            const image = nft.image_url;
            const collection = nft.asset_contract.name;
            const tokenId = nft.token_id;
            const contract = nft.asset_contract.address;
            const nftInfo = { image, collection, tokenId, contract }
            nftsInfo.push(nftInfo);
        }
    }

    return nftsInfo;
}

function RenderNFTs() {
    const [nfts, setNfts] = useState([]);
    useEffect(() => {
        getNFTs().then(setNfts)
    }, []);

    const cards = nfts.map((nft) => {
        const createLottery = <CreateLottery nftImg={nft.image} tokenId={nft.tokenId} collection={nft.collection} contract={nft.contract} />;
        return <Col>
            {NftCard({
                src: nft.image,
                tokenId: nft.tokenId,
                collection: nft.collection,
                action: createLottery
            })}
        </Col>
    });
    return <Row align='center'>{cards}</Row>;
}


function Lotteries() {
    return (
        <Tabs className='Tabs mb-3'
            defaultActiveKey="browse"
            id="justify-tab-example"
            justify
        >
            <Tab eventKey="browse" title="Browse Lotteries">
                <h1 className='LotteriesTitle'>Buy WonkaBars of some lottery</h1>
                <RenderLotteries />
            </Tab>
            <Tab eventKey="create" title="Create Lottery">
                <h1 className='LotteriesTitle'>Create a lottery using your NFTs as collateral</h1>
                <RenderNFTs />
            </Tab>
        </Tabs>
    );

}

export default Lotteries; 