// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ECDSA {

    function recover(string calldata message, bytes32 r, bytes32 s, uint8 v) public pure returns (address){
        bytes32 h = sha256(abi.encodePacked(message));
        address signer = ecrecover(h, v, r, s);
        return signer;

    }


    function recoverFromSignature(bytes32 h, bytes memory signature ) public pure returns (address){
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly ("memory-safe") {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        address signer = ecrecover(h, v, r, s);
        return signer;
    }

}