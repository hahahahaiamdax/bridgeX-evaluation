## Proxy合约能否部署时指定

在proxy合约中，可以在部署环节同时指定logic合约地址以及调用logic合约内的某一函数来初始化proxy合约，详见[TransparentUpgradeableProxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L78-L82)

具体调用方法如下：

```solidity
constructor(address _logic, address initialOwner, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
   _admin = address(new ProxyAdmin(initialOwner));
   // Set the storage value and emit an event for ERC-1967 compatibility
   ERC1967Utils.changeAdmin(_proxyAdmin());
 }
```

有TransparentUpgradeableProxy的构造函数可知，在初始化时可同时完成：

- 设置proxy合约的logic地址

- 设置admin地址

- 调用logic合约某一函数，如果不需要调用函数，在传参时`_data`字段为“0x”



### proxy合约的新改进与不足

在最新版的openzeppelin 5.0版本之后，主要做了以下改动：

- proxy合约内的admin不再使用用户地址来代替，而是使用内置的`ProxyAdmin`合约来充当admin

- proxy合约默认不再提供对外接口函数，这使得用户无法直接使用proxy合约来完成代码升级

- proxy合约内不提供admin转移函数，默认是以`ProxyAdmin`内的为主

基于以上改进，导致现有的cloak-service模型需要做进一步改进

已知`ProxyAdmin`合约内提供的方法为：

- upgradeAndCall（升级合约的同时，可同步执行升级合约后的某一函数）
  
  此处设计在升级合约时，同时执行stateFactory合约内的admin转移函数，达到一笔交易即可达到合约托管的目的



## 用到的以太坊接口

- 状态读取（eth_getStorageAt）
  
  获取单个slot的值 （只能获取到合约状态）
  
  一次只能读取一个

- 状态读取 （`eth_getProof`）（ganache中未提供此接口，无法测试，在采集数据时只能依赖eth_getStorageAt来读取）
  
  获取账户、合约状态以及账户、合约状态的证明
  
  请求参数
  
  ```json
  {
    "jsonrpc": "2.0",
    "method": "eth_getStorageProof",
    "params": [
      "0xcontract_address", // 合约或账户地址
      ["0xstorage_index1", "0xstorage_index2", ...], // 可选，需要读取的slot列表
      "0xblock_number"  // 可选，区块高度
    ],
    "id": 1
  }
  
  
  ```
  
  响应结果
  
  ```json
  {
    "id": 1,
    "jsonrpc": "2.0",
    "result": {
      "accountProof": [
        "0xf90211a...0701bc80",
        "0xf90211a...0d832380",
        "0xf90211a...5fb20c80",
        "0xf90211a...0675b80",
        "0xf90151a0...ca08080"
      ],
      "address" : "0x7f0d15c7faae65896648c8273b6d7e43f58fa842",
      "balance" : "0x0",
      "codeHash" : "0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470",
      "nonce" : "0x0",
      "storageHash" : "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
      "storageProof" : [
          {
            "key" : "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
            "proof" : ["0x...."],
            "value" : "0x0"
          }
      ]
    }
  }
  ```
  
  - codehash为合约代码的hash，验证方法是先通过`eth_getCode`方法来获取合约代码，然后计算合约代码hash并与code_hash进行比较是否相等
  
  - accountProof是证明账户的合法性，证明的内容是`{balance，nonce，codeHash，storageHash}`，如果`accountProof`证明通过，可依次获得该账户的余额，交易nonce，合约代码和合约状态根是合法的
  
  - storageProof是证明合约状态的合法性，在被需要证明的每一个slot中，都将对应一个proof来单独验证该slot是否合法

- 读取合约代码（eth_getCode）

- 发送交易（eth_sendRawTransaction）

- 获取交易原文（eth_getTransactionByHash）

- 获取交易回执（eth_getTransactionReceipt）


## 批量读取时耗
1. ganache-cli不支持调用eth_getProof，无法进行批量读取实验
```
Error: Returned error: Method eth_getProof not supported.
    at Object.ErrorResponse (/root/cloak-client/node_modules/web3-core-helpers/lib/errors.js:28:19)
    at /root/cloak-client/node_modules/web3-core-requestmanager/lib/index.js:300:36
    at /root/cloak-client/node_modules/web3-providers-http/lib/index.js:124:13
```