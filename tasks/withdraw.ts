import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl } from "./utils";
import { Wallet, JsonRpcProvider } from "ethers";
import { SourceSender, SourceSender__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";

task(`withdraw`, `Withdraws native tokens from a SourceSender contract `)
    .addParam(`senderAddress`, `The address of the SourceSender contract `)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { senderAddress } = taskArguments;
        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const signer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to withdraw on the ${hre.network.name} blockchain using ${signer.address} address`);
        spinner.start();

        const sourceSender: SourceSender = SourceSender__factory.connect(senderAddress, signer)
        const tx = await sourceSender.withdraw(signer.address)
        await tx.wait()

        console.log(`✅ Funds withdrawn from address ${await sourceSender.getAddress()} on the ${hre.network.name} blockchain`)
        spinner.stop();
    })