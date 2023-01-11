import React, { useState } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Modal from 'react-bootstrap/Modal';
import Card from 'react-bootstrap/Card';

function BuyWonkaBar() {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  return (
    <>
      <Button variant="primary" onClick={handleShow}>
        Buy Wonka Bar
      </Button>

      <Modal show={show} onHide={handleClose}>
        <Modal.Header closeButton>
          <Modal.Title>Buy ... WonkaBars</Modal.Title>
        </Modal.Header>
        <Modal.Body>
            <li>A wonkabar costs: ... ethers</li>
            <li>The lottery expires in ... days</li>
          <Card className='Card'>
            <Card.Img className='CardImg' src="https://imageio.forbes.com/specials-images/imageserve/6170e01f8d7639b95a7f2eeb/Sotheby-s-NFT-Natively-Digital-1-2-sale-Bored-Ape-Yacht-Club--8817-by-Yuga-Labs/0x0.png?format=png&width=960"/>
        </Card>
        <Form>
            <Form.Group className="mb-3" controlId="buyWonkaForm.ControlInput1">
              <Form.Label>How many wonka bar you want to buy?</Form.Label>
              <Form.Control
                type="int"
                placeholder="4 wonkabar"
                autoFocus
              />
            </Form.Group>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>
            Discard
          </Button>
          <Button variant="primary" onClick={handleClose}>
            Buy wonka bar
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  );
}

export default BuyWonkaBar;