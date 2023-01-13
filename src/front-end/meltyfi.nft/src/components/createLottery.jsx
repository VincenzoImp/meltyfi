import React, { useState } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Modal from 'react-bootstrap/Modal';
import Card from 'react-bootstrap/Card';
import { ethers } from "ethers";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import { addressMeltyFiNFT } from "../App";
import { Alert, Container, Row, Col } from 'react-bootstrap';

async function callCreateLottery(duration, prizeContract, prizeTokenId, wonkaBarPrice, wonkaBarsMaxSupply) {
	const provider = new ethers.providers.Web3Provider(window.ethereum)
	await provider.send("eth_requestAccounts", []);
	const signer = provider.getSigner();

	const contractApprove = new ethers.Contract(prizeContract, [{
		"inputs": [{
			"internalType": "address", "name": "to", "type": "address"
		}, { "internalType": "uint256", "name": "tokenId", "type": "uint256" }],
		"name": "approve",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}], provider);
	const contractWithSigner = contractApprove.connect(signer);


	/*contract.on("approvedNFT", (event) => {
	//actually create the lottery ;
  });*/

	let meltyfi = new ethers.Contract(addressMeltyFiNFT, MeltyFiNFT, provider);
	meltyfi = meltyfi.connect(signer);
	try {
		const approveResponse = await contractWithSigner.approve(addressMeltyFiNFT, prizeTokenId);
		const receipt = await provider.waitForTransaction(approveResponse.hash);
		if (receipt.status) {
			await meltyfi.createLottery(duration, prizeContract, prizeTokenId, wonkaBarPrice, wonkaBarsMaxSupply);
		} else {
			console.log("Call failed!");
		}
	}
	catch (err) {
		return err;
	}
	return 0;
}


function CreateLottery(props) {
	const [show, setShow] = useState(false);
	const [showAlert, setShowAlert] = useState(false);
	const [wonkaBarPrice, setWonkaBarPrice] = useState(1);
	const [wonkaBarMaxSupply, setWonkaBarMaxSupply] = useState(5);
	const [duration, setDuration] = useState(0);

	const handleDurationChange = (event) => {
		const input = event.target.value - Math.floor(Date.now() / 1000);
		if (isNaN(input) || input <= 0) {
			setDuration(0);
		} else {
			setDuration(input);
		}
	};

	const handleWonkaBarMaxSupply = (event) => {
		const input = parseInt(event.target.value);
		if (isNaN(input) || input <= 4) {
			setWonkaBarMaxSupply(5);
		}
		else if (input > 100) {
			setWonkaBarMaxSupply(100);
		}
		else {
			setWonkaBarMaxSupply(input);
		}
	};

	const handleWonkaBarPrice = (event) => {
		const input = parseInt(event.target.value);
		if (isNaN(input) || input <= 0) {
			setWonkaBarPrice(1);
		} else {
			setWonkaBarPrice(input);
		}
	};


	const handleShow = () => setShow(true);
	const handleClose = () => setShow(false);
	const handleBuy = async () => {
		const result = await callCreateLottery(duration, props.contract, props.tokenId, wonkaBarPrice, wonkaBarMaxSupply);
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
				Create Lottery
			</Button>
			<Modal show={show} onHide={handleClose}>
				<Modal.Header closeButton className='BgColor2 TextColor1'>
					<Modal.Title>Create Lottery for {props.collection} #{props.tokenId} </Modal.Title>
				</Modal.Header>
				<Modal.Body className='BgColor1 TextColor2'>
					<Container align='center' className='pb-3'>
						<Card className='Card'>
							<Card.Img className='CardImg' src={props.nftImg} />
						</Card>
					</Container>
					<Form>
						<Form.Group className="mb-3" controlId="createLotteryForm.ControlInput1">
							<Row>
								<Col>
									<Form.Label className='pt-2'>Wei for single WonkaBar</Form.Label>
								</Col>
								<Col>
									<Form.Control
										type="number"
										autoFocus
										value={wonkaBarPrice}
										step='1'
										onChange={handleWonkaBarPrice}
										className='BgColor2 TextColor1'
									/>
								</Col>
							</Row>
						</Form.Group>
						<Form.Group className="mb-3" controlId="createLotteryForm.ControlInput2">
							<Row>
								<Col>
									<Form.Label className='pt-2'>WonkaBar max supply</Form.Label>
								</Col>
								<Col>
									<Form.Control
										type="number"
										value={wonkaBarMaxSupply}
										autoFocus
										onChange={handleWonkaBarMaxSupply}
										className='BgColor2 TextColor1'
									/>
								</Col>
							</Row>
						</Form.Group>
						<Form.Group className="mb-3" controlId="createLotteryForm.ControlInput3">
							<Row>
								<Col>
									<Form.Label className='pt-2'>Select expiration day</Form.Label>
								</Col>
								<Col>
									<Form.Control
										type="date"
										name="dob"
										autoFocus
										value={duration}
										onChange={handleDurationChange}
										className='BgColor2 TextColor1'
									/>
								</Col>
							</Row>
						</Form.Group>
					</Form>
					<div className='pt-2'>Total revenue: {wonkaBarMaxSupply * wonkaBarPrice * Math.pow(10, -18)} ETH</div>
					<Alert variant="danger" show={showAlert} onClose={() => setShowAlert(false)} dismissible>
						<Alert.Heading>Oh snap! You got an error!</Alert.Heading>
						<p>Please try again.</p>
					</Alert>

				</Modal.Body>
				<Modal.Footer className='BgColor2 TextColor1'>
					<Button variant="secondary" className="TextColor2" onClick={handleClose}>
						Cancel
					</Button>
					<Button className="CardButton" onClick={handleBuy}>
						Create Lottery
					</Button>
				</Modal.Footer>
			</Modal>
		</>
	);
}

export default CreateLottery;