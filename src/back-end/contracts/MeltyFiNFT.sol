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
        uint256 wonkaBarsSold;
        uint256 wonkaBarsWelted;
        uint256 wonkaBarsTotalAmount;
        uint256 wonkaBarPrice;
        uint256 expirationDate;
        uint256 lotteryId;
        address lotteryOwner;
        address lotteryWinner;
    }

    ChocoChip internal immutable _contractChocoChip;

    WonkaBar internal immutable _contractWonkaBar;

    MeltyFiDAO internal immutable _contractMeltyFiDAO;

    uint256 internal immutable _royaltyDAOPercentage;
    uint256 internal immutable _upperLimitPercentage;
    uint256 internal _totalLotteriesCreated;

    mapping(uint256 => Lottery) internal _lotteryIdToLottery;
    mapping(address => EnumerableSet.UintSet) internal _lotteryOwnerToLotteryIds;
    mapping(address => EnumerableSet.UintSet) internal _prizeContractToLotteryIds;
    mapping(address => EnumerableSet.UintSet) internal _wonkaBarHolderToLotteryIds;

    EnumerableSet.UintSet internal _validLotteries;
    EnumerableSet.AddressSet internal _validLotteryOwners;
    EnumerableSet.AddressSet internal _validPrizeContracts;
    EnumerableSet.AddressSet internal _validWonkaBarHolders;
    
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

        _royaltyDAOPercentage = 5;
        _upperLimitPercentage = 25;
        _totalLotteriesCreated = 0;
    }

    function _addressChocoChip() internal view virtual returns (address) {
        return address(_contractChocoChip);
    }

    function _addressWonkaBar() internal view virtual returns (address) {
        return address(_contractWonkaBar);
    }

    function _addressMeltyFiDAO() internal view virtual returns (address) {
        return address(_contractMeltyFiDAO);
    }

    function _amountToRepay(Lottery memory lottery) internal view virtual returns (uint256) {
        return lottery.wonkaBarsSold * lottery.wonkaBarPrice;
    }

    function _isExpired(Lottery memory lottery) internal view virtual returns (bool) {
        return block.timestamp >= lottery.expirationDate;
    }

    function _clearValidLotteries(Lottery memory lottery) internal virtual {
        if (
            (_isExpired(lottery) && lottery.wonkaBarsSold == 0) 
            || 
            lottery.wonkaBarsSold == lottery.wonkaBarsWelted /// && _isExpired(lottery) (true by costruction)
        )
        {
            _validLotteries.remove(lottery.lotteryId);
        }
    }

    function _clearValidLotteryOwners(address lotteryOwner) internal virtual {
        if (_lotteryOwnerToLotteryIds[lotteryOwner].length() == 0) {
            _validLotteryOwners.remove(lotteryOwner);
        }
    }

    function _clearValidPrizeContracts(IERC721 prizeContract) internal virtual {
        if (_prizeContractToLotteryIds[address(prizeContract)].length() == 0) {
            _validPrizeContracts.remove(address(prizeContract));
        }
    }

    function _clearValidWonkaBarHolders(address wonkaBarHolder) internal virtual {
        if (_wonkaBarHolderToLotteryIds[wonkaBarHolder].length() == 0) {
            _validWonkaBarHolders.remove(wonkaBarHolder);
        }
    }

    function addressChocoChip() public view virtual returns (address) {
        return _addressChocoChip();
    }

    function addressWonkaBar() public view virtual returns (address) {
        return _addressWonkaBar();
    }

    function addressMeltyFiDAO() public view virtual returns (address) {
        return addressMeltyFiDAO();
    }

    function amountToRepay(uint256 lotteryId) public view virtual returns (uint256) {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        return _amountToRepay(lottery);
    }

    function isExpired(uint256 lotteryId) public view virtual returns (bool) {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        return _isExpired(lottery);
    }

    function createLottery(
        IERC721 prizeContract,
        uint256 prizeTokenId,
        uint256 wonkabarsTotalAmount,
        uint256 wonkabarPrice,
        uint256 expirationDate
    ) public virtual 
    {
        require(
            wonkabarsTotalAmount
        )
        require(
            block.timestamp < expirationDate,
            ""
        );

        require(
            prizeContract.ownerOf(prizeTokenId) == _msgSender(),
            ""
        );

        prizeContract.safeTransferFrom(_msgSender(), address(this), prizeTokenId);

        uint256 lotteryId = _totalLotteriesCreated;
        _totalLotteriesCreated += 1;

        Lottery memory lottery = Lottery(
            prizeContract,
            prizeTokenId,
            0,
            0,
            wonkabarsTotalAmount,
            wonkabarPrice,
            expirationDate,
            lotteryId,
            _msgSender(),
            address(0)
        );

        _lotteryIdToLottery[lotteryId] = lottery;
        _lotteryOwnerToLotteryIds[_msgSender()].add(lotteryId);
        _prizeContractToLotteryIds[address(prizeContract)].add(lotteryId);

        _validLotteries.add(lotteryId);
        _validLotteryOwners.add(_msgSender());
        _validPrizeContracts.add(address(prizeContract));
       
    }

    function buyWonkaBars(
        uint256 lotteryId, 
        uint256 amount
    ) public virtual payable
    {
        
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];

        uint256 totalSpending = amount * lottery.wonkaBarPrice;

        require(
            lottery.wonkaBarsSold + amount <= lottery.wonkaBarsTotalAmount,
            ""
        );

        require(
            (_contractWonkaBar.balanceOf(_msgSender(), lotteryId) + amount) / lottery.wonkaBarsTotalAmount <= _upperLimitPercentage / 100,
            ""
        );

        require(
            msg.value >= totalSpending,
            ""
        );

        uint256 valueToDAO = (totalSpending / 100) * _royaltyDAOPercentage; 
        Address.sendValue(payable(_addressMeltyFiDAO()), valueToDAO);

        uint256 valueToLotteryOwner = totalSpending - valueToDAO;
        Address.sendValue(payable(lottery.lotteryOwner), valueToLotteryOwner);

        _contractWonkaBar.mint(
            _msgSender(),
            lotteryId,
            amount,
            ""
        );

        lottery.wonkaBarsSold += amount;

        _wonkaBarHolderToLotteryIds[_msgSender()].add(lotteryId);
        _validWonkaBarHolders.add(_msgSender());

    }

    function repayLoan(uint256 lotteryId) public virtual payable {

        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        uint256 totalPayable = _amountToRepay(lottery);

        require(
            lottery.lotteryOwner == _msgSender(),
            ""
        );

        require(
            msg.value >= totalPayable,
            ""
        );

        require(
            _isExpired(lottery) == false,
            "" 
        );

        _contractChocoChip.mint(
            _msgSender(),
            totalPayable * 1000
        );

        lottery.prizeContract.safeTransferFrom(address(this), _msgSender(), lottery.prizeTokenId);

        _lotteryOwnerToLotteryIds[_msgSender()].remove(lotteryId);
        _prizeContractToLotteryIds[address(lottery.prizeContract)].remove(lotteryId);
        
        _clearValidLotteries(lottery);

        _clearValidLotteryOwners(_msgSender());
        _clearValidPrizeContracts(lottery.prizeContract);

    }
    

    function meltWonkaBars(uint256 lotteryId, uint256 amount) public virtual {

        Lottery memory lottery = _lotteryIdToLottery[lotteryId];

        require(
            _contractWonkaBar.balanceOf(_msgSender(), lotteryId) >= amount,
            ""
        );

        require(
            _isExpired(lottery) == true,
            ""
        );
        
    }

    function andTheWinnerIs(uint256 _id) public virtual {}
    
}

/**
 * @dev
 * il lender riceve 1 choc pari al numero di finney spesi in ticket
 * il bowworare riceve 1 choc pari al numero di finney spesi in interessi
 *
 */
