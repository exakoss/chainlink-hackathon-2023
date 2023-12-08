import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl } from "./utils";
import { Wallet, JsonRpcProvider, BigNumberish} from "ethers";
import { WeatherConsumer, WeatherConsumer__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";
import { FUNCTIONS_DON_ID, FUNCTIONS_ROUTER } from "./constants";

task(`deploy-weather-consumer`, `Deploys WeatherConsumer.sol on AvalancheFuji`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const functionsRouterAddress = taskArguments.router ? taskArguments.router : FUNCTIONS_ROUTER[hre.network.name]
        // const functionsDonId = taskArguments.donId ? taskArguments.donId : FUNCTIONS_DON_ID[hre.network.name]

        //1659 for AvalancheFuji
        const subscriptionId: BigNumberish = 1659
        const gasLimit: BigNumberish = 2000000

        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to deploy SVGConsumer smart contract on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const weatherConsumerFactory: WeatherConsumer__factory = await hre.ethers.getContractFactory('WeatherConsumer')
        const weatherConsumer: WeatherConsumer = await weatherConsumerFactory.deploy(functionsRouterAddress, subscriptionId, gasLimit)
        await weatherConsumer.waitForDeployment()

        console.log(`✅ WeatherConsumer contract deployed at address ${await weatherConsumer.getAddress()} on the ${hre.network.name} blockchain`)
        spinner.stop();
    })