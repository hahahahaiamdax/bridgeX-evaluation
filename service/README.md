<p align="center">
    <h1 align="center">
      Cloak Service
    </h1>
</p>

<div align="center">
    <h4>
        <a href="/CONTRIBUTING.md">
            👥 Contributing
        </a>
        <span>&nbsp;&nbsp;|&nbsp;&nbsp;</span>
        <a href="/CODE_OF_CONDUCT.md">
            🤝 Code of conduct
        </a>
        <span>&nbsp;&nbsp;|&nbsp;&nbsp;</span>
        <a href="https://github.com/OxHainan/cloak-service/contribute">
            🔎 Issues
        </a>
        <!-- <span>&nbsp;&nbsp;|&nbsp;&nbsp;</span>
        <a href="https://t.me/joinchat/B-PQx1U3GtAh--Z4Fwo56A">
            🗣️ Chat &amp; Support
        </a> -->
    </h4>
</div>

| Cloak service is a protocol, designed to be a brige between Ethereum and the Cloak Network. |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

The core of the Cloak service protocol is to complete the functions of on-chain hosting and synchronization of user contracts in Ethereum. Cloak service supports proxy protocol developed with [EIP1967](https://eips.ethereum.org/EIPS/eip-1967), such as [TransparentUpgradeableProxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/transparent/TransparentUpgradeableProxy.sol) in [Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts).
 To learn more about Cloak visit [Cloak docs](https://cloak-docs.readthedocs.io/en/latest/).


---

## 🛠 Install

Clone this repository:

```bash
git clone https://github.com/OxHainan/cloak-service.git
```

and make sure the following dependencies have been installed
```bash
npm install -g truffle ganache-cli
```

## 📜 Usage

### Compile contracts

```bash
truffle compile
```

### Testing

```bash
truffle test
```

### Deploy contracts

```bash
truffle migrate
```

### Contract Escrow

From the user contract, the user can join the cloak using the following operations:

```solidity
contract Demo {
    uint a;
    function set(uint i) public {
        a += i;
    }

    function get() public view returns(uint) {
        return a;
    }
}
```

If you want to join the cloak network, you can upgrade to proxy bridage.

```javascript
proxy.upgradeTo(proxyBridge.address);
```

Initiate an escrow transaction in our service contract.

```javascript
service.escrow(proxy.address)
```

Now, the demo contract has completed contract escrow.
