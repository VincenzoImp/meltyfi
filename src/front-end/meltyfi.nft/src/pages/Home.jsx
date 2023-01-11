import {Container} from "react-bootstrap";
import logo from "../images/logo.png";

function Home() {
    return (
        <Container>
            <h1>MeltyFi protocol</h1>
            <h2>
                The <b>MeltyFi protocol</b> is innovative solution for <b>peer - to - pool lending and borrowing with
                NFT collateral</b>. Thanks to its structure and <b>independence from off-chain factors</b> such as the
                floor price of NFTs, MeltyFi allows borrowers to easily obtain loans <b>without the risk of involuntary
                liquidation of the NFT</b>, allowing them to obtain liquidity without risking the loss of their NFT.
                Additionally, the MeltyFi protocol allows lenders to use their capital to <b>provide liquidity for loans
                through a lottery system</b>. For this use of capital, lenders are obviously rewarded, and in the event
                that the loan they funded is not repaid, they have the opportunity to win the NFT used as collateral
                proportional to the capital they provided for that loan. If the loan is repaid, the lenders are
                obviously returned the capital they invested. Those who also repay a loan are rewarded with an amount
                equal to the interest paid to the protocol.
            </h2>
            <img src={logo} alt="MeltyFi protocol"/>
            <h1>How does it work?</h1>
            <h2>
                MeltyFiNFT is the contract that runs the core functionality of the MeltyFi protocol. It manages the
                creation, cancellation and conclusion of lotteries, as well as the sale and refund of WonkaBars for each
                lottery, and also reward good users with ChocoChips. The contract allows users to create a lottery by
                choosing their NFT to put as lottery prize, setting an expiration date and defining a price in Ether for
                each WonkaBar sold. When a lottery is created, the contract will be able to mint a fixed amount of
                WonkaBars (setted by lottery owner) for the lottery. These WonkaBars are sold to users interested in
                participating in the lottery and money raised are sent to the lottery owner (less some fees). Once the
                expiration date is reached, the contract selects a random WonkaBar holder as the winner, who receives
                the prize NFT. Plus every wonkabar holder is rewarded with ChocoCips. If the lottery is cancelled by the
                owner beafore the expiration date, the contract refunds WonkaBars holders with Ether of the lottery
                owners. Plus every wonkabar holder is rewarded with ChocoCips.
            </h2>
        </Container>
    );
}

export default Home;