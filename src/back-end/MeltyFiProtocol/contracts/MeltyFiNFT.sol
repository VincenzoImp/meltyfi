// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/// ChocoChip.sol is the governance token of the MeltyFi protocol
import "./ChocoChip.sol";
/// LogoCollection.sol is the meme token of the MeltyFi protocol
import "./LogoCollection.sol";
/// MeltyFiDAO.sol is the governance contract of the MeltyFi protocol
import "./MeltyFiDAO.sol";
/// VRFv2DirectFundingConsumer.sol is a contract that generates random number
import "./VRFv2DirectFundingConsumer.sol";
/// AutomationBase.sol is a contract that provides basic functionality for integration with Chainlink, a platform for creating connections between smart contracts and external services
import "@chainlink/contracts/src/v0.8/AutomationBase.sol";
/// AutomationCompatibleInterface.sol is an interface that defines the required methods for being compatible with the Chainlink platform and using its automation functionality
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
///Ownable.sol is a contract that provides a basic access control mechanism
import "@openzeppelin/contracts/access/Ownable.sol";
/// ERC1155Supply.sol is a contract that extends the ERC1155 contract and provides functionality for managing the supply of ERC1155 tokens
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
/// IERC721.sol is an interface that defines the required methods for an ERC721 contract
import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 
/// IERC721Receiver.sol is an interface that defines methods for receiving ERC721 tokens
import"@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
/// Address library provides utilities for working with addresses
import "@openzeppelin/contracts/utils/Address.sol"; 
/// EnumerableSet library provides a data structure for storing and iterating over sets of values
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol"; 

/**
 * @notice MeltyFiNFT is the contract that that runs the core functionality of the MeltyFi protocol.
 *         It manages the creation, cancellation and conclusion of lotteries, as well as the
 *         sale and refund of WonkaBars for each lottery, and also reward good users with ChocoChips.
 *         The contract allows users to create a lottery by choosing their NFT to put as lottery prize,
 *         setting an expiration date and defining a price in Ether for each WonkaBar sold.
 *         When a lottery is created, the contract will be able to mint a fixed amount of WonkaBars
 *         (setted by lottery owner) for the lottery. These WonkaBars are sold to users interested
 *         in participating in the lottery and money raised are sent to the lottery owner (less some fees).
 *         Once the expiration date is reached, the contract selects a random WonkaBar
 *         holder as the winner, who receives the prize NFT. Plus every wonkabar holder is rewarded
 *         with ChocoCips. If the lottery is cancelled by the owner beafore the expiration date,
 *         the contract refunds WonkaBars holders with Ether of the lottery owners. Plus every
 *         wonkabar holder is rewarded with ChocoCips.
 */
