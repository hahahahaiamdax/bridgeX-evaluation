// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

interface IProxyBridge
{
    function upgradeAndChangeAdmin(address newImplementation) external;
}