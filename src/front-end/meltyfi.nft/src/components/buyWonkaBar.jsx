import React, { useState } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Modal from 'react-bootstrap/Modal';
import Card from 'react-bootstrap/Card';
import { ethers } from "ethers";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import { addressMeltyFiNFT } from "../App";
import { Alert } from 'react-bootstrap';


async function buyWonkaBars(wonkaBarPrice, lotteryId) {

  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    let meltyfi = new ethers.Contract(addressMeltyFiNFT, MeltyFiNFT, provider);
    meltyfi = meltyfi.connect(signer);
    await meltyfi.buyWonkaBars(lotteryId, wonkaBarPrice);
  }
  catch (err) {
    return err.name;
  }
  return 0;
}

function BuyWonkaBar(props) {
  const [show, setShow] = useState(false);
  const [showAlert, setShowAlert] = useState(false);
  const [wonkaBarQuantity, setWonkaBarQuantity] = useState(1);

  const handleQuantityChange = (event) => {
    const input = parseInt(event.target.value);
    if (isNaN(input) || input <= 0) {
      setWonkaBarQuantity(1);
    } else {
      setWonkaBarQuantity(input);
    }
  };

  const handleShow = () => setShow(true);
  const handleClose = () => setShow(false);
  const handleBuy = async () => {
    const result = await buyWonkaBars(props.wonkaBarPrice * wonkaBarQuantity, props.lotteryId);
    if (result === 0) {
      setShow(false);
    }
    else {
      setShowAlert(true);
      console.log(result);
    }
  };

  return (
    <>
      <Button className="CardButton" onClick={handleShow}>
        Buy Wonka Bar
      </Button>
      <Modal show={show} onHide={handleClose}>
        <Modal.Header closeButton>
          <Modal.Title>Buy {props.collection} #{props.tokenId} WonkaBars</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Card className='Card'>
            <Card.Img className='CardImg' src={props.nftImg} />
          </Card>
          <Form>
            <Form.Group className="mb-3" controlId="buyWonkaForm.ControlInput1">
              <Form.Label>How many wonka bar you want to buy?</Form.Label>
              <Form.Control
                type="number"
                value={wonkaBarQuantity}
                autoFocus
                onChange={handleQuantityChange}
              />
            </Form.Group>
          </Form>
          <p>Total cost: {props.wonkaBarPrice * wonkaBarQuantity}  ethers</p>
          <Alert variant="danger" show={showAlert} onClose={() => setShowAlert(false)} dismissible>
            <Alert.Heading>Oh snap! You got an error!</Alert.Heading>
            <p>Please try again.</p>
          </Alert>

        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>
            Cancel purchase
          </Button>
          <Button className="CardButton" onClick={handleBuy}>
            Buy wonka bar
          </Button>
        </Modal.Footer>
      </Modal>

    </>
  );
}

export default BuyWonkaBar;