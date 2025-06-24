// Copyright (c) Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {IERC1155} from "@openzeppelin/contracts/token/erc1155/IERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/erc1155/IERC1155Receiver.sol";

import {Checkin} from "./Checkin.sol";
import {PassportCheck} from "./PassportCheck.sol";


/**
 * Allow players to submit claim requests.
 *
 * Each ERC1155 NFT added to this contract has a percentage likely to be returned and the
 * number available for claim. NFTs can be given the percentage likelihood of claim of 0%.
 * This indicates that the token is a fallback option if other claims aren't going to be 
 * returned.
 *
 * The algorithm for determining which token id to return is:
 *
 * generate random_value between 0% and 100%
 * cumulative_percentage = 0
 * for (all token ids where the remaining balance to be claimed is > 0, and the token isn't a fallback option) {
 *   if random_value is between cumulative_percentage and cumulative_percentage + token ids percentage {
 *     allocate that token id
 *   }
 * }
 * if (no token has been allocated) {
 *   Allocate token from the first fallback option available.
 * }
 *
 * This contract is designed to be upgradeable.
 */
contract Claim is AccessControlEnumerableUpgradeable, PausableUpgradeable, PassportCheck, UUPSUpgradeable, IERC1155Receiver {
    /// @notice Error: Attempting to upgrade contract storage to version 0.
    error CanNotUpgradeToLowerOrSameVersion(uint256 _storageVersion);

    /// @notice The number of tokens to be added can not be zero.
    error AddMoreTokensBalanceMustBeNonZero();
    /// @notice The percentage can not be greater than 100%.
    error AddMoreTokensPercentageTooLarge();
    /// @notice NewDaysPlayedToClaim is too small.
    error ProposedNewDaysPlayedToClaimTooSmall(uint256 _newDaysPlayedToClaim);
    /// @notice When calling RemoveTokens, the number of tokens to be removed can not be zero.
    error CantRemoveNoTokens();
    /// @notice The number of tokens to be removed was greater than the balance. 
    error BalanceTooLow(uint256 slot, uint256 amount, uint256 balance);

    /// @notice There are no tokens avaialable for claim.
    error NoTokensAvailableForClaim();
    /// @notice The game player has attempted a claim too early.
    error ClaimTooEarly(uint256 _daysPlayed, uint256 _claimedSoFar);
    /// @notice Claim was called from an account that isn't a Passport Wallet.
    error ClaimNonPassportAccount(address _claimer);
    /// @notice prepareClaim hasn't been called before claim was called.
    error ClaimBeforeClaimPrepare(address _passportAddr, uint256 _salt);

    /// @notice Value of daysPlayedToClaim has been set.
    event SettingDaysPlayedToClaim(uint256 _newDaysPlayedToClaim);
    /// @notice Tokens were added to the contract.
    event TokensAdded(uint256 _slot, address _erc1155Contract, uint256 _tokenId, uint256 _amount, uint256 _percentage);
    /// @notice Tokens were removed from the contract.
    event TokensRemoved(uint256 _slot, address _erc1155Contract, uint256 _tokenId, uint256 _amount);
    /// @notice A game player has claimed an NFT.
    event Claimed(address _gamePlayer, address _erc1155Contract, uint256 _tokenId, uint256 _daysPlayed, uint256 _claimedSoFar);

    /// @notice The first Owner role is returned as the owner of the contract.
    bytes32 public constant OWNER_ROLE = bytes32("OWNER_ROLE");

    /// @notice CONFIG_ROLE: Controls upgrades, passport check 
    /// config, time to wait for claiming a token.
    bytes32 public constant CONFIG_ROLE = bytes32("CONFIG_ROLE");

    /// @notice TOKEN_ROLE: Token adding and removal.
    bytes32 public constant TOKEN_ROLE = bytes32("TOKEN_ROLE");


    /// @notice Version 0 version number
    uint256 internal constant _VERSION1 = 1;

    uint256 private constant DEFAULT_DAYS_PLAYED_TO_CLAIM = 30;
    uint256 private constant ONE_HUNDRED_PERCENT = 10000;

    uint256 private constant INVALID = 0;

    uint256 private constant MIN_DAYS_PLAYED_TO_CLAIM = 7;


    /// @notice version number of the storage variable layout.
    uint256 public version;

    // Mapping to player to the most recent days played they have claimed.
    mapping(address player => uint256 alreadyClaimed) public claimedDay;

    // Holds a player's stats.
    struct ClaimableToken {
        address erc1155Contract;
        uint256 tokenId;
        uint256 balance;    // Number available for claim.
        uint256 percentage; // Percentage to two decimal places. Hence 23.45% is 2345.
    }
    mapping (uint256 => ClaimableToken) public claimableTokens;

    uint256 public nextSpareClaimableTokenSlot;
    uint256 public firstInUseClaimableTokenSlot;

    Checkin public checkin;

    uint256 public daysPlayedToClaim;

    // True when the add function is being called.
    bool private transient inAddFunction;

    /**
     * @notice Initialises the upgradeable contract, setting up admin accounts.
     * @param _roleAdmin the address to grant `DEFAULT_ADMIN_ROLE` to.
     * @param _owner the address to grant `OWNER_ROLE` to.
     * @param _configAdmin the address to grant `CONFIG_ROLE` to.
     * @param _aPassportWallet A passport wallet address. This can be any Passport wallet.
     * @param _checkin Checkin contract.
     */
    function initialize(address _roleAdmin, address _owner, address _configAdmin, address _tokenAdmin,
        address _aPassportWallet, address _checkin) public virtual initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __Pausable_init();
        __PassportCheck_init(_aPassportWallet);
        _grantRole(DEFAULT_ADMIN_ROLE, _roleAdmin);
        _grantRole(OWNER_ROLE, _owner);
        _grantRole(CONFIG_ROLE, _configAdmin);
        _grantRole(TOKEN_ROLE, _tokenAdmin);
        version = _VERSION1;
        checkin = Checkin(_checkin);

        nextSpareClaimableTokenSlot = 1;
        firstInUseClaimableTokenSlot = 1;
        daysPlayedToClaim = DEFAULT_DAYS_PLAYED_TO_CLAIM;
    }

    /**
     * @notice Function to be called when upgrading this contract.
     * @dev Call this function as part of upgradeToAndCall().
     *      This initial version of this function reverts. There is no situation
     *      in which it makes sense to upgrade to the V0 storage layout.
     *      Note that this function is permissionless. Future versions must
     *      compare the code version and the storage version and upgrade
     *      appropriately. As such, the code will revert if an attacker calls
     *      this function attempting a malicious upgrade.
     * @ param _data ABI encoded data to be used as part of the contract storage upgrade.
     */
    function upgradeStorage(bytes memory /* _data */) external virtual {
        revert CanNotUpgradeToLowerOrSameVersion(version);
    }

    /**
     * @notice Add a smart contract wallet to the Allowlist.
     * This will allowlist the proxy and implementation contract pair.
     * First, the bytecode of the proxy is added to the bytecode allowlist.
     * Second, the implementation address stored in the proxy is stored in the
     * implementation address allowlist.
     * @param _walletAddr the wallet address to be added to the allowlist
     */
    function addPassportWallet(address _walletAddr) external onlyRole(CONFIG_ROLE) {
        _addWalletToAllowlist(_walletAddr);
    }

    /**
     * @notice Remove a smart contract wallet from the Allowlist
     * This will remove the proxy bytecode hash and implementation contract address pair from the allowlist
     * @param _walletAddr the wallet address to be removed from the allowlist
     */
    function removePassportWallet(address _walletAddr) external onlyRole(CONFIG_ROLE) {
        _removeWalletFromAllowlist(_walletAddr);
    }

    /**
     * @notice Pause the operational parts of the contract.
     */
    function pause() external onlyRole(CONFIG_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause the operational parts of the contract.
     */
    function unpause() external onlyRole(CONFIG_ROLE) {
        _unpause();
    }

    /**
     * @notice Change the number of days between when game players can claim new tokens.
     * @param _newDaysPlayedToClaim The new number of days before a player can claim.
     */
    function setDaysPlayedToClaim(uint256 _newDaysPlayedToClaim) external onlyRole(CONFIG_ROLE) {
        if (_newDaysPlayedToClaim < MIN_DAYS_PLAYED_TO_CLAIM) {
            revert ProposedNewDaysPlayedToClaimTooSmall(_newDaysPlayedToClaim);
        }
        daysPlayedToClaim = _newDaysPlayedToClaim;
        emit SettingDaysPlayedToClaim(_newDaysPlayedToClaim);
    }

    /**
     * @notice Add tokens to the contract.
     * @param _claimableToken Information about tokens to be added to the contract.
     */
    function addMoreTokens(ClaimableToken calldata _claimableToken) external onlyRole(TOKEN_ROLE) {
        inAddFunction = true;
        if (_claimableToken.balance == 0) {
            revert AddMoreTokensBalanceMustBeNonZero();
        }
        if (_claimableToken.percentage > ONE_HUNDRED_PERCENT) {
            revert AddMoreTokensPercentageTooLarge();
        }

        IERC1155 erc1155 = IERC1155(_claimableToken.erc1155Contract);
        erc1155.safeTransferFrom(msg.sender, address(this), _claimableToken.tokenId, _claimableToken.balance, new bytes(0));

        uint256 slot = nextSpareClaimableTokenSlot;
        claimableTokens[slot] = _claimableToken;
        nextSpareClaimableTokenSlot = slot + 1;

        emit TokensAdded(slot, address(_claimableToken.erc1155Contract), _claimableToken.tokenId, 
            _claimableToken.balance, _claimableToken.percentage);

        // Reset the transient variable just in case this function is being called as a larger call graph.
        inAddFunction = false;
    }

    /**
     * @notice Remove all tokens from a token slot.
     * @param _slot Entry in claimable tokens map.
     */
    function removeAllTokens(uint256 _slot) external onlyRole(TOKEN_ROLE) {
        _removeTokens(_slot, 0);
    }

    /**
     * @notice Remove some tokens from a token slot.
     * @param _slot Entry in claimable tokens map.
     * @param _amount The number of tokens to remove. 
     */
    function removeTokens(uint256 _slot, uint256 _amount) external onlyRole(TOKEN_ROLE) {
        if (_amount == 0) {
            revert CantRemoveNoTokens();
        }
        _removeTokens(_slot, _amount);
    }

    /**
     * @notice Claim an NFT. 
     */
    function claim() external whenNotPaused() {
        // Claims are only allowed from passport wallets.
        if (!isPassport(msg.sender)) {
            revert ClaimNonPassportAccount(msg.sender);
        }

        // Check that the player is eligible to claim.
        (uint256 daysPlayed, uint256 claimedSoFar) = _checkAndUpdateClaimedDay();

        // Calculate an on-chain random number.
        uint256 randomValue = _generateRandom(block.number - 1);

        // Select an NFT based on the random value.
        (address nftContract, uint256 tokenId) = _determineRandomNft(randomValue);

        // Transfer an NFT to the game player.
        IERC1155 erc1155 = IERC1155(nftContract);
        erc1155.safeTransferFrom(address(this), msg.sender, tokenId, 1, new bytes(0));

        emit Claimed(msg.sender, nftContract, tokenId, daysPlayed, claimedSoFar);
    }

    /**
     * @dev Handles the receipt of a single ERC-1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @ param operator The address which initiated the transfer (i.e. msg.sender)
     * @ param from The address which previously owned the token
     * @ param id The ID of the token being transferred
     * @ param value The amount of tokens being transferred
     * @ param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address /* operator */,
        address /* from */,
        uint256 /* id */,
        uint256 /* value */,
        bytes calldata /* data */
    ) external view override(IERC1155Receiver) returns (bytes4) {
        if (inAddFunction) {
            return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
        }
        else {
            return bytes4(0);
        }

    }

    /**
     * @dev Handles the receipt of a multiple ERC-1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @ param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @ param from The address which previously owned the token
     * @ param ids An array containing ids of each token being transferred (order and length must match values array)
     * @ param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @ param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address /* operator */,
        address /* from */,
        uint256[] calldata /* ids */,
        uint256[] calldata /* values */,
        bytes calldata /* data */
    ) external pure override(IERC1155Receiver) returns (bytes4) {
        // There is no circumstance in which a batch transfer should be made.
        return bytes4(0);
    }


    /**
     * @dev Returns the address of the current owner, for use by systems that need an "owner".
     */
    function owner() public view virtual returns (address) {
        return getRoleMember(OWNER_ROLE, 0);
    }

    /**
     * @notice Return the list of claimable tokens. 
     * @return Information about claimable tokens.
     */
    function getClaimableNfts() external view returns (ClaimableToken[] memory) {
        // Determine how big the array to be returned should be.
        uint256 numUniqueNfts = 0;
        for (uint256 i = firstInUseClaimableTokenSlot; i < nextSpareClaimableTokenSlot; i++) {
            ClaimableToken storage claimableToken = claimableTokens[i];
            uint256 balance = claimableToken.balance;
            if (balance != 0) {
                numUniqueNfts++;
            }
        }

        // Populate the array to return
        ClaimableToken[] memory uniqueNfts = new ClaimableToken[](numUniqueNfts);
        uint256 offset = 0;
        for (uint256 i = firstInUseClaimableTokenSlot; i < nextSpareClaimableTokenSlot; i++) {
            ClaimableToken storage claimableToken = claimableTokens[i];
            uint256 balance = claimableToken.balance;
            if (balance != 0) {
                uniqueNfts[offset].erc1155Contract = claimableToken.erc1155Contract;
                uniqueNfts[offset].tokenId = claimableToken.tokenId;
                uniqueNfts[offset].balance = claimableToken.balance;
                uniqueNfts[offset].percentage = claimableToken.percentage;
                offset++;
            }
        }
        return uniqueNfts;
    }

    /**
     * @notice Remove tokens allocated to a slot.
     * @dev This function will crash if the slot hasn't been initialised.
     * @param _slot Entry in claimable tokens map.
     * @param _amount The number of tokens to transfer, or 0 if all tokens should be transferred.
     */
    function _removeTokens(uint256 _slot, uint256 _amount) internal {
        ClaimableToken storage claimableToken = claimableTokens[_slot];
        uint256 balance = claimableToken.balance;
        uint256 amount = (_amount == 0) ? balance : _amount;
        if (balance < amount) {
            revert BalanceTooLow(_slot, _amount, balance);
        }
        claimableToken.balance = balance - amount;
        IERC1155 erc1155 = IERC1155(claimableToken.erc1155Contract);
        uint256 tokenId = claimableToken.tokenId;
        erc1155.safeTransferFrom(address(this), msg.sender, tokenId, amount, new bytes(0));
        emit TokensRemoved(_slot, address(erc1155), tokenId, amount);
    }


    /**
     * @notice Check if days played is DAYS_PLAYED_TO_CLAIM more than when the game player previously claimed.
     */
    function _checkAndUpdateClaimedDay() internal returns (uint256, uint256) {
        uint256 daysPlayed;
        (, daysPlayed) = checkin.stats(msg.sender);
        uint256 claimedSoFar = claimedDay[msg.sender];
        if (daysPlayed >= claimedSoFar + daysPlayedToClaim) {
            // Claim approved!
            claimedDay[msg.sender] = claimedSoFar + daysPlayedToClaim;
        }
        else {
            revert ClaimTooEarly(daysPlayed, claimedSoFar);
        }
        return (daysPlayed, claimedSoFar);
    }


    /**
     * @notice Return a random number between 0 and 100000.
     * @dev The security of this function is no absolute. 
     * Things to consider:
     * - Only Passport Wallets can call the claim function. This ensures Immutable's Relayer checks
     *   the call trace before execution to ensure only game owned contracts are in the call path.
     * - Attackers would need to create a modified version of the game app, that uses the games
     *   API key, to make the Relayer perceive the game is executing the transaction. 
     * - Attackers would need to find a time when many blocks in a row are empty (this doesn't happen
     *   on Immutable zkEVM).
     * - Attackers would need to estimate the future block hash based on no transactions in the
     *   blocks.
     * - The attacker would have to guess which block their transaction was going to be included in.
     * - Passport does not support multi-call. As such, the attacker could not use passport to
     *   claim an NFT and then separately check which NFT was claimed, and revert if a suitable NFT is 
     *   not obtained. As such, they might have to repeat attack attempts to be successful.
     * - Claim can only be called once each 30 days of game play. 
     * - If an attack is observed, this random number generator could be updated to use a VRF.
     *
     * This function is virtual so that overriding test contracts can insert a random number of 
     * their choice.
     */
    function _generateRandom(uint256 _blockNum) internal virtual view returns (uint256) {
        bytes32 bhash = blockhash(_blockNum);
        bytes32 rand = keccak256(abi.encodePacked(msg.sender, bhash));
        return uint256(rand) % ONE_HUNDRED_PERCENT;
    }

    /**
     * @notice Determine the NFT to return based on the random value.
     * @param _randomValue Value that matches a percentage between 0 and 10000 (0% and 100%).
     */
    function _determineRandomNft(uint256 _randomValue) internal returns (address, uint256) {
        uint256 infiniteToken = INVALID;
        uint256 runningTotalPercentage = 0;

        for (uint256 i = firstInUseClaimableTokenSlot; i < nextSpareClaimableTokenSlot; i++) {
            ClaimableToken storage claimableToken = claimableTokens[i];
            uint256 balance = claimableToken.balance;
            if (balance == 0) {
                if (i == firstInUseClaimableTokenSlot) {
                    firstInUseClaimableTokenSlot++;
                }
                continue;
            }
            uint256 percentage = claimableToken.percentage;
            if (percentage == 0) {
                if (infiniteToken == INVALID) {
                    infiniteToken = i;
                }
                continue;
            }
            runningTotalPercentage = runningTotalPercentage + percentage;
            if (runningTotalPercentage > _randomValue) {
                claimableToken.balance = balance - 1;
                return (claimableToken.erc1155Contract, claimableToken.tokenId);
            }
        }

        if (infiniteToken != INVALID) {
            ClaimableToken storage claimableToken = claimableTokens[infiniteToken];
            claimableToken.balance = claimableToken.balance - 1;
            return (claimableToken.erc1155Contract, claimableToken.tokenId);
        }

        revert NoTokensAvailableForClaim();
    }

    // Override the _authorizeUpgrade function
    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(CONFIG_ROLE) {}


    /// @notice storage gap for additional variables for upgrades
    // slither-disable-start unused-state
    // solhint-disable-next-line var-name-mixedcase
    uint256[20] private __ClaimGap;
    // slither-disable-end unused-state

}
