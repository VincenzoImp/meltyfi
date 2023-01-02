// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ChocoChip.sol";
import "./MeltyFiDAO.sol";
import "./WonkaBar.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract MeltyFiNFT is Ownable {

    enum lotteryState { ACTIVE, CANCELLED, CONCLUDED, INVALID }

    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Lottery {
        uint256 expirationDate;
        uint256 id;
        address owner;
        IERC721 prizeContract;
        uint256 prizeTokenId;
        lotteryState state;
        address winner;
        uint256 wonkaBarsSold;  /// equal to totalSupply by costruction
        uint256 wonkaBarsMelted;
        uint256 wonkaBarsMaxSupply;
        uint256 wonkaBarPrice;
    }

    ChocoChip internal immutable _contractChocoChip;
    WonkaBar internal immutable _contractWonkaBar;
    MeltyFiDAO internal immutable _contractMeltyFiDAO;

    uint256 internal immutable _amountChocoChipPerEther;
    uint256 internal immutable _royaltyDAOPercentage;
    uint256 internal immutable _upperLimitPercentage;

    uint256 internal _totalLotteriesCreated;

    mapping(uint256 => Lottery) internal _lotteryIdToLottery;

    mapping(address => EnumerableSet.UintSet) internal _lotteryOwnerToValidLotteryIds;
    mapping(address => EnumerableSet.UintSet) internal _prizeContractToValidLotteryIds;
    mapping(address => EnumerableSet.UintSet) internal _wonkaBarHolderToValidLotteryIds;

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
            address(contractChocoChip) == address(contractMeltyFiDAO.token()),
            ""
        );

        require(
            contractChocoChip.owner() == _msgSender(), 
            ""
        );

        _contractChocoChip = contractChocoChip;
        _contractWonkaBar = contractWonkaBar;
        _contractMeltyFiDAO = contractMeltyFiDAO;

        _amountChocoChipPerEther = 1000;
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

    function _amountToRefund(Lottery memory lottery, address addressToRefund) internal view virtual returns (uint256) {
        return _contractWonkaBar.balanceOf(addressToRefund, lottery.id) * lottery.wonkaBarPrice;
    }

    function _isValidLottery(Lottery memory lottery) internal view virtual returns (bool) {
        bool result = !(
                lottery.state == lotteryState.INVALID
            ||
            (
                lottery.state == lotteryState.CANCELLED 
                && 
                lottery.wonkaBarsSold == 0
            ) 
            || 
            (
                lottery.state == lotteryState.CONCLUDED
                &&
                lottery.wonkaBarsSold == lottery.wonkaBarsMelted
            )
        );
        return result;
    }

    function _updateValidLotteries(Lottery memory lottery) internal virtual {
        if (lottery.state != lotteryState.INVALID && _isValidLottery(lottery) == false) {

            Lottery storage sLottery = _lotteryIdToLottery[lottery.id];

            sLottery.state = lotteryState.INVALID;

            _validLotteries.remove(lottery.id);

            _lotteryOwnerToValidLotteryIds[_msgSender()].remove(lottery.id);
            _prizeContractToValidLotteryIds[address(lottery.prizeContract)].remove(lottery.id);

            _updateValidLotteryOwners(_msgSender());
            _updateValidPrizeContracts(address(lottery.prizeContract));
        }
    }

    function _updateValidLotteryOwners(address lotteryOwner) internal virtual {
        if (_lotteryOwnerToValidLotteryIds[lotteryOwner].length() == 0) {
            _validLotteryOwners.remove(lotteryOwner);
        }
    }

    function _updateValidPrizeContracts(address prizeContract) internal virtual {
        if (_prizeContractToValidLotteryIds[prizeContract].length() == 0) {
            _validPrizeContracts.remove(prizeContract);
        }
    }

    function _updateValidWonkaBarHolders(address wonkaBarHolder) internal virtual {
        if (_wonkaBarHolderToValidLotteryIds[wonkaBarHolder].length() == 0) {
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
        return _addressMeltyFiDAO();
    }

    function amountToRepay(uint256 lotteryId) public view virtual returns (uint256) {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        return _amountToRepay(lottery);
    }

    function amountToRefund(uint256 lotteryId, address addressToRefund) public view virtual returns (uint256) {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        return _amountToRefund(lottery, addressToRefund);
    }

    function isValidLottery(uint256 lotteryId) public view virtual returns (bool) {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        return _isValidLottery(lottery);
    }

    function createLottery(
        IERC721 prizeContract,
        uint256 prizeTokenId,
        uint256 wonkaBarsMaxSupply,
        uint256 wonkabarPrice,
        uint256 expirationDate
    ) public virtual 
    {
        require(
            (wonkaBarsMaxSupply / 100) * _upperLimitPercentage >= 1,
            ""
        );
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
            expirationDate,
            lotteryId,
            _msgSender(),
            prizeContract,
            prizeTokenId,
            lotteryState.ACTIVE,
            address(0),
            0,
            0,
            wonkaBarsMaxSupply,
            wonkabarPrice
        );

        _lotteryIdToLottery[lotteryId] = lottery;

        _lotteryOwnerToValidLotteryIds[_msgSender()].add(lotteryId);
        _prizeContractToValidLotteryIds[address(prizeContract)].add(lotteryId);

        _validLotteries.add(lotteryId);

        _validLotteryOwners.add(_msgSender());
        _validPrizeContracts.add(address(prizeContract));

    }

    function buyWonkaBars(
        uint256 lotteryId, 
        uint256 amount
    ) public virtual payable
    {
        
        Lottery storage lottery = _lotteryIdToLottery[lotteryId];

        uint256 totalSpending = amount * lottery.wonkaBarPrice;

        require(
            lottery.wonkaBarsSold + amount <= lottery.wonkaBarsMaxSupply,
            ""
        );

        require(
            (_contractWonkaBar.balanceOf(_msgSender(), lotteryId) + amount) / lottery.wonkaBarsMaxSupply 
            <= 
            _upperLimitPercentage / 100,
            ""
        );

        require(
            msg.value >= totalSpending,
            ""
        );

        uint256 valueToDAO = (totalSpending / 100) * _royaltyDAOPercentage; 
        Address.sendValue(payable(_addressMeltyFiDAO()), valueToDAO);

        uint256 valueToLotteryOwner = totalSpending - valueToDAO;
        Address.sendValue(payable(lottery.owner), valueToLotteryOwner);

        _contractWonkaBar.mint(
            _msgSender(),
            lotteryId,
            amount,
            ""
        );

        lottery.wonkaBarsSold += amount;

        _wonkaBarHolderToValidLotteryIds[_msgSender()].add(lotteryId);

        _validWonkaBarHolders.add(_msgSender());

    }

    function repayLoan(uint256 lotteryId) public virtual payable {

        Lottery storage lottery = _lotteryIdToLottery[lotteryId];

        uint256 totalPaying = _amountToRepay(lottery);

        require(
            lottery.owner == _msgSender(),
            ""
        );

        require(
            msg.value >= totalPaying,
            ""
        );

        require(
            lottery.state == lotteryState.ACTIVE,
            "" 
        );

        _contractChocoChip.mint(
            _msgSender(),
            totalPaying * _amountChocoChipPerEther
        );

        lottery.prizeContract.safeTransferFrom(address(this), _msgSender(), lottery.prizeTokenId);

        lottery.state == lotteryState.CANCELLED;
        
        _updateValidLotteries(lottery);
    }
    

    function meltWonkaBars(uint256 lotteryId, uint256 amount) public virtual {

        Lottery storage lottery = _lotteryIdToLottery[lotteryId];
        uint256 totalRefunding = _amountToRefund(lottery, _msgSender());

        require(
            _contractWonkaBar.balanceOf(_msgSender(), lotteryId) >= amount,
            ""
        );

        require(
            lottery.state == lotteryState.CANCELLED
            ||
            lottery.state == lotteryState.CONCLUDED,
            ""
        );

        _contractWonkaBar.burn(
            _msgSender(),
            lotteryId,
            amount
        );

        _contractChocoChip.mint(
            _msgSender(),
            totalRefunding * _amountChocoChipPerEther
        );

        if (lottery.state == lotteryState.CANCELLED) {
            Address.sendValue(payable(_msgSender()), totalRefunding);
        }

        if (_contractWonkaBar.balanceOf(_msgSender(), lotteryId) == 0) {
            _wonkaBarHolderToValidLotteryIds[_msgSender()].remove(lotteryId);
            _updateValidWonkaBarHolders(_msgSender());
        }

        _updateValidLotteries(lottery);
        
    }

    function drawWinner() public virtual {}
    
}

/**
 * @dev
 * il lender riceve 1 choc pari al numero di finney spesi in ticket
 * il bowworare riceve 1 choc pari al numero di finney spesi in interessi
 *
 */
