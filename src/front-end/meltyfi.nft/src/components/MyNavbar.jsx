import { Nav, Row, Col, Button, Container } from 'react-bootstrap';

function MyNavbar() {
    return (
        <Container className='Top'>
            <Row>
                <Col >
                    <Container className='SiteName'>
                        <h1>MeltyFi</h1>
                    </Container>
                </Col>
                <Col xs={8}>
                    <Nav className='Navbar' activeKey="/home">
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
                        <Button className='LoginButton' name=''>
                            <h4>Login</h4>
                        </Button>
                    </Container>
                </Col>
            </Row>
        </Container>

    );
}

export default MyNavbar;