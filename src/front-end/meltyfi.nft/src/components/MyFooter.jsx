import { Row, Col } from 'react-bootstrap';

function MyFooter() {
    return (
        <div className='Footer'>
            <Row>
                <Col>
                    <p>ChocoChip address: <a href='https://etherscan.io/'>0x</a></p>
                </Col>
                <Col>
                    <p>Wonkabar address: <a href='https://etherscan.io/'>0x</a></p>
                </Col>
                <Col>
                    <p>MeltyFi NFT address: <a href='https://etherscan.io/'>0x</a></p>
                </Col>
                <Col>
                    <p>MeltyFi DAO address: <a href='https://etherscan.io/'>0x</a></p>
                </Col>
            </Row>
        </div>
    );
}

export default MyFooter;