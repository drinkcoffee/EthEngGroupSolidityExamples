// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {SmartAccountDelegate} from "../src/SmartAccountDelegate.sol";
import {ERC20} from "../src/ERC20.sol";

contract SmartAccountDelegateTest is Test {
    // Alice's address and private key (EOA with no initial contract code).
    address payable ALICE_ADDRESS = payable(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    uint256 constant ALICE_PK = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
 
    // Bob's address and private key (Bob will execute transactions on Alice's behalf).
    address constant BOB_ADDRESS = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    uint256 constant BOB_PK = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
 
    // The contract that Alice will delegate execution to.
    SmartAccountDelegate public implementation;
 
    // ERC-20 token contract for minting test tokens.
    ERC20 public token;
 
    function setUp() public {
        // Deploy the delegation contract (Alice will delegate calls to this contract).
        implementation = new SmartAccountDelegate();
 
        // Deploy an ERC-20 token contract where Alice is the minter.
        token = new ERC20(ALICE_ADDRESS);
    }
 
    function testSignDelegationAndThenAttachDelegation() public {
        // Construct a single transaction call: Mint 100 tokens to Bob.
        SmartAccountDelegate.Call[] memory calls = new SmartAccountDelegate.Call[](1);
        bytes memory data = abi.encodeCall(ERC20.mint, (100, BOB_ADDRESS));
        calls[0] = SmartAccountDelegate.Call({to: address(token), data: data, value: 0});
 
        // Alice signs a delegation allowing `implementation` to execute transactions on her behalf.
        VmSafe.SignedDelegation memory signedDelegation = vm.signDelegation(address(implementation), ALICE_PK);
 
        // Bob attaches the signed delegation from Alice and broadcasts it.
        vm.broadcast(BOB_PK);
        vm.attachDelegation(signedDelegation);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(ALICE_ADDRESS).code;
        require(code.length > 0, "no code written to Alice");
 
        // As Bob, execute the transaction via Alice's assigned contract.
        SmartAccountDelegate(ALICE_ADDRESS).execute(calls);
 
        // Verify Bob successfully received 100 tokens.
        assertEq(token.balanceOf(BOB_ADDRESS), 100);
    }



    function testSignAndAttachDelegation() public {
        // Construct a single transaction call: Mint 100 tokens to Bob.
        SmartAccountDelegate.Call[] memory calls = new SmartAccountDelegate.Call[](1);
        bytes memory data = abi.encodeCall(ERC20.mint, (100, BOB_ADDRESS));
        calls[0] = SmartAccountDelegate.Call({to: address(token), data: data, value: 0});
 
        // Alice signs and attaches the delegation in one step (eliminating the need for separate signing).
        vm.signAndAttachDelegation(address(implementation), ALICE_PK);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(ALICE_ADDRESS).code;
        require(code.length > 0, "no code written to Alice");
 
        // As Bob, execute the transaction via Alice's assigned contract.
        vm.broadcast(ALICE_PK);
        SmartAccountDelegate(ALICE_ADDRESS).execute(calls);
 
        // Verify Bob successfully received 100 tokens.
        vm.assertEq(token.balanceOf(BOB_ADDRESS), 100);
    }


    function testSignDelegationAndThenAttachDelegationBadAuth() public {
        // Construct a single transaction call: Mint 100 tokens to Bob.
        SmartAccountDelegate.Call[] memory calls = new SmartAccountDelegate.Call[](1);
        bytes memory data = abi.encodeCall(ERC20.mint, (100, BOB_ADDRESS));
        calls[0] = SmartAccountDelegate.Call({to: address(token), data: data, value: 0});
 
        // Alice signs a delegation allowing `implementation` to execute transactions on her behalf.
        VmSafe.SignedDelegation memory signedDelegation = vm.signDelegation(address(implementation), ALICE_PK);
 
        // Bob attaches the signed delegation from Alice and broadcasts it.
        vm.broadcast(BOB_PK);
        vm.attachDelegation(signedDelegation);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(ALICE_ADDRESS).code;
        require(code.length > 0, "no code written to Alice");
 
        // As Bob, execute the transaction via Alice's assigned contract.
        vm.expectRevert(abi.encodeWithSelector(SmartAccountDelegate.InvalidAuthority.selector));
        SmartAccountDelegate(ALICE_ADDRESS).execute(calls);
    }

}