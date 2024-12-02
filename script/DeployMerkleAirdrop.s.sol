// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AnotherToken} from "../src/AnotherToken.sol";

contract DeployMerkleAidrop is Script {

    bytes32 private _merkleRoot = 0xe7942661b2b26bfba2ec6c09d56b3dbf2e3a8fc6fba415d3a60baabe01310b6b;
    uint256 private _amount = 25 * 4 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, AnotherToken) {
        vm.startBroadcast();
        AnotherToken token = new AnotherToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(_merkleRoot, token);
        token.mint(address(airdrop), _amount);
        console.log("Merkle Airdrop deployed at %s", address(airdrop));
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() public {
        deployMerkleAirdrop();
    }

}