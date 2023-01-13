import Card from 'react-bootstrap/Card';
import { Container } from 'react-bootstrap';

function NftCard({ src, tokenId, collection, action }) {
    return (
        <Card className='Card'>
            <Card.Img className='CardImg' src={src} />
            <Card.Body className='CardBody'>
                <Container align='center'>
                    <Card.Title className='CardTitle'>
                        {collection} #{tokenId}
                    </Card.Title>
                </Container>
                <Container align='center' className='pt-2'>
                    {action}
                </Container>
            </Card.Body>
        </Card>
    );
}

export default NftCard;
