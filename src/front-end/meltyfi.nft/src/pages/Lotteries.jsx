import LotteryCard from '../components/lotteryCard.jsx';
import { Container, Row, Col } from 'react-bootstrap';


function Lotteries() {
    return (
        <Container className='ciccio'>
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