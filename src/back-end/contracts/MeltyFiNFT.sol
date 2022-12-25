// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ChocoChip.sol";
import "./WonkaBar.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MeltyFiNFT is Ownable {
    // ChocoChip contract
    ChocoChip internal immutable _contractChocoChip;

    // WonkaTicket contract
    WonkaBar internal immutable _contractWonkaBar;

    constructor() {
        _contractChocoChip = new ChocoChip();
        _contractWonkaBar = new WonkaBar();
    }

    /**
     * @dev Returns the address of the ERC20 governance token (Choco Chip, CHOC).
     */
    function addressChocoChip() public view virtual returns (address) {
        return address(_contractChocoChip);
    }

    /**
     * @dev Returns the address of the ERC1155 utility token (Wonka Bar, WKB).
     */
    function addressWonkaBar() public view virtual returns (address) {
        return address(_contractWonkaBar);
    }
}

/**
 * @dev
 * il lender riceve 1 choc pari al numero di finney spesi in ticket
 * il bowworare riceve 1 choc pari al numero di finney spesi in interessi
 *
 */
