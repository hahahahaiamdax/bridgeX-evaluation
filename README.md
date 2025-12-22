# bridgeX-evaluation
## slots statistics
We evaluate BridgeX's costs of data/token migration between L1/L2 blockchains for different businesses: ERC20, Auction, and Member, and the business code (i.e., smart contract) is in the "contracts" folder.

To reproduce the evaluation results of BridgeX, you can deploy the three contracts locally and send transactions to call the corresponding function of the contracts. Subsequently, you can use an IDE (such as Remix IDE) to view and count the number of contract slots created/updated due to these transactions. Finally, you can multiply the number of slots by the corresponding universal state interoperation cost (21,900 gas per new slot; 6903 gas per existing slot) to obtain the cost data of BridgeX.

For convenience, we have completed the above steps on the testnet so that you can directly view the statistics of slots. We deployed the three contracts: ERC20, auction, and member on the Sepolia testnet. The contract addresses are:

- ERC20: 0xadd2607935a12814af72c06e4e5bb64a435abdf5
- Auction：0x586660035bF89175C3b714BB64284635d417aFb2
- member：0x424d1c0b4134BFE5e71632BA5f72Beb17246F4a3

Then we sent transactions to involve the functions of the three contracts. The transaction hashes are as follows:

- ERC20:
  - transfer tx：0x2329f65bd36299b3c6f42a1da89907f3ce538611f02479253c8385305354f18e
- auction：
  - create auction tx：0x2329f65bd36299b3c6f42a1da89907f3ce538611f02479253c8385305354f18e
  - bid tx：0x9e24dbb445e8abeabc4ad2edb97782fbd78e3f2ec8140d29036da82038f0d075
- member：
  - create member1 tx：0x0ead6b471d40dff4454dd7d0e1f9a67eee8756ae2d652cfe61db48693a61c4e5
  - create member2 tx：0x897fb2ebcc599673d00dabf765c5b7b4cb5edf012705690e6ff4ed123f9a9251



The above transactions made the corresponding contract's storage layout change, which can be observed on the etherscan explorer. For example, [the ERC20 transfer tx](https://sepolia.etherscan.io/tx/0x2329f65bd36299b3c6f42a1da89907f3ce538611f02479253c8385305354f18e#statechange) changed two slots of the ERC20 contract (whose address is 0xaDD26079...a435Abdf5)：

![image-20251112101240151](./src/image-20251112101240151.png)



The slots statistics for bridgeX evaluation may involve multiple transactions, *e.g.*, the slots statistics for the ERC20 contract involve 50 transfer transactions. For convenience, we provide a Python script (*i.e.*, slotsNumStatistics.py) to count the number of changed slots.

In addition, this repository does not provide a fully automated script that includes all experimental steps, for example, you need to manually deploy contracts and invoke functions. However, this also provides you with a certain degree of flexibility. You can freely select one or two blockchains and replace the relevant parameters in the slotsNumStatistics.py script (including API interfaces, contract addresses, and transaction hashes) with your own. After running the script, you can obtain the test results of the blockchain you choose.
