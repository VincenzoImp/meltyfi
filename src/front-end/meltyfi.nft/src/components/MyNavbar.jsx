import { Nav, Row, Col, Button, Container } from 'react-bootstrap';

function MyNavbar() {
    return (
        <Row className='Top'>
            <Col className='SiteName'>
                <Container>
                    <h1>MeltyFi</h1>
                </Container>
            </Col>
            <Col xs={8}>
                <Nav className='Nav' activeKey="/home">
                    <Nav.Item>
                        <Button className='NavButton'>
                            <Nav.Link className='NavLink' href="/home">Home</Nav.Link>
                        </Button>
                    </Nav.Item>
                    <Nav.Item >
                        <Button className='NavButton'>
                            <Nav.Link className='NavLink' href="/lotteries" >Lotteries</Nav.Link>
                        </Button>
                    </Nav.Item>
                    <Nav.Item >
                        <Button className='NavButton'>
                            <Nav.Link className='NavLink' href="/profile" >Profile</Nav.Link>
                        </Button>
                    </Nav.Item>
                    <Nav.Item >
                        <Button className='NavButton'>
                            <Nav.Link className='NavLink' href="https://github.com/VincenzoImp/MeltyFi" >GitHub</Nav.Link>
                        </Button>
                    </Nav.Item>
                </Nav>
            </Col>
            <Col >
                <Container>
                    <Button className='LoginButton'>
                        <h4>Login</h4>
                    </Button>
                </Container>
            </Col>
        </Row>
    );
}

export default MyNavbar;