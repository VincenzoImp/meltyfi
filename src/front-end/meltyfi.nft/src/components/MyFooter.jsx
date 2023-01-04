import { Row, Col, Container } from 'react-bootstrap';

function MyFooter() {
    return (
        <Container className='Footer' fluid>
            <Row>
                <Col>
                    <div>ChocoChip address: <a href='https://etherscan.io/'>0x</a></div>
                </Col>
                <Col>
                    <div>Wonkabar address: <a href='https://etherscan.io/'>0x</a></div>
                </Col>
                <Col>
                    <div>MeltyFi NFT address: <a href='https://etherscan.io/'>0x</a></div>
                </Col>
                <Col>
                    <div>MeltyFi DAO address: <a href='https://etherscan.io/'>0x</a></div>
                </Col>
            </Row>
        </Container>
    );
}

export default MyFooter;