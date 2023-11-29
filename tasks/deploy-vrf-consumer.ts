import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl } from "./utils";
import { Wallet, JsonRpcProvider, BigNumberish} from "ethers";
import { VRFv2Consumer, VRFv2Consumer__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";

task(`deploy-vrf-consumer`, `Deploys VRFv2Consumer.sol on Sepolia`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {

        const subscriptionId: BigNumberish = 7263

        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to deploy VRFv2Consumer smart contract on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        // const myChainNftFactory: MyChainNFT__factory = await hre.ethers.getContractFactory('MyChainNFT') as MyChainNFT__factory;
        // const myChainNft: MyChainNFT = await myChainNftFactory.deploy(deployer.address, subscriptionId, coordinatorAddress);
        // await myChainNft.waitForDeployment();
        const vrfConsumerFactory: VRFv2Consumer__factory = await hre.ethers.getContractFactory('VRFv2Consumer')
        const vrfConsumer: VRFv2Consumer = await vrfConsumerFactory.deploy(subscriptionId)
        await vrfConsumer.waitForDeployment()

        console.log(`✅ VRFv2Consumer contract deployed at address ${await vrfConsumer.getAddress()} on the ${hre.network.name} blockchain`)
        spinner.stop();
    })