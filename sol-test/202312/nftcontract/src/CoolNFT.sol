// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";


contract CoolNFT is  ERC721PausableUpgradeable, AccessControlUpgradeable {
    error NotPauser(address _notPauser);
    error NotUnpauser(address _notUnpauser);
    error NotMinter(address _notMinter);

    string public constant NAME = "Just Cool!";
    string public constant SYMBOL = "JCL";

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    modifier onlyPauser {
        if (!hasRole(PAUSER_ROLE, msg.sender)) {
            revert NotPauser(msg.sender);
        }
        _;
    }

    modifier onlyUnpauser {
        if (!hasRole(UNPAUSER_ROLE, msg.sender)) {
            revert NotUnpauser(msg.sender);
        }
        _;
    }

    modifier onlyMinter {
        if (!hasRole(MINTER_ROLE, msg.sender)) {
            revert NotMinter(msg.sender);
        }
        _;
    }

    function initialize() public virtual onlyInitializing {
        __ERC721_init(NAME, SYMBOL);
        __ERC721Pausable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UNPAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function pause() external onlyPauser {
        _pause();
    }

    function unpause() external onlyUnpauser {
        _unpause();
    }

    function mint(address to, uint256 tokenId) external onlyMinter {
        _mint(to, tokenId);
    }


    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override (AccessControlUpgradeable, ERC721Upgradeable) returns (bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || ERC721Upgradeable.supportsInterface(interfaceId);
    }
}
