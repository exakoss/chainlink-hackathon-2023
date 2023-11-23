import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl, getRouterConfig } from "./utils";
import { Wallet, JsonRpcProvider} from "ethers";
import { DestinationMinter, DestinationMinter__factory, MyChainNFT, MyChainNFT__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";
import { LINK_ADDRESSES, VRF_WRAPPER } from './constants';

task(`deploy-mychain-nft`, `Deploys MyChainNFT.sol and DestinationMinter.sol smart contracts`)
    .addOptionalParam(`router`, `The address of the Router contract on the destination blockchain`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const routerAddress = taskArguments.router ? taskArguments.router : getRouterConfig(hre.network.name).address;
        const linkAddress = taskArguments.link ? taskArguments.link : LINK_ADDRESSES[hre.network.name];
        const wrapperAddress = taskArguments.wrapper ? taskArguments.wrapper : VRF_WRAPPER[hre.network.name];

        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to deploy MyChainNFT smart contract on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const myChainNftFactory: MyChainNFT__factory = await hre.ethers.getContractFactory('MyChainNFT') as MyChainNFT__factory;
        const myChainNft: MyChainNFT = await myChainNftFactory.deploy(deployer.address, linkAddress, wrapperAddress);
        await myChainNft.waitForDeployment();

        console.log(`✅ MyChainNFT contract deployed at address ${await myChainNft.getAddress()} on the ${hre.network.name} blockchain`)

        console.log(`ℹ️  Attempting to deploy DestinationMinter smart contract on the ${hre.network.name} blockchain using ${deployer.address} address, with the Router address ${routerAddress} provided as constructor argument`);
        spinner.start();

        const destinationMinterFactory: DestinationMinter__factory = await hre.ethers.getContractFactory('DestinationMinter') as DestinationMinter__factory;
        const destinationMinter: DestinationMinter = await destinationMinterFactory.deploy(routerAddress, await myChainNft.getAddress());
        await destinationMinter.waitForDeployment();

        spinner.stop();
        console.log(`✅ DestinationMinter contract deployed at address ${await destinationMinter.getAddress()} on the ${hre.network.name} blockchain`);

        console.log(`ℹ️  Attempting to grant the minter role to the DestinationMinter smart contract`);
        spinner.start();

        const tx = await myChainNft.transferOwnership(await destinationMinter.getAddress());
        await tx.wait();

        spinner.stop();
        console.log(`✅ DestinationMinter can now mint MyNFTs. Transaction hash: ${tx.hash}`);
    })