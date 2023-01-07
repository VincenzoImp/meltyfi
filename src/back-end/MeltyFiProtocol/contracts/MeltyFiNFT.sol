// SPDX-License-Identifier: MIT

/**
 * MeltyFiNFT is the contract that run the protocol of the MeltyFi platform.
 * It manages the creation, cancellation and conclusion of lotteries, as well as the
 * sale and refund of WonkaBars for each lottery, and also reward good users with ChocoChips.
 * The contract allows users to create a lottery by choosing their NFT to put as lottery prize,
 * setting an expiration date and defining a price in Ether for each WonkaBar sold.
 * When a lottery is created, the contract will be able to mint a fixed amount of WonkaBars
 * (setted by lottery owner) for the lottery. These WonkaBars are sold to users interested
 * in participating in the lottery and money raised are sent to the lottery owner (less some fees).
 * Once the expiration date is reached, the contract selects a random WonkaBar
 * holder as the winner, who receives the prize NFT. Plus every wonkabar holder is rewarded
 * with ChocoCips. If the lottery is cancelled by the owner beafore the expiration date,
 * the contract refunds WonkaBars holders with Ether of the lottery owners. Plus every
 * wonkabar holder is rewarded with ChocoCips.
 * @author MeltyFi Team
 * @version 0.1.0
 */

pragma solidity ^0.8.9;

/// ChocoChip contract is the governance token of the MeltyFi protocol.
import "./ChocoChip.sol";
/// LogoCollection contract is the meme token of the MeltyFi protocol.
import "./LogoCollection.sol";
/// MeltyFiDAO contract is the governance contract of the MeltyFi protocol.
import "./MeltyFiDAO.sol";
/// IERC721 interface defines the required methods for an ERC721 contract.
import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 
///
import"@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
//
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
//
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
/// Address library provides utilities for working with addresses.
import "@openzeppelin/contracts/utils/Address.sol"; 
/// EnumerableSet library provides a data structure for storing and iterating over sets of values.
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol"; 
///
import "@chainlink/contracts/src/v0.8/AutomationBase.sol";
///
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

