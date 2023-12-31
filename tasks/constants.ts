export type AddressMap = { [blockchain: string]: string };
export type TokenAmounts = { token: string, amount: string }

export enum PayFeesIn {
    Native,
    LINK
}

export const supportedNetworks = [
    `ethereumSepolia`,
    `optimismGoerli`,
    `arbitrumTestnet`,
    `avalancheFuji`,
    `polygonMumbai`,
];

export const LINK_ADDRESSES: AddressMap = {
    [`ethereumSepolia`]: `0x779877A7B0D9E8603169DdbD7836e478b4624789`,
    [`polygonMumbai`]: `0x326C977E6efc84E512bB9C30f76E30c160eD06FB`,
    [`optimismGoerli`]: `0xdc2CC710e42857672E7907CF474a69B63B93089f`,
    [`arbitrumTestnet`]: `0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28`,
    [`avalancheFuji`]: `0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846`
};

export const VRF_COORDINATOR: AddressMap = {
    [`ethereumSepolia`]: `0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625`,
    [`polygonMumbai`]: `0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed`,
    [`optimismGoerli`]: `0x674Cda1Fef7b3aA28c535693D658B42424bb7dBD`,
    [`arbitrumTestnet`]: `0x6D80646bEAdd07cE68cab36c27c626790bBcf17f`,
    [`avalancheFuji`]: `0x2eD832Ba664535e5886b75D64C46EB9a228C2610`
};

export const VRF_WRAPPER: AddressMap = {
    [`ethereumSepolia`]: `0xab18414CD93297B0d12ac29E63Ca20f515b3DB46`,
    [`polygonMumbai`]: `0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693`,
    [`optimismGoerli`]: `0x674Cda1Fef7b3aA28c535693D658B42424bb7dBD`,
    [`arbitrumTestnet`]: `0x674Cda1Fef7b3aA28c535693D658B42424bb7dBD`,
    [`avalancheFuji`]: `0x9345AC54dA4D0B5Cda8CB749d8ef37e5F02BBb21`
};

export const VRF_KEYHASH: AddressMap = {
    [`ethereumSepolia`]: `0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c`,
    [`polygonMumbai`]: `0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f`,
    [`optimismGoerli`]: `0x674Cda1Fef7b3aA28c535693D658B42424bb7dBD`,
    [`arbitrumTestnet`]: `0x83d1b6e3388bed3d76426974512bb0d270e9542a765cd667242ea26c0cc0b730`,
    [`avalancheFuji`]: `0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61`
};

export const FUNCTIONS_DON_ID: AddressMap = {
    [`ethereumSepolia`]: `0xb83E47C2bC239B3bf370bc41e1459A34b41238D0`,
    [`polygonMumbai`]: `0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C`,
    //OP and ARB are disabled for functions
    [`optimismGoerli`]: `0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0`,
    [`arbitrumTestnet`]: `0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0`,
    [`avalancheFuji`]: `0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0`
};

export const FUNCTIONS_ROUTER: AddressMap = {
    [`ethereumSepolia`]: `0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000`,
    [`polygonMumbai`]: `0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000`,
    //OP and ARB are disabled for functions
    [`optimismGoerli`]: `0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0`,
    [`arbitrumTestnet`]: `0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0`,
    [`avalancheFuji`]: `0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0`
};

export const routerConfig = {
    ethereumSepolia: {
        address: `0xd0daae2231e9cb96b94c8512223533293c3693bf`,
        chainSelector: `16015286601757825753`,
        feeTokens: [LINK_ADDRESSES[`ethereumSepolia`], `0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534`]
    },
    optimismGoerli: {
        address: `0xeb52e9ae4a9fb37172978642d4c141ef53876f26`,
        chainSelector: `2664363617261496610`,
        feeTokens: [LINK_ADDRESSES[`optimismGoerli`], `0x4200000000000000000000000000000000000006`]
    },
    avalancheFuji: {
        address: `0x554472a2720e5e7d5d3c817529aba05eed5f82d8`,
        chainSelector: `14767482510784806043`,
        feeTokens: [LINK_ADDRESSES[`avalancheFuji`], `0xd00ae08403B9bbb9124bB305C09058E32C39A48c`]
    },
    arbitrumTestnet: {
        address: `0x88e492127709447a5abefdab8788a15b4567589e`,
        chainSelector: `6101244977088475029`,
        feeTokens: [LINK_ADDRESSES[`arbitrumTestnet`], `0x32d5D5978905d9c6c2D4C417F0E06Fe768a4FB5a`]
    },
    polygonMumbai: {
        address: `0x70499c328e1e2a3c41108bd3730f6670a44595d1`,
        chainSelector: `12532609583862916517`,
        feeTokens: [LINK_ADDRESSES[`polygonMumbai`], `0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889`]
    }
}