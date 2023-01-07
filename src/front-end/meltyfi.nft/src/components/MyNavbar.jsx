import { Nav, Row, Col, Container } from 'react-bootstrap';
import { ConnectWallet } from "@thirdweb-dev/react";

function MyNavbar() {
    return (
        <Container className='Top'>
            <Row>
                <Col>
                    <Container>
                        <h1>MeltyFi.NFT</h1>
                    </Container>
                </Col>
                <Col xs={7}>
                    <Nav className='Navbar' activeKey="/home">
                        <Nav.Item>
                            <Nav.Link className='NavLink' href="/home">Home</Nav.Link>
                        </Nav.Item>
                        <Nav.Item >
                            <Nav.Link className='NavLink' href="/lotteries" >Lotteries</Nav.Link>
                        </Nav.Item>
                        <Nav.Item >
                            <Nav.Link className='NavLink' href="/profile" >Profile</Nav.Link>
                        </Nav.Item>
                        <Nav.Item >
                            <Nav.Link className='NavLink' href="https://github.com/VincenzoImp/MeltyFi" >GitHub</Nav.Link>
                        </Nav.Item>
                    </Nav>
                </Col>
                <Col >
                    <Container>
                        <ConnectWallet accentColor="#d9ad91" colorMode="dark" />
                    </Container>
                </Col>
            </Row>
        </Container>

    );
}

export default MyNavbar;
