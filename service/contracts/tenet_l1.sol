// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

interface TenetL2 {
    function mint(
        address token,
        address to,
        uint256 amount
    ) external;
}

interface IERC20Minimal {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Tenet is Ownable {
    struct App {
        bool isResgister;
        string id;
        address admin;
    }

    struct Node {
        bool isResgister;
        address id;
        string ip;
        bytes32 mrenclave;
        uint256 version;
        bytes32 publicKey;
        bytes report;
        string appId;
    }

    struct Round {
        address[] nodeList;
    }

    mapping(string => App) apps;
    mapping(address => string) admin2AppId;
    mapping(address => Node) nodes;
    mapping(address => bool) tokenRegistered;
    mapping(string => mapping(uint256 => Round)) rounds;

    event Deposit(address token, address user, uint256 amount);
    event Dispatch(bytes payload);

    function deposit(address token, uint256 amount) external {
        require(tokenRegistered[token], "Token not registered");
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20Minimal.transferFrom.selector,
                msg.sender,
                address(this),
                amount
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Deposit failed"
        );

        emit Dispatch(
            abi.encodeWithSelector(
                TenetL2.mint.selector,
                token,
                msg.sender,
                amount
            )
        );
        // emit Deposit(token, msg.sender, amount);
    }

    event Withdraw(address token, address user, uint256 amount);

    function withdraw(
        address token,
        address user,
        uint256 amount
    ) external {
        // TODO: onlyAppAdmin
        require(tokenRegistered[token], "Token not registered");
        require(
            balance(token) >= amount,
            "Token balance lower than the value requested"
        );
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20Minimal.transfer.selector,
                user,
                amount
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Withdral failed"
        );
        emit Withdraw(token, user, amount);
    }

    function balance(address tokenAddr) internal view returns (uint256) {
        (bool success, bytes memory data) = tokenAddr.staticcall(
            abi.encodeWithSelector(
                IERC20Minimal.balanceOf.selector,
                address(this)
            )
        );
        require(success && data.length >= 32);
        return abi.decode(data, (uint256));
    }

    function registerToken(address tokenAddr) external onlyOwner {
        require(
            !tokenRegistered[tokenAddr],
            "Token address already registered"
        );
        tokenRegistered[tokenAddr] = true;
    }

    function registerApp(string calldata appId) external {
        require(!apps[appId].isResgister, "App id already registered");
        apps[appId].isResgister = true;
        apps[appId].id = appId;
        apps[appId].admin = msg.sender;
        admin2AppId[msg.sender] = appId;
    }

    function registerNode(
        address id,
        string calldata ip,
        bytes32 mrenclave,
        uint256 version,
        bytes32 publicKey,
        bytes calldata report
    ) external onlyAppAdmin {
        require(!nodes[id].isResgister, "Node already registered");
        nodes[id].id = id;
        nodes[id].ip = ip;
        nodes[id].mrenclave = mrenclave;
        nodes[id].version = version;
        nodes[id].publicKey = publicKey;
        nodes[id].report = report;
        nodes[id].appId = admin2AppId[msg.sender];
    }

    modifier onlyAppAdmin() {
        require(
            bytes(admin2AppId[msg.sender]).length > 0,
            "App not registered or permission denied"
        );
        require(
            apps[admin2AppId[msg.sender]].admin == msg.sender,
            "Permision denied"
        );
        _;
    }
}
