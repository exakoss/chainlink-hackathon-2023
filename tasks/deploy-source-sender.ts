import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl, getRouterConfig } from "./utils";
import { Wallet, JsonRpcProvider } from "ethers";
import { SourceSender, SourceSender__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";
import { LINK_ADDRESSES } from "./constants";


task(`deploy-source-sender`, `Deploys SourceMinter.sol smart contract`)
    .addParam(`nftAddress`, `The address of the NFT contract to send on the source blockchain`)
    .addOptionalParam(`router`, `The address of the Router contract on the source blockchain`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const routerAddress = taskArguments.router ? taskArguments.router : getRouterConfig(hre.network.name).address;
        const linkAddress = taskArguments.link ? taskArguments.link : LINK_ADDRESSES[hre.network.name]
        const nftAddress = taskArguments.nftAddress ? taskArguments.nftAddress : ""

        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl);
        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();

        console.log(`ℹ️  Attempting to deploy SourceSender smart contract on the ${hre.network.name} blockchain using ${deployer.address} address, with the Router address ${routerAddress}, NFT address ${nftAddress} and LINK address ${linkAddress} provided as constructor arguments`);
        spinner.start();

        const sourceSenderFactory: SourceSender__factory = await hre.ethers.getContractFactory('SourceSender') as SourceSender__factory;
        const sourceSender: SourceSender = await sourceSenderFactory.deploy(routerAddress, linkAddress, nftAddress);
        await sourceSender.waitForDeployment();

        spinner.stop();
        console.log(`✅ SourceSender contract deployed at address ${await sourceSender.getAddress()} on the ${hre.network.name} blockchain`);
    })