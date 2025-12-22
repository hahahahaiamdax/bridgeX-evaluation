// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./utils/StateStorage.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

abstract contract State {
    using StateStorage for bytes32[];
    // this is the keccak 256 hash of "cloak.state.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT =
        0x2a7ee7a990a244bda6b8218d6cc50c824030ffcca1203a6c59bdca9cb30f9e58;

    // this is the keccak 256 hash of "cloak.state.executor" subtracted by 1
    bytes32 private constant _EXECUTOR_SLOT =
        0xb8348531df8271f8aede09ac451eebefaf9b4f564d3006bd336f1747c0d8d659;

    // this is the keccak 256 hash of "cloak.state.proof" subtracted by 1
    bytes32 private constant _PROOF_SLOT =
        0x2c3b1d89f196b8b08364560cca554b8f81cb28533bd8b87aacb02775960713c2;

    bytes32 internal constant _ACCOUNT_HASH =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function _setRollBack(address account) internal {
        require(
            account != address(0),
            "BaseState: account is the zero address"
        );
        StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value = account;
    }

    function _getRollBack() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value;
    }

    function _setExecutor(address account) internal {
        require(
            account != address(0),
            "BaseState: account is the zero address"
        );
        StorageSlot.getAddressSlot(_EXECUTOR_SLOT).value = account;
    }

    function _getExecutor() internal view returns (address) {
        return StorageSlot.getAddressSlot(_EXECUTOR_SLOT).value;
    }

    modifier onlyExecutor() {
        require(
            _getExecutor() == msg.sender,
            "State: caller is not the executor"
        );
        _;
    }

    modifier onlyInitialized() {
        require(
            _getExecutor() == address(0),
            "StateFactory: executor has already setting"
        );
        _;
    }

    function _clearConfigure() internal {
        StorageSlot.getBytes32Slot(_PROOF_SLOT).value = bytes32(0);
        StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value = address(0);
        StorageSlot.getAddressSlot(_EXECUTOR_SLOT).value = address(0);
    }

    function _setProofHash(bytes32 proof) internal {
        require(proof != bytes32(0), "State: proof is none");
        StorageSlot.getBytes32Slot(_PROOF_SLOT).value = proof;
    }

    function _getProofHash() internal view returns (bytes32) {
        return StorageSlot.getBytes32Slot(_PROOF_SLOT).value;
    }

    function _updateState(
        bytes32 proof,
        bytes32[] memory keys,
        bytes32[] memory vals
    ) internal {

    
        // require(_proof == proof, "State: verification proof failed");
      //  keys.sstore(vals);
    }
}
