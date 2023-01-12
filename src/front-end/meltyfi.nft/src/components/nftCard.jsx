import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';

function NftCard({src, tokenId, collection, action}) {
    return (
        <Card className='Card'>
            <Card.Img className='CardImg' src={src}/>
            <Card.Body className='CardBody'>
                <Card.Title className='CardTitle'>
                    {tokenId} @ {collection}
                </Card.Title>
                {action}
            </Card.Body>
        </Card>
    );
}

export default NftCard;
