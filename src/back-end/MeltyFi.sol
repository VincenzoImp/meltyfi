// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./MeltyFiNFT.sol";
import "./MeltyFiDAO.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract MeltyFi is Ownable, MeltyFiNFT, MeltyFiDAO {

    constructor()
        MeltyFiNFT()
        MeltyFiDAO(
            _contractChocoChip,
            new TimelockController(
                3600,
                new address[](0),
                new address[](0),
                msg.sender
            )
        )
    {}
}
