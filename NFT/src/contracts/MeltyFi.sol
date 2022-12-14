// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error MeltyFi__NotOwner();

contract MeltyFi {

    address private owner;

    struct Lottery { 
        uint sold_tickets;
        uint total_ticket_supply;
        //function price_distribution_function;
        uint deadline;
        //IERC721 NFT list;
    }
    //lottery_list;
    modifier onlyOwner {
        if (msg.sender != owner) revert MeltyFi__NotOwner();
        _;
    }
}
