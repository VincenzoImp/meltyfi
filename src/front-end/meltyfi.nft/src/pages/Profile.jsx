import {Card, Col, Container, Row} from "react-bootstrap";
import {useAddress} from "@thirdweb-dev/react";
import MeltyFiNFT from "../contracts/MeltyFiNFT.json";
import ChocoChip from "../contracts/ChocoChip.json";
import {useEffect, useState} from "react";
import LotteryCard from "../components/lotteryCard";
import {addressMeltyFiNFT, sdk} from "../App";


async function asyncFilter(arr, predicate) {
    const results = await Promise.all(arr.map(predicate));
    return arr.filter((_v, index) => results[index]);
}

// async function asyncMap(arr, predicate) {
//     return await Promise.all(arr.map(predicate));
// }

async function loadLotteries(meltyfi, address) {
    const lotteries = await meltyfi.call("activeLotteryIds");
    const [owned, applied] = await Promise.all([
            asyncFilter(lotteries, async lottery => await meltyfi.call("getLotteryOwner", lottery) === address),
            meltyfi.call("holderInLotteryIds", address)
        ])
    ;
    return [lotteries, owned, applied];
}

async function loadMetadata(meltyfi, lottery, address) {
    lottery = parseInt(lottery);
    const prizeContract = await meltyfi.call("getLotteryPrizeContract", lottery);
    let [contract, token] = await Promise.all([
        sdk.getContract(prizeContract, "nft-collection"),
        meltyfi.call("getLotteryPrizeTokenId", lottery)
    ]);
    let [nft, owner, expirationDate, wonkaBarsTotal, wonkaBarsSold, wonkaBarsOwned, winner, state] = await Promise.all([
        contract.get(token),
        meltyfi.call("getLotteryOwner", lottery),
        meltyfi.call("getLotteryExpirationDate", lottery),
        meltyfi.call("getLotteryWonkaBarsMaxSupply", lottery),
        meltyfi.call("getLotteryWonkaBarsSold", lottery),
        meltyfi.call("balanceOf", address, lottery),
        meltyfi.call("getWinner", lottery),
        meltyfi.call("getLotteryState", lottery),
    ]);
    nft = nft.metadata;
    expirationDate = new Date(Number(expirationDate) * 1000);
    wonkaBarsTotal = Number(wonkaBarsTotal);
    wonkaBarsSold = Number(wonkaBarsSold);
    wonkaBarsOwned = Number(wonkaBarsOwned);
    return {
        lottery,
        name: nft.name,
        image: nft.image,
        owner,
        expirationDate,
        wonkaBarsTotal,
        wonkaBarsSold,
        wonkaBarsOwned,
        winner,
        state
    };
}

async function getChocoChips(meltyfi, address) {
    const chocoChip = await sdk.getContract(await meltyfi.call("addressChocoChip"), ChocoChip);
    return await chocoChip.call("balanceOf", address);
}

async function loadProfileData(address) {
    if (address === undefined)
        return [[], [], [], 0]
    const meltyfi = await sdk.getContract(addressMeltyFiNFT, MeltyFiNFT);
    let [lotteries, owned, applied] = await loadLotteries(meltyfi, address);
    let fetched = {};
    const ownedMetadata = new Array(0);
    // eslint-disable-next-line no-unused-vars
    for (const [_, lottery] of Object.entries(owned)) {
        if (fetched[lottery] === undefined) {
            const metadata = await loadMetadata(meltyfi, lottery, address)
            fetched[lottery] = metadata;
            ownedMetadata.push(metadata);
        } else {
            ownedMetadata.push(fetched[lottery]);
        }
    }
    const appliedMetadata = new Array(0);
    // eslint-disable-next-line no-unused-vars
    for (const [_, lottery] of Object.entries(applied)) {
        if (fetched[lottery] === undefined) {
            const metadata = await loadMetadata(meltyfi, lottery, address)
            fetched[lottery] = metadata;
            appliedMetadata.push(metadata);
        } else {
            appliedMetadata.push(fetched[lottery]);
        }
    }
    const chocoChips = Number(await getChocoChips(meltyfi, address));
    return [lotteries, ownedMetadata, appliedMetadata, chocoChips];
}

function getOwnedCards(lotteries) {
    return lotteries.map((lottery) => {
        let text = <Card.Text>
            Expire date: {lottery.expirationDate.toLocaleString()}<br/>
            Wonka Bars
            sold: {lottery.wonkaBarsOwned}/{lottery.wonkaBarsTotal} ( {lottery.wonkaBarsSold / lottery.wonkaBarsTotal * 100}%)<br/>
        </Card.Text>
        return <Col>
            {LotteryCard({
                src: lottery.image,
                name: lottery.name,
                text,
                onClickFunction: () => {
                    alert("ciao")
                },
                onClickText: "Repay loan"
            })}
        </Col>
    });
}

function getAppliedCards(lotteries) {
    return lotteries.map((lottery) => {
        let text, onClickFunction = undefined, onClickText = undefined;
        if (lottery.state === 0) {
            text = <Card.Text>
                Expire date: {lottery.expirationDate.toLocaleString()}<br/>
                Wonka Bars owned: {lottery.wonkaBarsOwned}<br/>
                Wonka Bars sold: {lottery.wonkaBarsSold}/{lottery.wonkaBarsTotal}
            </Card.Text>
        } else {
            //todo onClickFunction, onClickText
            let state, winner = undefined;
            if (lottery.state === 1) {
                state = "Canceled";
                winner = "No winner";
            } else {
                state = "Concluded";
                const url = `https://goerli.etherscan.io/address/${winner}`;
                winner = <a href={url}>{lottery.winner}</a>;
            }
            text = <Card.Text>
                State: {state}<br/>
                {winner}<br/>
                Wonka Bars owned: {lottery.wonkaBarsOwned}<br/>
                Wonka Bars sold: {lottery.wonkaBarsSold}/{lottery.wonkaBarsTotal}
            </Card.Text>
        }
        return <Col>
            {LotteryCard({
                src: lottery.image,
                name: lottery.name,
                text,
                onClickFunction,
                onClickText
            })}
        </Col>;
    });
}

function Profile() {
    const address = useAddress();
    const [profileData, setProfileData] = useState([[], [], [], 0]);
    useEffect(() => {
        loadProfileData(address).then(setProfileData)
    }, [address]);
    // eslint-disable-next-line no-unused-vars
    const [_lotteries, owned, applied, chocoChips] = profileData;
    let lotteriesSection;
    if (address !== undefined) {
        lotteriesSection = <Container>
            <div>Your ChocoChip balance: {chocoChips}</div>
            Owned:<br/>
            <Container>
                <Row>{getOwnedCards(owned)}</Row>
            </Container>
            Applied:<br/>
            <Container>
                <Row>{getAppliedCards(applied)}</Row>
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
