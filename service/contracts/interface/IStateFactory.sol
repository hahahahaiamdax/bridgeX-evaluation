// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

interface IStateFactory {
    function initialize(address logic) external;
    function upgrade(address logic) external;
    function cancel(address master) external;
    function updateState(bytes32 proof, bytes32[] memory keys, bytes32[] memory vals) external;
}