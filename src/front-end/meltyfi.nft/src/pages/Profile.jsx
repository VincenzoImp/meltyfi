import {Col, Container, Row} from 'react-bootstrap';
import {ThirdwebSDK} from "@thirdweb-dev/sdk";
import {useAddress} from "@thirdweb-dev/react";
import ABI from "../contracts/nft.json";
import {useEffect, useState} from "react";
import LotteryCard from "../components/lotteryCard";

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

async function loadProfileData(sdk, address) {
    const meltyfi = await sdk.getContract("0x4dD4451E62f2b5faDf3fFc981880dBB36F97157A", ABI);
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
    return [lotteries, ownedMetadata, appliedMetadata];
}

function getCards(lotteries) {
    return lotteries.map((lottery) => {
        return <Col>
            {LotteryCard({
                src: lottery.image,
                name: lottery.name,
                owner: lottery.owner,
                lottery: lottery.lottery
            })}
        </Col>
    });
}

function Profile() {
    const sdk = new ThirdwebSDK("goerli");
    const address = useAddress();
    const [profileData, setProfileData] = useState(null);
    useEffect(() => {
        loadProfileData(sdk, address).then(setProfileData)
    }, [address]);
    const [_lotteries, owned, applied] = profileData || [[], [], []];
    // console.log("lotteries", lotteries, typeof lotteries);
    // console.log("owned", owned, typeof owned);
    // console.log("applied", applied, typeof applied);
    return (<Container>
        <h1>Chi sono</h1>
        The standard Lorem Ipsum passage<br/>
        Owned:<br/>
        <Container>
            <Row>{getCards(owned)}</Row>
        </Container>
        Applied:<br/>
        <Container>
            <Row>{getCards(applied)}</Row>
        </Container>
    </Container>);
}

export default Profile;
