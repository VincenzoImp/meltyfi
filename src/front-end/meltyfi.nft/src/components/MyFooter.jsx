import { Row, Col, Container } from 'react-bootstrap';

function MyFooter() {
    return (
        <Container className='Footer'>
            <Row>
                <Col>
                    <div>ChocoChip address: <a href='https://goerli.etherscan.io/address/0xca078ACEeb58d24e6e3aEB15c2336d799fef2376'>0xca078ACEeb58d24e6e3aEB15c2336d799fef2376</a></div>
                </Col>
                <Col>
                    <div>Wonkabar address: <a href='https://goerli.etherscan.io/address/0x743995534BbAeB0DB0B76d90c43bc1477Ba649dE'>0x743995534BbAeB0DB0B76d90c43bc1477Ba649dE</a></div>
                </Col>
                <Col>
                    <div>MeltyFi NFT address: <a href='https://goerli.etherscan.io/address/0x'>0x</a></div>
                </Col>
                <Col>
                    <div>MeltyFi DAO address: <a href='https://goerli.etherscan.io/address/0x2fd5c39fEEb46dFF5cd2FE333CDDfd0053587994'>0x2fd5c39fEEb46dFF5cd2FE333CDDfd0053587994</a></div>
                </Col>
            </Row>
        </Container>
    );
}

export default MyFooter;