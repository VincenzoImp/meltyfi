import Card from 'react-bootstrap/Card';
import { Container } from 'react-bootstrap';

function LotteryCard({ src, tokenId, collection, text, lotteryId, action }) {
    return (
        <Card className='Card'>
            <Card.Img className='CardImg' src={src} />
            <Card.Body className='CardBody'>
                <Card.Title className='CardTitle'>
                    {collection} #{tokenId}
                </Card.Title>
                <Card.Text>
                    Lottery #{lotteryId}
                </Card.Text>
                {text}
                <Container align='center'>
                    {action}
                </Container>

            </Card.Body>
        </Card>
    );
}

export default LotteryCard;
