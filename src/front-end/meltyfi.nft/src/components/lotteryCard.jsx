import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';

function LotteryCard({src, name, collection, text, lotteryId, action}) {
    let button = undefined;
    /*if (onClickFunction !== undefined) {
        button = <Button className='CardButton' onClick={onClickFunction}>{onClickText}</Button>;
    }*/
    return (
        <Card className='Card'>
            <Card.Img className='CardImg' src={src}/>
            <Card.Body className='CardBody'>
                <Card.Title className='CardTitle'>
                    {name} @ {collection}
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
