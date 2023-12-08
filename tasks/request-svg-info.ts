import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl } from "./utils";
import { Wallet, JsonRpcProvider, BigNumberish} from "ethers";
import { SVGConsumer, SVGConsumer__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";

task(`request-svg-info`, `sends a request to generate a SVG via chainlink functions`)
    .addParam(`address`, `The address of the SVGConsumer contract`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { address } = taskArguments;
        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const signer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to mintTokenID on the ${hre.network.name} blockchain using ${signer.address} address`);
        spinner.start();

        const svgConsumer: SVGConsumer = SVGConsumer__factory.connect(address, signer)
        const tx = await svgConsumer.requestSVGInfo("5","5")
        await tx.wait()

        console.log(`✅ SVGConsumer requestSVGInfo at address ${await svgConsumer.getAddress()} on the ${hre.network.name} blockchain`)
        spinner.stop();
    })