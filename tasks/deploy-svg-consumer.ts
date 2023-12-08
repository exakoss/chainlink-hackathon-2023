import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl } from "./utils";
import { Wallet, JsonRpcProvider, BigNumberish} from "ethers";
import { GettingStartedSVGConsumer, GettingStartedSVGConsumer__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";
// import { FUNCTIONS_DON_ID, FUNCTIONS_ROUTER } from "./constants";

task(`deploy-svg-consumer`, `Deploys VRFv2Consumer.sol on AvalancheFuji`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {

        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to deploy SVGConsumer smart contract on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const svgConsumerFactory: GettingStartedSVGConsumer__factory = await hre.ethers.getContractFactory('GettingStartedSVGConsumer')
        const svgConsumer: GettingStartedSVGConsumer = await svgConsumerFactory.deploy()
        await svgConsumer.waitForDeployment()

        console.log(`✅ SVGConsumer contract deployed at address ${await svgConsumer.getAddress()} on the ${hre.network.name} blockchain`)
        spinner.stop();
    })