// SPDX-License-Identifier: MIT
// VincenzoImp MeltyFi (last updated v0.0.1) (NFT/src/MeltyFi.sol)

pragma solidity ^0.8.0;

import "./ChocoChip.sol";
import "./WonkaTicket.sol";

contract MeltyFi {

    address private owner;
    
    ChocoChip public immutable choco;

    struct Lottery { 
        uint sold_tickets;
        uint total_ticket_supply;
        //function price_distribution_function;
        uint deadline;
        //IERC721 NFT list;
    }

    constructor() {
        choco = new ChocoChip("ChocoChip", "CHCH", 10000000, address(this));
        
    }
    function transferMelty() public {
        choco.approve(msg.sender, 10);
    }
    function saldo() public view returns (uint256){
        return choco.balanceOf(msg.sender);
    }
}
