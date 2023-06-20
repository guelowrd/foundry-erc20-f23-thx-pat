// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address alice;
    address bob;

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        vm.prank(msg.sender);
        ourToken.transfer(alice, STARTING_BALANCE);
    }

    function testAliceBalance() public {
        assertEq(ourToken.balanceOf(alice), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend 1000 tokens
        vm.prank(alice);
        ourToken.approve(bob, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(bob);
        ourToken.transferFrom(alice, bob, transferAmount);

        assertEq(ourToken.balanceOf(alice), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(bob), transferAmount);
    }
}
