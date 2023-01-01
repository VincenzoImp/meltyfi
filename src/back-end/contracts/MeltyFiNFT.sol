// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ChocoChip.sol";
import "./WonkaBar.sol";
import "./MeltyFiDAO.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * MeltyFiNFT is a contract for creating and managing lotteries using
 * ERC721 tokens as prizes. Users can purchase tickets for the lottery
 * using Choco Chip tokens, and receive WonkaBar tokens in return.
 * The contract also provides a way for the owner of a lottery to end
 * the lottery early and distribute the funds raised to the owner and
 * the MeltyFiDAO contract.
 */
contract MeltyFiNFT is Ownable {
    using SafeMath for uint256;

    /**
     * A struct to represent a single lottery.
     */
    struct Lottery {
        /** ERC721 token representing the prize of the lottery. */
        ERC721 prize;
        /** Number of remaining tickets in the lottery. */
        uint256 ticketRemining;
        /** Total number of tickets in the lottery. */
        uint256 ticketTotal;
        /** Price of each ticket, in Choco Chip tokens. */
        uint256 ticketPrice;
        /** Total amount raised by the lottery, in Choco Chip tokens. */
        uint256 totalRaised;
        /** Expiration date of the lottery. */
        uint256 expirationDate;
        /** Address of the owner of the lottery. */
        address owner;
        /** Token ID of the ERC721 prize. */
        uint256 tokenId;
    }

    /**
     * An instance of the ChocoChip contract.
     */
    ChocoChip internal immutable _contractChocoChip;

    /**
     * An instance of the WonkaBar contract.
     */
    WonkaBar internal immutable _contractWonkaBar;

    /**
     * An instance of the MeltyFiDAO contract.
     */
    MeltyFiDAO internal immutable _contractMeltyFiDAO;

    /**
     * A mapping from an address to an array of lottery IDs owned by that address.
     */
    mapping(address => uint256[]) public LotteryPerOwner;

    /**
     * An array of all the created lotteries.
     */
    Lottery[] public Lotteries;

    /**
     * Constructor to initialize the contract with instances of the
     * ChocoChip, WonkaBar, and MeltyFiDAO contracts.
     *
     * @param contractChocoChip instance of the ChocoChip contract.
     * @param contractWonkaBar instance of the WonkaBar contract.
     * @param contractMeltyFiDAO instance of the MeltyFiDAO contract.
     */
    constructor(
        ChocoChip contractChocoChip,
        WonkaBar contractWonkaBar,
        MeltyFiDAO contractMeltyFiDAO
    ) {
        _contractChocoChip = contractChocoChip;
        _contractWonkaBar = contractWonkaBar;
        _contractMeltyFiDAO = contractMeltyFiDAO;
    }

    /**
     * Returns the address of the ChocoChip contract.
     *
     * @return address of the ChocoChip contract.
     */
    function addressChocoChip() public view virtual returns (address) {
        return address(_contractChocoChip);
    }

    /**
     * Returns the address of the WonkaBar contract.
     *
     * @return address of the WonkaBar contract.
     */
    function addressWonkaBar() public view virtual returns (address) {
        return address(_contractWonkaBar);
    }

    /**
     * Returns the address of the MeltyFiDAO contract.
     *
     * @return address of the MeltyFiDAO contract.
     */
    function addressMeltyFiDAO() public view virtual returns (address) {
        return address(_contractMeltyFiDAO);
    }

    /**
     * Creates a new lottery.
     *
     * @param _prize ERC721 token representing the prize of the lottery.
     * @param _tokenId Token ID of the ERC721 prize.
     * @param _ticketTotal Total number of tickets in the lottery.
     * @param _ticketPrice Price of each ticket, in Choco Chip tokens.
     * @param _expirationDate Expiration date of the lottery.
     */
    function createLottery(
        ERC721 _prize,
        uint256 _tokenId,
        uint256 _ticketTotal,
        uint256 _ticketPrice,
        uint256 _expirationDate
    ) public {
        // Check that the expiration date has not passed
        require(
            block.timestamp <= _expirationDate,
            "Expiration date has already passed"
        );

        // Transfer the ERC721 prize to the contract
        _prize.safeTransferFrom(msg.sender, address(this), _tokenId);

        // Create a new lottery and add it to the array of lotteries
        uint256 id = Lotteries.length;
        Lottery memory lottery = Lottery(
            _prize,
            _ticketTotal,
            _ticketTotal,
            _ticketPrice,
            0,
            _expirationDate,
            msg.sender,
            _tokenId
        );
        Lotteries.push(lottery);

        // Add the lottery ID to the list of lotteries owned by the creator
        LotteryPerOwner[msg.sender].push(id);
    }

    /**
     * Purchases a ticket for a lottery and receives a WonkaBar token in return.
     *
     * @param howMany Number of tickets to purchase.
     * @param id ID of the lottery to purchase tickets for.
     */
    function buyWonkBar(uint256 howMany, uint256 id) public payable virtual {
        // Check that the number of tickets is greater than 0
        require(howMany > 0, "must be greater that 0");

        // Check that there are enough remaining tickets
        require(
            howMany <= Lotteries[id].ticketRemining,
            "Not enough tickets remaining"
        );

        // Check that the correct payment amount was sent
        require(
            msg.value >= howMany * Lotteries[id].ticketPrice,
            "Incorrect payment amount"
        );

        // Calculate the amounts to be sent to the MeltyFiDAO and the owner of the lottery
        (, uint256 tmp1) = msg.value.tryDiv(100);
        (, uint256 toDAO) = tmp1.tryMul(5);
        payable(addressMeltyFiDAO()).transfer(toDAO);
        (, uint256 tmp2) = msg.value.tryDiv(100);
        (, uint256 toOwner) = tmp2.tryMul(90);
        payable(Lotteries[id].owner).transfer(toOwner);

        // Mint the WonkaBar tokens and update the lottery data
        WonkaBar._mintBatch(howMany);
        Lotteries[id].ticketRemining -= howMany;
        Lotteries[id].totalRaised += toOwner;
    }

    /**
     * Allows the owner of a lottery to end the lottery early and
     * return the prize to the contract. The funds raised by the lottery
     * will be distributed to the owner and the MeltyFiDAO contract.
     *
     * @param id ID of the lottery to end.
     */
    function rapayLoan(uint256 id) public virtual {
        // Check that the caller is the owner of the lottery
        require(
            Lotteries[id].owner == msg.sender,
            "Only the owner can repay the loan"
        );

        // Transfer the prize back to the contract and distribute the funds
        Lotteries[id].prize.safeTransferFrom(
            address(this),
            msg.sender,
            Lotteries[id].tokenId
        );
        payable(addressMeltyFiDAO()).transfer(
            Lotteries[id].totalRaised.div(10)
        );
        payable(Lotteries[id].owner).transfer(
            Lotteries[id].totalRaised.mul(9).div(10)
        );

        // Delete the lottery data
        delete Lotteries[id];
        delete LotteryPerOwner[Lotteries[id].owner][
            LotteryPerOwner[Lotteries[id].owner].length - 1
        ];
        LotteryPerOwner[Lotteries[id].owner].length--;
    }

    function meltWonkaBar(uint256 howMany) public virtual {
        require(
            WonkaBar.balanceOf(msg.sender) >= howMany,
            "Expiration date has already passed"
        );
        WonkaBar._burn(howMany, msg.sender);
    }

    function andTheWinnerIs(uint256 _id) public virtual {}
}

/**
 * @dev
 * il lender riceve 1 choc pari al numero di finney spesi in ticket
 * il bowworare riceve 1 choc pari al numero di finney spesi in interessi
 *
 */
