// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ChocoChip.sol";
import "./WonkaBar.sol";
import "./MeltyFiDAO.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract MeltyFiNFT is Ownable {
    // ChocoChip contract
    ChocoChip internal immutable _contractChocoChip;

    // WonkaBar contract
    WonkaBar internal immutable _contractWonkaBar;

    // MeltyFiDAO contract
    MeltyFiDAO internal immutable _contractMeltyFiDAO;

    constructor(ChocoChip contractChocoChip, WonkaBar contractWonkaBar, MeltyFiDAO contractMeltyFiDAO) {
        _contractChocoChip = contractChocoChip;
        _contractWonkaBar = contractWonkaBar;
        _contractMeltyFiDAO = contractMeltyFiDAO;
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

    /**
     * @dev Returns the address of the DAO ecosystem (MeltyFi DAO).
     */
    function addressMeltyFiDAO() public view virtual returns (address) {
        return address(_contractMeltyFiDAO);
    }
}

/**
 * @dev
 * il lender riceve 1 choc pari al numero di finney spesi in ticket
 * il bowworare riceve 1 choc pari al numero di finney spesi in interessi
 *
 */
