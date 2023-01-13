import {Card, Col, Container, Row} from "react-bootstrap";
import {useAddress} from "@thirdweb-dev/react";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import ChocoChip from "../ABIs/ChocoChip.json";
import {useEffect, useState} from "react";
import LotteryCard from "../components/lotteryCard";
import {addressMeltyFiNFT, sdk} from "../App";
import {ethers} from "ethers";
import MeltWonkaBars from "../components/MeltWonkaBars";
import RepayLoan from "../components/RepayLoan";


async function asyncFilter(arr, predicate) {
    const results = await Promise.all(arr.map(predicate));
    return arr.filter((_v, index) => results[index]);
}

async function loadLotteries(meltyfi, address) {
    let [owned, applied] = await Promise.all([
        asyncFilter(
            await meltyfi.call("ownedLotteryIds", address),
            async lottery => (await meltyfi.call("getLottery", lottery))[5] === 0
        ),
        meltyfi.call("holderInLotteryIds", address)
    ]);
    return [owned, applied];
}

async function loadMetadata(meltyfi, lottery, address) {
    lottery = parseInt(lottery);
    // eslint-disable-next-line no-unused-vars
    let [expirationDate, _, owner, prizeContract, prizeTokenId, state, winner, wonkaBarsSold, wonkaBarsMaxSupply, wonkaBarPrice] = await meltyfi.call(
        "getLottery", lottery);
    let [contract, wonkaBarsOwned] = await Promise.all([
        sdk.getContract(prizeContract, "nft-collection"),
        meltyfi.call("balanceOf", address, lottery),
    ]);
    let [nft, collection, amountToRepay] = await Promise.all([
        contract.get(prizeTokenId),
        contract.call("name"),
        meltyfi.call("amountToRepay", lottery)
    ]);
    expirationDate = new Date(Number(expirationDate) * 1000);
    wonkaBarsMaxSupply = Number(wonkaBarsMaxSupply);
    wonkaBarsSold = Number(wonkaBarsSold);
    wonkaBarsOwned = Number(wonkaBarsOwned);
    return {
        lottery,
        name: nft.metadata.name,
        image: nft.metadata.image,
        prizeTokenId: nft.metadata.id,
        collection,
        owner,
        expirationDate,
        wonkaBarsMaxSupply,
        wonkaBarsSold,
        wonkaBarsOwned,
        wonkaBarPrice,
        winner,
        state,
        amountToRepay
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
    let [owned, applied] = await loadLotteries(meltyfi, address);
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
    return [ownedMetadata, appliedMetadata, chocoChips];
}

function getOwnedCards(lotteries) {
    const cards = lotteries.map((data) => {
        const toRepayETH = ethers.utils.formatUnits(data.amountToRepay, "ether");
        let text =
            <Card.Text>
                <li className="NoDot"><b>Expire date:</b> {data.expirationDate.toLocaleString()}</li>
                <li className="NoDot"><b>WonkaBars sold:</b> {data.wonkaBarsSold}/{data.wonkaBarsMaxSupply}</li>
                <li className="NoDot"><b>To repay:</b> {toRepayETH.toString()} ETH</li>
            </Card.Text>
        return <Col>
            {LotteryCard({
                src: data.image,
                tokenId: data.prizeTokenId,
                collection: data.collection,
                text,
                lotteryId: data.lottery,
                action: <RepayLoan toRepayETH={toRepayETH} lottery={data.lottery}/>,
            })}
        </Col>
    });
    return <Row align='center'>{cards}</Row>;
}

function getAppliedCards(lotteries, address) {
    // const [showAlert, setShowAlert] = useState(false);
    const cards = lotteries.map((data) => {
        let first_line,
            second_line,
            third_line,
            fourth_line;

        let state;
        if (data.state === 0) {
            state = "Active";
        } else if (data.state === 1) {
            state = "Cancelled";
        } else {
            state = "Concluded";
        }
        first_line = <li className="NoDot"><b>State:</b> {state}</li>

        second_line = <li className="NoDot"><b>Expire date:</b> {data.expirationDate.toLocaleString()}</li>

        if (data.state === 0) {
            third_line =
                <li className="NoDot"><b>WonkaBars sold:</b> {data.wonkaBarsSold}/{data.wonkaBarsMaxSupply}</li>
        } else {
            let winner;
            if (data.state === 1) {
                winner = "None";
            } else {
                const url = `https://goerli.etherscan.io/address/${data.winner}`;
                winner = <a href={url}>{data.winner.slice(0, 6)}...{data.winner.slice(-4)}</a>;
            }
            third_line = <li className="NoDot"><b>Winner:</b> {winner}</li>
        }

        if (data.state === 0) {
            fourth_line =
                <li className="NoDot"><b>Win percentage:</b> {data.wonkaBarsOwned / data.wonkaBarsSold * 100}%</li>
        } else {
            let receive;
            if (data.state === 1) {
                receive = "Refund and CHOC";
            } else {
                if (data.winner === address) {
                    receive = "Prize and CHOC";
                } else {
                    receive = "CHOC";
                }
            }
            fourth_line = <li className="NoDot"><b>You will receive:</b> {receive}</li>
        }

        let action;
        if (data.state === 0) {
            action = <MeltWonkaBars disabled={true} wonkaBarsOwned={data.wonkaBarsOwned}/>
        } else {
            action = <MeltWonkaBars disabled={false} wonkaBarsOwned={data.wonkaBarsOwned} lottery={data.lottery}/>
        }
        const text = <Card.Text>
            {first_line}
            {second_line}
            {third_line}
            {fourth_line}
        </Card.Text>
        return <Col>
            {LotteryCard({
                src: data.image,
                tokenId: data.prizeTokenId,
                collection: data.collection,
                text,
                lotteryId: data.lottery,
                action
            })}
        </Col>;
    });
    return <Row align='center'>{cards}</Row>
}

function Profile() {
    const address = useAddress();
    const [profileData, setProfileData] = useState([[], [], [], 0]);
    useEffect(() => {
        loadProfileData(address).then(setProfileData)
    }, [address]);
    // eslint-disable-next-line no-unused-vars
    const [owned, applied, chocoChips] = profileData;
    let profileSection;
    if (address !== undefined) {
        profileSection = <Container>
            <Row>
                <Col></Col>
                <Col className='ChocoBalanceBox' align='center'>
                    <h3 className="ChocoBalanceText">{chocoChips * Math.pow(10, -18)} CHOC</h3>
                </Col>
                <Col></Col>
            </Row>
            <h2 align='center' className="pt-5 ms-0">Your active lotteries</h2>
            <Row>{getOwnedCards(owned)}</Row>
            <h2 align='center' className="pt-5">Your WonkaBars</h2>
            <Row>{getAppliedCards(applied, address)}</Row>
        </Container>;
    } else {
        profileSection =
            <Container className="PleaseLogin"><h1>Connect your wallet to access your profile</h1></Container>
    }
    return profileSection;
}

export default Profile;
