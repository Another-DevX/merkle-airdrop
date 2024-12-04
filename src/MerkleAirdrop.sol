// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop_InvalidSignature();

    event Claim(address indexed account, uint256 amount);

    address[] claimers;
    bytes32 private immutable MERKLE_ROOT;
    IERC20 private _airdropToken;
    mapping(address => bool) private _claimed;

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        MERKLE_ROOT = merkleRoot;
        _airdropToken = airdropToken;
    }

    function getMessage(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {
        (address actualSigner, ,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
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

        if (
            !_isValidSignature(account, getMessage(account, amount), v, r, s)
        ) {
            revert MerkleAirdrop_InvalidSignature();
        }

        _claimed[account] = true;
        _airdropToken.safeTransfer(account, amount);
        emit Claim(account, amount);
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
