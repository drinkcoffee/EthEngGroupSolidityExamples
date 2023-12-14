// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";


contract CoolNFT is  ERC721PresetMinterPauserAutoIdUpgradeable {
    string public constant NAME = "Just Cool!";
    string public constant SYMBOL = "JCL";
    string public constant URI = "https://somewhere.com/";

    function initialize() public virtual initializer {
        super.initialize(NAME, SYMBOL, URI);
    }
}
