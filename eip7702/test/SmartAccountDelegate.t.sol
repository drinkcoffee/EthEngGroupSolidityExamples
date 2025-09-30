// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {SmartAccountDelegate} from "../src/SmartAccountDelegate.sol";
import {FixedSupplyERC20, ERC20} from "../src/FixedSupplyERC20.sol";

contract SmartAccountDelegateTest is Test {

    uint256 constant SUPPLY = 100;
    uint256 constant AMOUNT = 10;

    address bank = makeAddr("Bank");


    // Alice's address and private key (EOA with no initial contract code).
    address payable alice;
    uint256 alicePrivateKey;


    // Bob's address and private key (Bob will execute transactions on Alice's behalf).
    address constant BOB_ADDRESS = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    uint256 constant BOB_PK = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
 
    // The contract that Alice will delegate execution to.
    SmartAccountDelegate public implementation;
 
    // ERC-20 token contract for minting test tokens.
    FixedSupplyERC20 public token;
 
    function setUp() public {
        address aliceAddr;
        (aliceAddr, alicePrivateKey) = makeAddrAndKey("Alice");
        alice = payable(aliceAddr);


        // Deploy the delegation contract (Alice will delegate calls to this contract).
        implementation = new SmartAccountDelegate();
 
        // Deploy an ERC-20 token contract where Alice is the minter.
        token = new FixedSupplyERC20(alice, SUPPLY, "TOKEN", "TOK");
    }
 
    function testSignDelegationAndThenAttachDelegation() public {
        SmartAccountDelegate.Call[] memory calls = createCalls();
 
        // Alice signs a delegation allowing `implementation` to execute transactions on her behalf.
        VmSafe.SignedDelegation memory signedDelegation = vm.signDelegation(address(implementation), alicePrivateKey);
 
        // Bob attaches the signed delegation from Alice and broadcasts it.
        vm.broadcast(BOB_PK);
        vm.attachDelegation(signedDelegation);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(alice).code;
        require(code.length > 0, "no code written to Alice");
 
        // As Bob, execute the transaction via Alice's assigned contract.
        SmartAccountDelegate(alice).execute(calls);
 
        // Verify Bob successfully received 10 tokens.
        assertEq(token.balanceOf(BOB_ADDRESS), 10);
    }



    function testSignAndAttachDelegation() public {
        SmartAccountDelegate.Call[] memory calls = createCalls();
 
        // Alice signs and attaches the delegation in one step (eliminating the need for separate signing).
        vm.signAndAttachDelegation(address(implementation), alicePrivateKey);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(alice).code;
        require(code.length > 0, "no code written to Alice");
 
        // As Bob, execute the transaction via Alice's assigned contract.
        vm.broadcast(alicePrivateKey);
        SmartAccountDelegate(alice).execute(calls);
 
        // Verify Bob successfully received 10 tokens.
        vm.assertEq(token.balanceOf(BOB_ADDRESS), 10);
    }


    function testSignDelegationAndThenAttachDelegationBadAuth() public {
        SmartAccountDelegate.Call[] memory calls = createCalls();
 
        // Alice signs a delegation allowing `implementation` to execute transactions on her behalf.
        VmSafe.SignedDelegation memory signedDelegation = vm.signDelegation(address(implementation), alicePrivateKey);
 
        // Bob attaches the signed delegation from Alice and broadcasts it.
        vm.broadcast(BOB_PK);
        vm.attachDelegation(signedDelegation);
 
        // Verify that Alice's account now behaves as a smart contract.
        bytes memory code = address(alice).code;
        require(code.length > 0, "no code written to Alice");
 
        // As Bob, execute the transaction via Alice's assigned contract.
        vm.expectRevert(abi.encodeWithSelector(SmartAccountDelegate.InvalidAuthority.selector));
        SmartAccountDelegate(alice).execute(calls);
    }

    function createCalls() private view returns (SmartAccountDelegate.Call[] memory) {
        // Construct a single transaction call: Transfer tokens to Bob.
        SmartAccountDelegate.Call[] memory calls = new SmartAccountDelegate.Call[](1);
        bytes memory data = abi.encodeCall(ERC20.transfer, (BOB_ADDRESS, AMOUNT));
        calls[0] = SmartAccountDelegate.Call({to: address(token), data: data, value: 0});
        return calls;
    }

}