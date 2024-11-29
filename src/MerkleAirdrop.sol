// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    event Claim(address indexed account, uint256 amount);

    address[] claimers;
    bytes32 private immutable MERKLE_ROOT;
    IERC20 private _airdropToken;
    mapping(address => bool) private _claimed;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        MERKLE_ROOT = merkleRoot;
        _airdropToken = airdropToken;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );

        if (!MerkleProof.verify(merkleProof, MERKLE_ROOT, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        if (_claimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        _claimed[account] = true;
        _airdropToken.safeTransfer(account, amount);
        emit Claim(account, amount);
    }

	function getMerkleRoot() external view returns (bytes32) {
		return MERKLE_ROOT;
	}

	function getAirDropToken() external view returns (IERC20) {
		return _airdropToken;
	}
}
