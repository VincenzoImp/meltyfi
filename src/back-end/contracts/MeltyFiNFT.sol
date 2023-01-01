// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ChocoChip.sol";
import "./MeltyFiDAO.sol";
import "./WonkaBar.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract MeltyFiNFT is Ownable {

    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Lottery {
        IERC721 prizeContract;
        uint256 prizeTokenId;
        uint256 wonkabarsSold;
        uint256 wonkabarsTotalAmount;
        uint256 wonkabarPrice;
        uint256 expirationDate;
        uint256 lotteryId;
        address lotteryOwner;
    }

    ChocoChip internal immutable _contractChocoChip;

    WonkaBar internal immutable _contractWonkaBar;

    MeltyFiDAO internal immutable _contractMeltyFiDAO;

    uint256 internal immutable _upperLimitPercentage;
    uint256 internal _totalLotteriesCreated;

    mapping(uint256 => Lottery) internal _lotteryIdToLottery;
    mapping(address => EnumerableSet.UintSet) internal _lotteryOwnerToLotteryIds;
    mapping(address => EnumerableSet.UintSet) internal _prizeContractToLotteryIds;
    mapping(address => EnumerableSet.UintSet) internal _wonkaBarHolderToLotteryIds;

    EnumerableSet.UintSet internal _existingLotteries;
    EnumerableSet.AddressSet internal _existingLotteryOwners;
    EnumerableSet.AddressSet internal _existingPrizeContracts;
    EnumerableSet.AddressSet internal _existingwonkaBarHolders;
    
    constructor(
        ChocoChip contractChocoChip,
        WonkaBar contractWonkaBar,
        MeltyFiDAO contractMeltyFiDAO
    )
    {
        require(
            contractChocoChip.owner() == _msgSender(), 
            "Caller is not the owner of ChocoChip contract"
        );

        require(
            contractWonkaBar.owner() == _msgSender(), 
            "Caller is not the owner of WonkaBar contract"
        );

        _contractChocoChip = contractChocoChip;
        _contractWonkaBar = contractWonkaBar;
        _contractMeltyFiDAO = contractMeltyFiDAO;

        _upperLimitPercentage = 25;
        _totalLotteriesCreated = 0;
    }

    function addressChocoChip() public view virtual returns (address) {
        return address(_contractChocoChip);
    }

    function addressWonkaBar() public view virtual returns (address) {
        return address(_contractWonkaBar);
    }

    function addressMeltyFiDAO() public view virtual returns (address) {
        return address(_contractMeltyFiDAO);
    }

    function createLottery(
        IERC721 prizeContract,
        uint256 prizeTokenId,
        uint256 wonkabarsTotalAmount,
        uint256 wonkabarPrice,
        uint256 daysBeforeDraw
    ) public virtual 
    {

        require(
            daysBeforeDraw > 0,
            ""
        );

        require(
            prizeContract.ownerOf(prizeTokenId) == _msgSender(),
            ""
        );

        prizeContract.safeTransferFrom(_msgSender(), address(this), prizeTokenId);

        uint256 expirationDate = block.timestamp + daysBeforeDraw * 1 days;
        uint256 lotteryId = _totalLotteriesCreated;
        _totalLotteriesCreated += 1;

        Lottery memory lottery = Lottery(
            prizeContract,
            prizeTokenId,
            0,
            wonkabarsTotalAmount,
            wonkabarPrice,
            expirationDate,
            lotteryId,
            _msgSender()
        );

        _lotteryIdToLottery[lotteryId] = lottery;
        _lotteryOwnerToLotteryIds[_msgSender()].add(lotteryId);
        _prizeContractToLotteryIds[address(prizeContract)].add(lotteryId);

        _existingLotteries.add(lotteryId);
        _existingLotteryOwners.add(_msgSender());
        _existingPrizeContracts.add(address(prizeContract));
       
    }

    function buyWonkaBars(
        uint256 lotteryId, 
        uint256 amount
    ) public virtual payable
    {
        
        Lottery storage lottery = _lotteryIdToLottery[lotteryId];

        require(
            lottery.wonkabarsSold + amount <= lottery.wonkabarsTotalAmount,
            ""
        );

        require(
            (_contractWonkaBar.balanceOf(_msgSender(), lotteryId) + amount) / lottery.wonkabarsTotalAmount <= _upperLimitPercentage / 100,
            ""
        );

        require(
            msg.value >= amount * lottery.wonkabarPrice,
            ""
        );

        _contractWonkaBar.mint(
            _msgSender(),
            lotteryId,
            amount,
            ""
        );

        lottery.wonkabarsSold += amount;

        _wonkaBarHolderToLotteryIds[_msgSender()].add(lotteryId);
        _existingwonkaBarHolders.add(_msgSender());

        valueToDAO = (amount * lottery.wonkabarPrice)
        sendValue(address(_contractMeltyFiDAO), 
    }

    /*
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
    */
}

/**
 * @dev
 * il lender riceve 1 choc pari al numero di finney spesi in ticket
 * il bowworare riceve 1 choc pari al numero di finney spesi in interessi
 *
 */
