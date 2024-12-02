// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AnotherToken} from "../src/AnotherToken.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    AnotherToken public token;
    uint256 public amount = 25 * 1e18;
    bytes32 public ROOT =
        0xe7942661b2b26bfba2ec6c09d56b3dbf2e3a8fc6fba415d3a60baabe01310b6b;
    bytes32 ZERO_PROOF =
        0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 PROOF_1 =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32[] public PROOF = [ZERO_PROOF, ZERO_PROOF, PROOF_1];
    address user;
    uint256 userPk;

    function setUp() public {
        token = new AnotherToken();
        airdrop = new MerkleAirdrop(ROOT, token);
        (user, userPk) = makeAddrAndKey("User");
        token.mint(address(airdrop), amount * 4);
        console.log("User Address :%s", user);
    }

    function testUserClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        console.log("Starting Balance: %s", startingBalance);

        vm.prank(user);
        airdrop.claim(user, amount, PROOF);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance: %s", endingBalance);

        assertEq(endingBalance - startingBalance, amount);
    }

    function testUserClaimTwice() public {
        testUserClaim();
        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(user, amount, PROOF);
    }
}
