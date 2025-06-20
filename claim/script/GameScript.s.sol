// Copyright (c) Whatgame Studios 2024 - 2024
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Checkin} from "../src/Checkin.sol";
import {Claim} from "../src/Claim.sol";
import {ImmutableERC1155} from "../src/immutable/ImmutableERC1155.sol";

contract GameScript is Script {
    function deployV1() public {
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        address roleAdmin = deployer;
        address upgradeAdmin = deployer;
        address owner = deployer;

        vm.broadcast();
        Checkin impl = new Checkin();
        bytes memory initData = abi.encodeWithSelector(
            Checkin.initialize.selector, roleAdmin, owner, upgradeAdmin);

        vm.broadcast();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);

        console.logString("Deployment address");
        console.logAddress(address(proxy));
    }

    function deployClaimV1() public {
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        address roleAdmin = deployer;
        address configAdmin = deployer;
        address tokenAdmin = deployer;
        address owner = deployer;

        // A randomly selected passport wallet on mainnet.
        address aPassportWalletMainnet = 0xDa77D416bb4238c9424b8d27A7f90fA2Bdf4911E;
        address checkinMainnet = 0xe2E762770156FfE253C49Da6E008b4bECCCf2812;

        vm.broadcast();
        Claim impl = new Claim();
        bytes memory initData = abi.encodeWithSelector(
            Claim.initialize.selector, 
            roleAdmin, owner, configAdmin, tokenAdmin, aPassportWalletMainnet, checkinMainnet);

        vm.broadcast();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);

        console.logString("Deployment address");
        console.logAddress(address(proxy));
    }



    function populateTokens() public {
        address tokenReserve = 0xD44D3C3EDC6D1dDBe429E6662Bd79F262DF25132;
        address claim = 0xb427336d725943BA4300EEC219587E207ad21146;
        address nftCollection = 0xb427336d725943BA4300EEC219587E207ad21146;

        ImmutableERC1155 erc1155 = ImmutableERC1155(nftCollection);

        Claim.ClaimableToken memory token = Claim.ClaimableToken({
            erc1155Contract: nftCollection,
            tokenId: 100,
            balance: 6,
            percentage: 100
        });

        Claim claimContract = Claim(claim);

        vm.broadcast(tokenReserve);
        erc1155.setApprovalForAll(address(claim), true);

        vm.broadcast(tokenReserve);
        claimContract.addMoreTokens(token);
        console.logString("Done");
    }
}
