// Copyright (c) Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

import {GameDayCheck} from "./GameDayCheck.sol";


/**
 * Manage checkins.
 *
 * This contract is designed to be upgradeable.
 */
contract Checkin is 
    AccessControlEnumerableUpgradeable, GameDayCheck, UUPSUpgradeable {

    /// @notice Error: Attempting to upgrade contract storage to version 0.
    error CanNotUpgradeToLowerOrSameVersion(uint256 _storageVersion);

    event CheckIn(uint256 _gameDay, address _player, uint256 _numDaysPlayed);


    /// @notice Only UPGRADE_ROLE can upgrade the contract
    bytes32 public constant UPGRADE_ROLE = bytes32("UPGRADE_ROLE");

    /// @notice The first Owner role is returned as the owner of the contract.
    bytes32 public constant OWNER_ROLE = bytes32("OWNER_ROLE");

    /// @notice Version 0 version number
    uint256 internal constant _VERSION1 = 1;
    /// @notice Version 2 version number
    uint256 private constant _VERSION2 = 2;
    /// @notice Version 3 version number
    uint256 private constant _VERSION3 = 3;


    /// @notice version number of the storage variable layout.
    uint256 public version;

    // Holds a player's stats.
    struct Stats {
        uint32 mostRecentGameDay;
        uint256 daysPlayed;
    }

    // Map: player address => player's stats.
    mapping(address => Stats) public stats;


    /**
     * @notice Initialises the upgradeable contract, setting up admin accounts.
     * @param _roleAdmin the address to grant `DEFAULT_ADMIN_ROLE` to.
     * @param _owner the address to grant `OWNER_ROLE` to.
     * @param _upgradeAdmin the address to grant `UPGRADE_ROLE` to.
     */
    function initialize(address _roleAdmin, address _owner, address _upgradeAdmin) public virtual initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _roleAdmin);
        _grantRole(OWNER_ROLE, _owner);
        _grantRole(UPGRADE_ROLE, _upgradeAdmin);
        version = _VERSION1;
    }

    /**
     * @notice Function to be called when upgrading this contract.
     * @dev Call this function as part of upgradeToAndCall().
     * @ param _data ABI encoded data to be used as part of the contract storage upgrade.
     */
    function upgradeStorage(bytes memory /* _data */) external virtual {
        revert CanNotUpgradeToLowerOrSameVersion(version);
    }

    /**
     * Log the day the game was played.
     *
     * @param _gameDay The day since the game epoch start.
     */
    function checkIn(uint32 _gameDay) external virtual {
        // Reverts if game day is in the future or in the past.
        checkGameDay(_gameDay);

        Stats storage playerStats = stats[msg.sender];
        if (_gameDay > playerStats.mostRecentGameDay) {
            playerStats.mostRecentGameDay = _gameDay;
            uint256 daysPlayed = playerStats.daysPlayed + 1;
            playerStats.daysPlayed = daysPlayed;
            emit CheckIn(_gameDay, msg.sender, daysPlayed);
        }
    }

    /**
     * @dev Returns the address of the current owner, for use by systems that need an "owner".
     * This is the first role admin.
     */
    function owner() public view virtual returns (address) {
        return getRoleMember(OWNER_ROLE, 0);
    }

    // Override the _authorizeUpgrade function
    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADE_ROLE) {}
}
