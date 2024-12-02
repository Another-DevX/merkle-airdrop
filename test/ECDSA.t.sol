// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {ECDSA} from "../src/ECDSA.sol";

contract MerkleAirdropTest is Test {
    ECDSA public ecdsa;
    address public user;
    uint256 public userPk;

    function setUp() public {
        ecdsa = new ECDSA();
        (user, userPk) = makeAddrAndKey("User");
    }

    function testRecover() public {
        string memory message = "Hello, Ethereum!";
        bytes32 h = sha256(abi.encodePacked(message));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPk, h);
        address result = ecdsa.recover(message, r, s, v);
        console.log("Recovered address: %s", result);
        assertEq(result, user);
    }

    function testRecoverFromSignature() public {
        string memory message = "Hello, Ethereum!";
        bytes32 h = sha256(abi.encodePacked(message));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPk, h);
        bytes memory signature = abi.encodePacked(r, s, v);
        address result = ecdsa.recoverFromSignature(h, signature);
        console.log("Recovered address: %s", result);
        assertEq(result, user);
    }
}
