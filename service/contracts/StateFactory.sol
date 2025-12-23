// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./State.sol";
import "./utils/EIP1967.sol";

contract StateFactory is State, EIP1967 {
    event Cancel(address indexed proxy, address indexed admin);

    function updateState(
        bytes32 proof,
        bytes32[] memory keys,
        bytes32[] memory vals
    ) external  {
        super._updateState(proof, keys, vals);
    }

    function initialize(address logic) external onlyInitialized {
        require(
            super._getRollBack() != logic,
            "StateFactory: the same as contract or not implementated"
        );

        super._setRollBack(logic);
        super._setExecutor(msg.sender);
        updateProof(logic);
    }

    function upgrade(address logic) external onlyExecutor {
        require(
            super._getRollBack() != logic,
            "StateFactory: new contract should be different"
        );

        super._setRollBack(logic);
        updateProof(logic);
    }

    function cancel(address master) external onlyExecutor {
        address logic = super._getRollBack();
        require(logic != address(0), "StateFactory: logic is the zero address");

        super._setImplementation(logic);
        super._changeAdmin(master);
        super._clearConfigure();
        emit Cancel(address(this), master);
    }

    function updateProof(address account) private {
        bytes32 proof = generateEscrowProof(account);
        super._setProofHash(proof);
    }

    function generateEscrowProof(
        address account
    ) private view returns (bytes32 proof) {
        address state = super._getImplementation();
        bytes32 codehash;
        assembly {
            codehash := extcodehash(account)
        }

        require(
            codehash != _ACCOUNT_HASH,
            "BaseState: account is a common address"
        );

        proof = keccak256(abi.encodePacked(codehash, state));
    }
}
