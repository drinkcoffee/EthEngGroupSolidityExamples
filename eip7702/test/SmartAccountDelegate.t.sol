// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {SmartAccountDelegate} from "../src/SmartAccountDelegate.sol";
import {FixedSupplyERC20, ERC20} from "../src/FixedSupplyERC20.sol";

contract SmartAccountDelegateTest is Test {

    uint256 constant SUPPLY = 100;
    uint256 constant AMOUNT = 10;

    // ERC-20 token contract for minting test tokens.
    FixedSupplyERC20 public token;

    // Alice's address and private key (EOA with no initial contract code).
    address payable alice;
    uint256 alicePrivateKey;

    // Bob's address and private key (EOA with no initial contract code).
    address bob;
    uint256 bobPrivateKey;

    // The contract that Alice will delegate execution to.
    SmartAccountDelegate public smartAccountTemplate;
 
    // Expected code for Alice after delegation.
    bytes public expectedAliceCode;
 
    function setUp() public {
        address aliceAddr;
        (aliceAddr, alicePrivateKey) = makeAddrAndKey("Alice");
        alice = payable(aliceAddr);
        (bob, bobPrivateKey) = makeAddrAndKey("Bob");

        // Deploy the delegation contract (Alice will delegate calls to this contract).
        smartAccountTemplate = new SmartAccountDelegate();
 
        expectedAliceCode = abi.encodePacked(uint24(0xef0100), address(smartAccountTemplate));

        // Deploy an ERC-20 token contract where Alice owns the total supply.
        token = new FixedSupplyERC20(alice, SUPPLY, "TOKEN", "TOK");
    }

    function testSignThenAttachDelegation() public {
        // Alice signs a delegation allowing `smartAccountTemplate` to execute transactions on her behalf.
        VmSafe.SignedDelegation memory signedDelegation = vm.signDelegation(address(smartAccountTemplate), alicePrivateKey);

        // Attach the signed delegation from Alice and broadcasts it.
        vm.attachDelegation(signedDelegation);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(alice).code;
        assertEq(expectedAliceCode, code, "Incorrect delegation code");
    }

    function testSignThenAttachDelegationWithCalls() public {
        testSignThenAttachDelegation();

        SmartAccountDelegate.Call[] memory calls = createCalls();
 
        // As Alice, execute the transaction via Alice's assigned contract.
        vm.prank(alice);
        SmartAccountDelegate(alice).execute(calls);
 
        // Verify Bob successfully received 10 tokens.
        assertEq(token.balanceOf(bob), 10);
    }

    function testSignThenAttachDelegationWithCallsBadAuth() public {
        testSignThenAttachDelegation();

        SmartAccountDelegate.Call[] memory calls = createCalls();
 
        // As Bob, execute the transaction via Alice's assigned contract.
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(SmartAccountDelegate.InvalidAuthority.selector, bob));
        SmartAccountDelegate(alice).execute(calls);
     }


    function testSignAndAttachDelegation() public {
        // Alice signs and attaches the delegation in one step (eliminating the need for separate signing).
        vm.signAndAttachDelegation(address(smartAccountTemplate), alicePrivateKey);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(alice).code;
        assertEq(expectedAliceCode, code, "Incorrect delegation code");
    }


    function testSignAndAttachDelegationWithCalls() public {
        testSignAndAttachDelegation();

        SmartAccountDelegate.Call[] memory calls = createCalls();
  
        // As Alice, execute the transaction via Alice's assigned contract.
        vm.prank(alice);
        SmartAccountDelegate(alice).execute(calls);
 
        // Verify Bob successfully received 10 tokens.
        vm.assertEq(token.balanceOf(bob), 10);
    }

    function testSignAndAttachDelegationWithCallsBadAuth() public {
        testSignAndAttachDelegation();

        SmartAccountDelegate.Call[] memory calls = createCalls();
  
        // As Bob, execute the transaction via Alice's assigned contract.
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(SmartAccountDelegate.InvalidAuthority.selector, bob));
        SmartAccountDelegate(alice).execute(calls);
    }

    function createCalls() private view returns (SmartAccountDelegate.Call[] memory) {
        // Construct a single transaction call: Transfer tokens to Bob.
        SmartAccountDelegate.Call[] memory calls = new SmartAccountDelegate.Call[](1);
        bytes memory data = abi.encodeCall(ERC20.transfer, (bob, AMOUNT));
        calls[0] = SmartAccountDelegate.Call({to: address(token), data: data, value: 0});
        return calls;
    }

}