import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';

function LotteryCard({src, tokenId, collection, text, lotteryId, action}) {
    return (
        <Card className='Card'>
            <Card.Img className='CardImg' src={src}/>
            <Card.Body className='CardBody'>
                <Card.Title className='CardTitle'>
                    {collection} #{tokenId}
                </Card.Title>
                <Card.Text>
                    Lottery #{lotteryId}
                </Card.Text>
                {text}
                {action}
            </Card.Body>
        </Card>
    );
}

export default LotteryCard;
