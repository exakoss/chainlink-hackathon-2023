# 3x Battle Wizards

3x Battle Wizards is a gaming project that utilizes Chainlink VRF, CCIP, Functions and DALLE-3 to introduce an element of unpredictability and generative art into lifecycles of gaming NFT projects. Built by @exakoss for Chainlink Hackathon 2023 Constellation.

Read more about the project: https://devpost.com/software/3xnft

Python Open AI API repo: https://github.com/exakoss/dalle3-png-chainlink-hackathon-2023

## Set Up Instructions:

0) Fork this repository and install dependencies via yarn. 

Define ALL environmental variables which include your private key for testing, RPC and API links to network that you are using in .env file, subsctiption IDs and gas Limits for Chainlink VRF and Functions in tasks and smart contracts. In MyChainNFT.sol, make necessary edits to metadata to fit your setting and set a python API link for DALLE generated images.

1) Run the following commands to set up contracts on Avalanche Fuji:

```shell
npx hardhat compile
npx hardhat deploy-mychain-nft --network avalancheFuji
```

This well deploy MyChainNFT.sol and DestinationMinter.sol contracts and transfer the ownership of MyChainNFT.sol to DestinationMinter.sol so it can mint NFTs that are being transffered via CCIP later.

2) Add your MyChainNFT.sol contract as a consumer to your Chainlink VRF and Functions subscriptions on Avalanche Fiji via Chainlink web interface.
3) Run the following command to set up SourceSender.sol on Avalanche Fuji:

```shell
npx hardhat deploy-source-sender --network avalancheFuji --nft-address *insert your MyChainNFT.sol address here*
```

This will deploy SourceSender.sol and approve it all MyChainNFT.sol NFTs so it can burn them later while bridging to a different chain via CCIP

4) Fund the deployed SourceSender with AVAX (or other native coins on other chains) via a transfer from your wallet.

5) Comment out the for loop in the constructor of MyChainNFT.sol and run the following command to deploy MyChainNFT.sol and DestinationMinter.sol on Polygon Mumbai

  ```shell
  npx hardhat compile
  npx hardhat deploy-mychain-nft --network polygonMumbai
  ```
6) Verify your MyChainNFT.sol on Avalanche Fuji:

```shell
npx hardhat verify --network avalancheFuji *MyChainNFT.sol address* *your VRF subscription ID* 0x2eD832Ba664535e5886b75D64C46EB9a228C2610 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61
```

7) Use block explorer or create tasks to call randomizeLevels() or sendRequest() to start playing the game and generating stats and images for your NFTs.
8) Use the following command to send a NFT to a different chain via CCIP:

```shell
  npx hardhat cross-chain-send --network avalancheFuji --source-blockchain avalancheFuji --source-sender *insert SourceSender.sol address here* --destination-blockchain polygonMumbai --destination-minter *insert DestinationMinter.sol address here* --pay-fees-in Native --token-id 0
```