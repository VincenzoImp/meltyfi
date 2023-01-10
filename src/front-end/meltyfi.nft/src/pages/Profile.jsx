import {Card, Col, Container, Row} from 'react-bootstrap';
import {ThirdwebSDK} from "@thirdweb-dev/sdk";
import {useAddress} from "@thirdweb-dev/react";
import MeltyFiNFT from "../contracts/MeltyFiNFT.json";
import ChocoChip from "../contracts/ChocoChip.json";
import {useEffect, useState} from "react";
import LotteryCard from "../components/lotteryCard";
import {addressMeltyFiNFT} from "../App";


async function asyncFilter(arr, predicate) {
    const results = await Promise.all(arr.map(predicate));
    return arr.filter((_v, index) => results[index]);
}

async function asyncMap(arr, predicate) {
    return await Promise.all(arr.map(predicate));
}

async function loadLotteries(meltyfi, address) {
    const lotteries = await meltyfi.call("activeLotteryIds");
    const owned = await asyncFilter(lotteries, async lottery => await meltyfi.call("getLotteryOwner", lottery) === address);
    const applied = await meltyfi.call("holderInLotteryIds", address);
    return [lotteries, owned, applied];
}

async function loadMetadata(sdk, meltyfi, lottery) {
    lottery = parseInt(lottery);
    const contract = await sdk.getContract(await meltyfi.call("getLotteryPrizeContract", lottery), "nft-collection");
    const token = await meltyfi.call("getLotteryPrizeTokenId", lottery);
    const metadata = (await contract.get(token)).metadata;
    const owner = await meltyfi.call("getLotteryOwner", lottery);
    return {lottery, name: metadata.name, image: metadata.image, owner};
}

async function getChocoChips(sdk, meltyfi, address) {
    const chocoChip = await sdk.getContract(await meltyfi.call("addressChocoChip"), ChocoChip);
    return await chocoChip.call("balanceOf", address);
}

async function loadProfileData(sdk, address) {
    if (address === undefined)
        return [[], [], [], 0]
    const meltyfi = await sdk.getContract(addressMeltyFiNFT, MeltyFiNFT);
    let [lotteries, owned, applied] = await loadLotteries(meltyfi, address);
    let fetched = {};
    const ownedMetadata = new Array(0);
    for (const [_, lottery] of Object.entries(owned)) {
        if (fetched[lottery] === undefined) {
            const metadata = await loadMetadata(sdk, meltyfi, lottery)
            fetched[lottery] = metadata;
            ownedMetadata.push(metadata);
        } else {
            ownedMetadata.push(fetched[lottery]);
        }
    }
    const appliedMetadata = new Array(0);
    for (const [_, lottery] of Object.entries(applied)) {
        if (fetched[lottery] === undefined) {
            const metadata = await loadMetadata(sdk, meltyfi, lottery)
            fetched[lottery] = metadata;
            appliedMetadata.push(metadata);
        } else {
            appliedMetadata.push(fetched[lottery]);
        }
    }
    const chocoChips = Number(await getChocoChips(sdk, meltyfi, address));
    return [lotteries, ownedMetadata, appliedMetadata, chocoChips];
}

function getCards(lotteries) {
    let text = <p>testo html<br/>accapo</p>
    return lotteries.map((lottery) => {
        return <Col>
            {LotteryCard({
                src: lottery.image,
                name: lottery.name,
                text,
                onClickFunction: () => {
                    alert("ciao")
                },
                onClickText: "clicca qui"
            })}
        </Col>
    });
}

function Profile() {
    const sdk = new ThirdwebSDK("goerli");
    const address = useAddress();
    const [profileData, setProfileData] = useState([[], [], [], 0]);
    useEffect(() => {
        loadProfileData(sdk, address).then(setProfileData)
    }, [address]);
    const [_lotteries, owned, applied, chocoChips] = profileData;
    let lotteriesSection;
    if (address !== undefined) {
        lotteriesSection = <Container>
            <div>Your ChocoChip balance: {chocoChips}</div>
            Owned:<br/>
            <Container>
                <Row>{getCards(owned)}</Row>
            </Container>
            Applied:<br/>
            <Container>
                <Row>{getCards(applied)}</Row>
            </Container>
        </Container>
    } else {
        lotteriesSection = <p>Connect your wallet to see your profile</p>
    }
    return <Container>
        <h1>Chi sono</h1>
        The standard Lorem Ipsum passage<br/>
        {lotteriesSection}
    </Container>;
}

export default Profile;
