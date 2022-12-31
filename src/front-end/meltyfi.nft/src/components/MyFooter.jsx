import { Container, Row, Col } from 'react-bootstrap';

function MyFooter() {
    return (
        <footer class="fixed-bottom">
            <Container>
                <Row>
                    <Col></Col>
                    <Col>
                        <p>contract address</p>
                    </Col>
                    <Col></Col>
                </Row>
            </Container>
        </footer>
    );
}

export default MyFooter;