// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

library StateStorage {
    function generateStateHash(bytes32[] memory keys) internal view returns(bytes32) {
        require(keys.length > 0, "State: length cannot be empty");
        bytes memory vals = new bytes(keys.length * 32);
        assembly {
            let length := mload(keys)
            let keyPointer := add(keys, 0x20)
            let valPointer := add(vals, 0x20)
              for {
                let end := add(keyPointer, mul(0x20, length))
            } lt(keyPointer, end) {
                keyPointer := add(keyPointer, 0x20)
                valPointer := add(valPointer, 0x20)
            } {
                mstore(valPointer, sload(mload(keyPointer)))
            }
        }

        return keccak256(vals);
    }

    function sstore(bytes32[] memory keys, bytes32[] memory vals) internal {
        require(keys.length == vals.length, "State: length is unequal");
        assembly {
            let length := mload(keys)
            let keyPointer := add(keys, 0x20)
            let valPointer := add(vals, 0x20)
            for {
                let end := add(keyPointer, mul(0x20, length))
            } lt(keyPointer, end) {
                keyPointer := add(keyPointer, 0x20)
                valPointer := add(valPointer, 0x20)
            } {
                sstore(mload(keyPointer), mload(valPointer))
            }
        }
    }
}