contract MeltyFiNFT is Ownable, IERC721Receiver, ERC1155Supply, AutomationBase, AutomationCompatibleInterface {

    /// Data type representing the possible states of a lottery
    enum lotteryState {
        ACTIVE,
        CANCELLED,
        CONCLUDED,
        TRASHED
    }

    /// Struct for storing the information of a lottery
    struct Lottery {
        /// Expiration date of the lottery, in seconds
        uint256 expirationDate;
        /// ID of the lottery
        uint256 id;
        /// Owner of the lottery
        address owner;
        /// Prize NFT contract of the lottery
        IERC721 prizeContract;
        /// Prize NFT token ID of the lottery
        uint256 prizeTokenId;
        /// State of the lottery
        lotteryState state;
        /// Winner of the lottery
        address winner;
        /// Number of WonkaBars sold for the lottery
        uint256 wonkaBarsSold;
        /// Maximum supply of WonkaBars for the lottery
        uint256 wonkaBarsMaxSupply;
        /// Price of each WonkaBar for the lottery, in wei
        uint256 wonkaBarPrice;
    }

    /// Using Address for address type
    using Address for address;
    /// Using EnumerableSet for EnumerableSet.AddressSet type
    using EnumerableSet for EnumerableSet.AddressSet;
    /// Using EnumerableSet for EnumerableSet.UintSet type
    using EnumerableSet for EnumerableSet.UintSet;

    /// Instance of the ChocoChip contract
    ChocoChip internal immutable _contractChocoChip;
    /// Instance of the LogoCollection contract
    LogoCollection internal immutable _contractLogoCollection;
    /// Instance of the MeltyFiDAO contract
    MeltyFiDAO internal immutable _contractMeltyFiDAO;
    /// Instance of the VRFv2DirectFundingConsumer contract
    VRFv2DirectFundingConsumer internal immutable _contractVRFv2DirectFundingConsumer;

    /// Amount of ChocoChips per Ether
    uint256 internal immutable _amountChocoChipPerEther;
    /// Percentage of royalties to be paid to the MeltyFiDAO
    uint256 internal immutable _royaltyDAOPercentage;
    /// Upper limit wonkabar balance percentage for a single address for a single lottery
    uint256 internal immutable _upperLimitBalanceOfPercentage;
    /// Upper limit wonkabar supply for a single lottery
    uint256 internal immutable _upperLimitMaxSupply;

    /// Total number of lotteries created.
    uint256 internal _totalLotteriesCreated;

    /// maps a unique lottery ID to a "Lottery" object containing information about the lottery itself
    mapping(
        uint256 => Lottery
    ) internal _lotteryIdToLottery;

    /// maps the address of a lottery owner to a set of lottery IDs that they own
    mapping(
        address => EnumerableSet.UintSet
    ) internal _lotteryOwnerToLotteryIds;

    /// maps the address of a WonkaBar holder to a set of lottery IDs for which they have purchased a ticket
    mapping(
        address => EnumerableSet.UintSet
    ) internal _wonkaBarHolderToLotteryIds;

    /// maps a lottery ID to a set of WonkaBar holder addresses that have purchased a ticket for that lottery
    mapping(
        uint256 => EnumerableSet.AddressSet
    ) internal _lotteryIdToWonkaBarHolders;

    /// set that stores the IDs of all active lotteries
    EnumerableSet.UintSet internal _activeLotteryIds;

    /**
     * @notice Creates a new instance of the MeltyFiNFT contract.
     *
     * @dev Raises error if the address of `contractChocoChip` is not equal to the token address of `contractMeltyFiDAO`.
     *      Raises error if the owner of `contractChocoChip` is not the current message sender.
     *      Raises error if the owner of `contractLogoCollection` is not the current message sender.
     *      Raises error if the owner of `contractVRFv2Consumer` is not the current message sender.
     *
     * @param contractChocoChip instance of the ChocoChip contract.
     * @param contractLogoCollection instance of the LogoCollection contract.
     * @param contractMeltyFiDAO instance of the MeltyFiDAO contract.
     */
    constructor(
        ChocoChip contractChocoChip,
        LogoCollection contractLogoCollection,
        MeltyFiDAO contractMeltyFiDAO,
        VRFv2DirectFundingConsumer contractVRFv2DirectFundingConsumer
    ) ERC1155("https://ipfs.io/ipfs/QmTiQsRBGcKyyipnRGVTu8dPfykM89QHn81KHX488cTtxa")
    {
        /// The ChocoChip contract and the MeltyFiDAO token must be the same contract
        require(
            address(contractChocoChip) == address(contractMeltyFiDAO.token()),
            "MeltyFiNFT: address of contractChocoChip is not equal to the token address of the contractMeltyFiDAO"
        );
        /// The caller must be the owner of the ChocoChip contract.
        require(
            contractChocoChip.owner() == _msgSender(), 
            "MeltyFiNFT: the owner of contractChocoChip is not the current message sender"
        );
        /// The caller must be the owner of the LogoCollection contract.
        require(
            contractLogoCollection.owner() == _msgSender(),
            "MeltyFiNFT: the owner of contractLogoCollection is not the current message sender"
        );
        /// The caller must be the owner of the VRFv2DirectFundingConsumer contract.
        require(
            contractVRFv2DirectFundingConsumer.owner() == _msgSender(), 
            "MeltyFiNFT: the owner of contractVRFv2DirectFundingConsumer is not the current message sender"
        );
        /// Initializing the immutable variables
        _contractChocoChip = contractChocoChip;
        _contractLogoCollection = contractLogoCollection;
        _contractMeltyFiDAO = contractMeltyFiDAO;
        _contractVRFv2DirectFundingConsumer = contractVRFv2DirectFundingConsumer;
        _amountChocoChipPerEther = 1000;
        _royaltyDAOPercentage = 5;
        _upperLimitBalanceOfPercentage = 25;
        _upperLimitMaxSupply = 100;
        _totalLotteriesCreated = 0;
    }

    /**
     * @notice Handles incoming ether payments.
     *
     * @dev This function is required for contracts that want to receive ether. 
     *      It is called automatically whenever ether is sent to the contract.
     */
    receive() external payable {
    }

    /**
     * @notice A function that is called when an ERC721 token is received by this contract.
     *
     * @param operator The address of the operator that is transferring the token.
     * @param from The address of the token owner.
     * @param tokenId The identifier of the token being transferred.
     * @param data Additional data associated with the token transfer.
     *
     * @return The four-byte selector of the `onERC721Received` function.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @notice This function allows the owner of the contract to take a snapshot of the choco chip balance
     */
    function snapshotChocoChip() external onlyOwner
    {
        /// call the snapshot function of ChocoChip contract
        _contractChocoChip.snapshot();
    }

    /**
     * @notice An internal function that is called before a token transfer occurs.
     *
     * @dev This function is called by the `transfer()` and `safeTransfer()` functions
     *      of the `ERC1155Supply` contract to perform any necessary pre-transfer
     *      logic. It is marked as `internal` and `override` to ensure that it can
     *      only be called from within the contract and that it can be overridden
     *      by derived contracts.
     *
     * @param operator The address of the operator that is transferring the tokens.
     * @param from The address of the token owner.
     * @param to The address of the recipient of the tokens.
     * @param ids An array of token identifiers.
     * @param amounts An array of token amounts.
     * @param data Additional data associated with the token transfer.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Supply)
    {
        /// update _wonkaBarHolderToLotteryIds and _lotteryIdToWonkaBarHolders
        for (uint256 i=0; i<ids.length; i++) {
            if (amounts[i] != 0 && to != address(0)) {
                _wonkaBarHolderToLotteryIds[to].add(ids[i]);
                _lotteryIdToWonkaBarHolders[ids[i]].add(to);
            }
        }
        /// call the super function to perform any necessary pre-transfer logic
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     * @notice An internal function that is called after a token transfer occurs.
     *
     * @dev This function is called by the `transfer()` and `safeTransfer()` functions
     *      of the `ERC1155` contract to perform any necessary post-transfer logic.
     *      It is marked as `internal` and `override` to ensure that it can only be
     *      called from within the contract and that it can be overridden by derived
     *      contracts.
     *
     * @param operator The address of the operator that transferred the tokens.
     * @param from The address of the token owner.
     * @param to The address of the recipient of the tokens.
     * @param ids An array of token identifiers.
     * @param amounts An array of token amounts.
     * @param data Additional data associated with the token transfer.
     */
    function _afterTokenTransfer (
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) 
    {
        /// update _wonkaBarHolderToLotteryIds and _lotteryIdToWonkaBarHolders
        for (uint256 i=0; i<ids.length; i++) {
            if (from != address(0) && balanceOf(from, ids[i]) == 0) {
                _wonkaBarHolderToLotteryIds[from].remove(ids[i]);
                _lotteryIdToWonkaBarHolders[ids[i]].remove(from);
            }
        }
        /// call the super function to perform any necessary post-transfer logic
        super._afterTokenTransfer (operator, from, to, ids, amounts, data);
    }

    /**
     * @dev An internal function that returns the address of the ChocoChip contract.
     *
     * @return The address of the ChocoChip contract.
     */
    function _addressChocoChip() internal view returns (address) 
    {
        /// return the address of the ChocoChip contract
        return address(_contractChocoChip);
    }

    /**
     * @dev An internal function that returns the address of the LogoCollection contract.
     *
     * @return The address of the LogoCollection contract.
     */
    function _addressLogoCollection() internal view returns (address) 
    {
        /// return the address of the LogoCollection contract
        return address(_contractLogoCollection);
    }

    /**
     * @dev An internal function that returns the address of the MeltyFiDAO contract.
     *
     * @return The address of the MeltyFiDAO contract.
     */
    function _addressMeltyFiDAO() internal view returns (address) 
    {
        /// return the address of the MeltyFiDAO contract
        return address(_contractMeltyFiDAO);
    }

    /**
     * @dev An internal function that returns the address of the VRFv2DirectFundingConsumer contract.
     *
     * @return The address of the VRFv2DirectFundingConsumer contract.
     */
    function _addressVRFv2DirectFundingConsumer() internal view returns (address) 
    {
        /// return the address of the VRFv2DirectFundingConsumer contract
        return address(_contractVRFv2DirectFundingConsumer);
    }

    /**
     * @dev An internal function that calculates the amount to refund to a given address for a given lottery.
     *      This function is called only if the lottery is cancelled. 
     *
     * @param lottery The lottery for which to calculate the refund amount.
     * @param addressToRefund The address to which the refund will be made.
     *
     * @return The amount to refund to the given address for the given lottery.
     */
    function _amountToRefund(
        Lottery memory lottery, 
        address addressToRefund
    ) internal view returns (uint256)
    {
        /// return the WonkaBar balance of the address in the given lottery multiplied by the price of WonkaBars in the lottery
        return balanceOf(addressToRefund, lottery.id) * lottery.wonkaBarPrice;
    }

    /**
     * @dev An internal function that calculates the amount to repay for a given lottery.
     *      This function is called only if the lottery is active. 
     *
     * @param lottery The lottery for which to calculate the amount to repay.
     *
     * @return The amount to repay for the given lottery.
     */
    function _amountToRepay(
        Lottery memory lottery
    ) internal pure returns (uint256)  
    {
        /// return the number of WonkaBars sold in the lottery multiplied by the price of WonkaBars in the lottery
        return lottery.wonkaBarsSold * lottery.wonkaBarPrice;
    }

    /**
     * @dev An internal function that mints a logo token to a given address.
     *
     * @param to The address to which the logo token will be minted.
     */
    function _mintLogo(
        address to
    ) internal
    {
        /// call the `mint()` function of the LogoCollection contract to mint a logo token to the given address
        _contractLogoCollection.mint(to, 0, 1, "");
    }   

    /**
     * @notice Returns an array of the IDs of all active lotteries.
     *
     * @dev An active lottery is one that has not yet been cancelled or colcluded
     *      and is still selling tickets. This function returns an array of the 
     *      IDs of all such lotteries.
     *
     * @return An array of the IDs of all active lotteries.
     */
    function activeLotteryIds() external view returns(uint256[] memory)
    {
        // return the values of _activeLotteryIds
        return _activeLotteryIds.values();
    }
    
    /**
     * @notice Returns the address of the ChocoChip contract.
     *
     * @return The address of the ChocoChip contract.
     */
    function addressChocoChip() external view returns (address) 
    {
        /// call the internal function to return the address of the ChocoChip contract
        return _addressChocoChip();
    }

    /**
     * @notice Returns the address of the LogoCollection contract.
     *
     * @return The address of the LogoCollection contract.
     */
    function addressLogoCollection() external view returns (address) 
    {
        /// call the internal function to return the address of the LogoCollection contract
        return _addressLogoCollection();
    }

    /**
     * @notice Returns the address of the MeltyFiDAO contract.
     *
     * @return The address of the MeltyFiDAO contract.
     */
    function addressMeltyFiDAO() external view returns (address) 
    {
        /// call the internal function to return the address of the MeltyFiDAO contract
        return _addressMeltyFiDAO();
    }

    /**
     * @notice Returns the address of the VRFv2DirectFundingConsumer contract.
     *
     * @return The address of the VRFv2DirectFundingConsumer contract.
     */
    function addressVRFv2DirectFundingConsumer() external view returns (address) 
    {
        /// call the internal function to return the address of the VRFv2DirectFundingConsumer contract
        return _addressVRFv2DirectFundingConsumer();
    }

    /**
     * @notice Returns the amount to refund to a given address for a given lottery.
     *
     * @param lotteryId The ID of the lottery for which to calculate the refund amount.
     * @param addressToRefund The address to which the refund will be made.
     *
     * @return The amount to refund to the given address for the given lottery. Returns 0 if the lottery is not cancelled.
     */
    function amountToRefund(
        uint256 lotteryId, 
        address addressToRefund
    ) external view returns (uint256)
    {
        /// retrieve the lottery with the given ID
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        /// if the lottery is not cancelled, return 0
        if (lottery.state != lotteryState.CANCELLED) {
            return 0;
        }
        /// otherwise, return the amount to refund calculated by the internal function
        return _amountToRefund(lottery, addressToRefund);
    }
    
    /**
     * @notice Returns the amount to repay for a given lottery.
     *
     * @param lotteryId The ID of the lottery for which to calculate the amount to repay.
     *
     * @return The amount to repay for the given lottery. Returns 0 if the lottery is not active.
     */
    function amountToRepay(
        uint256 lotteryId
    ) external view returns (uint256)
    {
        /// retrieve the lottery with the given ID
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        /// if the lottery is not active, return 0
        if (lottery.state != lotteryState.ACTIVE) {
            return 0;
        }
        /// otherwise, return the amount to repay calculated by the internal function
        return _amountToRepay(lottery);
    }

    /**
     * @notice Returns the amount of ChocoChips per Ether.
     *
     * @return The amount of ChocoChips per Ether.
     */
    function getAmountChocoChipPerEther() external view returns(uint256) 
    {
        /// return amount of ChocoChips per Ether
        return _amountChocoChipPerEther;
    }
    
    /**
     * @notice Returns the struct of given lottery.
     *
     * @param lotteryId The ID of the lottery for which to retrieve struct.
     *
     * @return The struct of given lottery.
     */
    function getLottery(
        uint256 lotteryId
    ) external view returns (Lottery memory)
    {
        return _lotteryIdToLottery[lotteryId];
    }

    /**
     * @notice Returns the percentage of royalties to be paid to the MeltyFiDAO.
     *
     * @return The percentage of royalties to be paid to the MeltyFiDAO.
     */
    function getRoyaltyDAOPercentage() external view returns(uint256)
    {
        /// return the percentage of royalties to be paid to the MeltyFiDAO
        return _royaltyDAOPercentage;
    }

    /**
     * @notice Returns the total number of lotteries created.
     *
     * @return The total number of lotteries created.
     */
    function getTotalLotteriesCreated() external view returns(uint256)
    {
        /// return the total number of lotteries created
        return _totalLotteriesCreated;
    }

    /**
     * @notice Returns the upper limit wonkabar balance percentage for a single address for a single lottery.
     *
     * @return The upper limit wonkabar balance percentage for a single address for a single lottery.
     */
    function getUpperLimitBalanceOfPercentage() external view returns(uint256)
    {
        /// return the upper limit wonkabar balance percentage for a single address for a single lottery
        return _upperLimitBalanceOfPercentage;
    }

    /**
     * @notice Returns the upper limit wonkabar supply for a single lottery.
     *
     * @return The upper limit wonkabar supply for a single lottery.
     */
    function getUpperLimitMaxSupply() external view returns(uint256)
    {
        /// return the upper limit wonkabar supply for a single lottery
        return _upperLimitMaxSupply;
    }

    /**
     * @notice Returns an array of the IDs of all lotteries in which a given address holds WonkaBars.
     *
     * @param holder The address of the WonkaBar holder.
     *
     * @return An array of the IDs of all lotteries in which the given address holds WonkaBars.
     */
    function holderInLotteryIds(
        address holder
    ) external view returns(uint256[] memory )
    {
        /// return the values of _wonkaBarHolderToLotteryIds[holder]
        return _wonkaBarHolderToLotteryIds[holder].values();
    }

    /**
     * @notice Mints a logo token and sends it to the given address.
     *
     * @param to The address to which the logo token should be sent.
     */
    function mintLogo(
        address to
    ) external 
    {
        /// call the internal function to mint a logo token and send it to the given address
        _mintLogo(to);
    }

    /**
     * @notice Returns an array of the IDs of all lotteries owned by a given address.
     *
     * @param owner The address of the lottery owner.
     *
     * @return An array of the IDs of all lotteries owned by the given address.
     */
    function ownedLotteryIds(
        address owner
    ) external view returns(uint256[] memory )
    {
        /// return the values of _lotteryOwnerToLotteryIds[owner]
        return _lotteryOwnerToLotteryIds[owner].values();
    }

    /**
     * @notice Creates a new lottery.
     *
     * @dev Raises error if the caller is not the owner of the prize.
     *      Raises error if the maximum number of Wonka Bars for sale is greater that the upper bound.
     *      Raises error if the maximum number of Wonka Bars for sale is lower than the lower bound.
     *
     * @param duration The duration of the lottery, in seconds.
     * @param prizeContract The contract that holds the prize for this lottery.
     * @param prizeTokenId The token ID of the prize for this lottery.
     * @param wonkaBarPrice The price of a Wonka Bar in this lottery.
     * @param wonkaBarsMaxSupply The maximum number of Wonka Bars that can be sold in this lottery.
     *
     * @return The ID of the new lottery.
     */
    function createLottery(
        uint256 duration,
        IERC721 prizeContract,
        uint256 prizeTokenId,
        uint256 wonkaBarPrice,
        uint256 wonkaBarsMaxSupply
    ) public returns (uint256) 
    {
        /*
        /// The caller must be the owner of the prize
        require(
            prizeContract.ownerOf(prizeTokenId) == _msgSender(), 
            "MeltyFi: The caller is not the owner of the prize"
        );
        */
        /// The maximum number of Wonka Bars for sale must not be greater than the upper bound
        require(
            wonkaBarsMaxSupply <= _upperLimitMaxSupply,
            "MeltyFi: The maximum number of Wonka Bars for sale is greater that the upper bound"
        );
        /// The maximum number of Wonka Bars for sale must not be lower than the lower bound
        require(
            (wonkaBarsMaxSupply * _upperLimitBalanceOfPercentage) / 100 >= 1, 
            "MeltyFi: The maximum number of Wonka Bars for sale is lower than the lower bound"
        );
        /// transfer the prize to this contract
        prizeContract.safeTransferFrom(
            _msgSender(),
            address(this),
            prizeTokenId
        );
        /// create a new lottery
        uint256 lotteryId = _totalLotteriesCreated;
        _lotteryIdToLottery[lotteryId] = Lottery(
            block.timestamp+duration, /// expiration date
            lotteryId, /// ID
            _msgSender(), /// owner
            prizeContract, /// prize contract
            prizeTokenId, /// prize token ID
            lotteryState.ACTIVE, /// state
            address(0), /// winner
            0, /// number of Wonka Bars sold
            wonkaBarsMaxSupply, /// maximum number of Wonka Bars for sale
            wonkaBarPrice /// price of a Wonka Bar
        );
        /// update internal state
        _totalLotteriesCreated += 1;
        _lotteryOwnerToLotteryIds[_msgSender()].add(lotteryId);
        _activeLotteryIds.add(lotteryId);
        /// return the ID of the new lottery
        return lotteryId;
    }

    /**
     * @notice Allows a user to buy a specified amount of Wonka Bars for a lottery. The caller must send the correct amount of Ether 
     *         along with the transaction. A percentage of the total spending will be transferred to the MeltyFiDAO contract and the rest 
     *         will be transferred to the owner of the lottery. The caller's balance of Wonka Bars for the specified lottery will also be 
     *         updated.
     *
     * @dev Raises error if the lottery is not really active.
     *      Raises error if after this purchease the total supply of WonkaBars will exceed the maximum supply allowed.
     *      Raises error if the caller's balance of Wonka Bars for this lottery, after the purchase, will exceed the `_upperLimitBalanceOfPercentage`.
     *      Raises error if the value sent is not enough to cover the cost of the Wonka Bars.
     *
     * @param lotteryId The ID of the lottery for which the Wonka Bars are being purchased.
     * @param amount The number of Wonka Bars to be purchased.
     */
    function buyWonkaBars(
        uint256 lotteryId, 
        uint256 amount
    ) public payable
    {
        /// retrieve the lottery with the given ID
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        /// calculate the total spending for the Wonka Bars
        uint256 totalSpending = amount * lottery.wonkaBarPrice;
        /// The lottery must be really active
        require(
            block.timestamp < lottery.expirationDate,
            "MeltyFiNFT: The lottery is not really active"
        );
        /// After this purchease the total supply of WonkaBars must not exceed the maximum supply allowed.
        require(
            lottery.wonkaBarsSold + amount <= lottery.wonkaBarsMaxSupply,
            "MeltyFi: After this purchease the total supply of WonkaBars will exceed the maximum supply allowed"
        );
        /// The caller's balance of Wonka Bars for this lottery, after the purchase, must not exceed the _upperLimitBalanceOfPercentage
        require(
            (
                ((balanceOf(_msgSender(), lotteryId) + amount + 1) * 100)
                / 
                lottery.wonkaBarsMaxSupply
            )
            <=
            _upperLimitBalanceOfPercentage,
            "MeltyFi: The caller's balance of Wonka Bars for this lottery, after the purchase, will exceed the _upperLimitBalanceOfPercentage"
        );
        /// The caller must sent anough amount of Ether to cover the cost of the Wonka Bars
        require(
            msg.value >= totalSpending, 
            "MeltyFiNFT: The value sent is not enough to cover the cost of the Wonka Bars"
        );
        /// transfer _royaltyDAOPercentage of the total spending to the MeltyFiDAO contract
        uint256 valueToDAO = (totalSpending / 100) * _royaltyDAOPercentage;
        Address.sendValue(payable(_addressMeltyFiDAO()), valueToDAO);
        /// transfer the rest of the total spending to the owner of the lottery
        uint256 valueToLotteryOwner = totalSpending - valueToDAO;
        Address.sendValue(payable(lottery.owner), valueToLotteryOwner);
        /// mint the Wonka Bars for the caller
        _mint(_msgSender(), lotteryId, amount, "");
        /// update the total number of Wonka Bars sold for the lottery
        _lotteryIdToLottery[lotteryId].wonkaBarsSold += amount;
    }

    /**
     * @notice Repays the loan for the given lotteryId. The caller of the function must be the owner of the lottery.
     *
     * @dev Raises error if the caller is not the owner of the lottery.
     *      Raises error if the value sent is not enough to repay the loan.
     *      Raises error if the lottery is not more active.
     *
     * @param lotteryId The id of the lottery to repay the loan for.
     */
    function repayLoan(
        uint256 lotteryId
    ) public payable 
    {
        /// retrieve the lottery with the given ID
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        /// Calculate the total amount to be repaid
        uint256 totalPaying = _amountToRepay(lottery);
        /// The caller must be the owner of the lottery
        require(
            lottery.owner == _msgSender(),
            "MeltyFi: The caller is not the owner of the lottery"
        );
        /// The caller must sent anough amount of Ether to repay the loan
        require(
            msg.value >= totalPaying, 
            "MeltyFi: The value sent is not enough to repay the loan"
        );
        /// The lottery must be active
        require(
            block.timestamp < lottery.expirationDate,
            "MeltyFiNFT: The lottery is not more active"
        );
        /// Mint Choco Chips to the owner of the lottery
        _contractChocoChip.mint(
            _msgSender(),
            totalPaying * _amountChocoChipPerEther
        );
        /// Transfer the prize to the owner of the lottery
        lottery.prizeContract.safeTransferFrom(
            address(this),
            _msgSender(),
            lottery.prizeTokenId
        );
        /// Remove the lottery from the active lotteries
        _activeLotteryIds.remove(lotteryId);
        /// set the expiration date to the current block timestamp
        _lotteryIdToLottery[lotteryId].expirationDate = block.timestamp;
        /// If the total supply of WonkaBars is 0, set the state to TRASHED, otherwise set it to CANCELLED
        if (totalSupply(lotteryId) == 0) {
            _lotteryIdToLottery[lotteryId].state = lotteryState.TRASHED;
        } else {
            _lotteryIdToLottery[lotteryId].state = lotteryState.CANCELLED;
        }
    }

    /**
     * @notice Draws the winner of a lottery.
     *
     * @dev Raises error if the lottery state is not active.
     *      Raises error if the lottery expiration date is not passed.
     *      Raises error if the VRF request for random words is not fulfilled.
     *
     * @param lotteryId The ID of the lottery.
     */
    function drawWinner(
        uint256 lotteryId
    ) public 
    {
        /// retrieve the lottery with the given ID
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        /// The lottery state must be active
        require(
            lottery.state == lotteryState.ACTIVE,
            "MeltyFi: The lottery state is not active"
        );
        // The lottery expiration date must be passed
        require(
            block.timestamp >= lottery.expirationDate,
            "MeltyFi: The lottery expiration date is not passed"
        );
        /// remove lottery from _activeLotteryIds
        _activeLotteryIds.remove(lotteryId);
        /// if there are no WonkaBar sold transfer prize to the owner, otherwise set lottery winner
        uint256 numberOfWonkaBars = totalSupply(lotteryId);
        if (numberOfWonkaBars == 0) {
            /// transfer prize to the owner if no tokens were sold
            lottery.prizeContract.safeTransferFrom(
                address(this),
                lottery.owner,
                lottery.prizeTokenId
            );
            /// set lottery state to trashed
            _lotteryIdToLottery[lotteryId].state = lotteryState.TRASHED;
        } else {
            /// set lottery winner
            EnumerableSet.AddressSet storage wonkaBarHolders = _lotteryIdToWonkaBarHolders[lotteryId];
            uint256 numberOfWonkaBarHolders = wonkaBarHolders.length();
            uint256 requestId = _contractVRFv2DirectFundingConsumer.requestRandomWords();
            (uint256 paid, bool fulfilled, uint256[] memory randomWords) = _contractVRFv2DirectFundingConsumer.getRequestStatus(requestId);
            /// The VRF request for random words must be fulfilled
            require(
                fulfilled, 
                "MeltyFi: The VRF request for random words is not fulfilled"
            );
            uint256 winnerIndex = (randomWords[0]%numberOfWonkaBars)+1;
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

    /**
     * @notice Allows a user to melt their WonkaBars of a specific lottery and receive a refund in return.
     *
     * @dev Raises error if the user does not have enough WonkaBar balance to melt the given amount.
     *      Raises error if the lottery is trashed.
     *      Raises error if lottery is really active.
     *      Raises error if lottery is waiting to be concluded by the oracle.
     *
     * @param lotteryId The ID of the lottery from which the WonkaBars will be melted.
     * @param amount The amount of WonkaBars to be melted.
     */
    function meltWonkaBars(
        uint256 lotteryId, 
        uint256 amount
    ) public 
    {
        /// retrieve the lottery with the given ID
        Lottery memory lottery = _lotteryIdToLottery[lotteryId];
        /// calculate the total refound for the Wonka Bars
        uint256 totalRefunding = _amountToRefund(lottery, _msgSender());
        /// the user must have enough WonkaBar balance to melt the given amount
        require(
            balanceOf(_msgSender(), lotteryId) >= amount,
            "MeltyFi: The user does not have enough WonkaBar balance to melt the given amount"
        );
        /// the lottery must not be trashed
        require(
            lottery.state != lotteryState.TRASHED,
            "MeltyFi: The lottery is trashed"
        );
        /// lottery must not be really active or waiting to be concluded by the oracle
        if (lottery.state == lotteryState.ACTIVE) {
            if (block.timestamp < lottery.expirationDate) {
                revert("MeltyFi: The lottery is still active");
            } else {
                revert("MeltyFi: The lottery is waiting to be concluded by the oracle");
            }
        }
        /// Burn the Wonka Bars for the caller
        _burn(_msgSender(), lotteryId, amount);
        /// Mint Choco Chips to the caller
        _contractChocoChip.mint(
            _msgSender(),
            totalRefunding * _amountChocoChipPerEther
        );
        /// if lottery state is cancelled, also refound the caller
        if (lottery.state == lotteryState.CANCELLED) {
            Address.sendValue(payable(_msgSender()), totalRefunding);
        }
        /// if the caller is the winner and he does not already receive the price
        if (
            lottery.state == lotteryState.CONCLUDED 
            && 
            _msgSender() == lottery.winner
            &&
            IERC721(lottery.prizeContract).ownerOf(lottery.prizeTokenId) == address(this)
        ) {
            /// transfer prize to the caller (the winner)
            IERC721(lottery.prizeContract).safeTransferFrom(
                address(this), 
                _msgSender(), 
                lottery.prizeTokenId
            );
        }
        /// if all lottery's WonkaBars are melted, trash the lottery
        if (totalSupply(lotteryId) == 0) {
            _lotteryIdToLottery[lotteryId].state = lotteryState.TRASHED;
        }
    }

    /**
     * @notice Checks if any active lotteries need to be concluded.
     *
     * @dev This function is designed to be called by an external contract using
     *      the `call` function. It is expected to be called periodically to check
     *      if any active lotteries need to be concluded (e.g. because the expiration
     *      date has passed).
     *
     * @param checkData Unused input data.
     *
     * @return upkeepNeeded Whether any lotteries need to be concluded.
     * @return performData The ID of the lottery to be concluded, if any.
     */
    function checkUpkeep(
        bytes calldata checkData
    ) external view cannotExecute returns (bool upkeepNeeded, bytes memory performData) 
    {
        uint256 numberOfActiveLottery = _activeLotteryIds.length();
        /// iterates through the set of active lotteries and checks the expiration date of each one
        for (uint256 i=0; i<numberOfActiveLottery; i++) {
            uint256 lotteryId = _activeLotteryIds.at(i);
            /// If it finds a lottery that has expired, it returns `true` and the ID of the lottery in `performData`
            if (_lotteryIdToLottery[lotteryId].expirationDate <= block.timestamp) {
                return (true, abi.encode(lotteryId));
            }
        }
        /// If it does not find any expired lotteries, it returns `false` and an empty string in `performData`
        return (false, "");
    }

    /**
     * @notice Concludes an active lottery.
     *
     * @dev This function is intended to be called by an external contract in response to the `checkUpkeep`
     *      function returning `true`. It decodes the `performData` input to retrieve the ID of the lottery
     *      to be concluded and calls the `drawWinner` function to draw the winner and update the state of the
     *      lottery.
     *
     * @param performData The ID of the lottery to be concluded.
     */
    function performUpkeep(
        bytes calldata performData
    ) external
    {
        uint256 lotteryId = abi.decode(performData, (uint256));
        /// call the drawWinner function to draw the winner and update the state of the lottery
        drawWinner(lotteryId);
    }
}
