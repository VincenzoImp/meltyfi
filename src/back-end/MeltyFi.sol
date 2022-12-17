// SPDX-License-Identifier: MIT
// VincenzoImp MeltyFi (last updated v0.0.1) (src/MeltyFi.sol)

pragma solidity ^0.8.0;

import "./ChocoChip.sol";
import "./WonkaTicket.sol";
import "./openzeppelin-contracts/utils/Address.sol";
import "./openzeppelin-contracts/utils/Context.sol";

contract MeltyFi is Context {
    using Address for address;

    // address of the contract owner
    address private _owner;
    
    // ChocoChip contract
    ChocoChip private _chocoChip;

    // WonkaTicket contract
    WonkaTicket private _wonkaTicket;

    struct Lottery { 
        uint sold_tickets;
        uint total_ticket_supply;
        //function price_distribution_function;
        uint deadline;
        //IERC721 NFT list;
    }

    constructor() {
        _owner = _msgSender();
        _chocoChip = new ChocoChip("Choco Chip", "CHOC", 1000000000*10**18, address(this));
        _wonkaTicket = new WonkaTicket("Wonka Ticket");
    }

    /**
     * @dev Returns the name of the owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the ERC20 governance token (Choco Chip, CHOC).
     */
    function chocoChipAddress() public view virtual returns (address) {
        return address(_chocoChip);
    }

    /**
     * @dev Returns the address of the ERC1155 utility token (Wonka Ticket, WTK).
     */
    function wonkaTicketAddress() public view virtual returns (address) {
        return address(_wonkaTicket);
    }
}


/**
* @dev 
* il lender riceve 1 choc pari al numero di finney spesi in ticket
* il bowworare riceve 1 choc pari al numero di finney spesi in interessi
* 
*/