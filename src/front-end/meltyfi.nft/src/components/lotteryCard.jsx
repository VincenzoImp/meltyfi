import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';

function LotteryCard({src, name, text, onClickFunction, onClickText}) {
    let button = undefined;
    if (onClickFunction !== undefined) {
        button = <Button className='CardButton' onClick={onClickFunction}>{onClickText}</Button>;
    }
    return (
        <Card className='Card'>
            <Card.Img className='CardImg' src={src}/>
            <Card.Body className='CardBody'>
                <Card.Title className='CardTitle'>
                    {name}
                </Card.Title>
                {text}
                {button}
            </Card.Body>
        </Card>
    );
}

export default LotteryCard;
