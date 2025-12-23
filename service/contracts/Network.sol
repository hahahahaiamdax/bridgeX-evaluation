// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Network is Ownable {
    struct Node {
        bool active;
        bool authorize;
        uint64 registerTime;
    }

    mapping(address => bool) public isRegistered;
    mapping(address => Node) public nodes;

    modifier whenRegister(address node) {
        require(isRegistered[node], "Network: node no registered");
        _;
    }

    modifier whenNotRegister() {
        require(isRegistered[msg.sender]== false, 
            "Network: node has already registered");
        _;
    }

    modifier onlyActive() {
        require(nodes[msg.sender].active, "Network: node is inactive");
        _;
    }

    modifier onlyNotAuthorized(address node) {
        require(nodes[node].authorize == false, 
            "Network: node has already authorized");
        _;
    }

    function authorize(
        address node
    ) public onlyOwner onlyNotAuthorized(node) whenRegister(node) {
        Node storage n = nodes[node];
        n.authorize = true;
        n.active = true;
    }

    function registerNode() public whenNotRegister() {
        isRegistered[msg.sender] = true;
        nodes[msg.sender] = Node(
            false, 
            false, 
            uint64(block.timestamp)
        );
    }

    function removeNode(address node) public onlyOwner whenRegister(node) {
        delete nodes[node];
        delete isRegistered[node];
    }

    function updateNode(
        address node, 
        bool active
    ) public onlyOwner whenRegister(node) {
        require(nodes[node].active != active, "Network: cannot update node");
        nodes[node].active = active;
    }
}