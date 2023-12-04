import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl, getRouterConfig } from "./utils";
import { Wallet, JsonRpcProvider, BigNumberish} from "ethers";
import { MyChainNFT, MyChainNFT__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";
import { token } from '../typechain-types/@openzeppelin/contracts'

task(`randomize-levels`, `Randomizes melee attack and melee defense for a specific tokenId`)
    .addParam(`nftAddress`, `The address of the NFT contract `)
    .addParam(`tokenId`, `Token Id Levels that will be randomized`,)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { nftAddress, tokenId } = taskArguments;
        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const signer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to randomizeLeves of token Id ${tokenId} on the ${hre.network.name} blockchain using ${signer.address} address`);
        spinner.start();

        const myChainNft: MyChainNFT = MyChainNFT__factory.connect(nftAddress, signer)
        const tx = await myChainNft.randomizeLevels(tokenId)
        await tx.wait()

        console.log(`✅ RandomizeLevels of tokenId ${tokenId} at address ${await myChainNft.getAddress()} on the ${hre.network.name} blockchain`)
        spinner.stop();
    })