import React, { useState, useEffect } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Modal from 'react-bootstrap/Modal';
import Card from 'react-bootstrap/Card';
import { ethers } from "ethers";
import MeltyFiNFT from "../ABIs/MeltyFiNFT.json";
import { addressMeltyFiNFT, sdk } from "../App";
import { Alert, Row, Col, Container } from 'react-bootstrap';


async function getAddressOwner() {

	const provider = new ethers.providers.Web3Provider(window.ethereum)
	await provider.send("eth_requestAccounts", []);
	const signer = provider.getSigner()
	const address = await signer.getAddress()
	return address;
}

async function getMaxAmountToBuy(lotteryId) {

	const provider = new ethers.providers.Web3Provider(window.ethereum)
	await provider.send("eth_requestAccounts", []);
	const signer = provider.getSigner()
	const address = await signer.getAddress()

	const meltyfi = await sdk.getContract(addressMeltyFiNFT, MeltyFiNFT);
	const [, , , , , , , wonkaBarsSold, wonkaBarsMaxSupply] = await meltyfi.call("getLottery", lotteryId);
	const maxPercentage = await meltyfi.call("getUpperLimitBalanceOfPercentage");
	const balance = await meltyfi.call("balanceOf", address, lotteryId);
	const maxForMe = wonkaBarsMaxSupply * maxPercentage / 100 - balance -1;
	const maxAmountToBuy = Math.min(maxForMe, wonkaBarsMaxSupply - wonkaBarsSold);
	return maxAmountToBuy;

}

async function buyWonkaBars(wonkaBars, totalAmount, lotteryId) {

	try {
		const provider = new ethers.providers.Web3Provider(window.ethereum)
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();
		let meltyfi = new ethers.Contract(addressMeltyFiNFT, MeltyFiNFT, provider);
		meltyfi = meltyfi.connect(signer);
		const stringAmount = totalAmount.toString();
		const options = { value: stringAmount }
		await meltyfi.buyWonkaBars(lotteryId, wonkaBars, options);
	}
	catch (err) {
		return err.name;
	}
	return 0;
}


function BuyWonkaBar(props) {
	const [maxAmountToBuy, setMaxAmountToBuy] = useState(0);
	useEffect(() => {
		getMaxAmountToBuy(props.lotteryId).then(setMaxAmountToBuy)
	}, []);
	const minAmountToBuy = 1 > parseInt(maxAmountToBuy) ? parseInt(maxAmountToBuy) : 1;
	const [show, setShow] = useState(false);
	const [showAlert, setShowAlert] = useState(false);
	const [wonkaBarQuantity, setWonkaBarQuantity] = useState(parseInt(minAmountToBuy));
	const [addressOwner, setAddressOwner] = useState("");
	
	useEffect(() => {
		getAddressOwner().then(setAddressOwner)
	}, []);

	const handleQuantityChange = (event) => {
		const input = parseInt(event.target.value);
		if (isNaN(input)||input < parseInt(minAmountToBuy)) {
			setWonkaBarQuantity(parseInt(minAmountToBuy));
		} else if (input > parseInt(maxAmountToBuy)) {
			setWonkaBarQuantity(parseInt(maxAmountToBuy));
		} else {
			setWonkaBarQuantity(input);
		}
	};

	const handleShow = () => setShow(true);
	const handleClose = () => setShow(false);
	const handleBuy = async () => {
		let amount = ethers.utils.parseUnits(props.wonkaBarPrice) * wonkaBarQuantity;
		const result = await buyWonkaBars(wonkaBarQuantity, amount, props.lotteryId);
		if (result === 0) {
			setShow(false);
		}
		else {
			setShowAlert(true);
			console.log(result);
		}
	};

	const urlOwner = `https://goerli.etherscan.io/address/${addressOwner}`;
	const urlContract = `https://goerli.etherscan.io/address/${props.contract}`;

	return (
		<>
			<Button className="CardButton" onClick={handleShow}>
				Buy WonkaBars
			</Button>
			<Modal show={show} onHide={handleClose}>
				<Modal.Header closeButton className='BgColor2 TextColor1'>
					<Modal.Title>Buy WonkaBars for {props.collection} #{props.tokenId}</Modal.Title>
				</Modal.Header>
				<Modal.Body className='BgColor1 TextColor2'>
					<Container align='center' className='pb-3'>
						<Card className='Card'>
							<Card.Img className='CardImg' src={props.nftImg} />
						</Card>
					</Container>
					<Form>
						<Form.Group className="mb-3" controlId="buyWonkaForm.ControlInput1">
							<Row>
								<Col>
									<Form.Label className='pt-2'>WonkaBar amount to buy</Form.Label>
								</Col>
								<Col>
									<Form.Control
										type="number"
										value={wonkaBarQuantity}
										autoFocus
										onChange={handleQuantityChange}
										className='BgColor2 TextColor1'
									/>
								</Col>
							</Row>
						</Form.Group>
					</Form>
					<div className='pt-2'>Prize contract: <a href={urlOwner}>{addressOwner.slice(0, 6)}...{addressOwner.slice(-4)}</a></div>
					<div className='pt-2'>Lottery owner: <a href={urlContract}>{props.contract.slice(0, 6)}...{props.contract.slice(-4)}</a> </div>
					<div className='pt-2'>WonkaBar price: {props.wonkaBarPrice.toString()} ETH</div>
					<div className='pt-2'>Total cost: {props.wonkaBarPrice * wonkaBarQuantity} ETH</div>
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
						Buy WonkaBars
					</Button>
				</Modal.Footer>
			</Modal>

		</>
	);
}

export default BuyWonkaBar;
