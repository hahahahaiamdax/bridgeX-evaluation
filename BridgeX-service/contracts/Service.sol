// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./StateFactory.sol";
import "./ProxyFactory.sol";
import "./ProxyBridge.sol";
import "./Network.sol";
import "./interface/IStateFactory.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Service is Network {
    using Address for address;
    ProxyFactory _proxyFactory;
    StateFactory _stateFactory;
    ProxyBridge _proxyBridge;

    struct Escrow {
        address master;
        bool enhanced;
    }

    mapping(address => Escrow) public escrows;

    constructor() {
        _stateFactory = new StateFactory();
        _proxyFactory = new ProxyFactory();
        _proxyBridge = new ProxyBridge(address(_proxyFactory));
    }

    modifier onlyEscrow(address proxy) {
        require(
            escrows[proxy].master == msg.sender,
            "Service: caller is not the escrow master"
        );
        _;
    }

    modifier onlyNotEscrow(address proxy) {
        require(
            escrows[proxy].master != msg.sender,
            "Service: contract has alread escrowed"
        );
        _;
    }

    modifier onlyNotEnhanced(address proxy) {
        require(
            escrows[proxy].enhanced == false,
            "Service: escrow enchaned become effective"
        );
        _;
    }

    function proxyFactory() public view returns (address) {
        return address(_proxyFactory);
    }

    function stateFactory() public view returns (address) {
        return address(_stateFactory);
    }

    function proxyBridge() public view returns (address) {
        return address(_proxyBridge);
    }

    function escrow(
        address proxy,
        address implementation
    ) public onlyNotEscrow(proxy) {
        require(
            proxy != implementation,
            "Service: implementation cannot be proxy"
        );
        _proxyFactory.upgradeAndChangeAdmin(proxy, stateFactory());
        IStateFactory(proxy).initialize(implementation);
        escrows[proxy] = Escrow(msg.sender, false);
    }

    function privacyEnhancement(
        address proxy
    ) public onlyEscrow(proxy) onlyNotEnhanced(proxy) {
        escrows[proxy].enhanced = true;
    }

    // (TODO) Wait for all state synchronization to complete
    function upgrade(address proxy, address logic) public onlyEscrow(proxy) {
        IStateFactory(proxy).upgrade(logic);
    }

    // (TODO) Wait for all state synchronization to complete
    function cancel(
        address proxy
    ) public onlyEscrow(proxy) onlyNotEnhanced(proxy) {
        IStateFactory(proxy).cancel(msg.sender);
        delete escrows[proxy];
    }

    function updateState(address proxy, bytes memory data) public {
        require(
            escrows[proxy].master != address(0),
            "Service: contract is not escrows"
        );

        proxy.functionCall(data);
    }

    function updateStateAndCancel(
        address[] memory proxy,
        bytes[] memory data
    ) public {
        require(proxy.length == data.length, "Service: both length not equal");

        for (uint8 i = 0; i < proxy.length; i++) {
            address addr = proxy[i];
            updateState(addr, data[i]);
            IStateFactory(addr).cancel(escrows[addr].master);
            delete escrows[addr];
        }
    }

    function updateState(address[] memory proxy, bytes[] memory data) public {
        require(proxy.length == data.length, "Service: both length not equal");

        for (uint8 i = 0; i < proxy.length; i++) {
            updateState(proxy[i], data[i]);
        }
    }
}

// web3.eth.sendTransaction({from:"0xcAB49152ef7F6550E8387A5957882C3e441A7ad0", to: "0xEAf9454bD1DaC02d94bCC7849F7E5f5c9f0f305B", data: "0x43d6928a000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000d437bf0270816b0402393c2caa7da829197de0b90000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000001643693d12794532882600060a33688af35926295c3047c7b74f5c67761ce9eb4dbd9fffcaa000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000318e1c7844e9109fd149166fe34fa6256db4c56e17f75d48ad81b2560d11db7a92a1940e3eca92f1342d924a843bb35c3345c7640b18f4ce2edaae040c34de7f7d09fadb56c5810a823c3ff7d15795d1ef2cd07ad6928763c50c99facc2d2aef2000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000027100000000000000000000000000000000000000000000000000000000000002710000000000000000000000000000000000000000000000000000000e8d4a4c1e000000000000000000000000000000000000000000000000000000000"})
