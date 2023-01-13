import { Container, Row, Col } from "react-bootstrap";
import logo from "../images/circleLogo.png";

function Home() {
    return (
        <Container>
            <h1>The protocol</h1>
            <Row>
                <Col xs={12} md={12} lg={12} xl={6}>
                    <h4>
                        The <b><u>MeltyFi protocol</u></b> is innovative solution for <b><u>peer-to-pool lending and borrowing with
                            NFT collateral</u></b>. Thanks to its structure and <b><u>independence from off-chain factors</u></b> such as the
                        floor price of NFTs, MeltyFi allows borrowers to easily obtain loans <b><u>without the risk of involuntary
                            liquidation of the NFT</u></b>, allowing them to obtain liquidity without risking the loss of their NFT.
                        Additionally, the MeltyFi protocol allows lenders to use their capital to <b><u>provide liquidity for loans
                            through a lottery system</u></b>. For this use of capital, lenders are obviously rewarded, and in the event
                        that the loan they funded is not repaid, they have the opportunity to win the NFT used as collateral
                        proportional to the capital they provided for that loan. If the loan is repaid, the lenders are
                        obviously returned the capital they invested. Those who also repay a loan are rewarded with an amount
                        equal to the interest paid to the protocol.
                    </h4>
                </Col>
                <Col xs={12} md={12} lg={12} xl={6} align='center'>
                    <img className='CircleLogo' src={logo} alt="MeltyFi Logo" />
                </Col>
            </Row>
            <Row className='HomeParagraph'>
                <h1>How does it work?</h1>
                <h4>
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
                </h4>
            </Row>

        </Container>
    );
}

export default Home;