contract MeltyFiNFT is ERC1155, ERC1155Supply, AutomationBase, AutomationCompatibleInterface, IERC721Receiver {

    enum lotteryState {
        ACTIVE,
        CANCELLED,
        CONCLUDED,
        TRASHED
    }

    /// Using Address for address type.
    using Address for address;
    /// Using EnumerableSet for EnumerableSet.AddressSet type.
    using EnumerableSet for EnumerableSet.AddressSet;
    /// Using EnumerableSet for EnumerableSet.UintSet type.
    using EnumerableSet for EnumerableSet.UintSet;

    /// Instance of the ChocoChip contract.
    ChocoChip internal immutable _contractChocoChip;
    /// Instance of the LogoCollection contract.
    LogoCollection internal immutable _contractLogoCollection;
    /// Instance of the MeltyFiDAO contract.
    MeltyFiDAO internal immutable _contractMeltyFiDAO;
    
    /// Amount of ChocoChips per Ether.
    uint256 internal immutable _amountChocoChipPerEther;
    /// Percentage of royalties to be paid to the MeltyFiDAO.
    uint256 internal immutable _royaltyDAOPercentage;
    /// Upper limit 
    uint256 internal immutable _upperLimitBalanceOfPercentage;
    /// Upper limit 
    uint256 internal immutable _upperLimitMaxSupply;

    /// Struct for storing the information of a lottery.
    struct Lottery {
        /// Expiration date of the lottery.
        uint256 expirationDate;
        /// ID of the lottery.
        uint256 id;
        /// Owner of the lottery.
        address owner;
        /// Prize NFT contract of the lottery.
        IERC721 prizeContract;
        /// Prize NFT token ID of the lottery.
        uint256 prizeTokenId;
        /// State of the lottery.
        lotteryState state;
        /// Winner of the lottery.
        address winner;
        /// Number of WonkaBars sold for the lottery.
        uint256 wonkaBarsSold;
        /// Maximum supply of WonkaBars for the lottery.
        uint256 wonkaBarsMaxSupply;
        /// Price of each WonkaBar for the lottery, in ChocoChips
        uint256 wonkaBarPrice;
    }

    /// Total number of lotteries created.
    uint256 internal _totalLotteriesCreated;

    mapping(
        uint256 => Lottery
    ) internal _lotteryIdToLottery;

    mapping(
        address => EnumerableSet.UintSet
    ) internal _lotteryOwnerToLotteryIds;

    mapping(
        address => EnumerableSet.UintSet
    ) internal _wonkaBarHolderToLotteryIds;

    mapping(
        uint256 => EnumerableSet.AddressSet
    ) internal _lotteryIdToWonkaBarHolders;

    EnumerableSet.UintSet internal _activeLotteryIds;

    /**
     * Constructor of the MeltyFiNFT contract.
     *
     * @param contractChocoChip instance of the ChocoChip contract.
     * @param contractLogoCollection instance of the LogoCollection contract.
     * @param contractMeltyFiDAO instance of the MeltyFiDAO contract.
     */
    constructor(
        ChocoChip contractChocoChip,
        LogoCollection contractLogoCollection,
        MeltyFiDAO contractMeltyFiDAO
    ) ERC1155("https://ipfs.io/ipfs/QmTiQsRBGcKyyipnRGVTu8dPfykM89QHn81KHX488cTtxa")
    {
        /// The ChocoChip contract and the MeltyFiDAO token must be the same contract.
        require(
            address(contractChocoChip) == address(contractMeltyFiDAO.token()),
            ""
        );
        /// The caller must be the owner of the ChocoChip contract.
        require(
            contractChocoChip.owner() == _msgSender(), 
            ""
        );
        /// The caller must be the owner of the LogoCollection contract.
        require(
            contractLogoCollection.owner() == _msgSender(),
            ""
        );

        /// Initializing the instance variables.
        _contractChocoChip = contractChocoChip;
        _contractLogoCollection = contractLogoCollection;
        _contractMeltyFiDAO = contractMeltyFiDAO;

        _amountChocoChipPerEther = 1000;
        _royaltyDAOPercentage = 5;
        _upperLimitBalanceOfPercentage = 25;
        _upperLimitMaxSupply = 100;
        _totalLotteriesCreated = 0;
    }

    receive() external payable virtual {
    }

    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) 
    {
        for (uint256 i=0; i<ids.length; i++) {
            if (amounts[i] != 0 && to != address(0)) {
                _wonkaBarHolderToLotteryIds[to].add(ids[i]);
                _lotteryIdToWonkaBarHolders[ids[i]].add(to);
            }
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _afterTokenTransfer (
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) 
    {
        for (uint256 i=0; i<ids.length; i++) {
            if (from != address(0) && balanceOf(from, ids[i]) == 0) {
                _wonkaBarHolderToLotteryIds[from].remove(ids[i]);
                _lotteryIdToWonkaBarHolders[ids[i]].remove(from);
            }
        }
        super._afterTokenTransfer (operator, from, to, ids, amounts, data);
    }

    function activeLotteryIds() public view returns(uint256[] memory ){
        return _activeLotteryIds.values();
    }

    function holderInLotteryIds(address holder) public view returns(uint256[] memory ){
        return _wonkaBarHolderToLotteryIds[holder].values();
    }


    /**
     * Returns the address of the ChocoChip contract.
     *
     * @return address of the ChocoChip contract.
     */
    function _addressChocoChip() internal view returns (address) 
    {
        return address(_contractChocoChip);
    }

    /**
     * Returns the address of the LogoCollection contract.
     *
     * @return address of the LogoCollection contract.
     */
    function _addressLogoCollection() internal view returns (address) 
    {
        return address(_contractLogoCollection);
    }

    /**
     * Returns the address of the MeltyFiDAO contract.
     *
     * @return address of the MeltyFiDAO contract.
     */
    function _addressMeltyFiDAO() internal view returns (address) 
    {
        return address(_contractMeltyFiDAO);
    }

    /**
     * Calculates the amount to be refunded to a user when a lottery is cancelled or has no WonkaBars sold.
     * The amount is equal to the number of ChocoChips the user paid for the WonkaBars minus the royalties to be paid to the MeltyFiDAO.
     *
     * @param lottery information of the lottery.
     * @param addressToRefund address of the user to be refunded.
     * @return amount to be refunded.
     */
    function _amountToRefund(
        Lottery memory lottery, 
        address addressToRefund
    ) internal view returns (uint256)
    {
        return balanceOf(addressToRefund, lottery.id) * lottery.wonkaBarPrice;
    }

    /**
     * Calculates the amount to be repaid to a user when a lottery is cancelled or has no WonkaBars sold.
     * The amount is equal to the number of WonkaBars the user bought multiplied by the price of each WonkaBar.
     *
     * @param lottery information of the lottery.
     * @return amount to be repaid.
     */
    function _amountToRepay(
        Lottery memory lottery
    ) internal pure returns (uint256)  
    {
        return lottery.wonkaBarsSold * lottery.wonkaBarPrice;
    }

    function _mintLogo(
        address to
    ) internal
    {
        _contractLogoCollection.mint(to, 0, 1, "");
    }   

    function addressChocoChip() public view returns (address) 
    {
        return _addressChocoChip();
    }

    function addressLogoCollection() public view returns (address) 
    {
        return _addressLogoCollection();
    }

    function addressMeltyFiDAO() public view returns (address) 
    {
        return _addressMeltyFiDAO();
    }

    function amountToRefund(
        uint256 lotteryId, 
        address addressToRefund
    ) public view returns (uint256)
    {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        if (lottery.state != lotteryState.CANCELLED) {
            return 0;
        }
        return _amountToRefund(lottery, addressToRefund);
    }
    
    function amountToRepay(
        uint256 lotteryId
    ) public view returns (uint256)
    {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        if (lottery.state != lotteryState.ACTIVE) {
            return 0;
        }
        return _amountToRepay(lottery);
    }

    function getLotteryExpirationDate(
        uint256 lotteryId
    ) public view returns (uint256) 
    {
        return _lotteryIdToLottery[lotteryId].expirationDate;
    }

    function getLotteryOwner(
        uint256 lotteryId
    ) public view returns (address) 
    {
        return _lotteryIdToLottery[lotteryId].owner;
    }

    function getLotteryPrizeContract(
        uint256 lotteryId
    ) public view returns (address) 
    {
        return address(_lotteryIdToLottery[lotteryId].prizeContract);
    }

    function getLotteryPrizeTokenId(
        uint256 lotteryId
    ) public view returns (uint256) 
    {
        return _lotteryIdToLottery[lotteryId].prizeTokenId;
    }

    function getLotteryState(
        uint256 lotteryId
    ) public view returns (lotteryState) 
    {
        return _lotteryIdToLottery[lotteryId].state;
    }

    function getWinner(
        uint256 lotteryId
    ) public view returns (address) 
    {
        return _lotteryIdToLottery[lotteryId].winner;
    }

    function getLotteryWonkaBarsSold(
        uint256 lotteryId
    ) public view returns (uint256) 
    {
        return _lotteryIdToLottery[lotteryId].wonkaBarsSold;
    }

    function getLotteryWonkaBarsMaxSupply(
        uint256 lotteryId
    ) public view returns (uint256) 
    {
        return _lotteryIdToLottery[lotteryId].wonkaBarsMaxSupply;
    }

    function getLotteryWonkaBarPrice(
        uint256 lotteryId
    ) public view returns (uint256) 
    {
        return _lotteryIdToLottery[lotteryId].wonkaBarPrice;
    }

    function mintLogo(
        address to
    ) public 
    {
        _mintLogo(to);
    }

    /**
     * Creates a new lottery.
     *
     * @param expirationDate expiration date of the lottery.
     * @param prizeContract address of the prize NFT contract.
     * @param prizeTokenId ID of the prize NFT token.
     * @param wonkaBarPrice price of each WonkaBar, in ChocoChips.
     * @param wonkaBarsMaxSupply maximum supply of WonkaBars for the lottery.
     * @return lotteryId of the newly created lottery.
     */
    function createLottery(
        uint256 expirationDate,
        IERC721 prizeContract,
        uint256 prizeTokenId,
        uint256 wonkaBarPrice,
        uint256 wonkaBarsMaxSupply
    ) public returns (uint256) 
    {
        /*
        require(
            prizeContract.ownerOf(prizeTokenId) == _msgSender(), 
            ""
        );
        */
        require(
            block.timestamp < expirationDate, 
            ""
        );
        require(
            wonkaBarsMaxSupply <= _upperLimitMaxSupply,
            ""
        );
        require(
            (wonkaBarsMaxSupply * _upperLimitBalanceOfPercentage) / 100 >= 1, 
            ""
        );

        prizeContract.safeTransferFrom(
            _msgSender(),
            address(this),
            prizeTokenId
        );

        uint256 lotteryId = _totalLotteriesCreated;

        /// Creating the lottery.
        _lotteryIdToLottery[lotteryId] = Lottery(
            expirationDate,
            lotteryId,
            _msgSender(),
            prizeContract,
            prizeTokenId,
            lotteryState.ACTIVE,
            address(0),
            0,
            wonkaBarsMaxSupply,
            wonkaBarPrice
        );

        /// manage after creating
        _totalLotteriesCreated += 1;
        _lotteryOwnerToLotteryIds[_msgSender()].add(lotteryId);
        _activeLotteryIds.add(lotteryId);

        return lotteryId;
    }

    /**
     * Buys WonkaBars for a lottery.
     *
     * @param lotteryId ID of the lottery.
     * @param amount amount of Ether paid for the WonkaBars.
     */
    function buyWonkaBars(
        uint256 lotteryId, 
        uint256 amount
    ) public payable
    {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];

        uint256 totalSpending = amount * lottery.wonkaBarPrice;

        /// The lottery must be active.
        require(
            block.timestamp < lottery.expirationDate,
            ""
        );
        /// The total supply of WonkaBars must not exceed the maximum supply allowed.
        require(
            lottery.wonkaBarsSold + amount <= lottery.wonkaBarsMaxSupply,
            ""
        );
        
        require(
            (
                ((balanceOf(_msgSender(), lotteryId) + amount + 1) * 100)
                / 
                lottery.wonkaBarsMaxSupply
            )
            <=
            _upperLimitBalanceOfPercentage,
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

        _mint(_msgSender(), lotteryId, amount, "");
        
        _lotteryIdToLottery[lotteryId].wonkaBarsSold += amount;

    }

    function repayLoan(uint256 lotteryId) public payable {
        
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];

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
            block.timestamp < lottery.expirationDate, 
            ""
        );

        _contractChocoChip.mint(
            _msgSender(),
            totalPaying * _amountChocoChipPerEther
        );

        lottery.prizeContract.safeTransferFrom(
            address(this),
            _msgSender(),
            lottery.prizeTokenId
        );
        
        /// manage after repaying
        _activeLotteryIds.remove(lotteryId);
        _lotteryIdToLottery[lotteryId].expirationDate = block.timestamp;
        if (totalSupply(lotteryId) == 0) {
            _lotteryIdToLottery[lotteryId].state = lotteryState.TRASHED;
        } else {
            _lotteryIdToLottery[lotteryId].state = lotteryState.CANCELLED;
        }

    }

    function meltWonkaBars(uint256 lotteryId, uint256 amount) public {
        
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];

        uint256 totalRefunding = _amountToRefund(lottery, _msgSender());

        require(
            balanceOf(_msgSender(), lotteryId) >= amount,
            ""
        );

        if (block.timestamp >= lottery.expirationDate) { //qui puo' essere conclusa o  trashed e non vogliamo che sia trashed
            require(
                totalSupply(lotteryId) > 0,
                ""/// lotteria trashed
            );
        } else { //qui puo' essere attiva o cancellata e non vogliamo che sia attiva
            require(
                lottery.state == lotteryState.CANCELLED,
                ""///lotteria attiva
            );
        }

        _burn(_msgSender(), lotteryId, amount);

        _contractChocoChip.mint(
            _msgSender(),
            totalRefunding * _amountChocoChipPerEther
        );

        if (lottery.state == lotteryState.CANCELLED) {
            Address.sendValue(payable(_msgSender()), totalRefunding);
        }

        if (
            lottery.state == lotteryState.CONCLUDED 
            && 
            _msgSender() == lottery.winner
            &&
            IERC721(lottery.prizeContract).ownerOf(lottery.prizeTokenId) == address(this)
        ) {
            IERC721(lottery.prizeContract).safeTransferFrom(
                address(this), 
                _msgSender(), 
                lottery.prizeTokenId
            );
        }
        
        /// manage after melting
        if (totalSupply(lotteryId) == 0) {
            _lotteryIdToLottery[lotteryId].state = lotteryState.TRASHED;
        }

    }

    function drawWinner(
        uint256 lotteryId
    ) internal 
    {
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];

        require(
            lottery.state == lotteryState.ACTIVE
            &&
            lottery.expirationDate < block.timestamp,
            ""
        );
        
        _activeLotteryIds.remove(lotteryId);
        uint256 numberOfWonkaBars = totalSupply(lotteryId);

        if (numberOfWonkaBars == 0) {
            lottery.prizeContract.safeTransferFrom(
                address(this),
                lottery.owner,
                lottery.prizeTokenId
            );
            _lotteryIdToLottery[lotteryId].state = lotteryState.TRASHED;
        } else {
            EnumerableSet.AddressSet storage wonkaBarHolders = _lotteryIdToWonkaBarHolders[lotteryId];
            uint256 numberOfWonkaBarHolders = wonkaBarHolders.length();
            uint256 winnerIndex = random(numberOfWonkaBars)+1;
            uint256 totalizer = 0; 
            address winner;
            
            for (uint256 i=0; i<numberOfWonkaBarHolders; i++) {
                address holder = wonkaBarHolders.at(i);
                totalizer += balanceOf(holder, lotteryId);
                if (winnerIndex <= totalizer) {
                    winner = holder;
                    break;
                }
            }
            _lotteryIdToLottery[lotteryId].winner = winner;
            _lotteryIdToLottery[lotteryId].state = lotteryState.CONCLUDED;
        }
        
    }

    function random(uint256 a) internal pure returns(uint256) {
        return a%a;
    }

    function checkUpkeep(
        bytes calldata /*checkData*/
    ) external view cannotExecute returns (bool upkeepNeeded, bytes memory performData) 
    {
        uint256 numberOfActiveLottery = _activeLotteryIds.length();
        for (uint256 i=0; i<numberOfActiveLottery; i++) {
            uint256 lotteryId = _activeLotteryIds.at(i);
            if (_lotteryIdToLottery[lotteryId].expirationDate < block.timestamp) {
                return (true, abi.encode(lotteryId));
            }
        }
        return (false, "");
    }

    function performUpkeep(bytes calldata performData) external {
        uint256 lotteryId = abi.decode(performData, (uint256));
        drawWinner(lotteryId);
    }


}

/**
 * @dev
 * il lender riceve 1 choc pari al numero di finney spesi in ticket
 * il bowworare riceve 1 choc pari al numero di finney spesi in interessi
 *
 */
