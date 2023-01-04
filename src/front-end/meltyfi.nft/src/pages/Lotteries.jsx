import LotteryCard from '../components/lotteryCard.jsx';
import { Container, Row, Col } from 'react-bootstrap';


function Lotteries() {
    return (
        <Container >
            <Row >
                <Col>
                    <LotteryCard src="https://media.elrond.com/nfts/asset/Qmf9DdY4tzgU3JEBe8TE88X2uD5pJfAYZRdLvXruRiF1uw/8146.png" />
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