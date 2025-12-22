// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
import "./interface/IProxyBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ProxyFactory is Ownable {

    string public name;
    constructor() {
        name = "Cloak Proxy Factory";
    }

    function upgradeAndChangeAdmin(
        address proxy, 
        address implementation
    ) public onlyOwner {
        IProxyBridge(proxy).upgradeAndChangeAdmin(implementation);
    }
}