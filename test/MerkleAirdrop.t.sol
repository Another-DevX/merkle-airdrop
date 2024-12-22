// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AnotherToken} from "../src/AnotherToken.sol";
import {DeployMerkleAidrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    AnotherToken public token;
    uint256 public amount = 25 * 1e18;
    bytes32 ZERO_PROOF =
        0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 PROOF_1 =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32[] public PROOF = [ZERO_PROOF, ZERO_PROOF, PROOF_1];
    address user;
    uint256 userPk;
    address gasPayer;

    function setUp() public {
        DeployMerkleAidrop deploy = new DeployMerkleAidrop();
        (airdrop, token) = deploy.deployMerkleAirdrop();
        (user, userPk) = makeAddrAndKey("User");
        gasPayer = makeAddr("gasPayer");
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

    function testUserClaimInBehalfAnotherUser() public {

        vm.prank(user);
        bytes32 digest = airdrop.getMessageDigest(user, amount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPk, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, amount, PROOF, v, r, s);
    }
}
