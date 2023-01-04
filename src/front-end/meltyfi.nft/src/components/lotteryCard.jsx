import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';

function LotteryCard({ src }) {
    return (
        <Card className='Card'>
            <Card.Img className='CardImg' src={src} />
            <Card.Body className='CardBody'>
                <Card.Title className='CardTitle'>
                    Card Title
                </Card.Title>
                <Card.Text className='CardText'>
                    Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
                </Card.Text>
                <Button className='CardButton'>Go somewhere</Button>
            </Card.Body>
        </Card >
    );
}

export default LotteryCard;