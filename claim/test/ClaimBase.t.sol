// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
// solhint-disable not-rely-on-time

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {Checkin} from "../src/Checkin.sol";
import {Claim} from "../src/Claim.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ImmutableERC1155} from "../src/immutable/ImmutableERC1155.sol";
import {OperatorAllowlistUpgradeable} from "../src/immutable/allowlist/OperatorAllowlistUpgradeable.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/erc1155/IERC1155Receiver.sol";

contract FakePassportMainModule is IERC1155Receiver{
    Claim claimContract;
    function setClaimContract(address _claimContract) external {
        claimContract = Claim(_claimContract);
    }
    function claim() external {
        claimContract.claim();
    }

    function onERC1155Received(
        address /* operator */,
        address /* from */,
        uint256 /* id */,
        uint256 /* value */,
        bytes calldata /* data */
    ) external pure override(IERC1155Receiver) returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address /* operator */,
        address /* from */,
        uint256[] calldata /* ids */,
        uint256[] calldata /* values */,
        bytes calldata /* data */
    ) external pure override(IERC1155Receiver) returns (bytes4) {
        // There is no circumstance in which a batch transfer should be made.
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    function supportsInterface(bytes4 /* interfaceId */) external pure returns (bool) {
        return true;
    }

}


abstract contract ClaimBaseTest is Test {
    uint256 constant TOK1_TOKEN_ID = 12;
    uint256 constant TOK1_AMOUNT = 3;
    uint256 constant TOK1_PERCENTAGE = 100; // 1%
    uint256 constant TOK2_TOKEN_ID = 13;
    uint256 constant TOK2_AMOUNT = 1000;
    uint256 constant TOK2_PERCENTAGE = 1900; // 19%
    uint256 constant TOK3_TOKEN_ID = 14;
    uint256 constant TOK3_AMOUNT = 2;
    uint256 constant TOK3_PERCENTAGE = 0;   // Fallback NFT
    uint256 constant TOK4_TOKEN_ID = 20;
    uint256 constant TOK4_AMOUNT = 13;
    uint256 constant TOK4_PERCENTAGE = 30; // 0.3%
    uint256 constant TOK5_TOKEN_ID = 30;
    uint256 constant TOK5_AMOUNT = 300;
    uint256 constant TOK5_PERCENTAGE = 0;   // Fallback NFT

    uint256 constant DEFAULT_TOKEN_ID = TOK1_TOKEN_ID;
    uint256 constant DEFAULT_AMOUNT = TOK1_AMOUNT;
    uint256 constant DEFAULT_PERCENTAGE = TOK1_PERCENTAGE;



    bytes32 public defaultAdminRole;
    bytes32 public configRole;
    bytes32 public ownerRole;
    bytes32 public tokenRole;

    address public roleAdmin;
    address public configAdmin;
    address public tokenAdmin;
    address public owner;
    address public operatorRegistrarAdmin;

    address public player1;
    address public player2;

    Claim claim;
    Checkin checkin;

    OperatorAllowlistUpgradeable allowList;
    ImmutableERC1155 public mockERC1155;
    FakePassportMainModule public passportWallet;
    address public passportWalletAddress;



    function setUp() public virtual {
        vm.roll(1000);

        roleAdmin = makeAddr("RoleAdmin");
        configAdmin = makeAddr("ConfigAdmin");
        tokenAdmin = makeAddr("TokenAdmin");
        owner = makeAddr("Owner");

        player1 = makeAddr("Player1");
        player2 = makeAddr("Player2");

        Claim temp = new Claim();
        defaultAdminRole = temp.DEFAULT_ADMIN_ROLE();
        configRole = temp.CONFIG_ROLE();
        ownerRole = temp.OWNER_ROLE();
        tokenRole = temp.TOKEN_ROLE();

        setUpCheckin();
        setUpPassportWallet();
        setUpClaim();
        passportWallet.setClaimContract(address(claim));
        setUpOperatorAllowlist();
        setUpMockERC1155();
    }

    function setUpCheckin() private {
        address upgradeAdmin = makeAddr("UpgradeAdmin");
        Checkin impl = new Checkin();
        bytes memory initData = abi.encodeWithSelector(
            Checkin.initialize.selector, address(0), address(0), upgradeAdmin);
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        checkin = Checkin(address(proxy));
    }

    bytes internal constant creationCode = hex"6054600f3d396034805130553df3fe63906111273d3560e01c14602b57363d3d373d3d3d3d369030545af43d82803e156027573d90f35b3d90fd5b30543d5260203df3";
    function setUpPassportWallet() private {
        bytes32 salt = bytes32(0);
        FakePassportMainModule fakeMainModule = new FakePassportMainModule();
        bytes memory code = abi.encodePacked(creationCode, uint256(uint160(address(fakeMainModule))));
        address deployedContract;
        assembly {
            deployedContract := create2(callvalue(), add(code, 32), mload(code), salt)
        }
        // check deployment success
        require(deployedContract != address(0), 'WalletFactory: deployment failed');
        passportWallet = FakePassportMainModule(deployedContract);
        passportWalletAddress = address(passportWallet);
    }

    function setUpClaim() private {
        Claim impl = new Claim();
        bytes memory initData = abi.encodeWithSelector(
            Claim.initialize.selector, 
            roleAdmin, owner, configAdmin, tokenAdmin, passportWallet, checkin);
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        claim = Claim(address(proxy));
    }

    function setUpOperatorAllowlist() private {
        address admin = address(0);
        address upgradeAdmin = address(0);
        operatorRegistrarAdmin = makeAddr("operatorRegistrarAdmin");
        OperatorAllowlistUpgradeable impl = new OperatorAllowlistUpgradeable();
        bytes memory initData = abi.encodeWithSelector(
            OperatorAllowlistUpgradeable.initialize.selector, admin, upgradeAdmin, operatorRegistrarAdmin
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        allowList = OperatorAllowlistUpgradeable(address(proxy));

        // Add Passport Wallet to the allowlist
        vm.prank(operatorRegistrarAdmin);
        allowList.addWalletToAllowlist(address(passportWallet));

        // Add claim contract to the allowlist
        address[] memory contracts = new address[](1);
        contracts[0] = address(claim);
        vm.prank(operatorRegistrarAdmin);
        allowList.addAddressesToAllowlist(contracts);
    }

    function setUpMockERC1155() private {
        string memory name = "Test Collection";
        string memory baseURI = "https://test.com/nfts/{id}.json";
        string memory contractURI = "https://test.com/collection.json";
        address operatorAllowlist = address(allowList);
        address receiver = address(1);
        uint96 feeNumerator = 10;
        address minter = makeAddr("minter");

        mockERC1155 = new ImmutableERC1155(
            owner,
            name,
            baseURI,
            contractURI,
            operatorAllowlist,
            receiver,
            feeNumerator);
        vm.prank(owner);
        mockERC1155.grantMinterRole(minter);
        vm.startPrank(minter);
        mockERC1155.safeMint(tokenAdmin, TOK1_TOKEN_ID, TOK1_AMOUNT, new bytes(0));
        mockERC1155.safeMint(tokenAdmin, TOK2_TOKEN_ID, TOK2_AMOUNT, new bytes(0));
        mockERC1155.safeMint(tokenAdmin, TOK3_TOKEN_ID, TOK3_AMOUNT, new bytes(0));
        mockERC1155.safeMint(tokenAdmin, TOK4_TOKEN_ID, TOK4_AMOUNT, new bytes(0));
        mockERC1155.safeMint(tokenAdmin, TOK5_TOKEN_ID, TOK5_AMOUNT, new bytes(0));
        vm.stopPrank();
    }
}
