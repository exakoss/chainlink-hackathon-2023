import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl, getRouterConfig } from "./utils";
import { Wallet, JsonRpcProvider, BigNumberish} from "ethers";
import { MyChainNFT, MyChainNFT__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";

task(`mint-token-id`, `Mints a tokenId from the given MyChainNFT contract`)
    .addParam(`nftAddress`, `The address of the NFT contract `)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { nftAddress } = taskArguments;
        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl)

        const wallet = new Wallet(privateKey);
        const signer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();
        console.log(`ℹ️  Attempting to mintTokenID on the ${hre.network.name} blockchain using ${signer.address} address`);
        spinner.start();

        const myChainNft: MyChainNFT = MyChainNFT__factory.connect(nftAddress, signer)
        const tx = await myChainNft.mintTokenId(signer.address, 35)
        await tx.wait()

        console.log(`✅ MyChainNFT mintTokendId at address ${await myChainNft.getAddress()} on the ${hre.network.name} blockchain`)
        spinner.stop();
    })