import { Row, Col, Container } from 'react-bootstrap';

function getLink() {
    const a = 'https://goerli.etherscan.io/address/';
}

function MyFooter() {
    return (
        <Container className='Footer'>
            <Row>
                <Col>
                    <div>MeltyFiNFT address: <a href={getLink()}>{ }</a></div>
                </Col>
                <Col>
                    <div>LogoCollection address: <a href={getLink()}>{ }</a></div>
                </Col>
                <Col>
                    <div>ChocoChip address: <a href={getLink()}>{ }</a></div>
                </Col>
                <Col>
                    <div>MeltyFiDAO address: <a href={getLink()}>{ }</a></div>
                </Col>
            </Row>
        </Container>
    );
}

export default MyFooter;