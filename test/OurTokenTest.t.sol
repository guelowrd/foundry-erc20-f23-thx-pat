// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;
    address public alice;
    address public bob;
    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        alice = makeAddr("alice"); // Replace with an actual user address
        bob = makeAddr("bob"); // Replace with another actual user address
        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 allowanceAmount = 100;

        // Approve alice to spend allowanceAmount tokens on behalf of the sender
        bool approvalSuccess = MintableToken(address(ourToken)).approve(
            alice,
            allowanceAmount
        );
        assertTrue(approvalSuccess, "Approval failed");

        // Check the allowance granted to alice
        assertEq(
            ourToken.allowance(address(this), alice),
            allowanceAmount,
            "Incorrect allowance"
        );
    }

    function testTransfers() public {
        uint256 transferAmount = 50;

        // Transfer tokens from the sender to alice
        vm.prank(bob);
        bool transferSuccess = ourToken.transfer(alice, transferAmount);
        assertTrue(transferSuccess, "Transfer failed");

        // Check the balances of the sender and alice
        assertEq(
            ourToken.balanceOf(bob),
            STARTING_BALANCE - transferAmount,
            "Incorrect balance"
        );
        assertEq(
            ourToken.balanceOf(alice),
            transferAmount,
            "Incorrect balance"
        );

        // Allow alice to spend tokens on behalf of bob
        vm.prank(bob);
        MintableToken(address(ourToken)).approve(alice, transferAmount);

        // alice transfers tokens from bob to alice
        vm.prank(alice);
        bool transferFromSuccess = MintableToken(address(ourToken))
            .transferFrom(bob, alice, transferAmount);
        assertTrue(transferFromSuccess, "TransferFrom failed");

        // Check the balances of bob and alice
        assertEq(
            ourToken.balanceOf(bob),
            STARTING_BALANCE - transferAmount * 2,
            "Incorrect balance"
        );
        assertEq(
            ourToken.balanceOf(alice),
            transferAmount * 2,
            "Incorrect balance"
        );
    }

    // Additional tests you can include

    function testSymbolAndName() public {
        string memory symbol = ourToken.symbol();
        string memory name = ourToken.name();

        assertEq(symbol, "OTK", "Incorrect symbol");
        assertEq(name, "OurToken", "Incorrect name");
    }

    function testDecimals() public {
        uint8 decimals = ourToken.decimals();

        assertEq(decimals, 18, "Incorrect decimals");
    }

    function testTotalSupply() public {
        uint256 totalSupply = ourToken.totalSupply();

        assertEq(
            totalSupply,
            deployer.INITIAL_SUPPLY(),
            "Incorrect total supply"
        );
    }

    function testBalanceOfBob() public {
        uint256 initialBalance = ourToken.balanceOf(bob);

        assertEq(initialBalance, STARTING_BALANCE, "Incorrect initial balance");
    }
}
